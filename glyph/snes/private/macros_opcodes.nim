# Copyright (c) 2018 Mamy André-Ratsimbazafy
# Distributed under the Apache v2 License (license terms are at http://www.apache.org/licenses/LICENSE-2.0).

import macros, strformat, strutils, tables, ../datatypes

when defined(glyphdebug):
  import strutils

macro genOpcTable*(opcs: untyped): untyped =
  # Usage:
  # ------
  #   genOpcTable:
  #     op lda: # LDA Load the Accumulator with Memory
  #       0xA1: cycles 6, {Ecc1_16bit, EccCrossBoundary}, DirectXIndirect
  #       0xA3: cycles 4, {Ecc1_16bit}                  , StackRelative
  #
  #       implementation:
  #         cpu.A = foobar

  # Parsed AST
  # ----------
  #   StmtList
  #     Command
  #       Ident "op"
  #       Ident "lda"
  #       StmtList
  #         Call
  #           IntLit 161
  #           StmtList
  #             Command
  #               Ident "cycles"
  #               IntLit 6
  #               Curly
  #                 Ident "Ecc1_16bit"
  #                 Ident "EccCrossBoundary"
  #               Ident "DirectXIndirect"
  #         Call
  #           IntLit 163
  #           StmtList
  #             Command
  #               Ident "cycles"
  #               IntLit 4
  #               Curly
  #                 Ident "Ecc1_16bit"
  #               Ident "StackRelative"
  #         Call
  #           Ident "implementation"
  #           StmtList
  #             Asgn
  #               DotExpr
  #                 Ident "cpu"
  #                 Ident "A"
  #               Ident "foobar"

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
      let hasKey = opcTable.hasKeyOrPut(opcode, opcParams)
      if hasKey:
        let usedBy = opcTable[opcode].name
        error &"Tried to insert opcode 0x{opcode.toHex(2)} for {name}. It is already used by {usedBy} instruction."

  # Reorder by opcode value
  opcTable.sort(proc(x, y: tuple[key: int, val: OpcParams]):int = cmp(x.key, y.key))

  when defined(glyphdebug):
    for k, v in opcTable.pairs:
      echo "0x" & k.toHex(2) & " - " & v.name
