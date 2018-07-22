# Copyright (c) 2018 Mamy André-Ratsimbazafy
# Distributed under the Apache v2 License (license terms are at http://www.apache.org/licenses/LICENSE-2.0).

import ./datatypes

# Note, for implementation we don't respect the:
#  - Ecc1_m16bit - Add 1 cycle if Accumulator is accessed in 16-bit mode
#  - Ecc2_m16bit - Add 2 cycles if Accumulator is accessed in 16-bit mode
#  - Ecc1_xy16bit - Add 1 cycle if Index Register is accessed in 16-bit mode
# We follow the rule of thumb: 8-byte access = 1 cpu cycle
# Opcode implementations should take care that
# implementation cycles = theoretical cycles + modifiers

func immediate*(sys: Sys, ecc: static[ExtraCycleCosts]): uint16 {.inline.}=
  result.lo = sys.mem[sys.cpu.regs.pc + 1]
  inc sys.cpu.cycles

  # If it's an Immediate Accumulator and Accum is in 8-bit mode, return
  when {Ecc1_m16bit, Ecc2_m16bit} * ecc != {}:
    if sys.cpu.regs.P.accum8bit:
      return

  # If it's an Immediate Index and Index is in 8-bit mode, return
  when Ecc1_xy16bit in ecc:
    if sys.cpu.regs.P.index8bit:
      return

  result.hi = sys.mem[sys.cpu.regs.pc + 2]
  inc sys.cpu.cycles
