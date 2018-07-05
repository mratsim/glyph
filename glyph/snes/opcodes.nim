# Copyright (c) 2018 Mamy André-Ratsimbazafy
# Distributed under the Apache v2 License (license terms are at http://www.apache.org/licenses/LICENSE-2.0).

import ./private/macros_opcodes, ./datatypes

genOpcTable:

  op ADC: # Add with Carry
    0x61: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectXIndirect
    0x63: cycles 4, {Ecc1_m16bit}                                       , StackRelative
    0x65: cycles 3, {Ecc1_m16bit, EccDirectlowNonZero}                  , Direct
    0x67: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirectLong
    0x69: cycles 2, {Ecc1_m16bit}                                       , Immediate
    0x6D: cycles 4, {Ecc1_m16bit}                                       , Absolute
    0x6F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLong
    0x71: cycles 5, {Ecc1_m16bit, EccDirectlowNonZero, EccCrossBoundary}, DirectIndirectY
    0x72: cycles 5, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirect
    0x73: cycles 7, {Ecc1_m16bit}                                       , StackRelativeIndirectY
    0x75: cycles 4, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectX
    0x77: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirectLongY
    0x79: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteY
    0x7D: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteX
    0x7F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLongX

    implementation:
      discard

  op AND: # AND Accumulator with memory
    0x21: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectXIndirect
    0x23: cycles 4, {Ecc1_m16bit}                                       , StackRelative
    0x25: cycles 3, {Ecc1_m16bit, EccDirectlowNonZero}                  , Direct
    0x27: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirectLong
    0x29: cycles 2, {Ecc1_m16bit}                                       , Immediate
    0x2D: cycles 4, {Ecc1_m16bit}                                       , Absolute
    0x2F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLong
    0x31: cycles 5, {Ecc1_m16bit, EccDirectlowNonZero, EccCrossBoundary}, DirectIndirectY
    0x32: cycles 5, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirect
    0x33: cycles 7, {Ecc1_m16bit}                                       , StackRelativeIndirectY
    0x35: cycles 4, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectX
    0x37: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirectLongY
    0x39: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteY
    0x3D: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteX
    0x3F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLongX

    implementation:
      discard

  op ASL: # Arithmetic Shift Left
    0x06: cycles 5, {EccDirectlowNonZero, Ecc2_m16bit}                  , Direct
    0x0A: cycles 2, {}                                                  , Accumulator
    0x0E: cycles 6, {Ecc2_m16bit}                                       , Absolute
    0x16: cycles 6, {EccDirectlowNonZero, Ecc2_m16bit}                  , DirectX
    0x1E: cycles 7, {Ecc2_m16bit}                                       , AbsoluteX

    implementation:
      discard

  op BCC: # Branch if Carry Clear
    0x90: cycles 2, {EccBranchTaken, Ecc65C02BranchCross}              , ProgramCounterRelative
    implementation:
      discard

  op BCS: # Branch if Carry Set
    0xB0: cycles 2, {EccBranchTaken, Ecc65C02BranchCross}              , ProgramCounterRelative
    implementation:
      discard

  op BEQ: # Branch if Equal
    0xF0: cycles 2, {EccBranchTaken, Ecc65C02BranchCross}              , ProgramCounterRelative
    implementation:
      discard

  op BIT: # Test Bits
    0x24: cycles 3, {Ecc1_m16bit, EccDirectNonZero}                     , Direct
    0x2C: cycles 4, {Ecc1_m16bit}                                       , Absolute
    0x34: cycles 4, {Ecc1_m16bit, EccDirectNonZero}                     , DirectX
    0x3C: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteX
    0x89: cycles 2, {Ecc1_m16bit}                                       , Immediate

    implementation:
      discard

  op BNE: # Branch if Not Equal
    0x30: cycles 2, {EccBranchTaken, Ecc65C02BranchCross}              , ProgramCounterRelative
    implementation:
      discard

  op BPL: # Branch if Plus
    0x10: cycles 2, {EccBranchTaken, Ecc65C02BranchCross}              , ProgramCounterRelative
    implementation:
      discard

  op BRA: # Branch Always
    0x80: cycles 3, {Ecc65C02BranchCross}                              , ProgramCounterRelative
    implementation:
      discard

  op BRK: # Break
    0x00: cycles 7, {EccBranchTaken, Ecc65C02BranchCross}              , Stack
    implementation:
      discard

  op BRL: # Branch Long Always
    0x82: cycles 2,                                                    , ProgCountRelativeLong
    implementation:
      discard

  op BVC: # Branch if Overflow Clear
    0x50: cycles 2, {EccBranchTaken, Ecc65C02BranchCross}              , ProgramCounterRelative
    implementation:
      discard

  op BVS: # Branch if Overflow Set
    0x70: cycles 2, {EccBranchTaken, Ecc65C02BranchCross}              , ProgramCounterRelative
    implementation:
      discard

  op CLC: # Clear Carry
    0x18: cycles 2, {}                                                 , Implied
    implementation:
      discard

  op CLD: # Clear Decimal Mode Flag
    0xD8: cycles 2, {}                                                 , Implied
    implementation:
      discard

  op CLI: # Clear Interrupt Disable Flag
    0x58: cycles 2, {}                                                 , Implied
    implementation:
      discard

  op CLV: # Clear Overflow Flag
    0xB8: cycles 2, {}                                                 , Implied
    implementation:
      discard

  op CMP: # Compare Accumulator with Memory
    0xC1: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectXIndirect
    0xC3: cycles 4, {Ecc1_m16bit}                                       , StackRelative
    0xC5: cycles 3, {Ecc1_m16bit, EccDirectlowNonZero}                  , Direct
    0xC7: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirectLong
    0xC9: cycles 2, {Ecc1_m16bit}                                       , Immediate
    0xCD: cycles 4, {Ecc1_m16bit}                                       , Absolute
    0xCF: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLong
    0xD1: cycles 5, {Ecc1_m16bit, EccDirectlowNonZero, EccCrossBoundary}, DirectIndirectY
    0xD2: cycles 5, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirect
    0xD3: cycles 7, {Ecc1_m16bit}                                       , StackRelativeIndirectY
    0xD5: cycles 4, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectX
    0xD7: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirectLongY
    0xD9: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteY
    0xDD: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteX
    0xDF: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLongX

    implementation:
      discard

  op CPX: # Compare Index Register X with Memory
    0xE0: cycles 2, {Ecc1_x16bit}                                       , Immediate
    0xE4: cycles 3, {EccDirectlowNonZero, Ecc1_x16bit}                  , Direct
    0xEC: cycles 4, {Ecc1_x16bit}                                       , Absolute

    implementation:
      discard

  op CPY: # Compare Index Register Y with Memory
    0xC0: cycles 2, {Ecc1_x16bit}                                       , Immediate
    0xC4: cycles 3, {EccDirectlowNonZero, Ecc1_x16bit}                  , Direct
    0xCC: cycles 4, {Ecc1_x16bit}                                       , Absolute

    implementation:
      discard

  op DEC: # Decrement
    0x3A: cycles 2, {}                                                  , Accumulator
    0xC6: cycles 2, {EccDirectlowNonZero, Ecc2_m16bit}                  , Direct
    0xCE: cycles 6, {Ecc2_m16bit}                                       , Absolute
    0xD6: cycles 6, {EccDirectlowNonZero, Ecc2_m16bit}                  , DirectX
    0xDE: cycles 7, {Ecc2_m16bit}                                       , AbsoluteX

    implementation:
      discard

  op DEX: # Decrement Index Register X
    0xCA: cycles 2, {}                                                  , Implied
    implementation:
      discard

  op DEY: # Decrement Index Register Y
    0x88: cycles 2, {}                                                  , Implied
    implementation:
      discard

  op EOR: # Exclusive OR
    0x41: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectXIndirect
    0x43: cycles 4, {Ecc1_m16bit}                                       , StackRelative
    0x45: cycles 3, {Ecc1_m16bit, EccDirectlowNonZero}                  , Direct
    0x47: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirectLong
    0x49: cycles 2, {Ecc1_m16bit}                                       , Immediate
    0x4D: cycles 4, {Ecc1_m16bit}                                       , Absolute
    0x4F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLong
    0x51: cycles 5, {Ecc1_m16bit, EccDirectlowNonZero, EccCrossBoundary}, DirectIndirectY
    0x52: cycles 5, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirect
    0x53: cycles 7, {Ecc1_m16bit}                                       , StackRelativeIndirectY
    0x55: cycles 4, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectX
    0x57: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirectLongY
    0x59: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteY
    0x5D: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteX
    0x5F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLongX

    implementation:
      discard

  op INC: # Increment
    0x1A: cycles 2, {}                                                  , Accumulator
    0xE6: cycles 2, {EccDirectlowNonZero, Ecc2_m16bit}                  , Direct
    0xEE: cycles 6, {Ecc2_m16bit}                                       , Absolute
    0xF6: cycles 6, {EccDirectlowNonZero, Ecc2_m16bit}                  , DirectX
    0xFE: cycles 7, {Ecc2_m16bit}                                       , AbsoluteX

    implementation:
      discard

  op INX: # Increment Index Register X
    0xE8: cycles 2, {}                                                  , Implied
    implementation:
      discard

  op INY: # Increment Index Register Y
    0xC8: cycles 2, {}                                                  , Implied
    implementation:
      discard

  op JMP: # Jump
    0x4C: cycles 3, {}                                                  , Absolute
    0x5C: cycles 4, {}                                                  , AbsoluteLong
    0X6C: cycles 5, {}                                                  , AbsoluteIndirect
    0x7C: cycles 6, {}                                                  , AbsoluteXIndirect
    0xDC: cycles 6, {}                                                  , AbsoluteIndirectLong

    implementation:
      discard

  op JSR: # Jump to Subroutine
    0x20: cycles 6, {}                                                  , Absolute
    0x22: cycles 8, {}                                                  , AbsoluteLong
    0xFC: cycles 8, {}                                                  , AbsoluteXIndirect

    implementation:
      discard

  op LDA: # Load Accumulator from Memory
    0xA1: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectXIndirect
    0xA3: cycles 4, {Ecc1_m16bit}                                       , StackRelative
    0xA5: cycles 3, {Ecc1_m16bit, EccDirectlowNonZero}                  , Direct
    0xA7: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirectLong
    0xA9: cycles 2, {Ecc1_m16bit}                                       , Immediate
    0xAD: cycles 4, {Ecc1_m16bit}                                       , Absolute
    0xAF: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLong
    0xB1: cycles 5, {Ecc1_m16bit, EccDirectlowNonZero, EccCrossBoundary}, DirectIndirectY
    0xB2: cycles 5, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirect
    0xB3: cycles 7, {Ecc1_m16bit}                                       , StackRelativeIndirectY
    0xB5: cycles 4, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectX
    0xB7: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirectLongY
    0xB9: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteY
    0xBD: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteX
    0xBF: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLongX

    implementation:
      discard

  op LDX: # Load Index Register X from Memory
    0xA2: cycles 2, {Ecc1_x16bit}                                       , Immediate
    0xA6: cycles 3, {EccDirectlowNonZero, Ecc1_x16bit}                  , Direct
    0xAE: cycles 4, {Ecc1_x16bit}                                       , Absolute
    0xB6: cycles 4, {EccDirectlowNonZero, Ecc1_x16bit}                  , DirectY
    0xBE: cycles 4, {EccCrossBoundary, Ecc1_x16bit}                     , AbsoluteY

    implementation:
      discard

  op LDY: # Load Index Register Y from Memory
    0xA0: cycles 2, {Ecc1_x16bit}                                       , Immediate
    0xA4: cycles 3, {EccDirectlowNonZero, Ecc1_x16bit}                  , Direct
    0xAC: cycles 4, {Ecc1_x16bit}                                       , Absolute
    0xB4: cycles 4, {EccDirectlowNonZero, Ecc1_x16bit}                  , DirectX
    0xBC: cycles 4, {EccCrossBoundary, Ecc1_x16bit}                     , AbsoluteX

    implementation:
      discard

  op LSR: # Logical Shift Memory or Accumulator Right
    0x06: cycles 5, {EccDirectlowNonZero, Ecc2_m16bit}                  , Direct
    0x0A: cycles 2, {}                                                  , Accumulator
    0x0E: cycles 6, {Ecc2_m16bit}                                       , Absolute
    0x16: cycles 6, {EccDirectlowNonZero, Ecc2_m16bit}                  , DirectX
    0x1E: cycles 7, {Ecc2_m16bit}                                       , AbsoluteX

    implementation:
      discard

  op MVN: # Block Move Negative
    0x54: cycles 1, {EccDirectlowNonZero}                               , BlockMove
    implementation:
      discard

  op MVP: # Block Move Positive
    0x44: cycles 1, {EccDirectlowNonZero}                               , BlockMove
    implementation:
      discard

  op NOP: # No Operation
    0xEA: cycles 2, {}                                                  , Implied
    implementation:
      discard

  op ORA: # OR Accumulator with Memory
    0x01: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectXIndirect
    0x03: cycles 4, {Ecc1_m16bit}                                       , StackRelative
    0x05: cycles 3, {Ecc1_m16bit, EccDirectlowNonZero}                  , Direct
    0x07: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirectLong
    0x09: cycles 2, {Ecc1_m16bit}                                       , Immediate
    0x0D: cycles 4, {Ecc1_m16bit}                                       , Absolute
    0x0F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLong
    0x11: cycles 5, {Ecc1_m16bit, EccDirectlowNonZero, EccCrossBoundary}, DirectIndirectY
    0x12: cycles 5, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirect
    0x13: cycles 7, {Ecc1_m16bit}                                       , StackRelativeIndirectY
    0x15: cycles 4, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectX
    0x17: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirectLongY
    0x19: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteY
    0x1D: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteX
    0x1F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLongX

    implementation:
      discard
