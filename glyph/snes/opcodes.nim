# Copyright (c) 2018 Mamy André-Ratsimbazafy
# Distributed under the Apache v2 License (license terms are at http://www.apache.org/licenses/LICENSE-2.0).

import ./private/macros_opcodes, ./datatypes

genOpcTable:

  op ADC: # Add with Carry
    0x61: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectXIndirect
    0x63: cycles 4, {Ecc1_m16bit}                                       , StackRelative
    0x65: cycles 3, {Ecc1_m16bit, EccDirectlowNonZero}                  , Direct
    0x67: cycles 6, {Ecc1_m16bit, EccDirectlowNonZero}                  , DirectIndirectLong
    0x69: cycles 2, {Ecc1_m16bit}                                       , ImmediateAccum
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
    0x29: cycles 2, {Ecc1_m16bit}                                       , ImmediateAccum
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
    0x89: cycles 2, {Ecc1_m16bit}                                       , ImmediateAccum

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
    0xC9: cycles 2, {Ecc1_m16bit}                                       , ImmediateAccum
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
    0xE0: cycles 2, {Ecc1_x16bit}                                       , ImmediateIndex
    0xE4: cycles 3, {EccDirectlowNonZero, Ecc1_x16bit}                  , Direct
    0xEC: cycles 4, {Ecc1_x16bit}                                       , Absolute

    implementation:
      discard

  op CPY: # Compare Index Register Y with Memory
    0xC0: cycles 2, {Ecc1_x16bit}                                       , ImmediateIndex
    0xC4: cycles 3, {EccDirectlowNonZero, Ecc1_x16bit}                  , Direct
    0xCC: cycles 4, {Ecc1_x16bit}                                       , Absolute

  op DEC: # Decrement
    0x3A: cycles 2, {}                                                  , Accumulator
    0xC6: cycles 2, {EccDirectlowNonZero, Ecc2_m16bit}                  , Direct
    0xCE: cycles 6, {Ecc2_m16bit}                                       , Absolute
    0xC6: cycles 6, {EccDirectlowNonZero, Ecc2_m16bit}                  , DirectX
    0xDE: cycles 7, {Ecc2_m16bit}                                       , AbsoluteX
