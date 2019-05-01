; Function Attrs: nounwind
declare i64 @llvm.hwacha.veidx()

; Function Attrs: noinline nounwind
define dso_local i64 @_pocl_launcher_saxpy(i64, float*, float*, float) {
body:
  %idx = call i64 @llvm.hwacha.veidx()
  %arrayidx.i = getelementptr float, float* %1, i64 %idx
  %tomul = load float, float* %arrayidx.i, align 4
  %mul.i = fmul float %tomul, %3

  %arrayidx2.i = getelementptr float, float* %2, i64 %idx
  %toadd = load float, float* %arrayidx2.i, align 4
  %add.i = fadd float %toadd, %mul.i
  store float %add.i, float* %arrayidx2.i, align 4
  ret i64 %0
}

define dso_local i64 @_pocl_launcher_saxpy_workgroup(float*, float*, float) {
  %vl = add i64 0, 1234
  %newvl = call i64 @_pocl_launcher_saxpy(i64 %vl, float* %0, float* %1, float %2)
  ret i64 %newvl
}

!opencl.kernels = !{!2}

!2 = !{i64 (i64, float*, float*, float)* @_pocl_launcher_saxpy} 