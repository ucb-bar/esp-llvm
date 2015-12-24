//===- MachineScalarization.cpp - Scalarization analysis --------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
// Determines which MBB are convergent across elements and which MI are
// element-invariant
// Based on [Lee, CGO, 2013]
//===----------------------------------------------------------------------===//

#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineScalarization.h"
#include "llvm/CodeGen/MachineProgramDependenceGraph.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/Support/Debug.h"

#include <set>
#include <algorithm>

using namespace llvm;

char MachineScalarization::ID = 0;
INITIALIZE_PASS_BEGIN(MachineScalarization, "machinescalar",
                "Machine Scalarization Analysis", true, true)
INITIALIZE_PASS_DEPENDENCY(MachineProgramDependenceGraph)
INITIALIZE_PASS_END(MachineScalarization, "machinescalar",
                "Machine Scalarization Analysis", true, true)

char &llvm::MachineScalarizationID = MachineScalarization::ID;

void MachineScalarization::releaseMemory() {
  invar.clear();
  conv.clear();
}

MachineScalarization::~MachineScalarization() {
  releaseMemory();
}

void MachineScalarization::markAllCDChildren(const MachineBasicBlock* mbb, SmallVector<const MachineInstr*,128> worklist) {
  MachinePDGChildIterator child_itr = MachinePDGChildIterator(PDG->BBtoCDS.find(mbb)->second);
  MachinePDGChildIterator child_end = MachinePDGChildIterator(PDG->BBtoCDS.find(mbb)->second,true);
  for(;child_itr != child_end; child_itr++) {
    //TODO: check for opencl barrier call in thie mbb
    if(conv[(*child_itr)->bb]) {
      conv[(*child_itr)->bb] = false;
      const MachineBasicBlock *bb = (*child_itr)->bb;
      MachineBasicBlock::const_iterator MII = bb->begin();
      MachineBasicBlock::const_iterator MIE = bb->end();
      for(; MII != MIE; ++MII) {
        worklist.push_back(MII);
      }
    }
    markAllCDChildren((*child_itr)->bb,worklist);
  }
}

void MachineScalarization::Calculate(MachineFunction &F) {
  MachineRegisterInfo *MRI = &F.getRegInfo();
  SmallVector<const MachineInstr*, 128> worklist;
  //Initialization
  for(MachineFunction::iterator MBBI = F.begin(), MBBE = F.end(); MBBI != MBBE; ++MBBI) {
    conv.insert(std::make_pair(MBBI, true));
    for(MachineBasicBlock::iterator MII = MBBI->begin(), MIE = MBBI->end(); MII != MIE; ++MII) {
      invar.insert(std::make_pair(MII, true));
      if(MII->isVariant())
        worklist.push_back(MII);
      //if(MII->getOpcode() == RISCV::VEIDX) 
        //worklist.push_back(MII);
      //if(MI->getOpcode() == AMO)
        //worklist.push_back(MI);
    }
  }
  while(!worklist.empty()) {
    const MachineInstr* MI = worklist.pop_back_val();
    invar[MI] = false;
    // Walk dataflow successors
    // For all defs, walk uses
    // For some reason phis don't have defs iterator setup correctly so we do it the old fashion way
    for(const MachineOperand &MO : MI->operands()) {
      if(!(MO.isReg() && MO.isDef()))
        continue;
      for(MachineOperand &UseMO : MRI->use_operands(MO.getReg())) {
        const MachineInstr* user = UseMO.getParent();
        if(invar[user])
          worklist.push_back(user);
      }
    }
    if(MI->isConditionalBranch()) {
      markAllCDChildren(MI->getParent(), worklist);
    }
  }
}

bool MachineScalarization::runOnMachineFunction(MachineFunction &F) {
  releaseMemory();

  PDG = &getAnalysis<MachineProgramDependenceGraph>();
  MF = &F;

  Calculate(F);

  return false;
}

void MachineScalarization::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.setPreservesAll();
  AU.addRequired<MachineProgramDependenceGraph>();
  MachineFunctionPass::getAnalysisUsage(AU);
}

namespace llvm {
  MachineFunctionPass *createMachineScalarizationPass() {
    return new MachineScalarization();
  }
}
