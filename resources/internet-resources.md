## VM resources

| Description                                            | Link                                                                                  |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------- |
| Nim VM (register based)                                | https://github.com/nim-lang/Nim/blob/devel/compiler/vm.nim                            |
|                                                        | https://github.com/felipensp/libvm                                                    |
|                                                        | https://github.com/GeneralNote/BlueVM                                                 |
|                                                        | https://github.com/jakogut/tinyvm                                                     |
|                                                        | https://github.com/dylanhross/C16_VM                                                  |
|                                                        | https://github.com/andrew-jacobs/emu816                                               |
|                                                        |                                                                                       |



## SNES resources

| Description                                            | Link                                                                                  |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------- |
| Super Famicom development wiki (SFDW)                  | https://wiki.superfamicom.org/                                                        |
| SFDW - instructions reference                          | https://wiki.superfamicom.org/65816-reference                                         |
| Kafuka board - 65816 ASM                               | http://acmlm.kafuka.org/board/thread.php?id=99.                                       |
| 6502.org - resource list                               | http://6502.org/tutorials/                                                            |
| 6502.org - opcode list                                 | http://6502.org/tutorials/65c816opcodes.html                                          |
| Emulator 101 - Opcode, addressing and timing reference | https://github.com/kpmiller/emulator101/blob/master/Generate6502Reference/6502ops.csv |
| Nesdev - Programmer's manual                           | https://wiki.nesdev.com/w/images/7/76/Programmanual.pdf                               |
|                                                        | https://github.com/michielvoo/SNES/wiki/CPU                                           |
| Yoshi's Snes in-depth technical doc                    | https://patpend.net/technical/snes/snes.txt                                           |
|                                                        | http://softpixel.com/~cwright/sianse/docs/65816NFO.HTM                                |
|                                                        | https://github.com/andrew-jacobs/emu816                                               |
|                                                        |                                                                                       |


## Interpreter optimization (from https://github.com/mratsim/chirp8/blob/master/research/interpreter_optimization.md)

| Description                                                                                                                                                                                                                 | Link                                                                                                                    |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| Design of a bytecode interpreter, including Stack vs Register, how to represent values (single type, tagged unions, untagged union, interface/virtual function)                                                             | http://gameprogrammingpatterns.com/bytecode.html                                                                        |
| Writing a fast interpreter: control-flow graph optimization from LuaJIT author                                                                                                                                              | http://lua-users.org/lists/lua-l/2011-02/msg00742.html                                                                  |
| In-depth dive on how to write an emulator                                                                                                                                                                                   | http://fms.komkon.org/EMUL8/HOWTO.html                                                                                  |
| Review of interpreter dispatch strategies to limit branch mispredictions: direct threaded code vs indirect threaded code vs token threaded code vs switch based dispatching vs replicated switch dispatching + Bibliography | http://realityforge.org/code/virtual-machines/2011/05/19/interpreters.html                                              |
| Fast VMs without assembly - speeding up the interpreter loop: threaded interpreter, duff's device, JIT, Nostradamus distributor                                                                                             | http://www.emulators.com/docs/nx25_nostradamus.htm                                                                      |
| Switch case vs Table vs Function caching/dynarec                                                                                                                                                                            | http://ngemu.com/threads/switch-case-vs-function-table.137562/                                                          |
| Dynamic recompilation introduction                                                                                                                                                                                          | http://ngemu.com/threads/dynamic-recompilation-an-introduction.20491/                                                   |
| Dynamic recompilation guide with Chip8                                                                                                                                                                                      | https://github.com/marco9999/Dynarec_Guide/blob/master/Introduction%20to%20Dynamic%20Recompilation%20in%20Emulation.pdf |
| Dynamic recompilation - accompanying source code                                                                                                                                                                            | https://github.com/marco9999/Super8_jitcore/                                                                            |
| Jump tables vs Switch                                                                                                                                                                                                       | http://www.cipht.net/2017/10/03/are-jump-tables-always-fastest.html                                                     |
| Paper: branch prediction and the performance of Interpreters - Don't trust the folklore                                                                                                                                     | https://hal.inria.fr/hal-01100647/document                                                                              |
| Presentation: Interpretation (basic indirect and direct threaded) vs binary translation                                                                                                                                     | http://www.ittc.ku.edu/~kulkarni/teaching/EECS768/slides/chapter2.pdf                                                   |
| Threaded interpretation vs Dynarec                                                                                                                                                                                          | http://www.emutalk.net/threads/55275-Threaded-interpretation-vs-Dynamic-Binary-Translation                              |
| Dynamic recompilation wiki                                                                                                                                                                                                  | http://emulation.gametechwiki.com/index.php/Dynamic_recompilation                                                       |
| Paper by author of ANTLR: The Structure and Performance of Efficient Interpreters                                                                                                                                           | https://www.jilp.org/vol5/v5paper12.pdf                                                                                 |
| Paper by author of ANTLR introducing dynamic replication: Optimizing Indirect Branch Prediction Accuracy in Virtual Machine Interpreter                                                                                     | https://www.scss.tcd.ie/David.Gregg/papers/toplas05.pdf                                                                 |
| Benchmarking VM Dispatch strategies in Rust: Switch vs unrolled switch vs tail call dispatch vs Computed Gotos                                                                                                              | https://pliniker.github.io/post/dispatchers/                                                                            |
| Computed Gotos for fast dispatching in Python                                                                                                                                                                               | https://github.com/python/cpython/blob/9d6171ded5c56679bc295bacffc718472bcb706b/Python/ceval.c#L571-L608                |
