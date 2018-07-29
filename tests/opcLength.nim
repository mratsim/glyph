# Copyright (c) 2018 Mamy André-Ratsimbazafy
# Distributed under the Apache v2 License (license terms are at http://www.apache.org/licenses/LICENSE-2.0).

import ../glyph/snes/datatypes

const OpcLength* = [
    Accumulator            : 1,
    Implied                : 1,
    Immediate              : 2, # 3 if 16-bit mode
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
