# Copyright (c) 2018 Mamy André-Ratsimbazafy
# Distributed under the Apache v2 License (license terms are at http://www.apache.org/licenses/LICENSE-2.0).

import tables

######################################################################
#
# Helpers
#
######################################################################

# We don't use union types here to allow compilation to JS.

template lo*(x: uint16): uint8 = uint8(x and 0b00000000_11111111)
template `lo=`*(x: var uint16, data: uint8) =
  x = (x and 0b11111111_00000000) or data.uint16

template hi*(x: uint16): uint8 = uint8(x and 0b11111111_00000000)
template `hi=`*(x: var uint16, data: uint8) =
  x = (x and 0b00000000_11111111) or (data.uint16 shl 8)

######################################################################
#
# CPU
#
######################################################################

type
  # Note using uint8 instead of machine word size will add zero-extending overhead at every load

  CPUStatusKind* = enum
    Carry              ## C - 0b00000001
    Zero               ## Z - 0b00000010
    IRQ_Disabled       ## I - 0b00000100
    Decimal_Mode       ## D - 0b00001000
    Index8bit          ## X - 0b00010000
    Accum8bit          ## M - 0b00100000
    Overflow           ## V - 0b01000000
    Negative           ## N - 0b10000000
    Emulation_mode     ## E - hidden / B - Break 0b00010000. Define if 6502 mode or 65816 mode

  CpuRegs* = object
    # General purpose registers
    A*: uint16        ## Accumulator - Math register. Stores operands or results of arithmetic operations.
    X*, Y*: uint16    ## Index registers. Reference memory, pass data, counters for loops ...
    # Addressing registers
    D*: uint16        ## Direct page addressing. Holds the memory bank address of the data the CPU is accessing.
    DB*: uint8        ## Data Bank. Holds the default bank for memory transfers.
    # Program control register
    PB*: uint8        ## Program Bank. Holds the bank address of all instruction fetches.
    PC*: uint8        ## Program Counter. Address of the current memory instruction.
    SP*: uint8        ## Stack Pointer.
    # Status register
    P*: set[CPUStatusKind]  ## Processor status

  AddressingMode* = enum
    # Name                 # Example
    Accumulator            # dec a
    Implied                # clc
    Immediate              # inc #$12 or #$1234
    Absolute               # and $1234
    AbsoluteLong           # and $123456
    AbsoluteLongX          # and $123456, x
    AbsoluteX              # and $1234, x
    AbsoluteY              # and $1234, y
    AbsoluteXIndirect      # jmp ($1234, x)
    AbsoluteIndirect       # jmp ($1234)
    AbsoluteIndirectLong   # jml [$1234]
    Direct                 # and $12
    DirectX                # stz $12, x
    DirectY                # stz $12, y
    DirectXIndirect        # and ($12, x)
    DirectIndirect         # and ($12)
    DirectIndirectLong     # and [$12]
    DirectIndirectY        # and ($12), y
    DirectIndirectLongY    # and [$12], y
    ProgramCounterRelative # beq $12
    ProgCountRelativeLong  # brl $1234
    StackRelative          # and $12, s
    StackRelativeIndirectY # and ($12, s), y
    BlockMove              # mvp $12, $34

  Cpu* = object
    regs: CpuRegs
    cycles: int

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

  Sys* = object
    cpu*: Cpu
    mem*: Mem

func `[]`*(mem: Mem, adr: SomeUnsignedInt): uint8 =
  # Stub
  discard
