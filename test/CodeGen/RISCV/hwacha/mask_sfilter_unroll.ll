; Function Attrs: nounwind
declare i64 @llvm.hwacha.veidx() #0

; Function Attrs: noinline nounwind
define dso_local void @_pocl_launcher_mask_sfilter_unroll(float* nocapture readonly, float* nocapture, i64, i16* nocapture readonly, float, float, float, float, float, float, float, float, float, i32, i64, i64, i64, i64, i64, i64, i64, i64, i64) #1 {
  %mul.i.i = shl i64 %17, 7
  %add.i.i = add i64 %mul.i.i, %20
  %call.i.i.i = tail call i64 @llvm.hwacha.veidx() #0
  %add1.i.i = add i64 %add.i.i, %call.i.i.i
  %add6.i.i = add i64 %21, %18
  %mul.i = shl i64 %add6.i.i, 1
  %mul2.i = mul nsw i64 %mul.i, %2
  %add.i = add nsw i64 %add1.i.i, %mul2.i
  %arrayidx.i = getelementptr inbounds i16, i16* %3, i64 %add.i
  %24 = load i16, i16* %arrayidx.i, align 2, !tbaa !4
  %tobool.i = icmp eq i16 %24, 0
  br i1 %tobool.i, label %entry.if.end_crit_edge.i, label %if.then.i

entry.if.end_crit_edge.i:                         ; preds = %23
  %.pre.i = or i64 %mul.i, 1
  %.pre248.i = mul nsw i64 %.pre.i, %2
  %.pre249.i = add nsw i64 %add1.i.i, %.pre248.i
  br label %if.end.i

if.then.i:                                        ; preds = %23
  %sub.i = add nsw i64 %add1.i.i, -1
  %sub3.i = add nsw i64 %mul.i, -1
  %mul4.i = mul nsw i64 %sub3.i, %2
  %add5.i = add nsw i64 %sub.i, %mul4.i
  %arrayidx6.i = getelementptr inbounds float, float* %0, i64 %add5.i
  %25 = load float, float* %arrayidx6.i, align 4, !tbaa !8
  %mul7.i = fmul float %25, %4
  %add10.i = add nsw i64 %add1.i.i, %mul4.i
  %arrayidx11.i = getelementptr inbounds float, float* %0, i64 %add10.i
  %26 = load float, float* %arrayidx11.i, align 4, !tbaa !8
  %mul12.i = fmul float %26, %5
  %add13.i = add nsw i64 %add1.i.i, 1
  %add16.i = add nsw i64 %add13.i, %mul4.i
  %arrayidx17.i = getelementptr inbounds float, float* %0, i64 %add16.i
  %27 = load float, float* %arrayidx17.i, align 4, !tbaa !8
  %mul18.i = fmul float %27, %6
  %add21.i = add nsw i64 %sub.i, %mul2.i
  %arrayidx22.i = getelementptr inbounds float, float* %0, i64 %add21.i
  %28 = load float, float* %arrayidx22.i, align 4, !tbaa !8
  %mul23.i = fmul float %28, %7
  %arrayidx26.i = getelementptr inbounds float, float* %0, i64 %add.i
  %29 = load float, float* %arrayidx26.i, align 4, !tbaa !8
  %mul27.i = fmul float %29, %8
  %add30.i = add nsw i64 %add13.i, %mul2.i
  %arrayidx31.i = getelementptr inbounds float, float* %0, i64 %add30.i
  %30 = load float, float* %arrayidx31.i, align 4, !tbaa !8
  %mul32.i = fmul float %30, %9
  %add34.i = or i64 %mul.i, 1
  %mul35.i = mul nsw i64 %add34.i, %2
  %add36.i = add nsw i64 %sub.i, %mul35.i
  %arrayidx37.i = getelementptr inbounds float, float* %0, i64 %add36.i
  %31 = load float, float* %arrayidx37.i, align 4, !tbaa !8
  %mul38.i = fmul float %31, %10
  %add41.i = add nsw i64 %add1.i.i, %mul35.i
  %arrayidx42.i = getelementptr inbounds float, float* %0, i64 %add41.i
  %32 = load float, float* %arrayidx42.i, align 4, !tbaa !8
  %mul43.i = fmul float %32, %11
  %add47.i = add nsw i64 %add13.i, %mul35.i
  %arrayidx48.i = getelementptr inbounds float, float* %0, i64 %add47.i
  %33 = load float, float* %arrayidx48.i, align 4, !tbaa !8
  %mul49.i = fmul float %33, %12
  %add50.i = fadd float %mul7.i, %mul12.i
  %add51.i = fadd float %add50.i, %mul18.i
  %add52.i = fadd float %add51.i, %mul23.i
  %add53.i = fadd float %add52.i, %mul27.i
  %add54.i = fadd float %add53.i, %mul32.i
  %add55.i = fadd float %add54.i, %mul38.i
  %add56.i = fadd float %add55.i, %mul43.i
  %add57.i = fadd float %add56.i, %mul49.i
  %arrayidx60.i = getelementptr inbounds float, float* %1, i64 %add.i
  store float %add57.i, float* %arrayidx60.i, align 4, !tbaa !8
  br label %if.end.i

if.end.i:                                         ; preds = %if.then.i, %entry.if.end_crit_edge.i
  %add63.pre-phi.i = phi i64 [ %.pre249.i, %entry.if.end_crit_edge.i ], [ %add41.i, %if.then.i ]
  %mul62.pre-phi.i = phi i64 [ %.pre248.i, %entry.if.end_crit_edge.i ], [ %mul35.i, %if.then.i ]
  %add61.pre-phi.i = phi i64 [ %.pre.i, %entry.if.end_crit_edge.i ], [ %add34.i, %if.then.i ]
  %arrayidx64.i = getelementptr inbounds i16, i16* %3, i64 %add63.pre-phi.i
  %34 = load i16, i16* %arrayidx64.i, align 2, !tbaa !4
  %tobool65.i = icmp eq i16 %34, 0
  br i1 %tobool65.i, label %mask_sfilter_unroll.exit, label %if.then.66.i

if.then.66.i:                                     ; preds = %if.end.i
  %sub67.i = add nsw i64 %add1.i.i, -1
  %add71.i = add nsw i64 %sub67.i, %mul2.i
  %arrayidx72.i = getelementptr inbounds float, float* %0, i64 %add71.i
  %35 = load float, float* %arrayidx72.i, align 4, !tbaa !8
  %mul73.i = fmul float %35, %4
  %arrayidx78.i = getelementptr inbounds float, float* %0, i64 %add.i
  %36 = load float, float* %arrayidx78.i, align 4, !tbaa !8
  %mul79.i = fmul float %36, %5
  %add80.i = add nsw i64 %add1.i.i, 1
  %add84.i = add nsw i64 %add80.i, %mul2.i
  %arrayidx85.i = getelementptr inbounds float, float* %0, i64 %add84.i
  %37 = load float, float* %arrayidx85.i, align 4, !tbaa !8
  %mul86.i = fmul float %37, %6
  %add90.i = add nsw i64 %mul62.pre-phi.i, %sub67.i
  %arrayidx91.i = getelementptr inbounds float, float* %0, i64 %add90.i
  %38 = load float, float* %arrayidx91.i, align 4, !tbaa !8
  %mul92.i = fmul float %38, %7
  %arrayidx96.i = getelementptr inbounds float, float* %0, i64 %add63.pre-phi.i
  %39 = load float, float* %arrayidx96.i, align 4, !tbaa !8
  %mul97.i = fmul float %39, %8
  %add101.i = add nsw i64 %mul62.pre-phi.i, %add80.i
  %arrayidx102.i = getelementptr inbounds float, float* %0, i64 %add101.i
  %40 = load float, float* %arrayidx102.i, align 4, !tbaa !8
  %mul103.i = fmul float %40, %9
  %add106.i = add nsw i64 %add61.pre-phi.i, 1
  %mul107.i = mul nsw i64 %add106.i, %2
  %add108.i = add nsw i64 %mul107.i, %sub67.i
  %arrayidx109.i = getelementptr inbounds float, float* %0, i64 %add108.i
  %41 = load float, float* %arrayidx109.i, align 4, !tbaa !8
  %mul110.i = fmul float %41, %10
  %add114.i = add nsw i64 %mul107.i, %add1.i.i
  %arrayidx115.i = getelementptr inbounds float, float* %0, i64 %add114.i
  %42 = load float, float* %arrayidx115.i, align 4, !tbaa !8
  %mul116.i = fmul float %42, %11
  %add121.i = add nsw i64 %mul107.i, %add80.i
  %arrayidx122.i = getelementptr inbounds float, float* %0, i64 %add121.i
  %43 = load float, float* %arrayidx122.i, align 4, !tbaa !8
  %mul123.i = fmul float %43, %12
  %add124.i = fadd float %mul73.i, %mul79.i
  %add125.i = fadd float %add124.i, %mul86.i
  %add126.i = fadd float %add125.i, %mul92.i
  %add127.i = fadd float %add126.i, %mul97.i
  %add128.i = fadd float %add127.i, %mul103.i
  %add129.i = fadd float %add128.i, %mul110.i
  %add130.i = fadd float %add129.i, %mul116.i
  %add131.i = fadd float %add130.i, %mul123.i
  %arrayidx135.i = getelementptr inbounds float, float* %1, i64 %add63.pre-phi.i
  store float %add131.i, float* %arrayidx135.i, align 4, !tbaa !8
  br label %mask_sfilter_unroll.exit

mask_sfilter_unroll.exit:                         ; preds = %if.then.66.i, %if.end.i
  ret void
}

; Function Attrs: nounwind
define dso_local void @_pocl_launcher_mask_sfilter_unroll_workgroup(i8** nocapture readonly, { i32, [3 x i64], [3 x i64], [3 x i64] }* nocapture readonly) #0 {
  %3 = bitcast i8** %0 to float***
  %4 = load float**, float*** %3, align 8
  %5 = load float*, float** %4, align 8
  %6 = getelementptr i8*, i8** %0, i64 1
  %7 = bitcast i8** %6 to float***
  %8 = load float**, float*** %7, align 8
  %9 = load float*, float** %8, align 8
  %10 = getelementptr i8*, i8** %0, i64 2
  %11 = bitcast i8** %10 to i64**
  %12 = load i64*, i64** %11, align 8
  %13 = load i64, i64* %12, align 8
  %14 = getelementptr i8*, i8** %0, i64 3
  %15 = bitcast i8** %14 to i16***
  %16 = load i16**, i16*** %15, align 8
  %17 = load i16*, i16** %16, align 8
  %18 = getelementptr i8*, i8** %0, i64 4
  %19 = bitcast i8** %18 to float**
  %20 = load float*, float** %19, align 8
  %21 = load float, float* %20, align 4
  %22 = getelementptr i8*, i8** %0, i64 5
  %23 = bitcast i8** %22 to float**
  %24 = load float*, float** %23, align 8
  %25 = load float, float* %24, align 4
  %26 = getelementptr i8*, i8** %0, i64 6
  %27 = bitcast i8** %26 to float**
  %28 = load float*, float** %27, align 8
  %29 = load float, float* %28, align 4
  %30 = getelementptr i8*, i8** %0, i64 7
  %31 = bitcast i8** %30 to float**
  %32 = load float*, float** %31, align 8
  %33 = load float, float* %32, align 4
  %34 = getelementptr i8*, i8** %0, i64 8
  %35 = bitcast i8** %34 to float**
  %36 = load float*, float** %35, align 8
  %37 = load float, float* %36, align 4
  %38 = getelementptr i8*, i8** %0, i64 9
  %39 = bitcast i8** %38 to float**
  %40 = load float*, float** %39, align 8
  %41 = load float, float* %40, align 4
  %42 = getelementptr i8*, i8** %0, i64 10
  %43 = bitcast i8** %42 to float**
  %44 = load float*, float** %43, align 8
  %45 = load float, float* %44, align 4
  %46 = getelementptr i8*, i8** %0, i64 11
  %47 = bitcast i8** %46 to float**
  %48 = load float*, float** %47, align 8
  %49 = load float, float* %48, align 4
  %50 = getelementptr i8*, i8** %0, i64 12
  %51 = bitcast i8** %50 to float**
  %52 = load float*, float** %51, align 8
  %53 = load float, float* %52, align 4
  %54 = getelementptr { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i64 0, i32 2, i64 0
  %55 = load i64, i64* %54, align 8
  %56 = getelementptr { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i64 0, i32 2, i64 1
  %57 = load i64, i64* %56, align 8
  %58 = getelementptr { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i64 0, i32 3, i64 0
  %59 = load i64, i64* %58, align 8
  %60 = getelementptr { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i64 0, i32 3, i64 1
  %61 = load i64, i64* %60, align 8
  tail call void @_pocl_launcher_mask_sfilter_unroll(float* %5, float* %9, i64 %13, i16* %17, float %21, float %25, float %29, float %33, float %37, float %41, float %45, float %49, float %53, i32 undef, i64 undef, i64 undef, i64 undef, i64 %55, i64 %57, i64 undef, i64 %59, i64 %61, i64 undef)
  ret void
}

; Function Attrs: nounwind readnone
define void @pocl.barrier() #3 {
  ret void
}

attributes #0 = { nounwind }
attributes #1 = { noinline nounwind "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8"  }
attributes #2 = { noinline nounwind }
attributes #3 = { nounwind readnone }

!llvm.ident = !{!0, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !2}
!opencl.kernels = !{!3}

!0 = !{!"clang version 3.7.0  (git@github.com:riscv/riscv-llvm ea484e8fe591e40d9c18ce982f25f006610ea782)"}
!1 = !{!"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"}
!2 = !{!"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"}
!3 = !{void (float*, float*, i64, i16*, float, float, float, float, float, float, float, float, float, i32, i64, i64, i64, i64, i64, i64, i64, i64, i64)* @_pocl_launcher_mask_sfilter_unroll}
!4 = !{!5, !5, i64 0}
!5 = !{!"short", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C/C++ TBAA"}
!8 = !{!9, !9, i64 0}
!9 = !{!"float", !6, i64 0}