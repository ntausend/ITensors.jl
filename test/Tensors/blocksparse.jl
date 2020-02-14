using ITensors,
      Test

@testset "BlockSparseTensor basic functionality" begin

  # Indices
  indsA = ([2,3],[4,5])

  # Locations of non-zero blocks
  locs = [(1,2),(2,1)]

  A = BlockSparseTensor(locs,indsA...)
  randn!(A)

  @test blockdims(A,(1,2)) == (2,5)
  @test blockdims(A,(2,1)) == (3,4)
  @test nnzblocks(A) == 2
  @test nnz(A) == 2*5+3*4
  @test inds(A) == ([2,3],[4,5])
  @test isblocknz(A,(2,1))
  @test isblocknz(A,(1,2))
  @test !isblocknz(A,(1,1))
  @test !isblocknz(A,(2,2))
  @test findblock(A,(2,1))==1
  @test findblock(A,(1,2))==2
  @test isnothing(findblock(A,(1,1)))
  @test isnothing(findblock(A,(2,2)))

  # Test different ways of getting nnz
  @test nnz(blockoffsets(A),inds(A)) == nnz(A)

  A[1,5] = 15
  A[2,5] = 25

  @test A[1,1] == 0
  @test A[1,5] == 15
  @test A[2,5] == 25

  D = dense(A)

  @test D == A

  for I in eachindex(A)
    @test D[I] == A[I]
  end

  A12 = blockview(A,(1,2))

  @test dims(A12) == (2,5)

  for I in eachindex(A12)
    @test A12[I] == A[I+CartesianIndex(0,4)]
  end

  B = BlockSparseTensor(undef,locs,indsA)
  randn!(B)

  C = A+B

  for I in eachindex(C)
    @test C[I] == A[I]+B[I]
  end

  Ap = permutedims(A,(2,1))

  @test blockdims(Ap,(1,2)) == (4,3)
  @test blockdims(Ap,(2,1)) == (5,2)
  @test nnz(A) == nnz(Ap)
  @test nnzblocks(A) == nnzblocks(Ap)

  for I in eachindex(C)
    @test A[I] == Ap[permute(I,(2,1))]
  end

  @testset "BlockSparseTensor setindex! add block" begin
    T = BlockSparseTensor([2,3],[4,5])

    for I in eachindex(C)
      @test T[I] == 0.0
    end
    @test nnz(T) == 0
    @test nnzblocks(T) == 0
    @test !isblocknz(T,(1,1))
    @test !isblocknz(T,(2,1))
    @test !isblocknz(T,(1,2))
    @test !isblocknz(T,(2,2))

    T[1,1] = 1.0

    @test T[1,1] == 1.0
    @test nnz(T) == 8
    @test nnzblocks(T) == 1
    @test isblocknz(T,(1,1))
    @test !isblocknz(T,(2,1))
    @test !isblocknz(T,(1,2))
    @test !isblocknz(T,(2,2))

    T[4,8] = 2.0

    @test T[4,8] == 2.0
    @test nnz(T) == 8+15
    @test nnzblocks(T) == 2
    @test isblocknz(T,(1,1))
    @test !isblocknz(T,(2,1))
    @test !isblocknz(T,(1,2))
    @test isblocknz(T,(2,2))

    T[1,6] = 3.0

    @test T[1,6] == 3.0
    @test nnz(T) == 8+15+10
    @test nnzblocks(T) == 3
    @test isblocknz(T,(1,1))
    @test !isblocknz(T,(2,1))
    @test isblocknz(T,(1,2))
    @test isblocknz(T,(2,2))

    T[4,2] = 4.0

    @test T[4,2] == 4.0
    @test nnz(T) == 8+15+10+12
    @test nnzblocks(T) == 4
    @test isblocknz(T,(1,1))
    @test isblocknz(T,(2,1))
    @test isblocknz(T,(1,2))
    @test isblocknz(T,(2,2))
  end

  @testset "Add with different blocks" begin
    # Indices
    inds = ([2,3],[4,5])

    # Locations of non-zero blocks
    locsA = [(1,1),(1,2),(2,2)]
    A = BlockSparseTensor(locsA,inds...)
    randn!(A)

    locsB = [(1,2),(2,1)]
    B = BlockSparseTensor(locsB,inds...)
    randn!(B)

    R = A+B

    @test nnz(R) == dim(R)
    for I in eachindex(R)
      @test R[I] == A[I] + B[I]
    end
  end

  @testset "permutedims!! with different blocks" begin
    # Indices
    indsA = ([2,3],[4,5])

    # Locations of non-zero blocks
    locsA = [(1,2),(2,1)]
    A = BlockSparseTensor(locsA,indsA...)
    randn!(A)

    perm = (2,1)

    locsB = [(2,1)]
    indsB = permute(indsA,perm)
    B = BlockSparseTensor(locsB,indsB...)
    randn!(B)

    R = permutedims!!(B,A,perm)

    @test nnz(R) == nnz(A)
    for I in eachindex(A)
      @test R[permute(I,perm)] == A[I]
    end
  end

  @testset "Contract" begin
    indsA = ([2,3],[4,5])
    locsA = [(1,1),(2,2),(2,1),(1,2)]
    A = BlockSparseTensor(locsA,indsA...)
    randn!(A)

    indsB = ([4,5],[3,2])
    locsB = [(1,2),(2,1),(1,1)]
    B = BlockSparseTensor(locsB,indsB...)
    randn!(B)

    R = contract(A,(1,-1),B,(-1,2))

    DA = dense(A)
    DB = dense(B)
    DR = contract(DA,(1,-1),DB,(-1,2))

    for I in eachindex(R)
      @test R[I] ≈ DR[I]
    end
  end

  @testset "reshape" begin
    indsA = ([2,3],[4,5])
    locsA = [(2,1),(1,2)]
    A = BlockSparseTensor(locsA,indsA...)
    randn!(A)

    indsB = ([8,12,10,15],)
    B = reshape(A,indsB)

    @test nnzblocks(A)==nnzblocks(B)
    @test nnz(A)==nnz(B)
    for i in 1:nnzblocks(B)
      blockA = blockview(A,i)
      blockB = blockview(B,i)
      @test reshape(blockA,size(blockB))==blockB
    end
  end

  @testset "permute_combine" begin
    indsA = ([2,3],[4,5],[6,7,8])
    locsA = [(2,1,1),(1,2,1),(2,2,3)]
    A = BlockSparseTensor(locsA,indsA...)
    randn!(A)

    B = Tensors.permute_combine(A,3,(2,1))

    @test nnzblocks(A)==nnzblocks(B)
    @test nnz(A)==nnz(B)
		
    Ap = permutedims(A,(3,2,1))

    for i in 1:nnzblocks(A)
      blockAp = blockview(Ap,i)
      blockB = blockview(B,i)
      @test reshape(blockAp,size(blockB))==blockB
    end
  end

  @testset "svd" begin

    @testset "svd example 1" begin
      A = BlockSparseTensor([(2,1),(1,2)],[2,2],[2,2])
      randn!(A)
      U,S,V = svd(A)
      @test isapprox(norm(array(U)*array(S)*array(V)'-array(A)),0; atol=1e-15)
    end

    @testset "svd example 2" begin
      A = BlockSparseTensor([(1,2),(2,3)],[2,2],[3,2,3])
      randn!(A)
      U,S,V = svd(A)
      @test isapprox(norm(array(U)*array(S)*array(V)'-array(A)),0.0; atol=1e-14)
    end

    @testset "svd example 3" begin
      A = BlockSparseTensor([(2,1),(3,2)],[3,2,3],[2,2])
      randn!(A)
      U,S,V = svd(A)
      @test isapprox(norm(array(U)*array(S)*array(V)'-array(A)),0.0; atol=1e-14)
    end

  end

end

