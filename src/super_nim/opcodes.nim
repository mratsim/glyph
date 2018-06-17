# Copyright (c) 2018 Mamy André-Ratsimbazafy
# Distributed under the Apache v2 License (license terms are at http://www.apache.org/licenses/LICENSE-2.0).

import
  macros, ./cpu, strformat, strutils

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

type
  ExtraCycleCost = enum
    Ecc1_16bit       # +1 cycle if access is done in 16-bit memory or accumulator
    EccNonZero       # +1 cycle if low byte of Direct page register != 0
    EccCrossBoundary # +1 cycle if adding index crosses a page boundary
    Ecc2_16bit       # +2 cycles if access is done in 16-bit memory or accumulator

  ExtraCycleCosts = set[ExtraCycleCost]

import tables

type
  OpcParams = tuple[name: string, cycles: int, ecc: NimNode, addr_mode: NimNode, impl: NimNode]
  OpcTable = OrderedTable[int, OpcParams]

macro genOpcTable(opcs: untyped): untyped =

  # genOpcTable:
  #   op lda: # LDA Load the Accumulator with Memory
  #     0xA1: cycles 6, {Ecc1_16bit, EccCrossBoundary}, DirectXIndirect
  #     0xA3: cycles 4, {Ecc1_16bit}                  , StackRelative

  #     implementation:
  #       cpu.A = foobar

  # StmtList
  #   Command
  #     Ident "op"
  #     Ident "lda"
  #     StmtList
  #       Call
  #         IntLit 161
  #         StmtList
  #           Command
  #             Ident "cycles"
  #             IntLit 6
  #             Curly
  #               Ident "Ecc1_16bit"
  #               Ident "EccCrossBoundary"
  #             Ident "DirectXIndirect"
  #       Call
  #         IntLit 163
  #         StmtList
  #           Command
  #             Ident "cycles"
  #             IntLit 4
  #             Curly
  #               Ident "Ecc1_16bit"
  #             Ident "StackRelative"
  #       Call
  #         Ident "implementation"
  #         StmtList
  #           Asgn
  #             DotExpr
  #               Ident "cpu"
  #               Ident "A"
  #             Ident "foobar"

  var opcTable = initOrderedTable[int, OpcParams]()

  for op in opcs:
    # Sanity checks
    op.expectKind nnkCommand
    assert op[0].eqIdent "op"
    op[1].expectKind nnkIdent
    op[2].expectKind nnkStmtList
    assert op.len == 3

    # Get name and implementation
    let name = op[1].strVal
    let implSection = op[2][op[2].len - 1]

    implSection.expectKind nnkCall
    assert implSection.len == 2
    assert implSection[0].eqIdent "implementation"
    implSection[1].expectKind nnkStmtList
    let impl = implSection[1]

    # Iterate over instruction params
    # we skip the last which is the implementation
    for instruction in op[2]:
      if instruction[0].kind == nnkIdent and instruction[0].eqIdent "implementation":
        break

      # Sanity checks
      instruction.expectKind nnkCall
      assert instruction.len == 2
      echo instruction.treerepr
      instruction[0].expectKind nnkIntLit
      instruction[1].expectKind nnkStmtList

      assert instruction[1].len == 1
      instruction[1][0].expectKind nnkCommand
      assert instruction[1][0].len == 4
      assert instruction[1][0][0].eqIdent "cycles"
      instruction[1][0][1].expectKind nnkIntLit
      instruction[1][0][2].expectKind nnkCurly
      instruction[1][0][3].expectKind nnkIdent

      # Get the values
      let
        opcode    = instruction[0].intVal.int
        cycles    = instruction[1][0][1].intVal.int
        ecc       = instruction[1][0][2]
        addr_mode = instruction[1][0][3]

        opcParams: OpcParams = (name, cycles, ecc, addr_mode, impl)

      # Add to the table
      assert opcTable.hasKeyOrPut(opcode, opcParams).not, &"Opcode 0x{opcode.toHex} {name} already exists"

  # Reorder by opcode value
  opcTable.sort(proc(x, y: tuple[key: int, val: OpcParams]):int = cmp(x.key, y.key))

genOpcTable:
  op LDA: # LDA Load the Accumulator with Memory
    0xA1: cycles 6, {Ecc1_16bit, EccCrossBoundary}, DirectXIndirect
    0xA3: cycles 4, {Ecc1_16bit}                  , StackRelative

    implementation:
      cpu.A = foobar
