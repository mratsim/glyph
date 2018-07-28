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

template lo*(x: uint16): uint8 = uint8(x and 0x00FF)
template `lo=`*(x: var uint16, data: uint8) =
  x = (x and 0xFF00) or data.uint16

template hi*(x: uint16): uint8 = uint8(x and 0xFF00)
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
    # Name                  # Example
    Accumulator             # dec a
    Implied                 # clc
    Immediate               # inc #$12 or #$1234
    Absolute                # and $1234
    AbsoluteLong            # and $123456
    AbsoluteLongX           # and $123456, x
    AbsoluteX               # and $1234, x
    AbsoluteY               # and $1234, y
    AbsoluteXIndirect       # jmp ($1234, x)
    AbsoluteIndirect        # jmp ($1234)
    AbsoluteIndirectLong    # jml [$1234]
    Direct                  # and $12
    DirectX                 # stz $12, x
    DirectY                 # stz $12, y
    DirectXIndirect         # and ($12, x)
    DirectIndirect          # and ($12)
    DirectIndirectLong      # and [$12]
    DirectIndirectY         # and ($12), y
    DirectIndirectLongY     # and [$12], y
    ProgramCounterRelative  # beq $12
    ProgCountRelativeLong   # brl $1234
    StackRelative           # and $12, s
    StackRelativeIndirectY  # and ($12, s), y
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

const OpcLength* = [
    Accumulator            : 1,
    Implied                : 1,
    Immediate              : 2,
    Absolute               : 3,
    AbsoluteLong           : 4,
    AbsoluteLongX          : 4,
    AbsoluteX              : 3,
    AbsoluteY              : 3,
    AbsoluteXIndirect      : 3,
    AbsoluteIndirect       : 3,
    AbsoluteIndirectLong   : 3,
    Direct                 : 2,
    DirectX                : 2,
    DirectY                : 2,
    DirectXIndirect        : 2,
    DirectIndirect         : 2,
    DirectIndirectLong     : 2,
    DirectIndirectY        : 2,
    DirectIndirectLongY    : 2,
    ProgramCounterRelative : 2,
    ProgCountRelativeLong  : 3,
    StackRelative          : 2,
    StackRelativeIndirectY : 2,
    BlockMove              : 3,
]

type
  ExtraCycleCost* = enum
    Ecc1_m16bit         # +1 cycle if access is done in 16-bit memory or accumulator
    EccDirectLowNonZero # +1 cycle if low byte of Direct page register != 0
    EccCrossBoundary    # +1 cycle if adding index crosses a page boundary
    Ecc2_m16bit         # +2 cycles if access is done in 16-bit memory or accumulator
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

func toAddr*(dataBank: uint8, adr: uint16): Addr {.inline.}=
  Addr(dataBank) shl 16 or Addr(adr)

func `[]`*(mem: Mem, adr: Addr): uint8 {.inline.}=
  # Stub
  discard

func `[]`*(mem: Mem, dataBank: uint8, adr: uint16): uint8 {.inline.}=
  # Stub
  mem[toAddr(dataBank, adr)]

func db*(adr: Addr): uint8 {.inline.}=
  ## Get the databank from a 24-bit address
  uint8(uint32(adr) shl 16)

######################################################################
#
# Aliases
#
######################################################################
template DB*(): uint8 {.dirty.} = sys.cpu.regs.DB
template PC*(): uint16 {.dirty.} = sys.cpu.regs.PC
template P*(): set[CPUStatusKind] {.dirty.} = sys.cpu.regs.P

template CycleCPU*() {.dirty.} = inc sys.cpu.cycles
template Next*()     {.dirty.} = inc PC
