// Scalar Registers
foreach Index = 0-63 in {
  def vs#Index : GPR32<Index, "vs"#Index>, DwarfRegNum<[Index]>;
}

// Address Registers
foreach Index = 0-31 in {
  def va#Index : GPR32<Index, "va"#Index>, DwarfRegNum<[Index]>;
}

// Predicate Registers
foreach Index = 0-15 in { // Colin FIXME: do we need separate regclass
  def vp#Index : GPR32<Index, "vp"#Index>, DwarfRegNum<[Index]>;
}

// Vector Registers
foreach Index = 0-255 in {
  def vv#Index : GPR32<Index, "vv"#Index>, DwarfRegNum<[Index]>;
}

// Register Sets
defm VSR : RISCVRegClass<"VSR", [i64,f64], 64, (add
  (sequence "vs%u", 0, 63)), 1>;
defm VAR : RISCVRegClass<"VAR", [i64], 64, (add
  (sequence "va%u", 0, 31)), 1>;
defm VPR : RISCVRegClass<"VPR", [i64], 64, (add
  (sequence "vp%u", 0, 15)), 1>;
defm VVR : RISCVRegClass<"VVR", [i64,f64], 64, (add
  (sequence "vv%u", 0, 255)), 1>;
