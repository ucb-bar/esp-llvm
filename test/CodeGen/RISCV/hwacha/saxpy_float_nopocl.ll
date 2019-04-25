; Function Attrs: nounwind
declare i64 @llvm.hwacha.veidx() #0

; Function Attrs: noinline nounwind
define dso_local void @_pocl_launcher_saxpy(float*, float*, float) {
body:
  %idx = call i64 @llvm.hwacha.veidx() #0
  %arrayidx.i = getelementptr float, float* %0, i64 %idx
  %tomul = load float, float* %arrayidx.i, align 4
  %mul.i = fmul float %tomul, %2

  %arrayidx2.i = getelementptr float, float* %1, i64 %idx
  %toadd = load float, float* %arrayidx2.i, align 4
  %add.i = fadd float %toadd, %mul.i
  store float %add.i, float* %arrayidx2.i, align 4
  ret void
}

define dso_local void @_pocl_launcher_saxpy_workgroup(float*, float*, float) {
  call void @_pocl_launcher_saxpy(float* %0, float* %1, float %2)
  ret void
}


attributes #0 = { nounwind }
attributes #1 = { noinline }

!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !1}
!opencl.kernels = !{!2}

!0 = !{!"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"}
!1 = !{!"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"}
!2 = !{void (float*, float*, float)* @_pocl_launcher_saxpy}