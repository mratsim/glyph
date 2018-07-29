# Copyright (c) 2018 Mamy André-Ratsimbazafy
# Distributed under the Apache v2 License (license terms are at http://www.apache.org/licenses/LICENSE-2.0).

import ./private/macros_opcodes, ./datatypes

genOpcTable:

  op ADC: # Add with Carry
    0x61: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectXIndirect
    0x63: cycles 4, {Ecc1_m16bit}                                       , StackRelative
    0x65: cycles 3, {Ecc1_m16bit, EccDirectLowNonZero}                  , Direct
    0x67: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirectLong
    0x69: cycles 2, {Ecc1_m16bit}                                       , Immediate
    0x6D: cycles 4, {Ecc1_m16bit}                                       , Absolute
    0x6F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLong
    0x71: cycles 5, {Ecc1_m16bit, EccDirectLowNonZero, EccCrossBoundary}, DirectIndirectY
    0x72: cycles 5, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirect
    0x73: cycles 7, {Ecc1_m16bit}                                       , StackRelativeIndirectY
    0x75: cycles 4, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectX
    0x77: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirectLongY
    0x79: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteY
    0x7D: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteX
    0x7F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLongX

    implementation:
      template adcImpl(sys: Sys, T: typedesc[uint8 or uint16], carry, overflow: var bool) =
        # Implement uint8 and uint16 mode

        template A {.dirty.} =
          # Alias for accumulator depending on mode
          when T is uint16: sys.cpu.regs.A
          else: sys.cpu.regs.A.lo

        func add(x, y: T, carry, overflow: var bool): T {.nimcall, inline.} =
          # Add function helper
          result = x + y
          carry = carry or result < x
          overflow =  overflow or
                      not(result.isMsbSet xor x.isMsbSet) or
                      not(result.isMsbSet xor y.isMsbSet)

        # Fetch data.
        # `addressingMode` and `extraCycleCosts` are injected by "implementation"
        let val = sys.`addressingMode`(T, `extraCycleCosts`{.inject.})

        # Computation
        # TODO: Decimal mode
        A = add(A, val, carry, overflow)
        A = add(A, T(P.carry), carry, overflow)

      # # # # # # # # # # # # # #

      var carry, overflow = false

      if P.emulation_mode:
        sys.adcImpl(uint8, carry, overflow)
      else:
        sys.adcImpl(uint16, carry, overflow)

      # Sets the flags
      P.carry    = carry
      P.overflow = overflow
      P.negative = A.isMsbSet
      P.zero     = A == 0

  op AND: # AND Accumulator with memory
    0x21: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectXIndirect
    0x23: cycles 4, {Ecc1_m16bit}                                       , StackRelative
    0x25: cycles 3, {Ecc1_m16bit, EccDirectLowNonZero}                  , Direct
    0x27: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirectLong
    0x29: cycles 2, {Ecc1_m16bit}                                       , Immediate
    0x2D: cycles 4, {Ecc1_m16bit}                                       , Absolute
    0x2F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLong
    0x31: cycles 5, {Ecc1_m16bit, EccDirectLowNonZero, EccCrossBoundary}, DirectIndirectY
    0x32: cycles 5, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirect
    0x33: cycles 7, {Ecc1_m16bit}                                       , StackRelativeIndirectY
    0x35: cycles 4, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectX
    0x37: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirectLongY
    0x39: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteY
    0x3D: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteX
    0x3F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLongX

    implementation:
      discard

  op ASL: # Arithmetic Shift Left
    0x06: cycles 5, {EccDirectLowNonZero, Ecc2_m16bit}                  , Direct
    0x0A: cycles 2, {}                                                  , Accumulator
    0x0E: cycles 6, {Ecc2_m16bit}                                       , Absolute
    0x16: cycles 6, {EccDirectLowNonZero, Ecc2_m16bit}                  , DirectX
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
    0x24: cycles 3, {Ecc1_m16bit, EccDirectNonZero}                    , Direct
    0x2C: cycles 4, {Ecc1_m16bit}                                      , Absolute
    0x34: cycles 4, {Ecc1_m16bit, EccDirectNonZero}                    , DirectX
    0x3C: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                    , AbsoluteX
    0x89: cycles 2, {Ecc1_m16bit}                                      , Immediate

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
    0x82: cycles 2, {}                                                 , ProgCountRelativeLong
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
    0xC1: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectXIndirect
    0xC3: cycles 4, {Ecc1_m16bit}                                       , StackRelative
    0xC5: cycles 3, {Ecc1_m16bit, EccDirectLowNonZero}                  , Direct
    0xC7: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirectLong
    0xC9: cycles 2, {Ecc1_m16bit}                                       , Immediate
    0xCD: cycles 4, {Ecc1_m16bit}                                       , Absolute
    0xCF: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLong
    0xD1: cycles 5, {Ecc1_m16bit, EccDirectLowNonZero, EccCrossBoundary}, DirectIndirectY
    0xD2: cycles 5, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirect
    0xD3: cycles 7, {Ecc1_m16bit}                                       , StackRelativeIndirectY
    0xD5: cycles 4, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectX
    0xD7: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirectLongY
    0xD9: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteY
    0xDD: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteX
    0xDF: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLongX

    implementation:
      discard

  op COP: # Co-Processor Enable
    0x02: cycles 7, {Ecc65816Native}                                    , Immediate

  op CPX: # Compare Index Register X with Memory
    0xE0: cycles 2, {Ecc1_xy16bit}                                      , Immediate
    0xE4: cycles 3, {EccDirectLowNonZero, Ecc1_xy16bit}                 , Direct
    0xEC: cycles 4, {Ecc1_xy16bit}                                      , Absolute

    implementation:
      discard

  op CPY: # Compare Index Register Y with Memory
    0xC0: cycles 2, {Ecc1_xy16bit}                                      , Immediate
    0xC4: cycles 3, {EccDirectLowNonZero, Ecc1_xy16bit}                 , Direct
    0xCC: cycles 4, {Ecc1_xy16bit}                                      , Absolute

    implementation:
      discard

  op DEC: # Decrement
    0x3A: cycles 2, {}                                                  , Accumulator
    0xC6: cycles 2, {EccDirectLowNonZero, Ecc2_m16bit}                  , Direct
    0xCE: cycles 6, {Ecc2_m16bit}                                       , Absolute
    0xD6: cycles 6, {EccDirectLowNonZero, Ecc2_m16bit}                  , DirectX
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
    0x41: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectXIndirect
    0x43: cycles 4, {Ecc1_m16bit}                                       , StackRelative
    0x45: cycles 3, {Ecc1_m16bit, EccDirectLowNonZero}                  , Direct
    0x47: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirectLong
    0x49: cycles 2, {Ecc1_m16bit}                                       , Immediate
    0x4D: cycles 4, {Ecc1_m16bit}                                       , Absolute
    0x4F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLong
    0x51: cycles 5, {Ecc1_m16bit, EccDirectLowNonZero, EccCrossBoundary}, DirectIndirectY
    0x52: cycles 5, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirect
    0x53: cycles 7, {Ecc1_m16bit}                                       , StackRelativeIndirectY
    0x55: cycles 4, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectX
    0x57: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirectLongY
    0x59: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteY
    0x5D: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteX
    0x5F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLongX

    implementation:
      discard

  op INC: # Increment
    0x1A: cycles 2, {}                                                  , Accumulator
    0xE6: cycles 2, {EccDirectLowNonZero, Ecc2_m16bit}                  , Direct
    0xEE: cycles 6, {Ecc2_m16bit}                                       , Absolute
    0xF6: cycles 6, {EccDirectLowNonZero, Ecc2_m16bit}                  , DirectX
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
    0xA1: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectXIndirect
    0xA3: cycles 4, {Ecc1_m16bit}                                       , StackRelative
    0xA5: cycles 3, {Ecc1_m16bit, EccDirectLowNonZero}                  , Direct
    0xA7: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirectLong
    0xA9: cycles 2, {Ecc1_m16bit}                                       , Immediate
    0xAD: cycles 4, {Ecc1_m16bit}                                       , Absolute
    0xAF: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLong
    0xB1: cycles 5, {Ecc1_m16bit, EccDirectLowNonZero, EccCrossBoundary}, DirectIndirectY
    0xB2: cycles 5, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirect
    0xB3: cycles 7, {Ecc1_m16bit}                                       , StackRelativeIndirectY
    0xB5: cycles 4, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectX
    0xB7: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirectLongY
    0xB9: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteY
    0xBD: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteX
    0xBF: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLongX

    implementation:
      discard

  op LDX: # Load Index Register X from Memory
    0xA2: cycles 2, {Ecc1_xy16bit}                                      , Immediate
    0xA6: cycles 3, {EccDirectLowNonZero, Ecc1_xy16bit}                 , Direct
    0xAE: cycles 4, {Ecc1_xy16bit}                                      , Absolute
    0xB6: cycles 4, {EccDirectLowNonZero, Ecc1_xy16bit}                 , DirectY
    0xBE: cycles 4, {EccCrossBoundary, Ecc1_xy16bit}                    , AbsoluteY

    implementation:
      discard

  op LDY: # Load Index Register Y from Memory
    0xA0: cycles 2, {Ecc1_xy16bit}                                      , Immediate
    0xA4: cycles 3, {EccDirectLowNonZero, Ecc1_xy16bit}                 , Direct
    0xAC: cycles 4, {Ecc1_xy16bit}                                      , Absolute
    0xB4: cycles 4, {EccDirectLowNonZero, Ecc1_xy16bit}                 , DirectX
    0xBC: cycles 4, {EccCrossBoundary, Ecc1_xy16bit}                    , AbsoluteX

    implementation:
      discard

  op LSR: # Logical Shift Memory or Accumulator Right
    0x46: cycles 5, {EccDirectLowNonZero, Ecc2_m16bit}                  , Direct
    0x4A: cycles 2, {}                                                  , Accumulator
    0x4E: cycles 6, {Ecc2_m16bit}                                       , Absolute
    0x56: cycles 6, {EccDirectLowNonZero, Ecc2_m16bit}                  , DirectX
    0x5E: cycles 7, {Ecc2_m16bit}                                       , AbsoluteX

    implementation:
      discard

  op MVN: # Block Move Negative
    0x54: cycles 1, {EccDirectLowNonZero}                               , BlockMove
    implementation:
      discard

  op MVP: # Block Move Positive
    0x44: cycles 1, {EccDirectLowNonZero}                               , BlockMove
    implementation:
      discard

  op NOP: # No Operation
    0xEA: cycles 2, {}                                                  , Implied
    implementation:
      discard

  op ORA: # OR Accumulator with Memory
    0x01: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectXIndirect
    0x03: cycles 4, {Ecc1_m16bit}                                       , StackRelative
    0x05: cycles 3, {Ecc1_m16bit, EccDirectLowNonZero}                  , Direct
    0x07: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirectLong
    0x09: cycles 2, {Ecc1_m16bit}                                       , Immediate
    0x0D: cycles 4, {Ecc1_m16bit}                                       , Absolute
    0x0F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLong
    0x11: cycles 5, {Ecc1_m16bit, EccDirectLowNonZero, EccCrossBoundary}, DirectIndirectY
    0x12: cycles 5, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirect
    0x13: cycles 7, {Ecc1_m16bit}                                       , StackRelativeIndirectY
    0x15: cycles 4, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectX
    0x17: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirectLongY
    0x19: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteY
    0x1D: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteX
    0x1F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLongX

    implementation:
      discard

  op PEA: # Push Effective Absolute Address
    0xF4: cycles 5, {}                                                  , Immediate
    implementation:
      discard

  op PEI: # Push Effective Indirect Address
    0xD4: cycles 6, {EccDirectLowNonZero}                               , Direct
    implementation:
      discard

  op PER: # Push Effective Absolute Address
    0x62: cycles 6, {}                                                  , Immediate
    implementation:
      discard

  op PHA: # Push Accumulator
    0x48: cycles 3, {Ecc1_m16bit}                                       , Immediate
    implementation:
      discard

  op PHB: # Push Data Bank Register
    0x8B: cycles 3, {}                                                  , Implied
    implementation:
      discard

  op PHD: # Push Direct Page Register
    0x0B: cycles 4, {}                                                  , Implied
    implementation:
      discard

  op PHK: # Push Program Bank Register
    0x4B: cycles 3, {}                                                  , Implied
    implementation:
      discard

  op PHP: # Push Processor Status Register
    0x08: cycles 3, {}                                                  , Implied
    implementation:
      discard

  op PHX: # Push Index Register X
    0xDA: cycles 3, {Ecc1_xy16bit}                                      , Implied
    implementation:
      discard

  op PHY: # Push Index Register Y
    0x5A: cycles 3, {Ecc1_xy16bit}                                      , Implied
    implementation:
      discard

  op PLA: # Pull Accumulator
    0x68: cycles 4, {Ecc1_m16bit}                                       , Implied
    implementation:
      discard

  op PLB: # Pull Data Bank Register
    0xAB: cycles 4, {}                                                  , Implied
    implementation:
      discard

  op PLD: # Pull Direct Page Register
    0x2B: cycles 5, {}                                                  , Implied
    implementation:
      discard

  op PLP: # Pull Processor Status Register
    0x28: cycles 4, {}                                                  , Implied
    implementation:
      discard

  op PLX: # Pull Index Register X
    0xFA: cycles 4, {Ecc1_xy16bit}                                      , Implied
    implementation:
      discard

  op PLY: # Pull Index Register Y
    0x7A: cycles 4, {Ecc1_xy16bit}                                      , Implied
    implementation:
      discard

  op REP: # Reset Processor Status Bits
    0xC2: cycles 3, {}                                                  , Immediate
    implementation:
      discard

  op ROL: # Rotate Memory or Accumulator Left
    0x26: cycles 5, {EccDirectLowNonZero, Ecc2_m16bit}                  , Direct
    0x2A: cycles 2, {}                                                  , Accumulator
    0x2E: cycles 6, {Ecc2_m16bit}                                       , Absolute
    0x36: cycles 6, {EccDirectLowNonZero, Ecc2_m16bit}                  , DirectX
    0x3E: cycles 7, {Ecc2_m16bit}                                       , AbsoluteX

    implementation:
      discard

  op ROR: # Rotate Memory or Accumulator Right
    0x66: cycles 5, {EccDirectLowNonZero, Ecc2_m16bit}                  , Direct
    0x6A: cycles 2, {}                                                  , Accumulator
    0x6E: cycles 6, {Ecc2_m16bit}                                       , Absolute
    0x76: cycles 6, {EccDirectLowNonZero, Ecc2_m16bit}                  , DirectX
    0x7E: cycles 7, {Ecc2_m16bit}                                       , AbsoluteX

    implementation:
      discard

  op RTI: # Return from Interrup
    0x40: cycles 6, {Ecc65816Native}                                    , Implied
    implementation:
      discard

  op RTL: # Return from Subroutine Long
    0x6B: cycles 6, {}                                                  , Implied
    implementation:
      discard

  op RTS: # Return from Subroutine
    0x60: cycles 6, {}                                                  , Implied
    implementation:
      discard

  op SBC: # Substract with Borrow from Accumulator
    0xE1: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectXIndirect
    0xE3: cycles 4, {Ecc1_m16bit}                                       , StackRelative
    0xE5: cycles 3, {Ecc1_m16bit, EccDirectLowNonZero}                  , Direct
    0xE7: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirectLong
    0xE9: cycles 2, {Ecc1_m16bit}                                       , Immediate
    0xED: cycles 4, {Ecc1_m16bit}                                       , Absolute
    0xEF: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLong
    0xF1: cycles 5, {Ecc1_m16bit, EccDirectLowNonZero, EccCrossBoundary}, DirectIndirectY
    0xF2: cycles 5, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirect
    0xF3: cycles 7, {Ecc1_m16bit}                                       , StackRelativeIndirectY
    0xF5: cycles 4, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectX
    0xF7: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirectLongY
    0xF9: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteY
    0xFD: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteX
    0xFF: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLongX

    implementation:
      discard

  op SEC: ## Set Carry Flag
    0x38: cycles 2, {}                                                  , Implied
    implementation:
      discard

  op SED: ## Set Decimal Flag
    0xF8: cycles 2, {}                                                  , Implied
    implementation:
      discard

  op SEI: ## Set Interrupt Flag
    0x78: cycles 2, {}                                                  , Implied
    implementation:
      discard

  op SEP: ## Reset Processor Status Bits
    0xE2: cycles 3, {}                                                  , Immediate
    implementation:
      discard

  op STA: # Store Accumulator to Memory
    0x81: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectXIndirect
    0x83: cycles 4, {Ecc1_m16bit}                                       , StackRelative
    0x85: cycles 3, {Ecc1_m16bit, EccDirectLowNonZero}                  , Direct
    0x87: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirectLong
    0x8D: cycles 4, {Ecc1_m16bit}                                       , Absolute
    0x8F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLong
    0x91: cycles 5, {Ecc1_m16bit, EccDirectLowNonZero, EccCrossBoundary}, DirectIndirectY
    0x92: cycles 5, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirect
    0x93: cycles 7, {Ecc1_m16bit}                                       , StackRelativeIndirectY
    0x95: cycles 4, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectX
    0x97: cycles 6, {Ecc1_m16bit, EccDirectLowNonZero}                  , DirectIndirectLongY
    0x99: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteY
    0x9D: cycles 4, {Ecc1_m16bit, EccCrossBoundary}                     , AbsoluteX
    0x9F: cycles 5, {Ecc1_m16bit}                                       , AbsoluteLongX

    implementation:
      discard

  op STP: ## Stop Processor
    0xDB: cycles 3, {Ecc3_reset}                                        , Implied
    implementation:
      discard

  op STX: ## Store Index Register X to Memory
    0x86: cycles 3, {EccDirectLowNonZero, Ecc1_xy16bit}                 , Direct
    0x8E: cycles 4, {Ecc1_xy16bit}                                      , Absolute
    0x96: cycles 4, {EccDirectLowNonZero, Ecc1_xy16bit}                 , DirectY

    implementation:
      discard

  op STY: ## Store Index Register X to Memory
    0x84: cycles 3, {EccDirectLowNonZero, Ecc1_xy16bit}                 , Direct
    0x8C: cycles 4, {Ecc1_xy16bit}                                      , Absolute
    0x94: cycles 4, {EccDirectLowNonZero, Ecc1_xy16bit}                 , DirectY

    implementation:
      discard

  op STZ: ## Store Zero to Memory
    0x64: cycles 3, {Ecc1_m16bit, EccDirectLowNonZero}                 , Direct
    0x74: cycles 4, {Ecc1_m16bit, EccDirectLowNonZero}                 , DirectX
    0x9C: cycles 4, {Ecc1_m16bit}                                      , Absolute
    0x9E: cycles 5, {Ecc1_m16bit}                                      , AbsoluteX

    implementation:
      discard

  op TAX: ## Transfer Accumulator to Index Register X
    0xAA: cycles 2, {}                                                 , Implied
    implementation:
      discard

  op TAY: ## Transfer Accumulator to Index Register X
    0xA8: cycles 2, {}                                                 , Implied
    implementation:
      discard

  op TCD: ## Transfer 16-bit Accumulator to Direct Page Register
    0x5B: cycles 2, {}                                                 , Implied
    implementation:
      discard

  op TCS: ## Transfer 16-bit Accumulator to Stack Pointer
    0x1B: cycles 2, {}                                                 , Implied
    implementation:
      discard

  op TDC: ## Transfer Direct Page Register to 16-bit Accumulator
    0x7B: cycles 2, {}                                                 , Implied
    implementation:
      discard

  op TRB: ## Test and Reset Memory Bits Against Accumulator
    0x14: cycles 5, {EccDirectLowNonZero, Ecc2_m16bit}                 , Direct
    0x1C: cycles 6, {EccCrossBoundary}                                 , Absolute
    implementation:
      discard

  op TSB: ## Test and Set Memory Bits Against Accumulator
    0x04: cycles 5, {EccDirectLowNonZero, Ecc2_m16bit}                 , Direct
    0x0C: cycles 6, {Ecc2_m16bit}                                      , Absolute
    implementation:
      discard

  op TSC: ## Transfer Stack Pointer to 16-bit Accumulator
    0x3B: cycles 2, {}                                                 , Implied
    implementation:
      discard

  op TSX: ## Transfer Stack pointer to Index Register X
    0xBA: cycles 2, {}                                                 , Implied
    implementation:
      discard

  op TXA: ## Transfer Stack pointer to Accumulator
    0x8A: cycles 2, {}                                                 , Implied
    implementation:
      discard

  op TXS: ## Transfer Index Register X to Stack pointer
    0x9A: cycles 2, {}                                                 , Implied
    implementation:
      discard

  op TXY: ## Transfer Index Register X to Index Register Y
    0x9B: cycles 2, {}                                                 , Implied
    implementation:
      discard

  op TYA: ## Transfer Index Register Y to Accumulator
    0x98: cycles 2, {}                                                 , Implied
    implementation:
      discard

  op TYX: ## Transfer Index Register Y to Index Register X
    0xBB: cycles 2, {}                                                 , Implied
    implementation:
      discard

  op WAI: ## Wait for Interrupt
    0xCB: cycles 3, {Ecc3_interrupt}                                   , Implied
    implementation:
      discard

  op WDM: ## Reserved for Future Expansion
    0x42: cycles 2, {}                                                 , Immediate
    implementation:
      discard

  op XBA: ## Exchange B and A 8-bit Accumulators
    0xEB: cycles 3, {}                                                 , Implied
    implementation:
      discard

  op XCE: ## Exchange Carry and Emulation Flags
    0xFB: cycles 2, {}                                                 , Implied
    implementation:
      discard
