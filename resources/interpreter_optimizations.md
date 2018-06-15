# Interpreter optimization

You will find the latest research in [Nimbus interpreter optimization wiki.](https://github.com/status-im/nimbus/wiki/Interpreter-optimization-resources)

## Pure interpreter

* Threading techniques for Forth (indirect, Direct, Token, Switch, Call, Segment threading)                                                                                                                                   - [link](http://www.complang.tuwien.ac.at/forth/threaded-code.html#call-threading)
* Benchmark of interpreter dispatch techniques for Forth on x86, PPC, MIPS, SPARC, Itanium and ARM                                                                                                                            - [link](http://www.complang.tuwien.ac.at/forth/threading/)
* PhD Thesis: Virtual machine Showdown: Stack vs Registers, with review of ALL interpreter dispatch techniques                                                                                                                - [link](https://www.scss.tcd.ie/publications/tech-reports/reports.07/TCD-CS-2007-49.pdf)
* Basic overview of computed gotos                                                                                                                                                                                            - [link](https://eli.thegreenplace.net/2012/07/12/computed-goto-for-efficient-dispatch-tables)
* Optimizing direct threaded code by selective inlining (Paper from 1998 which includes JIT introduction with code!)                                                                                                          - [link](http://flint.cs.yale.edu/jvmsem/doc/threaded.ps)
* Design of a bytecode interpreter, including Stack vs Register, how to represent values (single type, tagged unions, untagged union, interface/virtual function)                                                             - [link](http://gameprogrammingpatterns.com/bytecode.html)
* Writing a fast interpreter: control-flow graph optimization from LuaJIT author                                                                                                                                              - [link](http://lua-users.org/lists/lua-l/2011-02/msg00742.html)
* In-depth dive on how to write an emulator                                                                                                                                                                                   - [link](http://fms.komkon.org/EMUL8/HOWTO.html)
* Review of interpreter dispatch strategies to limit branch mispredictions: direct threaded code vs indirect threaded code vs token threaded code vs switch based dispatching vs replicated switch dispatching + Bibliography - [link](http://realityforge.org/code/virtual-machines/2011/05/19/interpreters.html)
* Fast VMs without assembly - speeding up the interpreter loop: threaded interpreter, duff's device, JIT, Nostradamus distributor by the author of Bosch x86 emulator                                                         - [link](http://www.emulators.com/docs/nx25_nostradamus.htm)
* Switch case vs Table vs Function caching/dynarec                                                                                                                                                                            - [link](http://ngemu.com/threads/switch-case-vs-function-table.137562/)
* Jump tables vs Switch                                                                                                                                                                                                       - [link](http://www.cipht.net/2017/10/03/are-jump-tables-always-fastest.html)
* Paper: branch prediction and the performance of Interpreters - Don't trust the folklore                                                                                                                                     - [link](https://hal.inria.fr/hal-01100647/document)
* Paper by author of ANTLR: The Structure and Performance of Efficient Interpreters                                                                                                                                           - [link](https://www.jilp.org/vol5/v5paper12.pdf)
* Paper by author of ANTLR introducing dynamic replication: Optimizing Indirect Branch Prediction Accuracy in Virtual Machine Interpreter                                                                                     - [link](https://www.scss.tcd.ie/David.Gregg/papers/toplas05.pdf)
* Benchmarking VM Dispatch strategies in Rust: Switch vs unrolled switch vs tail call dispatch vs Computed Gotos                                                                                                              - [link](https://pliniker.github.io/post/dispatchers/)
* Computed Gotos for fast dispatching in the official CPython codebase                                                                                                                                                                               - [link](https://github.com/python/cpython/blob/9d6171ded5c56679bc295bacffc718472bcb706b/Python/ceval.c#L571-L608)

## JIT / Dynamic recompilation

* Simple portable JIT (x86, x64, ARM, PowerPC and MIPS) for Brainfuck using DynASM (by LuaJIT author) - [Link](http://blog.reverberate.org/2012/12/hello-jit-world-joy-of-simple-jits.html)
* Optimizing direct threaded code by selective inlining                                   - [link](http://flint.cs.yale.edu/jvmsem/doc/threaded.ps)
* Dynamic recompilation introduction                                                      - [link](http://ngemu.com/threads/dynamic-recompilation-an-introduction.20491/)
* Dynamic recompilation guide with Chip8                                                  - [link](https://github.com/marco9999/Dynarec_Guide/blob/master/Introduction%20to%20Dynamic%20Recompilation%20in%20Emulation.pdf)
* Dynamic recompilation - accompanying source code                                        - [link](https://github.com/marco9999/Super8_jitcore/)
* Presentation: Interpretation (basic indirect and direct threaded) vs binary translation - [link](http://www.ittc.ku.edu/~kulkarni/teaching/EECS768/slides/chapter2.pdf)
* Threaded interpretation vs Dynarec                                                      - [link](http://www.emutalk.net/threads/55275-Threaded-interpretation-vs-Dynamic-Binary-Translation)
* Dynamic recompilation wiki                                                              - [link](http://emulation.gametechwiki.com/index.php/Dynamic_recompilation)

## Context Threading

Context threading is a promising alternative to Direct/Indirect/Call/Token/Subroutine/Switch threading
that makes interpretation nice with the hardware branch predictor. Practical implementation wanted:

  - [Web version of the thesis by Zalewski](http://www.cs.toronto.edu/~matz/dissertation/matzDissertation-latex2html/node7.html)
  - [Paper](http://www.cs.toronto.edu/~matz/pubs/demkea_context.pdf)
  - [Powerpoint](https://webdocs.cs.ualberta.ca/~amaral/cascon/CDP05/slides/CDP05-berndl.pdf)
  - [Review / Critic](https://www.complang.tuwien.ac.at/anton/lvas/sem06w/fest.pdf)
  - Cited and reviewed in [Virtual Machine Showdown PhD Thesis](https://www.scss.tcd.ie/publications/tech-reports/reports.07/TCD-CS-2007-49.pdf)

Basically, instead of computed goto, you have computed "call" and each section called is ended by
the ret (return) instruction. Note that it the address called is still inline, there is no parameter pushed on the stack.

The trick is that CPU has the following types of predictors:

- Linear or straight-line code
- Conditional branches
- Calls and Returns
- Indirect branches

But direct threaded code / computed goto only makes use of indirect branches (goto). Context Threading seems to reduce
cache misses by up to 95% by exploiting all those predictors. However it requires assembly as there is no way to generate
arbitrary call and ret instructions.

## Codebases

- [Bochs x86 emulator](https://sourceforge.net/projects/bochs/)
  - [Virtualization without Execution: Designing a portable VM - Powerpoint](http://bochs.sourceforge.net/VirtNoJit.pdf)
  - [Virtualization without Execution - Paper](http://bochs.sourceforge.net/Virtualization_Without_Hardware_Final.pdf)
  - Author is also the author of the Nostradamus Distributor linked in pure interpreter optimizations
- MorphoVM
  - Thesis: [Morpho VM: An Indirect Threaded Stackless
Virtual Machine](https://skemman.is/bitstream/1946/4809/1/hhg-bs.pdf)

## Nim implementation benchmark

```Nim
import random, sequtils, times

type
  Op = enum
    Halt # = 0x0000
    Inc  # = 0x0100
    Dec  # = 0x0110
    Mul2 # = 0x0230
    Div2 # = 0x0240
    Add7 # = 0x0307
    Neg  # = 0x0400

func interp_switch(code: seq[Op], initVal: int): int =

  var
    pc = 0
  result = initVal

  while true:
    case code[pc]:
    of Halt:
      return
    of Inc:
      inc pc
      inc result
    of Dec:
      inc pc
      dec result
    of Mul2:
      inc pc
      result *= 2
    of Div2:
      inc pc
      result = result div 2
    of Add7:
      inc pc
      inc result, 7
    of Neg:
      inc pc
      result = -result

#################################################################################################################

func interp_cgoto(code: seq[Op], initVal: int): int =
  # Requires a dense enum
  var
    pc = 0
  result = initVal

  while true:
    {.computedGoto.}
    let instr = code[pc]
    case instr:
    of Halt:
      return
    of Inc:
      inc pc
      inc result
    of Dec:
      inc pc
      dec result
    of Mul2:
      inc pc
      result *= 2
    of Div2:
      inc pc
      result = result div 2
    of Add7:
      inc pc
      inc result, 7
    of Neg:
      inc pc
      result = -result

#################################################################################################################

func halt(result: var int, stop: var bool) {.inline, nimcall.}=
  stop = true

func inc(result: var int, stop: var bool) {.inline, nimcall.}=
  inc result

func dec(result: var int, stop: var bool) {.inline, nimcall.}=
  dec result

func mul2(result: var int, stop: var bool) {.inline, nimcall.}=
  result *= 2

func div2(result: var int, stop: var bool) {.inline, nimcall.}=
  result = result div 2

func add7(result: var int, stop: var bool) {.inline, nimcall.}=
  inc result, 7

func neg(result: var int, stop: var bool) {.inline, nimcall.}=
  result = -result

# Requires dense enum
type InstrF = proc (result: var int, stop: var bool){.inline, nimcall, noSideEffect, gcsafe, locks: 0.}

type FuncTable = array[Op, InstrF]

const funcTable: FuncTable = [
  Halt: halt,
  Inc: inc,
  Dec: dec,
  Mul2: mul2,
  Div2: div2,
  Add7: add7,
  Neg: neg
]

proc interp_ftable(code: seq[Op], initVal: int): int =
  # Requires dense enum
  var
    pc = 0
    stop = false
  result = initVal

  while not stop:
    funcTable[code[pc]](result, stop)
    inc pc

#################################################################################################################

type
  InstrNext = proc (val: var int, code: seq[Op], pc: var int, stop: var bool): OpH {.inline, nimcall.}

  OpH = ref object
    handler: InstrNext

  FuncTableNext = array[Op, OpH]

proc halt(val: var int, code: seq[Op], pc: var int, stop: var bool): OpH {.inline, nimcall.}
proc inc(val: var int, code: seq[Op], pc: var int, stop: var bool): OpH {.inline, nimcall.}
proc dec(val: var int, code: seq[Op], pc: var int, stop: var bool): OpH {.inline, nimcall.}
proc mul2(val: var int, code: seq[Op], pc: var int, stop: var bool): OpH {.inline, nimcall.}
proc div2(val: var int, code: seq[Op], pc: var int, stop: var bool): OpH {.inline, nimcall.}
proc add7(val: var int, code: seq[Op], pc: var int, stop: var bool): OpH {.inline, nimcall.}
proc neg(val: var int, code: seq[Op], pc: var int, stop: var bool): OpH {.inline, nimcall.}

let funcTableNext: FuncTableNext = [
  Halt: OpH(handler: halt),
  Inc: OpH(handler: inc),
  Dec: OpH(handler: dec),
  Mul2: OpH(handler: mul2),
  Div2: OpH(handler: div2),
  Add7: OpH(handler: add7),
  Neg: OpH(handler: neg)
]

proc halt(val: var int, code: seq[Op], pc: var int, stop: var bool): OpH {.inline, nimcall.}=
  stop = true

proc inc(val: var int, code: seq[Op], pc: var int, stop: var bool): OpH {.inline, nimcall.}=

  inc val
  inc pc
  result = funcTableNext[code[pc]]

proc dec(val: var int, code: seq[Op], pc: var int, stop: var bool): OpH {.inline, nimcall.}=
  dec val
  inc pc
  result = funcTableNext[code[pc]]

proc mul2(val: var int, code: seq[Op], pc: var int, stop: var bool): OpH {.inline, nimcall.}=
  val *= 2
  inc pc
  result = funcTableNext[code[pc]]

proc div2(val: var int, code: seq[Op], pc: var int, stop: var bool): OpH {.inline, nimcall.}=
  val = val div 2
  inc pc
  result = funcTableNext[code[pc]]

proc add7(val: var int, code: seq[Op], pc: var int, stop: var bool): OpH {.inline, nimcall.}=
  inc val, 7
  inc pc
  result = funcTableNext[code[pc]]

proc neg(val: var int, code: seq[Op], pc: var int, stop: var bool): OpH {.inline, nimcall.}=
  val = -val
  inc pc
  result = funcTableNext[code[pc]]

proc interp_handlers(code: seq[Op], initVal: int): int =
  # Requires dense enum
  var
    pc = 0
    stop = false
    oph = funcTableNext[code[pc]]
  result = initVal

  while not stop:
    oph = oph.handler(result, code, pc, stop)

#################################################################################################################

type
  OpD = ref object {.inheritable.}

  Ohalt {.final.}= ref object of OpD
  Oinc {.final.}= ref object of OpD
  Odec {.final.}= ref object of OpD
  Omul2 {.final.}= ref object of OpD
  Odiv2 {.final.}= ref object of OpD
  Oadd7 {.final.}= ref object of OpD
  Oneg {.final.}= ref object of OpD

  FuncTableToken = array[Op, OpD]

method execute(op: OpD, result: var int, stop: var bool) {.base, inline, noSideEffect.} =
  raise newException(ValueError, "To override")

method execute(op: Ohalt, result: var int, stop: var bool) {.inline, noSideEffect.}=
  stop = true

method execute(op: Oinc, result: var int, stop: var bool) {.inline, noSideEffect.}=
  inc result

method execute(op: Odec, result: var int, stop: var bool) {.inline, noSideEffect.}=
  dec result

method execute(op: Omul2, result: var int, stop: var bool) {.inline, noSideEffect.}=
  result *= 2

method execute(op: Odiv2, result: var int, stop: var bool) {.inline, noSideEffect.}=
  result = result div 2

method execute(op: Oadd7, result: var int, stop: var bool) {.inline, noSideEffect.}=
  inc result, 7

method execute(op: Oneg, result: var int, stop: var bool) {.inline, noSideEffect.}=
  result = -result

let funcTableToken: FuncTableToken = [
  Halt: Ohalt(),
  Inc: Oinc(),
  Dec: Odec(),
  Mul2: Omul2(),
  Div2: Odiv2(),
  Add7: Oadd7(),
  Neg: Oneg()
]

proc interp_methods(code: seq[Op], initVal: int): int =
  # Requires dense enum
  var
    pc = 0
    stop = false
    opt: OpD
  result = initVal

  while not stop:
    opt = funcTableToken[code[pc]]
    opt.execute(result, stop)
    inc pc

#################################################################################################################

import random, sequtils, times, os, strutils, strformat

const Nb_Instructions = 1_000_000_000

template bench(impl: untyped) =
  let start = cpuTime()
  let r = impl(instructions, n)
  let stop = cpuTIme()
  let elapsed = stop - start
  echo "result: " & $r
  let procname = impl.astToStr
  let mips = (Nb_Instructions.float / (1_000_000.0 * elapsed))
  echo procname & " took " & $elapsed & "s for " & $Nb_Instructions & " instructions: " & $mips & " Mips (M instructions/s)"

proc main(n: int)=
  randomize(42)

  let ops = [Inc, Dec, Mul2, Div2, Add7, Neg]
  let instructions = newSeqWith(Nb_Instructions, rand(ops)) & Halt

  bench(interp_switch)
  bench(interp_cgoto) # requires dense enum (no holes)
  bench(interp_ftable) # requires dense enum (no holes) or tables (instead of arrays)
  bench(interp_handlers) # requires dense enum (no holes) or tables (instead of arrays)
  bench(interp_methods) # requires dense enum (no holes) or tables (instead of arrays)

# Warmup
var start = cpuTime()
block:
  var foo = 123
  for i in 0 ..< 1_000_000_000:
    foo += i*i mod 456
    foo = foo mod 789

# Compiler shouldn't optimize away the results as cpuTime rely on sideeffects
var stop = cpuTime()
echo "Warmup: " & $(stop - start) & "s"

# Main loop
let arguments = commandLineParams()
let initial = if arguments.len > 0: parseInt($arguments[0])
              else: 1

main(initial)

## Results on i5-5257U (Broadwell mobile dual core 2.7 turbo 3.1Ghz)
# Note that since Haswell, Intel CPU are significantly improed on Switch prediction
# This probably won't carry to ARM devices

# Warmup: 4.081501s
# result: -14604293096444
# interp_switch took 8.604712000000003s for 1000000000 instructions: 116.2153945419672 Mips (M instructions/s)
# result: -14604293096444
# interp_cgoto took 7.367597000000004s for 1000000000 instructions: 135.7294651159665 Mips (M instructions/s)
# result: -201628509198920 <--- some bug here to fix
# interp_ftable took 8.957571000000002s for 1000000000 instructions: 111.6374070604631 Mips (M instructions/s)
# result: -14604293096444
# interp_handlers took 11.039072s for 1000000000 instructions: 90.58732473164413 Mips (M instructions/s)
# result: -14604293096444
# interp_methods took 23.359635s for 1000000000 instructions: 42.80888806695823 Mips (M instructions/s)
```
