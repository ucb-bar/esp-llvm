add_llvm_library(LLVMRISCVDesc
  RISCVMCAsmBackend.cpp
  RISCVMCAsmInfo.cpp
  RISCVMCCodeEmitter.cpp
  RISCVMCExpr.cpp
  RISCVMCObjectWriter.cpp
  RISCVMCTargetDesc.cpp
  )

add_dependencies(LLVMRISCVDesc RISCVCommonTableGen)
