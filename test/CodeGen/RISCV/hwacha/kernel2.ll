define dso_local void @test(i64 addrspace(1)* nocapture %in) nounwind {
entry:
  %arrayidx = getelementptr inbounds i64, i64 addrspace(1)* %in, i64 1
  ret void
}

define dso_local void @launchTest(i64 addrspace(1)* nocapture %in) {
    call void @test(i64 addrspace(1)* nocapture %in)
    ret void
}

!opencl.kernels = !{!0}
!0 = !{void (i64 addrspace(1)*)* @test}