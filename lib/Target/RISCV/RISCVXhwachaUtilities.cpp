#include "RISCVXhwachaUtilities.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "hwacha-utils"

bool llvm::isOpenCLKernelFunction(const Function &F) {
  NamedMDNode* oclKernels = F.getParent()->getNamedMetadata("opencl.kernels");
  if (oclKernels) {
    LLVM_DEBUG(oclKernels->dump());
  }

  if (!oclKernels || oclKernels->getNumOperands() == 0) return false;

  for (unsigned i = 0, e = oclKernels->getNumOperands(); i != e; ++i) {
    llvm::MDNode *kernel_iter = oclKernels->getOperand(i);
    if(!kernel_iter->getOperand(0))
      continue;
    if(isa<llvm::ValueAsMetadata>(kernel_iter->getOperand(0))) {
      llvm::ValueAsMetadata* vam = dyn_cast<llvm::ValueAsMetadata>(kernel_iter->getOperand(0));
      llvm::Function *kernel_prototype =
        llvm::cast<llvm::Function>(vam->getValue());
      // LLVM_DEBUG(dbgs() << "Kernel Prototype" << "\n");
      // LLVM_DEBUG(kernel_prototype->dump());
      // LLVM_DEBUG(dbgs() << kernel_prototype->getName() << " | " << F.getName() << "\n");
      if(kernel_prototype->getName().equals(F.getName()))
        return true;
    }
  }
  return false;
}