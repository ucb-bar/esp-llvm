; Function Attrs: nounwind
declare i64 @llvm.hwacha.veidx() #0

; Function Attrs: noinline nounwind
define dso_local void @_pocl_launcher_sgemm_unroll(float* nocapture readonly, float* nocapture readonly, float* nocapture, i32, i32, i64, i64, i64, i64, i64, i64, i64, i64, i64) #1 {
for.cond.4.preheader.i:
  %mul.i.i = shl i64 %8, 7
  %add.i.i = add i64 %mul.i.i, %11
  %call.i.i.i = tail call i64 @llvm.hwacha.veidx() #0
  %add1.i.i = add i64 %add.i.i, %call.i.i.i
  %add6.i.i = add i64 %12, %9
  %mul.i = shl i64 %add6.i.i, 2
  %add11.i.i = add i64 %13, %10
  %mul3.i = shl i64 %add11.i.i, 2
  %conv.i = sext i32 %3 to i64
  %mul9.i = mul nsw i64 %mul3.i, %conv.i
  %add18.i = add nsw i64 %mul9.i, %add1.i.i
  %arrayidx19.i = getelementptr inbounds float, float* %2, i64 %add18.i
  %.pre.i = load float, float* %arrayidx19.i, align 4, !tbaa !4
  %add10.i = add nsw i64 %mul.i, %mul9.i
  %arrayidx.i = getelementptr inbounds float, float* %0, i64 %add10.i
  %14 = load float, float* %arrayidx.i, align 4, !tbaa !4
  %mul12.i = mul nsw i64 %mul.i, %conv.i
  %add13.i = add nsw i64 %mul12.i, %add1.i.i
  %arrayidx14.i = getelementptr inbounds float, float* %1, i64 %add13.i
  %15 = load float, float* %arrayidx14.i, align 4, !tbaa !4
  %mul15.i = fmul float %14, %15
  %add20.i = fadd float %.pre.i, %mul15.i
  store float %add20.i, float* %arrayidx19.i, align 4, !tbaa !4
  %inc.i = or i64 %mul.i, 1
  %add10.i.1 = add nsw i64 %inc.i, %mul9.i
  %arrayidx.i.1 = getelementptr inbounds float, float* %0, i64 %add10.i.1
  %16 = load float, float* %arrayidx.i.1, align 4, !tbaa !4
  %mul12.i.1 = mul nsw i64 %inc.i, %conv.i
  %add13.i.1 = add nsw i64 %mul12.i.1, %add1.i.i
  %arrayidx14.i.1 = getelementptr inbounds float, float* %1, i64 %add13.i.1
  %17 = load float, float* %arrayidx14.i.1, align 4, !tbaa !4
  %mul15.i.1 = fmul float %16, %17
  %add20.i.1 = fadd float %add20.i, %mul15.i.1
  store float %add20.i.1, float* %arrayidx19.i, align 4, !tbaa !4
  %inc.i.1 = add nsw i64 %inc.i, 1
  %add10.i.2 = add nsw i64 %inc.i.1, %mul9.i
  %arrayidx.i.2 = getelementptr inbounds float, float* %0, i64 %add10.i.2
  %18 = load float, float* %arrayidx.i.2, align 4, !tbaa !4
  %mul12.i.2 = mul nsw i64 %inc.i.1, %conv.i
  %add13.i.2 = add nsw i64 %mul12.i.2, %add1.i.i
  %arrayidx14.i.2 = getelementptr inbounds float, float* %1, i64 %add13.i.2
  %19 = load float, float* %arrayidx14.i.2, align 4, !tbaa !4
  %mul15.i.2 = fmul float %18, %19
  %add20.i.2 = fadd float %add20.i.1, %mul15.i.2
  store float %add20.i.2, float* %arrayidx19.i, align 4, !tbaa !4
  %inc.i.2 = or i64 %mul.i, 3
  %add10.i.3 = add nsw i64 %inc.i.2, %mul9.i
  %arrayidx.i.3 = getelementptr inbounds float, float* %0, i64 %add10.i.3
  %20 = load float, float* %arrayidx.i.3, align 4, !tbaa !4
  %mul12.i.3 = mul nsw i64 %inc.i.2, %conv.i
  %add13.i.3 = add nsw i64 %mul12.i.3, %add1.i.i
  %arrayidx14.i.3 = getelementptr inbounds float, float* %1, i64 %add13.i.3
  %21 = load float, float* %arrayidx14.i.3, align 4, !tbaa !4
  %mul15.i.3 = fmul float %20, %21
  %add20.i.3 = fadd float %add20.i.2, %mul15.i.3
  store float %add20.i.3, float* %arrayidx19.i, align 4, !tbaa !4
  %inc22.i = or i64 %mul3.i, 1
  %mul9.i.1 = mul nsw i64 %inc22.i, %conv.i
  %add18.i.1 = add nsw i64 %mul9.i.1, %add1.i.i
  %arrayidx19.i.1 = getelementptr inbounds float, float* %2, i64 %add18.i.1
  %.pre.i.1 = load float, float* %arrayidx19.i.1, align 4, !tbaa !4
  %add10.i.1.1 = add nsw i64 %mul.i, %mul9.i.1
  %arrayidx.i.1.2 = getelementptr inbounds float, float* %0, i64 %add10.i.1.1
  %22 = load float, float* %arrayidx.i.1.2, align 4, !tbaa !4
  %23 = load float, float* %arrayidx14.i, align 4, !tbaa !4
  %mul15.i.1.6 = fmul float %22, %23
  %add20.i.1.7 = fadd float %.pre.i.1, %mul15.i.1.6
  store float %add20.i.1.7, float* %arrayidx19.i.1, align 4, !tbaa !4
  %add10.i.1.1.9 = add nsw i64 %inc.i, %mul9.i.1
  %arrayidx.i.1.1 = getelementptr inbounds float, float* %0, i64 %add10.i.1.1.9
  %24 = load float, float* %arrayidx.i.1.1, align 4, !tbaa !4
  %25 = load float, float* %arrayidx14.i.1, align 4, !tbaa !4
  %mul15.i.1.1 = fmul float %24, %25
  %add20.i.1.1 = fadd float %add20.i.1.7, %mul15.i.1.1
  store float %add20.i.1.1, float* %arrayidx19.i.1, align 4, !tbaa !4
  %add10.i.2.1 = add nsw i64 %inc.i.1, %mul9.i.1
  %arrayidx.i.2.1 = getelementptr inbounds float, float* %0, i64 %add10.i.2.1
  %26 = load float, float* %arrayidx.i.2.1, align 4, !tbaa !4
  %27 = load float, float* %arrayidx14.i.2, align 4, !tbaa !4
  %mul15.i.2.1 = fmul float %26, %27
  %add20.i.2.1 = fadd float %add20.i.1.1, %mul15.i.2.1
  store float %add20.i.2.1, float* %arrayidx19.i.1, align 4, !tbaa !4
  %add10.i.3.1 = add nsw i64 %inc.i.2, %mul9.i.1
  %arrayidx.i.3.1 = getelementptr inbounds float, float* %0, i64 %add10.i.3.1
  %28 = load float, float* %arrayidx.i.3.1, align 4, !tbaa !4
  %29 = load float, float* %arrayidx14.i.3, align 4, !tbaa !4
  %mul15.i.3.1 = fmul float %28, %29
  %add20.i.3.1 = fadd float %add20.i.2.1, %mul15.i.3.1
  store float %add20.i.3.1, float* %arrayidx19.i.1, align 4, !tbaa !4
  %inc22.i.1 = add nsw i64 %inc22.i, 1
  %mul9.i.2 = mul nsw i64 %inc22.i.1, %conv.i
  %add18.i.2 = add nsw i64 %mul9.i.2, %add1.i.i
  %arrayidx19.i.2 = getelementptr inbounds float, float* %2, i64 %add18.i.2
  %.pre.i.2 = load float, float* %arrayidx19.i.2, align 4, !tbaa !4
  %add10.i.2.10 = add nsw i64 %mul.i, %mul9.i.2
  %arrayidx.i.2.11 = getelementptr inbounds float, float* %0, i64 %add10.i.2.10
  %30 = load float, float* %arrayidx.i.2.11, align 4, !tbaa !4
  %31 = load float, float* %arrayidx14.i, align 4, !tbaa !4
  %mul15.i.2.15 = fmul float %30, %31
  %add20.i.2.16 = fadd float %.pre.i.2, %mul15.i.2.15
  store float %add20.i.2.16, float* %arrayidx19.i.2, align 4, !tbaa !4
  %add10.i.1.2 = add nsw i64 %inc.i, %mul9.i.2
  %arrayidx.i.1.2.18 = getelementptr inbounds float, float* %0, i64 %add10.i.1.2
  %32 = load float, float* %arrayidx.i.1.2.18, align 4, !tbaa !4
  %33 = load float, float* %arrayidx14.i.1, align 4, !tbaa !4
  %mul15.i.1.2 = fmul float %32, %33
  %add20.i.1.2 = fadd float %add20.i.2.16, %mul15.i.1.2
  store float %add20.i.1.2, float* %arrayidx19.i.2, align 4, !tbaa !4
  %add10.i.2.2 = add nsw i64 %inc.i.1, %mul9.i.2
  %arrayidx.i.2.2 = getelementptr inbounds float, float* %0, i64 %add10.i.2.2
  %34 = load float, float* %arrayidx.i.2.2, align 4, !tbaa !4
  %35 = load float, float* %arrayidx14.i.2, align 4, !tbaa !4
  %mul15.i.2.2 = fmul float %34, %35
  %add20.i.2.2 = fadd float %add20.i.1.2, %mul15.i.2.2
  store float %add20.i.2.2, float* %arrayidx19.i.2, align 4, !tbaa !4
  %add10.i.3.2 = add nsw i64 %inc.i.2, %mul9.i.2
  %arrayidx.i.3.2 = getelementptr inbounds float, float* %0, i64 %add10.i.3.2
  %36 = load float, float* %arrayidx.i.3.2, align 4, !tbaa !4
  %37 = load float, float* %arrayidx14.i.3, align 4, !tbaa !4
  %mul15.i.3.2 = fmul float %36, %37
  %add20.i.3.2 = fadd float %add20.i.2.2, %mul15.i.3.2
  store float %add20.i.3.2, float* %arrayidx19.i.2, align 4, !tbaa !4
  %inc22.i.2 = or i64 %mul3.i, 3
  %mul9.i.3 = mul nsw i64 %inc22.i.2, %conv.i
  %add18.i.3 = add nsw i64 %mul9.i.3, %add1.i.i
  %arrayidx19.i.3 = getelementptr inbounds float, float* %2, i64 %add18.i.3
  %.pre.i.3 = load float, float* %arrayidx19.i.3, align 4, !tbaa !4
  %add10.i.3.19 = add nsw i64 %mul.i, %mul9.i.3
  %arrayidx.i.3.20 = getelementptr inbounds float, float* %0, i64 %add10.i.3.19
  %38 = load float, float* %arrayidx.i.3.20, align 4, !tbaa !4
  %39 = load float, float* %arrayidx14.i, align 4, !tbaa !4
  %mul15.i.3.24 = fmul float %38, %39
  %add20.i.3.25 = fadd float %.pre.i.3, %mul15.i.3.24
  store float %add20.i.3.25, float* %arrayidx19.i.3, align 4, !tbaa !4
  %add10.i.1.3 = add nsw i64 %inc.i, %mul9.i.3
  %arrayidx.i.1.3 = getelementptr inbounds float, float* %0, i64 %add10.i.1.3
  %40 = load float, float* %arrayidx.i.1.3, align 4, !tbaa !4
  %41 = load float, float* %arrayidx14.i.1, align 4, !tbaa !4
  %mul15.i.1.3 = fmul float %40, %41
  %add20.i.1.3 = fadd float %add20.i.3.25, %mul15.i.1.3
  store float %add20.i.1.3, float* %arrayidx19.i.3, align 4, !tbaa !4
  %add10.i.2.3 = add nsw i64 %inc.i.1, %mul9.i.3
  %arrayidx.i.2.3 = getelementptr inbounds float, float* %0, i64 %add10.i.2.3
  %42 = load float, float* %arrayidx.i.2.3, align 4, !tbaa !4
  %43 = load float, float* %arrayidx14.i.2, align 4, !tbaa !4
  %mul15.i.2.3 = fmul float %42, %43
  %add20.i.2.3 = fadd float %add20.i.1.3, %mul15.i.2.3
  store float %add20.i.2.3, float* %arrayidx19.i.3, align 4, !tbaa !4
  %add10.i.3.3 = add nsw i64 %inc.i.2, %mul9.i.3
  %arrayidx.i.3.3 = getelementptr inbounds float, float* %0, i64 %add10.i.3.3
  %44 = load float, float* %arrayidx.i.3.3, align 4, !tbaa !4
  %45 = load float, float* %arrayidx14.i.3, align 4, !tbaa !4
  %mul15.i.3.3 = fmul float %44, %45
  %add20.i.3.3 = fadd float %add20.i.2.3, %mul15.i.3.3
  store float %add20.i.3.3, float* %arrayidx19.i.3, align 4, !tbaa !4
  ret void
}

; Function Attrs: nounwind
define dso_local void @_pocl_launcher_sgemm_unroll_workgroup(i8** nocapture readonly, { i32, [3 x i64], [3 x i64], [3 x i64] }* nocapture readonly) #0 {
  %3 = bitcast i8** %0 to float***
  %4 = load float**, float*** %3, align 8
  %5 = load float*, float** %4, align 8
  %6 = getelementptr i8*, i8** %0, i64 1
  %7 = bitcast i8** %6 to float***
  %8 = load float**, float*** %7, align 8
  %9 = load float*, float** %8, align 8
  %10 = getelementptr i8*, i8** %0, i64 2
  %11 = bitcast i8** %10 to float***
  %12 = load float**, float*** %11, align 8
  %13 = load float*, float** %12, align 8
  %14 = getelementptr i8*, i8** %0, i64 3
  %15 = bitcast i8** %14 to i32**
  %16 = load i32*, i32** %15, align 8
  %17 = load i32, i32* %16, align 4
  %18 = getelementptr { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i64 0, i32 2, i64 0
  %19 = load i64, i64* %18, align 8
  %20 = getelementptr { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i64 0, i32 2, i64 1
  %21 = load i64, i64* %20, align 8
  %22 = getelementptr { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i64 0, i32 2, i64 2
  %23 = load i64, i64* %22, align 8
  %24 = getelementptr { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i64 0, i32 3, i64 0
  %25 = load i64, i64* %24, align 8
  %26 = getelementptr { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i64 0, i32 3, i64 1
  %27 = load i64, i64* %26, align 8
  %28 = getelementptr { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i64 0, i32 3, i64 2
  %29 = load i64, i64* %28, align 8
  tail call void @_pocl_launcher_sgemm_unroll(float* %5, float* %9, float* %13, i32 %17, i32 undef, i64 undef, i64 undef, i64 undef, i64 %19, i64 %21, i64 %23, i64 %25, i64 %27, i64 %29)
  ret void
}


; Function Attrs: nounwind readnone
define void @pocl.barrier() #3 {
  ret void
}

attributes #0 = { nounwind }
attributes #1 = { noinline nounwind }
attributes #2 = { noinline nounwind }
attributes #3 = { nounwind readnone }

!llvm.ident = !{!0, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !2}
!opencl.kernels = !{!3}

!0 = !{!"clang version 3.7.0  (git@github.com:riscv/riscv-llvm ea484e8fe591e40d9c18ce982f25f006610ea782)"}
!1 = !{!"clang version 3.7.0  (git@github.com:riscv/riscv-llvm 3421e84fb7650d427ea200d94e74732ce2995066)"}
!2 = !{!"clang version 3.7.0  (git@github.com:riscv/riscv-llvm e40d0933929057622d08a7b68fc90773d912ecaa)"}
!3 = !{void (float*, float*, float*, i32, i32, i64, i64, i64, i64, i64, i64, i64, i64, i64)* @_pocl_launcher_sgemm_unroll}
!4 = !{!5, !5, i64 0}
!5 = !{!"float", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C/C++ TBAA"}