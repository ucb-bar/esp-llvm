; Function Attrs: nounwind
declare i64 @llvm.hwacha.veidx() #0

; Function Attrs: noinline nounwind
define dso_local void @_pocl_launcher_mask_dfilter(double*, double*, i64, i16* , double, double, double, double, double, double, double, double, double, i32, i64, i64, i64, i64, i64, i64, i64, i64, i64) #1 {
  %mul.i.i = mul i64 %17, 64
  %add.i.i = add i64 %mul.i.i, %20
  %call.i.i.i = call i64 @llvm.hwacha.veidx() #0
  %add.i.i.i = add i64 %call.i.i.i, 0
  %add1.i.i = add i64 %add.i.i, %add.i.i.i
  %mul3.i.i = mul i64 %18, 1
  %add4.i.i = add i64 %mul3.i.i, %21
  %add6.i.i = add i64 %add4.i.i, 0
  %mul.i = mul nsw i64 %add6.i.i, %2
  %add.i = add nsw i64 %mul.i, %add1.i.i
  %arrayidx.i = getelementptr inbounds i16, i16* %3, i64 %add.i
  %24 = load i16, i16* %arrayidx.i, align 2, !tbaa !3
  %tobool.i = icmp eq i16 %24, 0
  br i1 %tobool.i, label %mask_dfilter.exit, label %if.then.i

if.then.i:                                        ; preds = %23
  %sub.i = add nsw i64 %add1.i.i, -1
  %sub2.i = add nsw i64 %add6.i.i, -1
  %mul3.i = mul nsw i64 %sub2.i, %2
  %add4.i = add nsw i64 %mul3.i, %sub.i
  %arrayidx5.i = getelementptr inbounds double, double* %0, i64 %add4.i
  %25 = load double, double* %arrayidx5.i, align 8, !tbaa !7
  %mul6.i = fmul double %25, %4
  %add9.i = add nsw i64 %mul3.i, %add1.i.i
  %arrayidx10.i = getelementptr inbounds double, double* %0, i64 %add9.i
  %26 = load double, double* %arrayidx10.i, align 8, !tbaa !7
  %mul11.i = fmul double %26, %5
  %add12.i = add nsw i64 %add1.i.i, 1
  %add15.i = add nsw i64 %mul3.i, %add12.i
  %arrayidx16.i = getelementptr inbounds double, double* %0, i64 %add15.i
  %27 = load double, double* %arrayidx16.i, align 8, !tbaa !7
  %mul17.i = fmul double %27, %6
  %add20.i = add nsw i64 %mul.i, %sub.i
  %arrayidx21.i = getelementptr inbounds double, double* %0, i64 %add20.i
  %28 = load double, double* %arrayidx21.i, align 8, !tbaa !7
  %mul22.i = fmul double %28, %7
  %arrayidx25.i = getelementptr inbounds double, double* %0, i64 %add.i
  %29 = load double, double* %arrayidx25.i, align 8, !tbaa !7
  %mul26.i = fmul double %29, %8
  %add29.i = add nsw i64 %mul.i, %add12.i
  %arrayidx30.i = getelementptr inbounds double, double* %0, i64 %add29.i
  %30 = load double, double* %arrayidx30.i, align 8, !tbaa !7
  %mul31.i = fmul double %30, %9
  %add33.i = add nsw i64 %add6.i.i, 1
  %mul34.i = mul nsw i64 %add33.i, %2
  %add35.i = add nsw i64 %mul34.i, %sub.i
  %arrayidx36.i = getelementptr inbounds double, double* %0, i64 %add35.i
  %31 = load double, double* %arrayidx36.i, align 8, !tbaa !7
  %mul37.i = fmul double %31, %10
  %add40.i = add nsw i64 %mul34.i, %add1.i.i
  %arrayidx41.i = getelementptr inbounds double, double* %0, i64 %add40.i
  %32 = load double, double* %arrayidx41.i, align 8, !tbaa !7
  %mul42.i = fmul double %32, %11
  %add46.i = add nsw i64 %mul34.i, %add12.i
  %arrayidx47.i = getelementptr inbounds double, double* %0, i64 %add46.i
  %33 = load double, double* %arrayidx47.i, align 8, !tbaa !7
  %mul48.i = fmul double %33, %12
  %add49.i = fadd double %mul6.i, %mul11.i
  %add50.i = fadd double %add49.i, %mul17.i
  %add51.i = fadd double %add50.i, %mul22.i
  %add52.i = fadd double %add51.i, %mul26.i
  %add53.i = fadd double %add52.i, %mul31.i
  %add54.i = fadd double %add53.i, %mul37.i
  %add55.i = fadd double %add54.i, %mul42.i
  %add56.i = fadd double %add55.i, %mul48.i
  %arrayidx59.i = getelementptr inbounds double, double* %1, i64 %add.i
  store double %add56.i, double* %arrayidx59.i, align 8, !tbaa !7
  br label %mask_dfilter.exit

mask_dfilter.exit:                                ; preds = %if.then.i, %23
  ret void
}

define dso_local void @_pocl_launcher_mask_dfilter_workgroup(i8**, { i32, [3 x i64], [3 x i64], [3 x i64] }*) {
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
  %13 = bitcast i8* %12 to i64*
  %14 = load i64, i64* %13
  %15 = getelementptr i8*, i8** %0, i32 3
  %16 = load i8*, i8** %15
  %17 = bitcast i8* %16 to i16**
  %18 = load i16*, i16** %17
  %19 = getelementptr i8*, i8** %0, i32 4
  %20 = load i8*, i8** %19
  %21 = bitcast i8* %20 to double*
  %22 = load double, double* %21
  %23 = getelementptr i8*, i8** %0, i32 5
  %24 = load i8*, i8** %23
  %25 = bitcast i8* %24 to double*
  %26 = load double, double* %25
  %27 = getelementptr i8*, i8** %0, i32 6
  %28 = load i8*, i8** %27
  %29 = bitcast i8* %28 to double*
  %30 = load double, double* %29
  %31 = getelementptr i8*, i8** %0, i32 7
  %32 = load i8*, i8** %31
  %33 = bitcast i8* %32 to double*
  %34 = load double, double* %33
  %35 = getelementptr i8*, i8** %0, i32 8
  %36 = load i8*, i8** %35
  %37 = bitcast i8* %36 to double*
  %38 = load double, double* %37
  %39 = getelementptr i8*, i8** %0, i32 9
  %40 = load i8*, i8** %39
  %41 = bitcast i8* %40 to double*
  %42 = load double, double* %41
  %43 = getelementptr i8*, i8** %0, i32 10
  %44 = load i8*, i8** %43
  %45 = bitcast i8* %44 to double*
  %46 = load double, double* %45
  %47 = getelementptr i8*, i8** %0, i32 11
  %48 = load i8*, i8** %47
  %49 = bitcast i8* %48 to double*
  %50 = load double, double* %49
  %51 = getelementptr i8*, i8** %0, i32 12
  %52 = load i8*, i8** %51
  %53 = bitcast i8* %52 to double*
  %54 = load double, double* %53
  %55 = getelementptr inbounds { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i32 0, i32 0
  %56 = getelementptr i32, i32* %55, i32 0
  %57 = load i32, i32* %56
  %58 = getelementptr inbounds { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i32 0, i32 1
  %59 = getelementptr [3 x i64], [3 x i64]* %58, i64 0, i64 0
  %60 = load i64, i64* %59
  %61 = getelementptr [3 x i64], [3 x i64]* %58, i64 0, i64 1
  %62 = load i64, i64* %61
  %63 = getelementptr [3 x i64], [3 x i64]* %58, i64 0, i64 2
  %64 = load i64, i64* %63
  %65 = getelementptr inbounds { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i32 0, i32 2
  %66 = getelementptr [3 x i64], [3 x i64]* %65, i64 0, i64 0
  %67 = load i64, i64* %66
  %68 = getelementptr [3 x i64], [3 x i64]* %65, i64 0, i64 1
  %69 = load i64, i64* %68
  %70 = getelementptr [3 x i64], [3 x i64]* %65, i64 0, i64 2
  %71 = load i64, i64* %70
  %72 = getelementptr inbounds { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i32 0, i32 3
  %73 = getelementptr [3 x i64], [3 x i64]* %72, i64 0, i64 0
  %74 = load i64, i64* %73
  %75 = getelementptr [3 x i64], [3 x i64]* %72, i64 0, i64 1
  %76 = load i64, i64* %75
  %77 = getelementptr [3 x i64], [3 x i64]* %72, i64 0, i64 2
  %78 = load i64, i64* %77
  call void @_pocl_launcher_mask_dfilter(double* %6, double* %10, i64 %14, i16* %18, double %22, double %26, double %30, double %34, double %38, double %42, double %46, double %50, double %54, i32 %57, i64 %60, i64 %62, i64 %64, i64 %67, i64 %69, i64 %71, i64 %74, i64 %76, i64 %78)
  ret void
}

define dso_local void @pocl.barrier() {
  ret void
}

attributes #0 = { nounwind }
attributes #1 = { noinline nounwind }
attributes #2 = { noinline }

!llvm.ident = !{!0, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1}
!opencl.kernels = !{!2}

!0 = !{!"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 2c5a12490b9af0b82717673d0ccde46a50a8bee5)"}
!1 = !{!"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"}
!2 = !{void (double*, double*, i64, i16*, double, double, double, double, double, double, double, double, double, i32, i64, i64, i64, i64, i64, i64, i64, i64, i64)* @_pocl_launcher_mask_dfilter}
!3 = !{!4, !4, i64 0}
!4 = !{!"short", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
!7 = !{!8, !8, i64 0}
!8 = !{!"double", !5, i64 0}