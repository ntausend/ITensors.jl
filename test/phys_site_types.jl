using ITensors,
      Test

@testset "Physics Sites" begin

  N = 10

  @testset "Spin Half sites" begin

    s = siteind("S=1/2")
    @test hastags(s,"S=1/2,Site")
    @test dim(s) == 2

    s = siteind("S=1/2";conserve_qns=true)
    @test hastags(s,"S=1/2,Site")
    @test dim(s) == 2
    @test nblocks(s) == 2
    @test qn(s,1) == QN("Sz",+1)
    @test qn(s,2) == QN("Sz",-1)

    s = siteinds("S=1/2",N)

    @test state(s[1],"Up") == s[1](1)
    @test state(s[1],"Dn") == s[1](2)
    @test_throws ArgumentError state(s[1],"Fake")

    Sz5 = op("Sz",s,5)
    @test hasinds(Sz5,s[5]',s[5])
     
    @test_throws ArgumentError op(s, "Fake", 2)
    @test Array(op("Id",s,3),s[3]',s[3])  ≈ [ 1.0  0.0; 0.0  1.0]
    @test Array(op("S+",s,3),s[3]',s[3])  ≈ [ 0.0  1.0; 0.0  0.0]
    @test Array(op("S⁺",s,3),s[3]',s[3])  ≈ [ 0.0  1.0; 0.0  0.0]
    @test Array(op("S-",s,4),s[4]',s[4])  ≈ [ 0.0  0.0; 1.0  0.0]
    @test Array(op("S⁻",s,4),s[4]',s[4])  ≈ [ 0.0  0.0; 1.0  0.0]
    @test Array(op("Sx",s,2),s[2]',s[2])  ≈ [ 0.0  0.5; 0.5  0.0]
    @test Array(op("Sˣ",s,2),s[2]',s[2])  ≈ [ 0.0  0.5; 0.5  0.0]
    @test Array(op("iSy",s,2),s[2]',s[2]) ≈ [ 0.0  0.5;-0.5  0.0]
    @test Array(op("iSʸ",s,2),s[2]',s[2]) ≈ [ 0.0  0.5;-0.5  0.0]
    @test Array(op("Sy",s,2),s[2]',s[2])  ≈ [0.0  -0.5im; 0.5im  0.0]
    @test Array(op("Sʸ",s,2),s[2]',s[2])  ≈ [0.0  -0.5im; 0.5im  0.0]
    @test Array(op("Sz",s,2),s[2]',s[2])  ≈ [ 0.5  0.0; 0.0 -0.5]
    @test Array(op("Sᶻ",s,2),s[2]',s[2])  ≈ [ 0.5  0.0; 0.0 -0.5]
  end

  @testset "Spin One sites" begin
    s = siteinds("S=1",N)

    @test state(s[1],"Up") == s[1](1)
    @test state(s[1],"0")  == s[1](2)
    @test state(s[1],"Dn") == s[1](3)
    @test_throws ArgumentError state(s[1],"Fake")

    Sz5 = op("Sz",s,5)
    @test hasinds(Sz5,s[5]',s[5])
     
    @test_throws ArgumentError op(s, "Fake", 2)
    @test Array(op("Id",s,3),s[3]',s[3])  ≈ [ 1.0 0.0 0.0; 0.0 1.0 0.0; 0.0 0.0 1.0]
    @test Array(op("S+",s,3),s[3]',s[3]) ≈ [ 0 √2 0; 0 0 √2; 0 0 0]
    @test Array(op("S⁺",s,3),s[3]',s[3]) ≈ [ 0 √2 0; 0 0 √2; 0 0 0]
    @test Array(op("S-",s,3),s[3]',s[3]) ≈ [ 0 0 0; √2 0 0; 0.0 √2 0]
    @test Array(op("S⁻",s,3),s[3]',s[3]) ≈ [ 0 0 0; √2 0 0; 0.0 √2 0]
    @test Array(op("Sx",s,3),s[3]',s[3]) ≈ [ 0 1/√2 0; 1/√2 0 1/√2; 0 1/√2 0]
    @test Array(op("Sˣ",s,3),s[3]',s[3]) ≈ [ 0 1/√2 0; 1/√2 0 1/√2; 0 1/√2 0]
    @test Array(op("iSy",s,3),s[3]',s[3]) ≈ [ 0 1/√2 0; -1/√2 0 1/√2; 0 -1/√2 0]
    @test Array(op("iSʸ",s,3),s[3]',s[3]) ≈ [ 0 1/√2 0; -1/√2 0 1/√2; 0 -1/√2 0]
    @test Array(op("Sy",s,3),s[3]',s[3]) ≈ [ 0 -1/√2im 0; +1/√2im 0 -1/√2im; 0 +1/√2im 0]
    @test Array(op("Sʸ",s,3),s[3]',s[3]) ≈ [ 0 -1/√2im 0; +1/√2im 0 -1/√2im; 0 +1/√2im 0]
    @test Array(op("Sz",s,2),s[2]',s[2]) ≈ [1.0 0 0; 0 0 0; 0 0 -1.0]
    @test Array(op("Sᶻ",s,2),s[2]',s[2]) ≈ [1.0 0 0; 0 0 0; 0 0 -1.0]
    @test Array(op("Sz2",s,2),s[2]',s[2]) ≈ [1.0 0 0; 0 0 0; 0 0 +1.0]
    @test Array(op("Sx2",s,2),s[2]',s[2]) ≈ [0.5 0 0.5;0 1.0 0;0.5 0 0.5]
    @test Array(op("Sy2",s,2),s[2]',s[2]) ≈ [0.5 0 -0.5;0 1.0 0;-0.5 0 0.5]
  end

  @testset "Fermion sites" begin
    s = siteind("Fermion")

    @test state(s,"0")   == s(1)
    @test state(s,"1")   == s(2)
    @test_throws ArgumentError state(s,"Fake")

    N = op(s,"N")
    @test hasinds(N,s',s)
     
    @test_throws ArgumentError op(s, "Fake")
    N = Array(op(s,"N"),s',s) 
    @test N ≈ [0. 0; 0 1]
    C = Array(op(s,"C"),s',s) 
    @test C ≈ [0. 1; 0 0]
    Cdag = Array(op(s,"Cdag"),s',s) 
    @test Cdag ≈ [0. 0; 1 0]
    F = Array(op(s,"F"),s',s) 
    @test F ≈ [1. 0; 0 -1]

    @test has_fermion_string("C", s)
    @test has_fermion_string("Cdag", s)
    @test !has_fermion_string("N", s)
  end

  @testset "Electron sites" begin
    s = siteind("Electron")

    @test state(s,"0")    == s(1)
    @test state(s,"Up")   == s(2)
    @test state(s,"Dn")   == s(3)
    @test state(s,"UpDn") == s(4)
    @test_throws ArgumentError state(s,"Fake")

    Nup = op(s,"Nup")
    @test hasinds(Nup,s',s)
     
    @test_throws ArgumentError op(s, "Fake")
    Nup = Array(op(s,"Nup"),s',s) 
    @test Nup ≈ [0. 0 0 0; 0 1 0 0; 0 0 0 0; 0 0 0 1]
    Ndn = Array(op(s,"Ndn"),s',s) 
    @test Ndn ≈ [0. 0 0 0; 0 0 0 0; 0 0 1 0; 0 0 0 1]
    Ntot = Array(op(s,"Ntot"),s',s) 
    @test Ntot ≈ [0. 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 2]
    Cup = Array(op(s,"Cup"),s',s) 
    @test Cup ≈ [0. 1 0 0; 0 0 0 0; 0 0 0 1; 0 0 0 0]
    Cdagup = Array(op(s,"Cdagup"),s',s) 
    @test Cdagup ≈ [0. 0 0 0; 1 0 0 0; 0 0 0 0; 0 0 1 0]
    Cdn = Array(op(s,"Cdn"),s',s) 
    @test Cdn ≈ [0. 0 1 0; 0 0 0 -1; 0 0 0 0; 0 0 0 0]
    Cdagdn = Array(op(s,"Cdagdn"),s',s) 
    @test Cdagdn ≈ [0. 0 0 0; 0 0 0 0; 1 0 0 0; 0 -1 0 0]
    F = Array(op(s,"F"),s',s) 
    @test F ≈ [1. 0 0 0; 0 -1 0 0; 0 0 -1 0; 0 0 0 1]
    Fup = Array(op(s,"Fup"),s',s) 
    @test Fup ≈ [1. 0 0 0; 0 -1 0 0; 0 0 1 0; 0 0 0 -1]
    Fdn3 = Array(op(s,"Fdn"),s',s) 
    @test Fdn3 ≈ [1. 0 0 0; 0 1 0 0; 0 0 -1 0; 0 0 0 -1]
    Sz3 = Array(op(s,"Sz"),s',s) 
    @test Sz3 ≈ [0. 0 0 0; 0 0.5 0 0; 0 0 -0.5 0; 0 0 0 0]
    Sx3 = Array(op(s,"Sx"),s',s) 
    @test Sx3 ≈ [0. 0 0 0; 0 0 0.5 0; 0 0.5 0 0; 0 0 0 0]
    Sp3 = Array(op(s,"S+"),s',s) 
    @test Sp3 ≈ [0. 0 0 0; 0 0 1 0; 0 0 0 0; 0 0 0 0]
    Sm3 = Array(op(s,"S-"),s',s) 
    @test Sm3 ≈ [0. 0 0 0; 0 0 0 0; 0 1 0 0; 0 0 0 0]

    @test has_fermion_string("Cup", s)
    @test has_fermion_string("Cdagup", s)
    @test has_fermion_string("Cdn", s)
    @test has_fermion_string("Cdagdn", s)
    @test !has_fermion_string("N", s)
  end

  @testset "tJ sites" begin
    s = siteind("tJ")

    @test state(s,"0")    == s(1)
    @test state(s,"Up")   == s(2)
    @test state(s,"Dn")   == s(3)
    @test_throws ArgumentError state(s,"Fake")

    @test_throws ArgumentError op(s, "Fake")
    Nup = op(s,"Nup")
    @test Nup[2,2] ≈ 1.0
    Ndn = op(s,"Ndn")
    @test Ndn[3,3] ≈ 1.0
    Ntot = op(s,"Ntot")
    @test Ntot[2,2] ≈ 1.0
    @test Ntot[3,3] ≈ 1.0
    Cup = Array(op(s,"Cup"),s',s) 
    @test Cup ≈ [0. 1 0; 0 0 0; 0 0 0]
    Cdup = Array(op(s,"Cdagup"),s',s) 
    @test Cdup ≈ [0 0 0; 1. 0 0; 0 0 0]
    Cdn = Array(op(s,"Cdn"),s',s) 
    @test Cdn ≈ [0. 0. 1; 0 0 0; 0 0 0]
    Cddn = Array(op(s,"Cdagdn"),s',s) 
    @test Cddn ≈ [0 0 0; 0. 0 0; 1 0 0]
    FP = Array(op(s,"FP"),s',s) 
    @test FP ≈ [1.0 0. 0; 0 -1.0 0; 0 0 -1.0]
    Fup = Array(op(s,"Fup"),s',s) 
    @test Fup ≈ [1.0 0. 0; 0 -1.0 0; 0 0 1.0]
    Fdn = Array(op(s,"Fdn"),s',s) 
    @test Fdn ≈ [1.0 0. 0; 0 1.0 0; 0 0 -1.0]
    Sz = Array(op(s,"Sz"),s',s) 
    @test Sz ≈ [0.0 0. 0; 0 0.5 0; 0 0 -0.5]
    Sx = Array(op(s,"Sx"),s',s) 
    @test Sx ≈ [0.0 0. 0; 0 0 1; 0 1 0]
    Sp = Array(op(s,"Splus"),s',s) 
    @test Sp ≈ [0.0 0. 0; 0 0 1.0; 0 0 0]
    Sm = Array(op(s,"Sminus"),s',s) 
    @test Sm ≈ [0.0 0. 0; 0 0 0; 0 1.0 0]

    @test has_fermion_string("Cup", s)
    @test has_fermion_string("Cdagup", s)
    @test has_fermion_string("Cdn", s)
    @test has_fermion_string("Cdagdn", s)
    @test !has_fermion_string("N", s)
  end

end

nothing
