define dso_local i64 @kernel_output_s0_x___block_id_x(i64 "noelim" %vl, i64 %consumed, i32 %t2, i8* noalias %input, i8* noalias %output) local_unnamed_addr #0 {
body:
  %0 = call i64 @llvm.hwacha.veidx() #12
  %output.s0.x.__block_id_x = add nsw i64 %0, %consumed
  %1 = sext i32 %t2 to i64
  %2 = add nsw i64 %output.s0.x.__block_id_x, %1
  %3 = bitcast i8* %input to i32*
  %4 = getelementptr inbounds i32, i32* %3, i64 %2
  %5 = load i32, i32* %4, align 4
  %6 = mul i32 %5, 2
  %7 = bitcast i8* %output to i32*
  %8 = getelementptr inbounds i32, i32* %7, i64 %output.s0.x.__block_id_x
  store i32 %6, i32* %8, align 4
  ret i64 0
}


define dso_local void @stripmine(i32 %t2, i8* noalias %input, i8* noalias %output) #10 {
entry:
  %vlret0 = call i64 @kernel_output_s0_x___block_id_x(i64 "noelim" 5, i64 5, i32 5, i8* %input, i8* %output)
  br label %loop

loop:
  %counter = phi i64 [ 1, %entry ], [ %total, %loop ]
  %wantedvl = sub i64 100, %counter
  %vlret = call i64 @kernel_output_s0_x___block_id_x(i64 "noelim" %wantedvl, i64 %counter, i32 %t2, i8* %input, i8* %output)
  %total = add i64 %counter, %vlret
  %exitcond = icmp eq i64 %total, 100
  br i1 %exitcond, label %loop, label %afterloop

afterloop:
  ret void
}


; Function Attrs: nounwind readnone
declare i64 @llvm.hwacha.veidx() #8

!opencl.kernels = !{!3}

!3 = !{i64 (i64, i64, i32, i8*, i8*)* @kernel_output_s0_x___block_id_x}

