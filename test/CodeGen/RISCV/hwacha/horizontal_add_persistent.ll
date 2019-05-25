declare i64 @llvm.hwacha.veidx()

define dso_local {i64, float} @horizontal_add(i64, float*, float "VReg") {
body:
  %idx = call i64 @llvm.hwacha.veidx()
  %arrayidx.i = getelementptr float, float* %1, i64 %idx
  %toadd = load float, float* %arrayidx.i, align 4
  %added = fadd float %toadd, %2

  %vlret = call i64 @llvm.hwacha.vretvl(i64 %0)

  %rv1 = insertvalue { i64, float } undef, i64 %vlret, 0
  %rv2 = insertvalue { i64, float } %rv1, float %added, 1

  ret {i64, float} %rv2
}


define dso_local {i64, float} @init_vector(i64, float*) { ; I need to double check syntax for this metadata
body:
  %idx = call i64 @llvm.hwacha.veidx()
  %arrayidx.i = getelementptr float, float* %1, i64 %idx
  %loaded = load float, float* %arrayidx.i, align 4

  %vlret = call i64 @llvm.hwacha.vretvl(i64 %0)

  %rv1 = insertvalue { i64, float } undef, i64 %vlret, 0
  %rv2 = insertvalue { i64, float } %rv1, float %loaded, 1

  ret {i64, float} %rv2
}

define dso_local {i64} @store_vector(i64, float*, float "VReg") !epilogue !2 {
body:
  %idx = call i64 @llvm.hwacha.veidx()
  %arrayidx.i = getelementptr float, float* %1, i64 %idx
  
  store float %2, float* %arrayidx.i, align 4

  %vlret = call i64 @llvm.hwacha.vretvl(i64 %0)

  %rv1 = insertvalue { i64 } undef, i64 %vlret, 0

  ret {i64} %rv1
}

define dso_local i64 @horizontal_add_launcher(float*, float*) {
  %vl = add i64 0, 1234

  %prologueRet = call {i64, float} @init_vector(i64 %vl, float* %0)

  %prologueVL = extractvalue { i64, float } %prologueRet, 0
  %initAdd = extractvalue { i64, float } %prologueRet, 1

  ; Should have shifted %0 by prologueVL elements to be correct but whatever
  %ret = call {i64, float} @horizontal_add(i64 %prologueVL, float* %0, float %initAdd)

  %newvl = extractvalue { i64, float } %ret, 0
  %accum = extractvalue { i64, float } %ret, 1

  %ret2 = call {i64, float} @horizontal_add(i64 %vl, float* %0, float %accum)

  %newvl2 = extractvalue { i64, float } %ret2, 0
  %accum2 = extractvalue { i64, float } %ret2, 1

  %ret3 = call {i64} @store_vector(i64 %vl, float* %1, float %accum2)

  ret i64 %newvl
}

!opencl.kernels = !{!3, !2, !4}

declare i64 @llvm.hwacha.vretvl(i64)

!2 = !{{i64, float} (i64, float*, float)* @horizontal_add}
!3 = !{{i64, float} (i64, float*)* @init_vector}
!4 = !{{i64} (i64, float*, float)* @store_vector}