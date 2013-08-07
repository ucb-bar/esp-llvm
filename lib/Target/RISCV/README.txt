//===---------------------------------------------------------------------===//
// Random notes about and ideas for the RISC-V backend.
//===---------------------------------------------------------------------===//
TODO:
-Sometimes values are loaded to x0
-trap on illegal shamt
-AUIPC does not work due to PCRel 
-Check on encoding functions
-Check loads/stores select operator for addr, should probably be more like ARMs (see ARMISelDAGToDAG.cpp:525)
