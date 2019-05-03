; Function Attrs: nounwind
declare i64 @llvm.hwacha.veidx() #0

; Function Attrs: noinline nounwind
define dso_local i64 @_pocl_launcher_saxpy_varstride(i64 "noelim" %vl, float*, float*, float, i64 %stride) {
body:
  %idx = call i64 @llvm.hwacha.veidx() #0
  %mulidx = mul i64 %idx, %stride
  %arrayidx.i = getelementptr float, float* %0, i64 %mulidx

  %tomul = load float, float* %arrayidx.i, align 4
  store float %tomul, float* %arrayidx.i, align 4
  
  %vlret = call i64 @llvm.hwacha.vretvl()
  ret i64 %vlret
}

define dso_local i64 @_pocl_launcher_saxpy(i64 "noelim" %vl, float*, float*, float) {
body:
  %idx = call i64 @llvm.hwacha.veidx() #0
  %mulidx = mul i64 %idx, 3
  %arrayidx.i = getelementptr float, float* %0, i64 %mulidx
  %tomul = load float, float* %arrayidx.i, align 4
  %mul.i = fmul float %tomul, %2

  %arrayidx2.i = getelementptr float, float* %1, i64 %mulidx
  %toadd = load float, float* %arrayidx2.i, align 4
  %add.i = fadd float %toadd, %mul.i
  store float %add.i, float* %arrayidx2.i, align 4
  
  %vlret = call i64 @llvm.hwacha.vretvl()
  ret i64 %vlret
}

define dso_local void @_pocl_launcher_saxpy_workgroup(float*, float*, float) {
  %newvl0 = call i64 @_pocl_launcher_saxpy(i64 4, float* %0, float* %1, float %2)
  %newvl = call i64 @_pocl_launcher_saxpy_varstride(i64 4, float* %0, float* %1, float %2, i64 2)
  ret void
}


attributes #0 = { nounwind }
attributes #1 = { noinline }

declare i64 @llvm.hwacha.vretvl()

!opencl.kernels = !{!2, !3}

!0 = !{!"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"}
!1 = !{!"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"}
!2 = !{i64 (i64, float*, float*, float, i64)* @_pocl_launcher_saxpy_varstride}
!3 = !{i64 (i64, float*, float*, float)* @_pocl_launcher_saxpy}