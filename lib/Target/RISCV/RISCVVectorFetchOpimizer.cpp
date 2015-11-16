#include "RISCV.h"
#include "RISCVSubtarget.h"
#include "RISCVXhwachaUtilities.h"
#include "llvm/CodeGen/MachineDominators.h"
#include "llvm/CodeGen/MachineScalarization.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/PassSupport.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetInstrInfo.h"
#include <algorithm>
#include <vector>

using namespace llvm;

#define DEBUG_TYPE "vfopt"

namespace llvm {
  MachineFunctionPass *createRISCVVectorFetchOptimizer();
  void initializeRISCVVectorFetchOptimizerPass(PassRegistry&);
}

namespace {
  struct RISCVVectorFetchOptimizer : public MachineFunctionPass {
    MachineScalarization       *MS;
    const RISCVInstrInfo     *TII;
  public:
    static char ID;

    RISCVVectorFetchOptimizer() : MachineFunctionPass(ID) {
      initializeRISCVVectorFetchOptimizerPass(*PassRegistry::getPassRegistry());
    }

    bool runOnMachineFunction(MachineFunction &MF) override;

    const char *getPassName() const override { return "RISCV Vector Fetch Optimizer"; }

    void getAnalysisUsage(AnalysisUsage &AU) const override {
      AU.addRequired<MachineScalarization>();
      MachineFunctionPass::getAnalysisUsage(AU);
    }
    virtual void processOpenCLKernel(MachineFunction &MF);
  };

  char RISCVVectorFetchOptimizer::ID = 0;

} // end anonymous namespace


INITIALIZE_PASS_BEGIN(RISCVVectorFetchOptimizer, "vfopt",
                      "RISCV Vector Fetch Optimizer", false, false)
INITIALIZE_PASS_DEPENDENCY(MachineScalarization)
INITIALIZE_PASS_END(RISCVVectorFetchOptimizer, "vfopt",
                    "RISCV Vector Fetch Optimizer", false, false)

MachineFunctionPass *llvm::createRISCVVectorFetchOptimizer() {
  return new RISCVVectorFetchOptimizer();
}

bool RISCVVectorFetchOptimizer::runOnMachineFunction(MachineFunction &MF) {
  bool Changed = false;

  MS = &getAnalysis<MachineScalarization>();
  TII = MF.getSubtarget<RISCVSubtarget>().getInstrInfo();

  if(isOpenCLKernelFunction(*(MF.getFunction())))
    processOpenCLKernel(MF);
  
  return Changed;
}

void RISCVVectorFetchOptimizer::processOpenCLKernel(MachineFunction &MF) {
  MachineRegisterInfo &MRI = MF.getRegInfo();
  const TargetInstrInfo &TII = *MF.getSubtarget().getInstrInfo();
  const TargetRegisterInfo &TRI = *MF.getSubtarget().getRegisterInfo();

  for (MachineFunction::iterator MFI = MF.begin(), MFE = MF.end(); MFI != MFE;
       ++MFI) {
    // In each BB change each instruction
    for (MachineBasicBlock::iterator I = MFI->begin(); I != MFI->end(); ++I) {
      // All inputs are vs registers and outputs are vv registers
      switch(I->getOpcode()) {
        case TargetOpcode::COPY :
          // If this is physical to virt copy do nothing
          if(TRI.isPhysicalRegister(I->getOperand(1).getReg()))
            break;
          MRI.setRegClass(I->getOperand(0).getReg(), 
              MRI.getRegClass(I->getOperand(1).getReg()));
          break;
        case RISCV::ADD64 :
          //FIXME: if we can have phys regs here check for that first
          if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
            if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
              I->setDesc(TII.get(RISCV::VADD_VSS));
            } else {
              I->setDesc(TII.get(RISCV::VADD_VSV));
            }
          } else {
            if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
              I->setDesc(TII.get(RISCV::VADD_VVS));
            } else {
              I->setDesc(TII.get(RISCV::VADD_VVV));
            }
          }
          // Destination is always vector
          MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
          // Check source type
          break;
        case RISCV::SLLI64 :
        {
          // Generate two instructions
          // 1. vaddi vstemp, vs0, imm
          unsigned vstemp = MRI.createVirtualRegister(&RISCV::VSRBitRegClass);
          MachineOperand &imm = I->getOperand(2);
          BuildMI(*MFI, I, I->getDebugLoc(), TII.get(RISCV::VADDI), vstemp).addReg(RISCV::vs0).addImm(imm.getImm());
          // 1. vsll vvdest, vssrc, vstemp
          I->setDesc(TII.get(RISCV::VSLL_VSS));
          // Destination is always vector
          MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
          I->getOperand(2).ChangeToRegister(vstemp, false);
          break;
        }
        case RISCV::FLW64 :
          I->setDesc(TII.get(RISCV::VLXW_F));
          // Destination is always vector
          MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
          // Shift vector portion to second src
          I->getOperand(2).ChangeToRegister(I->getOperand(1).getReg(), false);
          I->getOperand(1).ChangeToRegister(RISCV::vs0, false);
          break;
        case RISCV::LW64 :
          I->setDesc(TII.get(RISCV::VLXW));
          // Destination is always vector
          MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
          // Shift vector portion to second src
          I->getOperand(2).ChangeToRegister(I->getOperand(1).getReg(), false);
          I->getOperand(1).ChangeToRegister(RISCV::vs0, false);
          break;
        case RISCV::FSW64 :
          I->setDesc(TII.get(RISCV::VSXW_F));
          // Shift vector portion to second src
          I->getOperand(2).ChangeToRegister(I->getOperand(1).getReg(), false);
          I->getOperand(1).ChangeToRegister(RISCV::vs0, false);
          break;
        case RISCV::SW64 :
          I->setDesc(TII.get(RISCV::VSXW));
          // Shift vector portion to second src
          I->getOperand(2).ChangeToRegister(I->getOperand(1).getReg(), false);
          I->getOperand(1).ChangeToRegister(RISCV::vs0, false);
          break;
        case RISCV::FADD_S_RDY :
          if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
            if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
              I->setDesc(TII.get(RISCV::VFADD_S_RDY_VSS));
            } else {
              I->setDesc(TII.get(RISCV::VFADD_S_RDY_VSV));
            }
          } else {
            if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
              I->setDesc(TII.get(RISCV::VFADD_S_RDY_VVS));
            } else {
              I->setDesc(TII.get(RISCV::VFADD_S_RDY_VVV));
            }
          }
          // Destination is always vector
          MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
          break;
        case RISCV::FMUL_S_RDY :
          if(MRI.getRegClass(I->getOperand(1).getReg()) == &RISCV::VSRBitRegClass) {
            if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
              I->setDesc(TII.get(RISCV::VFMUL_S_RDY_VSS));
            } else {
              I->setDesc(TII.get(RISCV::VFMUL_S_RDY_VSV));
            }
          } else {
            if(MRI.getRegClass(I->getOperand(2).getReg()) == &RISCV::VSRBitRegClass) {
              I->setDesc(TII.get(RISCV::VFMUL_S_RDY_VVS));
            } else {
              I->setDesc(TII.get(RISCV::VFMUL_S_RDY_VVV));
            }
          }
          // Destination is always vector
          MRI.setRegClass(I->getOperand(0).getReg(), &RISCV::VVRBitRegClass);
          break;
        case RISCV::RET :
          I->setDesc(TII.get(RISCV::VSTOP));
          I->RemoveOperand(1);
          I->RemoveOperand(0);
          break;
        default:
          printf("Unable to handle Opcode:%u in OpenCL kernel\n", I->getOpcode());
          I->dump();
      }
    }
  }
}
