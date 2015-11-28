Low Level Virtual Machine (LLVM)
======================================================

This directory and its subdirectories contain source code for the Low Level
Virtual Machine, a toolkit for the construction of highly optimized compilers,
optimizers, and runtime environments.

LLVM is open source software. You may freely distribute it under the terms of
the license agreement found in `LICENSE.txt`.

Please see the documentation provided in `docs/` for further
assistance with LLVM, and in particular `docs/GettingStarted.rst` for getting
started with LLVM and `docs/README.txt` for an overview of LLVM's
documentation setup.

If you're writing a package for LLVM, see `docs/Packaging.rst` for our
suggestions.


RISC-V LLVM Support [![Build Status](https://travis-ci.org/riscv/riscv-llvm.svg?branch=riscv-trunk)](https://travis-ci.org/riscv/riscv-llvm)
--------------------------------------------------------

Author  : Colin Schmidt (colins@eecs.berkeley.edu)  
Date    : February 24, 2014  
Version : (under version control)  


This repository contains a new target for LLVM RISC-V. It supports the latest
version of the ISA 2.0. This backend currently only supports assembly generation
and riscv64-unknown-\*-gcc must be used to assemble and link the executable. The
[RISCV](https://github.com/riscv/riscv-llvm/tree/RISCV) branch is based on LLVM 3.3 and, the 
[riscv-trunk](https://github.com/riscv/riscv-llvm/tree/riscv-trunk) branch is following upstream LLVM master.

The backend is structured similarly to most other LLVM backends and tries to use 
the tablegen format as much as possible. The description of the instructions
are found in `RISCVInstFormats.td`, and `RISCVInstrInfo*.td`. The registers are 
described in `RISCVRegisterInfo.td` and the calling convention is described in
`RISCVCallingConv.td`.

The instructions are defined using the LLVM IR DAG format, and simple 
instructions that use pre-existing LLVM IR operations should be very easy to
add. The instructions are divided into separate files based on their extension,
e.g. atomic operations are defined in `RISCVInstInfoA.td`. Instructions 
implemented with these patterns are simply matched against the programs LLVM IR
DAG for selection. More complicated instructions can use C++ to perform custom
lowering of the LLVM IR in `RISCVISelLowering.cpp`. Combining of multiple LLVM IR
nodes into single target instructions is also possible using C++ in
the same file. In general `RISCVISelLowering.cpp` sets up the lowering based on
the ISA and the specific subtargets features. 

This backend does not include all features of a backend but is focused on 
generating assembly in an extensible way such that adding new ISA extensions
and using them should be relatively painless. As the RISC-V support develops
the backend may provide more features.

The compiler is fairly robust with similar performance to riscv64-unknown-\*-gcc, so it use
in any and all projects is encouraged.

Feedback and suggestions are welcome.

Installation
------------------------------------------------------------------

The LLVM RISCV backend is built just as the normal LLVM system.

	$ git clone -b RISCV https://github.com/riscv/riscv-llvm.git
	$ git submodule update --init
	$ mkdir build
	$ cd build
	$ ../configure --prefix=/opt/riscv --enable-targets=riscv
	$ make
	$ make install

Now if `/opt/riscv` is on your path you should be able to use clang and LLVM with
RISC-V support.

Use
--------------------------------------------------------------------

Using the llvm-riscv is fairly simple to build a full executable however you
need riscv-64-unknown-\*-gcc to do the assembling and linking. An example of compiling hello
world:

	$ cat hello.c
	#include <stdio.h>
	int main() {
	    printf("Hello World!\n");
	}
	$ clang -target riscv -mriscv=RV64IAMFD -S hello.c -o hello.S
	$ riscv-64-unknown-elf-gcc -o hello.riscv hello.S

