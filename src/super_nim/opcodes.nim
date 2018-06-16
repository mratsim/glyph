# Copyright (c) 2018 Mamy André-Ratsimbazafy
# Distributed under the Apache v2 License (license terms are at http://www.apache.org/licenses/LICENSE-2.0).

import
  macros, ./cpu

const OpcLength = [
    Accumulator            : 1,
    Implied                : 1,
    ImmediateAccum         : 2,
    # ImmAccum16           : 3,
    ImmediateIndex         : 2,
    # ImmIndex16           : 3,
    Absolute               : 3,
    AbsLong                : 4,
    AbsLongX               : 4,
    AbsX                   : 3,
    AbsY                   : 3,
    AbsXIndirect           : 3,
    AbsIndirect            : 3,
    AbsIndirectLong        : 3,
    Direct                 : 2,
    DirectX                : 2,
    DirectY                : 2,
    DirectXIndirect        : 2,
    DirectIndirect         : 2,
    DirectIndirectLong     : 2,
    DirectIndirectY        : 2,
    DirectIndirectLongY    : 2,
    ProgramCounterRelative : 2,
    PCRelativeLong         : 3,
    Stack                  : 1,
    StackRelative          : 2,
    StackRelativeIndirectY : 2,
    BlockMove              : 3,
]

dumpTree:
  op lda:
    0xA1: cycles 6, DirectXIndirect
    0xA3: cycles 4, StackRelative

  cpu.A = foobar
