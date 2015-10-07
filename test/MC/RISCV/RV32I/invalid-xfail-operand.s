# Instructions that are expected to fail
#
# RUN: llvm-mc %s -triple=riscv-unknown-linux -show-encoding -mcpu=RV32I | FileCheck %s
# XFAIL: *

	add	x0, x1, x2, x3

#-- EOF

