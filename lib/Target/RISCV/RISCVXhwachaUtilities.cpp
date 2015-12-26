//===- RISCVXhwachaUtilities.cpp - Utility Functions -----------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file contains miscellaneous utility functions
//===----------------------------------------------------------------------===//

#include "RISCVXhwachaUtilities.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"

bool llvm::isOpenCLKernelFunction(const Function &F) {
  NamedMDNode* oclKernels = F.getParent()->getNamedMetadata("opencl.kernels");

  if (!oclKernels || oclKernels->getNumOperands() == 0) return false;

  for (unsigned i = 0, e = oclKernels->getNumOperands(); i != e; ++i) {
    llvm::MDNode *kernel_iter = oclKernels->getOperand(i);
    if(!kernel_iter->getOperand(0))
      continue;
    if(isa<llvm::ValueAsMetadata>(kernel_iter->getOperand(0))) {
      llvm::ValueAsMetadata* vam = dyn_cast<llvm::ValueAsMetadata>(kernel_iter->getOperand(0));
      llvm::Function *kernel_prototype =
        llvm::cast<llvm::Function>(vam->getValue());
      if(kernel_prototype->getName().equals(F.getName()))
        return true;
    }
  }
  return false;
}

