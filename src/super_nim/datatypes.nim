# Copyright (c) 2018 Mamy André-Ratsimbazafy
# Distributed under the Apache v2 License (license terms are at http://www.apache.org/licenses/LICENSE-2.0).

import tables

######################################################################
#
# CPU
#
######################################################################

type
  Int = int         ## Base uint type used in the VM. Having it at the host word size will be faster.
                    ## as otherwise all load will require zero extending. It takes more space though.
  U8 = range[Int(0) .. Int(0xFF)]
  U16 = range[Int(0) .. Int(0xFFFF)]

  CPUStatusKind* = enum
    Carry = 0b00000001, ## C - 0b00000001
    Zero,               ## Z - 0b00000010
    IRQ_Disabled,       ## I - 0b00000100
    Decimal_Mode,       ## D - 0b00001000
    IndexRegister8bit,  ## X - 0b00010000
    AccumRegister8bit,  ## M - 0b00100000
    Overflow,           ## V - 0b01000000
    Negative,           ## N - 0b10000000
    Emulation_mode      ## E - hidden / B - Break 0b00010000. Define if 6502 mode or 65816 mode

  Cpu* = object
    # Status register
    P: set[CPUStatusKind]  ## Processor status
    # General purpose registers
    A: U16           ## Accumulator - Math register. Stores operands or results of arithmetic operations.
    X, Y: U16        ## Index registers. Reference memory, pass data, counters for loops ...
    # Addressing registers
    D: U16           ## Direct page addressing. Holds the memory bank address of the data the CPU is accessing.
    DB: U8           ## Data Bank. Holds the default bank for memory transfers.
    # Program control register
    PC: U16          ## Program Counter. Address of the current memory instruction.
    PB: U8           ## Program Bank. Holds the bank address of all instruction fetches.
    SP: U16          ## Stack Pointer.

  AddressingMode* = enum
    # Name                 # Example
    Accumulator            # dec a
    Implied                # clc
    ImmediateAccum         # inc #$12
    # ImmAccum16           # lda #$1234
    ImmediateIndex         # ldx #$12
    # ImmIndex16           # ldy #$1234
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
    Stack                  # rts
    StackRelative          # and $12, s
    StackRelativeIndirectY # and ($12, s), y
    BlockMove              # mvp $12, $34

template accessLoHi(field: untyped) =
  ## Create proc to address low and high part
  ## of a 16-bit field
  # Note we could use union but that prevents Javascript compilation

  func `field l`*(cpu: Cpu): U8 {.inline.}= cpu.`field` and 7
  func `field h`*(cpu: Cpu): U8 {.inline.}= cpu.`field` shr 8


######################################################################
#
# Opcodes
#
######################################################################

const OpcLength* = [
    Accumulator            : 1,
    Implied                : 1,
    # Immediate            : 2,
    ImmediateAccum         : 2,
    # ImmAccum16           : 3,
    ImmediateIndex         : 2,
    # ImmIndex16           : 3,
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
    Stack                  : 1,
    StackRelative          : 2,
    StackRelativeIndirectY : 2,
    BlockMove              : 3,
]

type
  ExtraCycleCost* = enum
    Ecc1_16bit          # +1 cycle if access is done in 16-bit memory or accumulator
    EccDirectlowNonZero # +1 cycle if low byte of Direct page register != 0
    EccCrossBoundary    # +1 cycle if adding index crosses a page boundary
    Ecc2_16bit          # +2 cycles if access is done in 16-bit memory or accumulator
    EccBranchTaken      # +1 cycle if branch taken
    Ecc65C02BranchCross # +1 cycle if branch taken, cross boundary and emulation mode

  ExtraCycleCosts* = set[ExtraCycleCost]

type
  OpcParams* = tuple[name: string, cycles: int, ecc: NimNode, addr_mode: NimNode, impl: NimNode]
  OpcTable* = OrderedTable[int, OpcParams]
