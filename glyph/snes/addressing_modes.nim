# Copyright (c) 2018 Mamy André-Ratsimbazafy
# Distributed under the Apache v2 License (license terms are at http://www.apache.org/licenses/LICENSE-2.0).

import ./datatypes

# $number represents an address in hexadecimal representation
# $HHLL corresponds to high-high-low-low nibbles of a 16-bit address
# #$CONST represent a constant (prefix #)

# Note, for implementation we don't respect the:
#  - Ecc1_m16bit - Add 1 cycle if Accumulator is accessed in 16-bit mode
#  - Ecc2_m16bit - Add 2 cycles if Accumulator is accessed in 16-bit mode
#  - Ecc1_xy16bit - Add 1 cycle if Index Register is accessed in 16-bit mode
# We follow the rule of thumb: 8-byte access = 1 cpu cycle
# Opcode implementations/tests should take care that
# implementation cycles = theoretical cycles + modifiers

template readPC(): uint8 {.dirty.} =
  ## Read a single byte, increment cycle and program counter
  # Note:
  #   Program segments cannot cross bank boundaries;
  #   if the program counter increments past $FFFF,
  #   it rolls over to $0000 without incrementing the program counter bank register.
  Next()
  CycleCPU()
  sys.mem[PB, PC]

func readAddr(sys: Sys, isLong: static[bool] = false): Addr {.inline.} =
  ## Read an address at the current program counter position and increment the program counter.
  ## Returns a 24-bit address
  #  Implementation - 65816 is little-endian:
  #    low byte then high byte then data bank byte
  result.lo = readPC()                                        # 1 cycle
  result.hi = readPC()                                        # 1 cycle
  result.bank = when isLong: readPC()                         # (+1 cycle if long addressing)
                else: DB

func readData(sys: Sys, T: typedesc[uint8 or uint16], adr: Addr): T {.inline.}=
  ## Read a uint8 or uint16 value at a specific data address.
  ## Crossing a bank boundary (0xFFFF) when reading data does not cost an extra cycle.
  #  Implementation - 65816 is little-endian:
  #    low byte then high byte
  when T is uint16:                                        # 2 cycles
    CycleCPU()
    result.lo = sys.mem[adr]

    CycleCPU()
    result.hi = sys.mem[adr + 1] # This crosses data banks. No extra cycle.
  else:                                                    # 1 cycle
    CycleCPU()
    result = sys.mem[adr]

func readIndirectAddr(sys: Sys, ptrAddr: uint16, isLong: static[bool] = false): Addr {.inline.}=
  ## Takes an address of a pointer and resolve/dereference that pointer.
  ## Input address A --> read an address B at that address A --> returns address B
  CycleCPU()                                               # 1 cycle
  result.lo = sys.mem[0, ptrAddr]
  CycleCPU()                                               # 1 cycle
  result.hi = sys.mem[0, ptrAddr+1]
  when isLong:
    CycleCPU()                                             # (+1 cycle if long addressing)
    result.bank = sys.mem[0, ptrAddr+2]
  else:
    result.bank = DB

template crossBoundary(adr: Addr, dataBank: uint8) {.dirty.} =
  ## Add 1 CPU cycle if crossing bank boundary.
  ## Physically, crossing a boundary when adding an index requires
  ## an extra read of the data bank byte to increment it.
  when EccCrossBoundary in ecc:
    if adr.bank != dataBank: CycleCPU()

template directLowNonZero(adr: Addr, d: uint16) {.dirty.} =
  ## Add 1 CPU cycle if low byte of direct register is non-zero
  ## Physically, extra cycle is needed f the register is not page-aligned.
  when EccDirectLowNonZero in ecc:
    if d.lo != 0x00: CycleCPU()

func immediate*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Immediate addressing mode - $OP #$CONST
  ## Returns the 1 or 2-byte constant immediately after the opcode
  ##  8-bit: inc   #$12 -- cycle: 1 -- length: 2
  ## 16-bit: inc #$1234 -- cycle: 2 -- length: 3
  when T is uint16:                                        # 2 cycles
    result.lo = readPC()
    result.hi = readPC()
  else:                                                    # 1 cycle
    result = readPC()

func absolute*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Absolute addressing mode - $OP $HHLL
  ## Loads and return the value at the (Current Data Bank, 16-bit address).
  ## Address is relative to the current data bank.
  ##  8-bit: and $1234 -- cycle: 3 -- length: 3
  ## 16-bit: and $1234 -- cycle: 4 -- length: 3

  let adr = sys.readAddr()                                 # 2 cycles
  result = sys.readData(T, adr, ecc)                       # 1 cycle (8-bit) or 2 cycles (16-bit)

func absoluteLong*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Absolute long addressing mode - $OP $DBHHLL
  ## Loads and return the value at the 24-bit address immediately after the opcode.
  ## The first 8-bit corresponds to the databank addressed.
  ##  8-bit: and $123456 -- cycle: 4 -- length: 4
  ## 16-bit: and $123456 -- cycle: 5 -- length: 4

  let adr = sys.readAddr()                                 # 3 cycles
  result = sys.readData(T, adr, ecc)                       # 1 cycle (8-bit) or 2 cycles (16-bit)

func absoluteX*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Absolute Indexed, X addressing mode - $OP $HHLL,X
  ## Loads and return the value at the (Current Data Bank, 16-bit address + X register).
  ## Address is relative to the current data bank.
  ##  8-bit: and #$1234, X -- cycle: 3 -- length: 3
  ## 16-bit: and #$1234, X -- cycle: 4 -- length: 3

  let adr = sys.readAddr() + X                             # 2 cycles
  crossBoundary(adr, DB)                                   # (+1 if crossing page boundary)
  result = sys.readData(T, adr, ecc)                       # 1 cycle (8-bit) or 2 cycles (16-bit)

func absoluteY*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Absolute Indexed, X addressing mode - $OP $HHLL,X
  ## Loads and return the value at the (Current Data Bank, 16-bit address + Y register).
  ## Address is relative to the current data bank.
  ##  8-bit: and $1234 -- cycle: 3 -- length: 3
  ## 16-bit: and $1234 -- cycle: 4 -- length: 3

  let adr = sys.readAddr() + Y                             # 2 cycles
  crossBoundary(adr, DB)                                   # (+1 if crossing page boundary)
  result = sys.readData(T, adr, ecc)                       # 1 cycle (8-bit) or 2 cycles (16-bit)

func absoluteLongX*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Absolute Long Indexed, X addressing mode - $OP $DBHHLL,X
  ## Loads and return the value at the (24-bit address + X register).
  ## The first 8-bit corresponds to the databank addressed.
  ##  8-bit: and $1234 -- cycle: 3 -- length: 3
  ## 16-bit: and $1234 -- cycle: 4 -- length: 3

  let adr = sys.readAddr(isLong = true)                    # 2 cycles
  let db = adr.db
  let effectiveAdr = readAddr + X
  crossBoundary(effectiveAdr, db)                          # (+1 if crossing page boundary)
  result = sys.readData(T, effectiveAdr, ecc)              # 1 cycle (8-bit) or 2 cycles (16-bit)

func direct*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Direct addressing mode - $OP $LL
  ## Loads and return the value at the (Bank 0, 8-bit address + D register).
  ##  8-bit: and $12 -- cycle: 3 -- length: 2
  ## 16-bit: and $12 -- cycle: 4 -- length: 2
  ## +1 cycle if Direct register is not page-aligned (low byte == 0)

  let adr = toAddr(0, D + readPC())                        # 1 cycle
  directLowNonZero(adr, D)                                 # (+1 Direct register low byte != 0)
  result = sys.readData(T, adr, ecc)                       # 1 cycle (8-bit) or 2 cycles (16-bit)

func directX*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Direct Indexed with X addressing mode - $OP $LL,X
  ## Loads and return the value at the (0, 8-bit address + D register + X register).
  ##  8-bit: and $12 -- cycle: 6 -- length: 2
  ## 16-bit: and $12 -- cycle: 7 -- length: 2
  ## +1 cycle if Direct register is not page-aligned (low byte == 0)

  let adr = toAddr(0, D + readPC() + X)                    # 1 cycle
  directLowNonZero(adr, D)                                 # (+1 Direct register low byte != 0)

  CycleCpu()                                               # 1 cycle (IO)
  result = sys.readData(T, adr, ecc)                       # 1 cycle (8-bit) or 2 cycles (16-bit)

func directY*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Direct Indexed with Y addressing mode - $OP $LL,Y
  ## Loads and return the value at the (0, 8-bit address + D register + Y register).
  ##  8-bit: and $12 -- cycle: 6 -- length: 2
  ## 16-bit: and $12 -- cycle: 7 -- length: 2
  ## +1 cycle if Direct register is not page-aligned (low byte == 0)

  let adr = toAddr(0, D + readPC() + X)                    # 1 cycle
  directLowNonZero(adr, D)                                 # (+1 Direct register low byte != 0)

  CycleCpu()                                               # 1 cycle (IO)
  result = sys.readData(T, adr, ecc)                       # 1 cycle (8-bit) or 2 cycles (16-bit)

func directXindirect*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Direct Indexed Indirect (with X) addressing mode - $OP ($LL,X)
  ## Loads and return the value at the (Current Data Bank, 8-bit address + D register + X register).
  ##  8-bit: and $12 -- cycle: 6 -- length: 2
  ## 16-bit: and $12 -- cycle: 7 -- length: 2
  ## +1 cycle if Direct register is not page-aligned (low byte == 0)

  let offset = D + readPC() + X                            # 1 cycle
  directLowNonZero(adr, D)                                 # (+1 Direct register low byte != 0)

  CycleCpu()                                               # 1 cycle (IO)
  let adr = sys.readIndirectAddr(offset)                   # 2 cycles (pointer dereference)
  result = sys.readData(T, adr, ecc)                       # 1 cycle (8-bit) or 2 cycles (16-bit)

func directIndirect*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Direct Indirect addressing mode - $OP ($LL)
  ## Loads and return the value at the (Current Data Bank, 8-bit address + D register).
  ##  8-bit: and $12 -- cycle: 5 -- length: 2
  ## 16-bit: and $12 -- cycle: 6 -- length: 2
  ## +1 cycle if Direct register is not page-aligned (low byte == 0)

  let offset = D + readPC()                                # 1 cycle
  directLowNonZero(adr, D)                                 # (+1 Direct register low byte != 0)

  let adr = sys.readIndirectAddr(offset)                   # 2 cycles (pointer dereference)
  result = sys.readData(T, adr, ecc)                       # 1 cycle (8-bit) or 2 cycles (16-bit)

func directIndirectLong*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Direct Indirect Long addressing mode - $OP [$LL]
  ## Loads and return the value at the (0 + carry, 8-bit address + D register).
  ##  8-bit: and $12 -- cycle: 5 -- length: 2
  ## 16-bit: and $12 -- cycle: 6 -- length: 2
  ## +1 cycle if Direct register is not page-aligned (low byte == 0)

  let offset = D + readPC()                                # 1 cycle
  directLowNonZero(adr, D)                                 # (+1 Direct register low byte != 0)

  let adr = sys.readIndirectAddr(offset, isLong = true)    # 3 cycles (long pointer dereference)
  result = sys.readData(T, adr, ecc)                       # 1 cycle (8-bit) or 2 cycles (16-bit)
