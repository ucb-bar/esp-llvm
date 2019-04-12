; Function Attrs: nounwind
declare i64 @llvm.hwacha.veidx() #0

; Function Attrs: noinline nounwind
define dso_local void @_pocl_launcher_saxpy(float*, float*, float) {
  %idx = call i64 @llvm.hwacha.veidx() #0
  %arrayidx.i = getelementptr float, float* %0, i64 %idx
  %4 = load float, float* %arrayidx.i, align 4
  %mul.i = fmul float %4, %2

  %arrayidx2.i = getelementptr float, float* %1, i64 %idx
  %5 = load float, float* %arrayidx2.i, align 4
  %add.i = fadd float %5, %mul.i
  store float %add.i, float* %arrayidx2.i, align 4
  ret void
}

define dso_local void @_pocl_launcher_saxpy_workgroup(i8**, { i32, [3 x i64], [3 x i64], [3 x i64] }*) {
  %3 = bitcast i8** %0 to float***
  %4 = load float**, float*** %3, align 8
  %5 = load float*, float** %4, align 8
  %6 = getelementptr i8*, i8** %0, i64 1
  %7 = bitcast i8** %6 to float***
  %8 = load float**, float*** %7, align 8
  %9 = load float*, float** %8, align 8
  %10 = getelementptr i8*, i8** %0, i64 2
  %11 = bitcast i8** %10 to float**
  %12 = load float*, float** %11, align 8
  %13 = load float, float* %12, align 4
  call void @_pocl_launcher_saxpy(float* %5, float* %9, float %13)
  ret void
}


define void @pocl.barrier() {
  ret void
}

attributes #0 = { nounwind }
attributes #1 = { noinline }

!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !1}
!opencl.kernels = !{!2}

!0 = !{!"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"}
!1 = !{!"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"}
!2 = !{void (float*, float*, float)* @_pocl_launcher_saxpy}