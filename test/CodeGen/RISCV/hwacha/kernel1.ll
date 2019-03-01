

; === launchTest
; Creating constant: t2: i64 = TargetConstant<0>
; Creating new node: t3: ch,glue = callseq_start t0, TargetConstant:i64<0>, TargetConstant:i64<0>
; Stack dump:
; 0.      Program arguments: llc -mtriple=riscv64 -debug ../../esp-llvm/test/CodeGen/RISCV/hwacha/kernel1.ll 
; 1.      Running pass 'Function Pass Manager' on module '../../esp-llvm/test/CodeGen/RISCV/hwacha/kernel1.ll'.
; 2.      Running pass 'RISCV DAG->DAG Pattern Instruction Selection' on function '@launchTest'
;  #0 0x00000000023ec5a5 llvm::sys::PrintStackTrace(llvm::raw_ostream&) /scratch/pranavprakash/upstream_fork/esp-llvm/lib/Support/Unix/Signals.inc:494:0
;  #1 0x00000000023ec638 PrintStackTraceSignalHandler(void*) /scratch/pranavprakash/upstream_fork/esp-llvm/lib/Support/Unix/Signals.inc:558:0
;  #2 0x00000000023ea560 llvm::sys::RunSignalHandlers() /scratch/pranavprakash/upstream_fork/esp-llvm/lib/Support/Signals.cpp:68:0
;  #3 0x00000000023ebfa0 SignalHandler(int) /scratch/pranavprakash/upstream_fork/esp-llvm/lib/Support/Unix/Signals.inc:357:0
;  #4 0x00007f5829ccd390 __restore_rt (/lib/x86_64-linux-gnu/libpthread.so.0+0x11390)
;  #5 0x0000000001be0168 llvm::NamedMDNode::getNumOperands() const /scratch/pranavprakash/upstream_fork/esp-llvm/lib/IR/Metadata.cpp:1077:0
;  #6 0x00000000010d4ff5 llvm::RISCVTargetLowering::LowerCall(llvm::TargetLowering::CallLoweringInfo&, llvm::SmallVectorImpl<llvm::SDValue>&) const /scratch/pranavprakash/upstream_fork/esp-llvm/lib/Target/RISCV/RISCVISelLowering.cpp:1730:0
;  #7 0x00000000021b4b57 llvm::TargetLowering::LowerCallTo(llvm::TargetLowering::CallLoweringInfo&) const /scratch/pranavprakash/upstream_fork/esp-llvm/lib/CodeGen/SelectionDAG/SelectionDAGBuilder.cpp:8811:0
;  #8 0x00000000021a8f85 llvm::SelectionDAGBuilder::lowerInvokable(llvm::TargetLowering::CallLoweringInfo&, llvm::BasicBlock const*) /scratch/pranavprakash/upstream_fork/esp-llvm/lib/CodeGen/SelectionDAG/SelectionDAGBuilder.cpp:6675:0
;  #9 0x00000000021a988e llvm::SelectionDAGBuilder::LowerCallTo(llvm::ImmutableCallSite, llvm::SDValue, bool, llvm::BasicBlock const*) /scratch/pranavprakash/upstream_fork/esp-llvm/lib/CodeGen/SelectionDAG/SelectionDAGBuilder.cpp:6788:0
; #10 0x00000000021ac364 llvm::SelectionDAGBuilder::visitCall(llvm::CallInst const&) /scratch/pranavprakash/upstream_fork/esp-llvm/lib/CodeGen/SelectionDAG/SelectionDAGBuilder.cpp:7335:0
; #11 0x0000000002182782 llvm::SelectionDAGBuilder::visit(unsigned int, llvm::User const&) /scratch/pranavprakash/upstream_fork/esp-llvm/include/llvm/IR/Instruction.def:209:0
; #12 0x00000000021820a6 llvm::SelectionDAGBuilder::visit(llvm::Instruction const&) /scratch/pranavprakash/upstream_fork/esp-llvm/lib/CodeGen/SelectionDAG/SelectionDAGBuilder.cpp:1080:0
; #13 0x000000000224560d llvm::SelectionDAGISel::SelectBasicBlock(llvm::ilist_iterator<llvm::ilist_detail::node_options<llvm::Instruction, true, false, void>, false, true>, llvm::ilist_iterator<llvm::ilist_detail::node_options<llvm::Instruction, true, false, void>, false, true>, bool&) /scratch/pranavprakash/upstream_fork/esp-llvm/lib/CodeGen/SelectionDAG/SelectionDAGISel.cpp:686:0
; #14 0x000000000224b41a llvm::SelectionDAGISel::SelectAllBasicBlocks(llvm::Function const&) /scratch/pranavprakash/upstream_fork/esp-llvm/lib/CodeGen/SelectionDAG/SelectionDAGISel.cpp:1817:0
; #15 0x0000000002244380 llvm::SelectionDAGISel::runOnMachineFunction(llvm::MachineFunction&) /scratch/pranavprakash/upstream_fork/esp-llvm/lib/CodeGen/SelectionDAG/SelectionDAGISel.cpp:497:0
; #16 0x00000000010c43dd (anonymous namespace)::RISCVDAGToDAGISel::runOnMachineFunction(llvm::MachineFunction&) /scratch/pranavprakash/upstream_fork/esp-llvm/lib/Target/RISCV/RISCVISelDAGToDAG.cpp:43:0
; #17 0x00000000016ac102 llvm::MachineFunctionPass::runOnFunction(llvm::Function&) /scratch/pranavprakash/upstream_fork/esp-llvm/lib/CodeGen/MachineFunctionPass.cpp:73:0
; #18 0x0000000001bb9ea7 llvm::FPPassManager::runOnFunction(llvm::Function&) /scratch/pranavprakash/upstream_fork/esp-llvm/lib/IR/LegacyPassManager.cpp:1643:0
; #19 0x0000000001bba119 llvm::FPPassManager::runOnModule(llvm::Module&) /scratch/pranavprakash/upstream_fork/esp-llvm/lib/IR/LegacyPassManager.cpp:1678:0
; #20 0x0000000001bba50e (anonymous namespace)::MPPassManager::runOnModule(llvm::Module&) /scratch/pranavprakash/upstream_fork/esp-llvm/lib/IR/LegacyPassManager.cpp:1743:0
; #21 0x0000000001bbac8d llvm::legacy::PassManagerImpl::run(llvm::Module&) /scratch/pranavprakash/upstream_fork/esp-llvm/lib/IR/LegacyPassManager.cpp:1856:0
; #22 0x0000000001bbae93 llvm::legacy::PassManager::run(llvm::Module&) /scratch/pranavprakash/upstream_fork/esp-llvm/lib/IR/LegacyPassManager.cpp:1888:0
; #23 0x000000000105f7b2 compileModule(char**, llvm::LLVMContext&) /scratch/pranavprakash/upstream_fork/esp-llvm/tools/llc/llc.cpp:599:0
; #24 0x000000000105dddd main /scratch/pranavprakash/upstream_fork/esp-llvm/tools/llc/llc.cpp:350:0
; #25 0x00007f5828a2a830 __libc_start_main /build/glibc-Cl5G7W/glibc-2.23/csu/../csu/libc-start.c:325:0
; #26 0x000000000105bfa9 _start (llc+0x105bfa9)

define dso_local void @test() nounwind {
entry:
  ret void
}

define dso_local void @launchTest() {
    call void @test()
    ret void
}

!opencl.kernels = !{!0}
!0 = !{void ()* @test}