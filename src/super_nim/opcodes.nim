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
    0x79: cycles 4, {Ecc1_16bit, EccCrossBoundary}                     , AbsY
    0x7D: cycles 4, {Ecc1_16bit, EccCrossBoundary}                     , AbsX
    0x7F: cycles 5, {ECC1_16bit}                                       , AbsLongX

    implementation:
      discard
