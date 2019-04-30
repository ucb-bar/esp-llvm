
define dso_local i64 @output.s0.x.__block_id_x(i64 %vl, i32 %t2, i8* noalias %input, i8* noalias %output) #11 {
body:
  %0 = call i64 @llvm.hwacha.veidx() #14
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
  ret i64 %vl
}

define dso_local void @kernel_output_s0_x___block_id_x(i32 %t2, i8* noalias %input, i8* noalias %output) #10 {
body:
  %vl = add i64 0, 5
  %vlret = call i64 @output.s0.x.__block_id_x(i64 %vl, i32 %t2, i8* %input, i8* %output)
  ret void
}


; Function Attrs: nounwind readnone
declare i64 @llvm.hwacha.veidx() #8

!opencl.kernels = !{!3}

!3 = !{i64 (i64, i32, i8*, i8*)* @output.s0.x.__block_id_x}