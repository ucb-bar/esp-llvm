# Instructions that are expected to fail
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV32I | FileCheck %s
# XFAIL: *

	add	x5, x4, x32

#-- EOF

