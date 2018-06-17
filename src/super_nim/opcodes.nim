# Copyright (c) 2018 Mamy André-Ratsimbazafy
# Distributed under the Apache v2 License (license terms are at http://www.apache.org/licenses/LICENSE-2.0).

import ./private/macros_opcodes, ./datatypes

genOpcTable:

  op ADC: # Add with Carry
    0x61: cycles 6, {Ecc1_16bit, EccDirectlowNonZero}                  , DirectXIndirect
    0x63: cycles 4, {Ecc1_16bit}                                       , StackRelative
    0x65: cycles 3, {Ecc1_16bit, EccDirectlowNonZero}                  , Direct
    0x67: cycles 6, {Ecc1_16bit, EccDirectlowNonZero}                  , DirectIndirectLong
    0x69: cycles 2, {Ecc1_16bit}                                       , ImmediateAccum
    0x6D: cycles 4, {Ecc1_16bit}                                       , Absolute
    0x6F: cycles 5, {Ecc1_16bit}                                       , AbsoluteLong
    0x71: cycles 5, {Ecc1_16bit, EccDirectlowNonZero, EccCrossBoundary}, DirectIndirectY
    0x72: cycles 5, {Ecc1_16bit, EccDirectlowNonZero}                  , DirectIndirect
    0x73: cycles 7, {ECC1_16bit}                                       , StackRelativeIndirectY
    0x75: cycles 4, {Ecc1_16bit, EccDirectlowNonZero}                  , DirectX
    0x77: cycles 6, {Ecc1_16bit, EccDirectlowNonZero}                  , DirectIndirectLongY
    0x79: cycles 4, {Ecc1_16bit, EccCrossBoundary}                     , AbsoluteY
    0x7D: cycles 4, {Ecc1_16bit, EccCrossBoundary}                     , AbsoluteX
    0x7F: cycles 5, {ECC1_16bit}                                       , AbsoluteLongX

    implementation:
      discard

  op AND: # AND Accumulator with memory
    0x21: cycles 6, {Ecc1_16bit, EccDirectlowNonZero}                  , DirectXIndirect
    0x23: cycles 4, {Ecc1_16bit}                                       , StackRelative
    0x25: cycles 3, {Ecc1_16bit, EccDirectlowNonZero}                  , Direct
    0x27: cycles 6, {Ecc1_16bit, EccDirectlowNonZero}                  , DirectIndirectLong
    0x29: cycles 2, {Ecc1_16bit}                                       , ImmediateAccum
    0x2D: cycles 4, {Ecc1_16bit}                                       , Absolute
    0x2F: cycles 5, {Ecc1_16bit}                                       , AbsoluteLong
    0x31: cycles 5, {Ecc1_16bit, EccDirectlowNonZero, EccCrossBoundary}, DirectIndirectY
    0x32: cycles 5, {Ecc1_16bit, EccDirectlowNonZero}                  , DirectIndirect
    0x33: cycles 7, {Ecc1_16bit}                                       , StackRelativeIndirectY
    0x35: cycles 4, {Ecc1_16bit, EccDirectlowNonZero}                  , DirectX
    0x37: cycles 6, {Ecc1_16bit, EccDirectlowNonZero}                  , DirectIndirectLongY
    0x39: cycles 4, {Ecc1_16bit, EccCrossBoundary}                     , AbsoluteY
    0x3D: cycles 4, {Ecc1_16bit, EccCrossBoundary}                     , AbsoluteX
    0x3F: cycles 5, {ECC1_16bit}                                       , AbsoluteLongX

    implementation:
      discard

  op ASL: # Arithmetic Shift Left
    0x06: cycles 5, {EccDirectlowNonZero, Ecc2_16bit}                  , Direct
    0x0A: cycles 2, {}                                                 , Accumulator
    0x0E: cycles 6, {Ecc2_16bit}                                       , Absolute
    0x16: cycles 6, {EccDirectlowNonZero, Ecc2_16bit}                  , DirectX
    0x1E: cycles 7, {Ecc2_16bit}                                       , AbsoluteX

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
