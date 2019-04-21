; Function Attrs: nounwind
declare i64 @llvm.hwacha.veidx() #0

; Function Attrs: noinline nounwind
define dso_local void @_pocl_launcher_saxpy(i32 %t2, i8*  %input, i8*  %output) {
body:
  %0 = call i64 @llvm.hwacha.veidx() #13
  %output.s0.x.__block_id_x = trunc i64 %0 to i32
  %1 = add nsw i32 %output.s0.x.__block_id_x, %t2
  %2 = bitcast i8* %input to i32*
  %3 = sext i32 %1 to i64
  %4 = getelementptr inbounds i32, i32* %2, i64 %3
  %5 = load i32, i32* %4, align 4
  %6 = bitcast i8* %output to i32*
  %7 = sext i32 %output.s0.x.__block_id_x to i64
  %8 = getelementptr inbounds i32, i32* %6, i64 %7
  store i32 %5, i32* %8, align 4
  ret void
}


; define dso_local void @_pocl_launcher_saxpy_workgroup(i8**, { i32, [3 x i64], [3 x i64], [3 x i64] }*) {
;   %3 = bitcast i8** %0 to float***
;   %4 = load float**, float*** %3, align 8
;   %5 = load float*, float** %4, align 8
;   %6 = getelementptr i8*, i8** %0, i64 1
;   %7 = bitcast i8** %6 to double***
;   %8 = load double**, double*** %7, align 8
;   %9 = load double*, double** %8, align 8
;   %10 = getelementptr i8*, i8** %0, i64 2
;   %11 = bitcast i8** %10 to double**
;   %12 = load double*, double** %11, align 8
;   %13 = load double, double* %12, align 4
;   call void @_pocl_launcher_saxpy(float* %5, double* %9, double %13)
;   ret void
; }


; define void @pocl.barrier() {
;   ret void
; }

attributes #0 = { nounwind }
attributes #1 = { noinline }

!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !1}
!opencl.kernels = !{!2}

!0 = !{!"clang version 3.7.0  (git@github.com:riscv/riscv-llvm b701702c63e224dd309b5b016a91641264eb181d)"}
!1 = !{!"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"}
!2 = !{void (i32, i8*, i8*)* @_pocl_launcher_saxpy}