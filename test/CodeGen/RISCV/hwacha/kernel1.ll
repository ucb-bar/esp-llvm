; Function Attrs: nounwind
declare i64 @llvm.hwacha.veidx() #0

; Function Attrs: noinline nounwind
define dso_local void @_pocl_launcher_saxpy(i32*, i32*, i32, i32, i64, i64, i64, i64, i64, i64, i64, i64, i64) {
  %mul.i.i = shl i64 %7, 9
  %add.i.i = add i64 %mul.i.i, %10
  %call.i.i.i = call i64 @llvm.hwacha.veidx() #0
  %add1.i.i = add i64 %add.i.i, %call.i.i.i
  %sext = shl i64 %add1.i.i, 32
  %idxprom.i = ashr exact i64 %sext, 32
  %arrayidx.i = getelementptr inbounds i32, i32* %0, i64 %idxprom.i
  %14 = load i32, i32* %arrayidx.i, align 4
  %mul.i = mul i32 %14, %2
  %sext1 = shl i64 %add1.i.i, 32
  %idxprom1.i = ashr exact i64 %sext1, 32
  %arrayidx2.i = getelementptr inbounds i32, i32* %1, i64 %idxprom1.i
  %15 = load i32, i32* %arrayidx2.i, align 4
  %add.i = add i32 %15, %mul.i
  store i32 %add.i, i32* %arrayidx2.i, align 4
  ret void
}

define dso_local void @_pocl_launcher_saxpy_workgroup(i8**, { i32, [3 x i64], [3 x i64], [3 x i64] }*) {
  %3 = bitcast i8** %0 to i32***
  %4 = load i32**, i32*** %3, align 8
  %5 = load i32*, i32** %4, align 8
  %6 = getelementptr i8*, i8** %0, i64 1
  %7 = bitcast i8** %6 to i32***
  %8 = load i32**, i32*** %7, align 8
  %9 = load i32*, i32** %8, align 8
  %10 = getelementptr i8*, i8** %0, i64 2
  %11 = bitcast i8** %10 to i32**
  %12 = load i32*, i32** %11, align 8
  %13 = load i32, i32* %12, align 4
  %14 = getelementptr { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i64 0, i32 2, i64 0
  %15 = load i64, i64* %14, align 8
  %16 = getelementptr { i32, [3 x i64], [3 x i64], [3 x i64] }, { i32, [3 x i64], [3 x i64], [3 x i64] }* %1, i64 0, i32 3, i64 0
  %17 = load i64, i64* %16, align 8
  call void @_pocl_launcher_saxpy(i32* %5, i32* %9, i32 %13, i32 undef, i64 undef, i64 undef, i64 undef, i64 %15, i64 undef, i64 undef, i64 %17, i64 undef, i64 undef)
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
!2 = !{void (i32*, i32*, i32, i32, i64, i64, i64, i64, i64, i64, i64, i64, i64)* @_pocl_launcher_saxpy}