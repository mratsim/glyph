# Copyright (c) 2018 Mamy André-Ratsimbazafy
# Distributed under the Apache v2 License (license terms are at http://www.apache.org/licenses/LICENSE-2.0).

import tables

######################################################################
#
# Helpers
#
######################################################################

# We don't use {.union.} types here for lo and hi uint8 access of uint16
# as it doesn't work with JS target.
# Ergonomically it also requires extra `u16`, `u8.lo`, `u8.hi` access.

template lo*(x: uint16): uint8 = x.uint8
template `lo=`*(x: var uint16, data: uint8) =
  x = (x and 0xFF00) or data.uint16

template hi*(x: uint16): uint8 = uint8(x shr 8)
template `hi=`*(x: var uint16, data: uint8) =
  x = (x and 0x00FF) or (data.uint16 shl 8)

func isMsbSet*[T: SomeUnsignedInt](n: T): bool {.inline.}=
  ## Returns true if the most significant bit of an integer is set.
  const msb_pos = sizeof(T) * 8 - 1
  result = bool(n shr msb_pos)

######################################################################
#
# CPU
#
######################################################################

type
  # Note using uint8 instead of machine word size will add zero-extending overhead at every load

  CPUStatusKind* = enum
    Carry                   ## C - 0b00000001
    Zero                    ## Z - 0b00000010
    IRQ_Disabled            ## I - 0b00000100
    Decimal_Mode            ## D - 0b00001000
    Index8bit               ## X - 0b00010000
    Accum8bit               ## M - 0b00100000
    Overflow                ## V - 0b01000000
    Negative                ## N - 0b10000000
    Emulation_mode          ## E - hidden / B - Break 0b00010000. Define if 6502 mode or 65816 mode

  CpuRegs* = object
    # General purpose registers
    A*: uint16              ## Accumulator - Math register. Stores operands or results of arithmetic operations.
    X*, Y*: uint16          ## Index registers. Reference memory, pass data, counters for loops ...
    # Addressing registers
    D*: uint16              ## Direct page addressing. Holds the memory bank address of the data the CPU is accessing.
    DB*: uint8              ## Data Bank. Holds the default bank for memory transfers.
    # Program control register
    PB*: uint8              ## Program Bank. Holds the bank address of all instruction fetches.
    PC*: uint16             ## Program Counter. Address of the current memory instruction.
    SP*: uint16             ## Stack Pointer.
    # Status register
    P*: set[CPUStatusKind]  ## Processor status

  AddressingMode* = enum
    # $number represents a number in hexadecimal representation
    # Name                  # Example
    Accumulator             # dec a
    Implied                 # clc
    Immediate               # inc #$12 or #$1234
    Absolute                # and $1234
    AbsoluteLong            # and $123456
    AbsoluteLongX           # and $123456,X
    AbsoluteX               # and $1234,X
    AbsoluteY               # and $1234,Y
    AbsoluteXIndirect       # jmp ($1234,X)
    AbsoluteIndirect        # jmp ($1234)
    AbsoluteIndirectLong    # jml [$1234]
    Direct                  # and $12
    DirectX                 # stz $12,X
    DirectY                 # stz $12,Y
    DirectXIndirect         # and ($12,X)
    DirectIndirect          # and ($12)
    DirectIndirectLong      # and [$12]
    DirectIndirectY         # and ($12),Y
    DirectIndirectLongY     # and [$12],Y
    ProgramCounterRelative  # beq $12
    ProgCountRelativeLong   # brl $1234
    StackRelative           # and $12,S
    StackRelativeIndirectY  # and ($12,S),Y
    BlockMove               # mvp $12, $34

  Cpu* = object
    regs*: CpuRegs
    cycles*: int

template genFlagAccessor(flag: CPUStatusKind, accessor: untyped) =
  template `accessor`*(P: set[CPUStatusKind]): bool =
    flag in P

  template `accessor=`*(P: set[CPUStatusKind], val: bool) =
    if val:
      P.incl flag
    else:
      P.excl flag

genFlagAccessor Carry, carry
genFlagAccessor Zero, zero
genFlagAccessor IRQ_Disabled, irq_disabled
genFlagAccessor Decimal_Mode, decimal_mode
genFlagAccessor Index8bit, index8bit
genFlagAccessor Accum8bit, accum8bit
genFlagAccessor Overflow, overflow
genFlagAccessor Negative, negative
genFlagAccessor Emulation_mode, emulation_mode

######################################################################
#
# Opcodes
#
######################################################################

type
  ExtraCycleCost* = enum
    Ecc1_m16bit         # +1 cycle if access is done in 16-bit memory or accumulator
    EccDirectLowNonZero # +1 cycle if low byte of Direct page register != 0
    EccCrossBoundary    # +1 cycle if adding index crosses a page boundary
    Ecc2_m16bit         # +2 cycles if access is done in 16-bit memory or accumulator (read-modify-write)
    EccBranchTaken      # +1 cycle if branch taken
    Ecc65C02BranchCross # +1 cycle if branch taken, cross boundary and emulation mode
    Ecc65816Native      # +1 cycle if 65816 mode (no emulation)
    Ecc1_xy16bit        # +1 cycle if access is done in 16-bit index register
    Ecc3_reset          # +3 cycles to shut CPU down: additional cycles required by reset for restart
    Ecc3_interrupt      # +3 cycles to shut CPU down: additional cycles required by interrupt for restart

  ExtraCycleCosts* = set[ExtraCycleCost]

type
  OpcParams* = tuple[name: string, cycles: int, ecc: NimNode, addr_mode: NimNode, impl: NimNode]
  OpcTable* = OrderedTable[int, OpcParams]


######################################################################
#
# Memory
#
######################################################################
type
  Mem* = object

  Sys* = ref object
    cpu*: Cpu
    mem*: Mem

  Addr* = distinct range[0'u32..0xFFFFFF'u32]
    ## 24-bit address

proc `shl`(x: Addr, y: int): Addr {.borrow, noSideEffect.}
proc `or`(x, y: Addr): Addr {.borrow, noSideEffect.}
proc `+`*(x, y: Addr): Addr {.borrow, noSideEffect.}

func `+`*(x: Addr, y: SomeInteger): Addr {.inline.} =
  x + Addr(y)

func toAddr*(bank: uint8, adr: uint16): Addr {.inline.}=
  Addr(bank) shl 16 or Addr(adr)

func `[]`*(mem: Mem, adr: Addr): uint8 {.inline.}=
  # Stub
  discard

func `[]`*(mem: Mem, bank: uint8, adr: uint16): uint8 {.inline.}=
  # Stub
  mem[toAddr(bank, adr)]

func bank*(adr: Addr): uint8 {.inline.}=
  ## Get the databank from a 24-bit address
  uint8(uint32(adr) shr 16)
template `bank=`*(adr: var Addr, bank: uint8) =
  ## Set the databank of a 24-bit address
  adr = (adr and 0xFFFF) or (data.Addr shl 16)

func relAddr*(adr: Addr): uint16 {.inline.}=
  ## Strip the databank and only return the relative address
  ## from a full address
  uint16(adr)

######################################################################
#
# Aliases
#
######################################################################
template DB*(): uint8 {.dirty.} = sys.cpu.regs.DB
template PB*(): uint8 {.dirty.} = sys.cpu.regs.pB
template PC*(): uint16 {.dirty.} = sys.cpu.regs.PC
template P*(): set[CPUStatusKind] {.dirty.} = sys.cpu.regs.P

template D*(): uint16 {.dirty.} = sys.cpu.regs.D

template X*(): uint16 {.dirty.} = sys.cpu.regs.X
template Y*(): uint16 {.dirty.} = sys.cpu.regs.Y

template CycleCPU*() {.dirty.} = inc sys.cpu.cycles
template Next*()     {.dirty.} = inc PC
