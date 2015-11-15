set(LLVM_TARGET_DEFINITIONS RISCV.td)

tablegen(LLVM RISCVGenAsmMatcher.inc -gen-asm-matcher)
tablegen(LLVM RISCVGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM RISCVGenCallingConv.inc -gen-callingconv)
tablegen(LLVM RISCVGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM RISCVGenMCCodeEmitter.inc -gen-emitter)
tablegen(LLVM RISCVGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM RISCVGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM RISCVGenSubtargetInfo.inc -gen-subtarget)
add_public_tablegen_target(RISCVCommonTableGen)

add_llvm_target(RISCVCodeGen
  RISCVAsmPrinter.cpp
  RISCVBranchSelector.cpp
  RISCVConstantPoolValue.cpp
  RISCVFrameLowering.cpp
  RISCVInstrInfo.cpp
  RISCVISelDAGToDAG.cpp
  RISCVISelLowering.cpp
  RISCVMachineFunctionInfo.cpp
  RISCVMCInstLower.cpp
  RISCVRegisterInfo.cpp
  RISCVSubtarget.cpp
  RISCVTargetMachine.cpp
  RISCVMachineFunctionInfo.cpp
  )

add_dependencies(LLVMRISCVCodeGen intrinsics_gen)

add_subdirectory(AsmParser)
add_subdirectory(InstPrinter)
add_subdirectory(TargetInfo)
add_subdirectory(MCTargetDesc)
