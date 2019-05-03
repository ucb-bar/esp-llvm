; Function Attrs: nounwind
declare i64 @llvm.hwacha.veidx() #0

; Function Attrs: noinline nounwind
define dso_local void @_pocl_launcher_dgemm_single(double*, double*, double*, i32, i32, i64, i64, i64, i64, i64, i64, i64, i64, i64) #1 {
  %mul.i.i = mul i64 %8, 64
  %add.i.i = add i64 %mul.i.i, %11
  %call.i.i.i = call i64 @llvm.hwacha.veidx() #0
  %add.i.i.i = add i64 %call.i.i.i, 0
  %add1.i.i = add i64 %add.i.i, %add.i.i.i
  %mul3.i.i = mul i64 %9, 1
  %add4.i.i = add i64 %mul3.i.i, %12
  %add6.i.i = add i64 %add4.i.i, 0
  %mul8.i.i = mul i64 %10, 1
  %add9.i.i = add i64 %mul8.i.i, %13
  %add11.i.i = add i64 %add9.i.i, 0
  %conv.i = sext i32 %3 to i64
  %mul.i = mul nsw i64 %add11.i.i, %conv.i
  %add.i = add nsw i64 %mul.i, %add6.i.i
  %arrayidx.i = getelementptr inbounds double, double* %0, i64 %add.i
  %15 = load double, double* %arrayidx.i, align 8, !tbaa !3
  %mul4.i = mul nsw i64 %add6.i.i, %conv.i
  %add5.i = add nsw i64 %mul4.i, %add1.i.i
  %arrayidx6.i = getelementptr inbounds double, double* %1, i64 %add5.i
  %16 = load double, double* %arrayidx6.i, align 8, !tbaa !3
  %add9.i = add nsw i64 %mul.i, %add1.i.i
  %arrayidx10.i = getelementptr inbounds double, double* %2, i64 %add9.i
  %17 = load double, double* %arrayidx10.i, align 8, !tbaa !3
  %mul11.i = fmul double %15, %16
  %add12.i = fadd double %17, %mul11.i
  store double %add12.i, double* %arrayidx10.i, align 8, !tbaa !3
  ret void
}

define dso_local void @_pocl_launcher_dgemm_single_workgroup(i8**, { i32, [3 x i64], [3 x i64], [3 x i64] }*) {
  %3 = getelementptr i8*, i8** %0, i32 0
  %4 = load i8*, i8** %3
  %5 = bitcast i8* %4 to double**
  %6 = load double*, double** %5
  %7 = getelementptr i8*, i8** %0, i32 1
  %8 = load i8*, i8** %7
  %9 = bitcast i8* %8 to double**
  %10 = load double*, double** %9
  %11 = getelementptr i8*, i8** %0, i32 2
  %12 = load i8*, i8** %11
  %13 = bitcast i8* %12 to double**
  %14 = load double*, double** %13
  %15 = getelementptr i8*, i8** %0, i32 3
  %16 = load i8*, i8** %15
  %17 = bitcast i8* %16 to i32*
  %18 = load i32, i32* %17
  %19 = getelementptr inbounds { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i32 0, i32 0
  %20 = getelementptr i32, i32* %19, i32 0
  %21 = load i32, i32* %20
  %22 = getelementptr inbounds { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i32 0, i32 1
  %23 = getelementptr [3 x i64], [3 x i64]* %22, i64 0, i64 0
  %24 = load i64, i64* %23
  %25 = getelementptr [3 x i64], [3 x i64]* %22, i64 0, i64 1
  %26 = load i64, i64* %25
  %27 = getelementptr [3 x i64], [3 x i64]* %22, i64 0, i64 2
  %28 = load i64, i64* %27
  %29 = getelementptr inbounds { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i32 0, i32 2
  %30 = getelementptr [3 x i64], [3 x i64]* %29, i64 0, i64 0
  %31 = load i64, i64* %30
  %32 = getelementptr [3 x i64], [3 x i64]* %29, i64 0, i64 1
  %33 = load i64, i64* %32
  %34 = getelementptr [3 x i64], [3 x i64]* %29, i64 0, i64 2
  %35 = load i64, i64* %34
  %36 = getelementptr inbounds { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i32 0, i32 3
  %37 = getelementptr [3 x i64], [3 x i64]* %36, i64 0, i64 0
  %38 = load i64, i64* %37
  %39 = getelementptr [3 x i64], [3 x i64]* %36, i64 0, i64 1
  %40 = load i64, i64* %39
  %41 = getelementptr [3 x i64], [3 x i64]* %36, i64 0, i64 2
  %42 = load i64, i64* %41
  call void @_pocl_launcher_dgemm_single(double* %6, double* %10, double* %14, i32 %18, i32 %21, i64 %24, i64 %26, i64 %28, i64 %31, i64 %33, i64 %35, i64 %38, i64 %40, i64 %42)
  ret void
}


define void @pocl.barrier() {
  ret void
}

attributes #0 = { nounwind }
attributes #1 = { noinline nounwind  }
attributes #2 = { noinline }

!opencl.kernels = !{!2}

!2 = !{void (double*, double*, double*, i32, i32, i64, i64, i64, i64, i64, i64, i64, i64, i64)* @_pocl_launcher_dgemm_single}
!3 = !{!4, !4, i64 0}
!4 = !{!"double", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}