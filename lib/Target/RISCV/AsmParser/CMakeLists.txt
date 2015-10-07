include_directories( ${CMAKE_CURRENT_BINARY_DIR}/.. ${CMAKE_CURRENT_SOURCE_DIR}/.. )

add_llvm_library(LLVMRISCVAsmParser
  RISCVAsmParser.cpp
  )

add_dependencies(LLVMRISCVAsmParser RISCVCommonTableGen)
