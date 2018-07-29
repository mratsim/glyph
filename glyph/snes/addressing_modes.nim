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

template readByte(): uint8 {.dirty.} =
  ## Read a single byte, increment cycle and program counter
  Next()
  CycleCPU()
  sys.mem[DB, PC]

func readAddr(sys: Sys, isLong: static[bool]): Addr {.inline.} =
  ## Read memory and implement the program counter.
  ## Returns a 24-bit address
  # Implementation - 65816 is little-endian:
  #   low byte then high byte then data bank byte
  var adr: uint16
  adr.lo = readByte()                                 # 2 cycles
  adr.hi = readByte()

  let db =  when isLong: readByte()                   # (+1 cycle if long addressing)
            else: DB()

  result = toAddr(db, adr)

func readVal(sys: Sys, T: typedesc[uint8 or uint16], adr: Addr, ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Read a uint8 or uint16 value at a specific address
  # Implementation - 65816 is little-endian:
  #   low byte then high byte
  when T is uint16:                                   # 2 cycles
    result.lo = sys.mem[adr]
    CycleCPU()

    when EccCrossBoundary in ecc:
      if adr.relAddr == 0xFFFF: CycleCPU()            # (+1 if crossing page boundary)

    result.hi = sys.mem[adr + 1]
    CycleCPU()

  else:                                               # 1 cycle
    result = sys.mem[adr]
    CycleCPU()

func immediate*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Immediate addressing mode - $OP #$CONST
  ## Returns the 1 or 2-byte constant immediately after the opcode
  ##  8-bit: inc   #$12 -- cycle: 1 -- length: 2
  ## 16-bit: inc #$1234 -- cycle: 2 -- length: 3

  when T is uint16:                                   # 2 cycles
    result.lo = readByte()
    result.hi = readByte()
  else:                                               # 1 cycle
    result = readByte()

func absolute*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Absolute addressing mode - $OP $HHLL
  ## Loads and return the value at the 16-bit address immediately after the opcode.
  ## Address is relative to the current data bank.
  ##  8-bit: and #$1234 -- cycle: 3 -- length: 3
  ## 16-bit: and #$1234 -- cycle: 4 -- length: 3

  let adr = sys.readAddr(isLong = false)              # 2 cycles
  result = sys.readVal(T, adr, ecc)                   # 1 cycle (8-bit) or 2 cycles (16-bit)

func absoluteLong*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Absolute long addressing mode - $OP $DBHHLL
  ## Loads and return the value at the 24-bit address immediately after the opcode.
  ## The first 8-bit corresponds to the databank addressed.
  ##  8-bit: and #$123456 -- cycle: 4 -- length: 4
  ## 16-bit: and #$123456 -- cycle: 5 -- length: 4

  let adr = sys.readAddr(isLong = true)               # 3 cycles
  result = sys.readVal(T, adr, ecc)                   # 1 cycle (8-bit) or 2 cycles (16-bit)

func absoluteX*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Absolute Indexed, X addressing mode - $OP $HHLL,X
  ## Loads and return the value at the (16-bit address + X register).
  ## Address is relative to the current data bank.
  ##  8-bit: and #$1234, X -- cycle: 3 -- length: 3
  ## 16-bit: and #$1234, X -- cycle: 4 -- length: 3

  let adr = sys.readAddr(isLong = false) + sys.regs.X # 2 cycles
  when EccCrossBoundary in ecc:
    if adr.db != DB: CycleCPU()                       # (+1 if crossing page boundary)
  result = sys.readVal(T, adr, ecc)                   # 1 cycle (8-bit) or 2 cycles (16-bit)

func absoluteY*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Absolute Indexed, X addressing mode - $OP $HHLL,X
  ## Loads and return the value at the (16-bit address + X register).
  ## Address is relative to the current data bank.
  ##  8-bit: and #$1234 -- cycle: 3 -- length: 3
  ## 16-bit: and #$1234 -- cycle: 4 -- length: 3

  let adr = sys.readAddr(isLong = false) + sys.regs.Y # 2 cycles
  when EccCrossBoundary in ecc:
    if adr.db != DB: CycleCPU()                       # (+1 if crossing page boundary)
  result = sys.readVal(T, adr, ecc)                   # 1 cycle (8-bit) or 2 cycles (16-bit)

func absoluteLongX*(sys: Sys, T: typedesc[uint8 or uint16], ecc: static[ExtraCycleCosts]): T {.inline.}=
  ## Absolute Long Indexed, X addressing mode - $OP $DBHHLL,X
  ## Loads and return the value at the (24-bit address + X register).
  ## The first 8-bit corresponds to the databank addressed.
  ##  8-bit: and #$1234 -- cycle: 3 -- length: 3
  ## 16-bit: and #$1234 -- cycle: 4 -- length: 3

  let readAddr = sys.readAddr(isLong = true)          # 2 cycles
  let db = readAddr.db
  let adr = readAddr + sys.regs.X
  when EccCrossBoundary in ecc:
    if adr.db != db: CycleCPU()                       # (+1 if crossing page boundary)
  result = sys.readVal(T, adr, ecc)                   # 1 cycle (8-bit) or 2 cycles (16-bit)
