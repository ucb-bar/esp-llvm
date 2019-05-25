declare i64 @llvm.hwacha.veidx()

define dso_local {i64, double} @horizontal_add(i64, double*, double "VReg") {
body:
  %idx = call i64 @llvm.hwacha.veidx()
  %arrayidx.i = getelementptr double, double* %1, i64 %idx
  %toadd = load double, double* %arrayidx.i, align 4
  %added = fadd double %toadd, %2

  %vlret = call i64 @llvm.hwacha.vretvl(i64 %0)

  %rv1 = insertvalue { i64, double } undef, i64 %vlret, 0
  %rv2 = insertvalue { i64, double } %rv1, double %added, 1

  ret {i64, double} %rv2
}

define dso_local {i64, double} @init_vector(i64, double*) { ; I need to double check syntax for this metadata
body:
  %idx = call i64 @llvm.hwacha.veidx()
  %arrayidx.i = getelementptr double, double* %1, i64 %idx
  %loaded = load double, double* %arrayidx.i, align 4

  %vlret = call i64 @llvm.hwacha.vretvl(i64 %0)

  %rv1 = insertvalue { i64, double } undef, i64 %vlret, 0
  %rv2 = insertvalue { i64, double } %rv1, double %loaded, 1

  ret {i64, double} %rv2
}

define dso_local {i64} @store_vector(i64, double*, double "VReg") !epilogue !2 {
body:
  %idx = call i64 @llvm.hwacha.veidx()
  %arrayidx.i = getelementptr double, double* %1, i64 %idx
  
  store double %2, double* %arrayidx.i, align 4

  %vlret = call i64 @llvm.hwacha.vretvl(i64 %0)

  %rv1 = insertvalue { i64 } undef, i64 %vlret, 0

  ret {i64} %rv1
}

define dso_local i64 @horizontal_add_launcher(double*, double*) {
  %vl = add i64 0, 1234

  %prologueRet = call {i64, double} @init_vector(i64 %vl, double* %0)

  %prologueVL = extractvalue { i64, double } %prologueRet, 0
  %initAdd = extractvalue { i64, double } %prologueRet, 1

  ; Should have shifted %0 by prologueVL elements to be correct but whatever
  %ret = call {i64, double} @horizontal_add(i64 %prologueVL, double* %0, double %initAdd)

  %newvl = extractvalue { i64, double } %ret, 0
  %accum = extractvalue { i64, double } %ret, 1

  %ret2 = call {i64, double} @horizontal_add(i64 %vl, double* %0, double %accum)

  %newvl2 = extractvalue { i64, double } %ret2, 0
  %accum2 = extractvalue { i64, double } %ret2, 1

  %ret3 = call {i64} @store_vector(i64 %vl, double* %1, double %accum2)

  ret i64 %newvl
}

!opencl.kernels = !{!3, !2, !4}

declare i64 @llvm.hwacha.vretvl(i64)

!2 = !{{i64, double} (i64, double*, double)* @horizontal_add}
!3 = !{{i64, double} (i64, double*)* @init_vector}
!4 = !{{i64} (i64, double*, double)* @store_vector}