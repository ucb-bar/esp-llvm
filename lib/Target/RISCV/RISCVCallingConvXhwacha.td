//===----------------------------------------------------------------------===//
// RV64 return value calling convention
//===----------------------------------------------------------------------===//
def RetCC_RISCVXhwacha : CallingConv<[
  //Only can have void return type FIXME: how do we assert
  CCIfType<[isVoid], CCAssignToReg<[vs0]>>
]>;

//===----------------------------------------------------------------------===//
// RV64 argument calling conventions
//===----------------------------------------------------------------------===//
def CC_RISCVXhwacha : CallingConv<[
  //Promote small int types to i64
  CCIfType<[i8, i16, i32], CCPromoteToType<i64>>,

  // All arguments are passed as scalar registers for now
  CCIfType<[i64], CCAssignToReg< 
  [vs1, vs2, vs3, vs4, vs5, vs6, vs7, vs8,
   vs9, vs10, vs11, vs12, vs13, vs14, vs15, vs16,
   vs17, vs18, vs19, vs20, vs21, vs22, vs23, vs24,
   vs25, vs26, vs27, vs28, vs29, vs30, vs31, vs32,
   vs33, vs34, vs35, vs36, vs37, vs38, vs39, vs40,
   vs41, vs42, vs43, vs44, vs45, vs46, vs47, vs48,
   vs49, vs50, vs51, vs52, vs53, vs54, vs55, vs56,
   vs57, vs58, vs59, vs60, vs61, vs62, vs63] >>,
  //Single precision floating point
  CCIfType<[f32], CCAssignToReg< 
  [vs1, vs2, vs3, vs4, vs5, vs6, vs7, vs8,
   vs9, vs10, vs11, vs12, vs13, vs14, vs15, vs16,
   vs17, vs18, vs19, vs20, vs21, vs22, vs23, vs24,
   vs25, vs26, vs27, vs28, vs29, vs30, vs31, vs32,
   vs33, vs34, vs35, vs36, vs37, vs38, vs39, vs40,
   vs41, vs42, vs43, vs44, vs45, vs46, vs47, vs48,
   vs49, vs50, vs51, vs52, vs53, vs54, vs55, vs56,
   vs57, vs58, vs59, vs60, vs61, vs62, vs63] >>,
  //double precision floating point
  CCIfType<[f64], CCAssignToReg< 
  [vs1, vs2, vs3, vs4, vs5, vs6, vs7, vs8,
   vs9, vs10, vs11, vs12, vs13, vs14, vs15, vs16,
   vs17, vs18, vs19, vs20, vs21, vs22, vs23, vs24,
   vs25, vs26, vs27, vs28, vs29, vs30, vs31, vs32,
   vs33, vs34, vs35, vs36, vs37, vs38, vs39, vs40,
   vs41, vs42, vs43, vs44, vs45, vs46, vs47, vs48,
   vs49, vs50, vs51, vs52, vs53, vs54, vs55, vs56,
   vs57, vs58, vs59, vs60, vs61, vs62, vs63] >>

]>;
