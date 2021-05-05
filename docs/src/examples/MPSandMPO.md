# MPS and MPO Examples

## Applying a Single-site Operator to an MPS

In many applications one needs to modify a matrix product 
state (MPS) by multiplying it with an operator that acts 
only on a single site. This is actually a very straightforward
operation and this formula shows you how to do it in ITensor.

Say we have an operator ``G^{s'_3}_{s_3}`` which
which acts non-trivially on site 3 of our MPS `psi`
as in the following diagram:

![](mps_onesite_figures/operator_app_mps.png)

To carry out this operation, contract the operator G with the MPS tensor for site 3,
removing the prime from the ``s'_3`` index afterward:

![](mps_onesite_figures/operator_contract.png)

```julia
newA = G * psi[3]
noprime!(newA)
```

Finally, put the new tensor back into MPS `psi` to update its third MPS tensor:

```julia
psi[3] = newA
```

Afterward, we can visualize the modified MPS as:

![](mps_onesite_figures/updated_mps.png)

As a technical note, if you are working in a context where gauge or orthogonality
properties of the MPS are important, such as in time evolution using two-site gates, 
then you may want to call `orthogonalize!(psi,3)`
before modifying the tensor at site 3, which will ensure that the MPS remains in a 
well-defined orthogonal gauge centered on site 3. Modifying a tensor which is left- or right-orthogonal
(i.e. not the "center" tensor of the gauge) will destroy the gauge condition and 
require extra operations to restore it. (Calling `orthogonalize!` method will automatically
fix this but will have to do extra work to do so.)


## Applying a Two-site Operator to an MPS

A very common operation with matrix product states (MPS) is 
multiplication by a two-site operator or "gate" which modifies 
the MPS. This procedure can be carried out in an efficient, 
controlled way which is adaptive in the MPS bond dimension.

Say we have an operator ``G^{s'_3 s'_4}_{s_3 s_4}`` which
is our gate and which acts on physical sites 3 and 4 of our MPS `psi`,
as in the following diagram:

![](twosite_figures/gate_app_mps.png)

To apply this gate in a controlled manner, first 'gauge' the MPS `psi` such
that either site 3 or 4 is the *orthogonality center*. Here we make site 3
the center:

```julia
orthogonalize!(psi,3)
```

![](twosite_figures/gate_gauge.png)

The other MPS tensors are now either left-orthogonal or right-orthogonal and can be
left out of further steps without producing incorrect results.

Next, contract the gate tensor G with the MPS tensors for sites 3 and 4

![](twosite_figures/gate_contract.png)

```julia
wf = (psi[3] * psi[4]) * G
noprime!(wf)
```

Finally, use the singular value decomposition (SVD) to factorize the
resulting tensor, multiplying the singular values into either U or V.
Assign these two tensors back into the MPS to update it.

![](twosite_figures/gate_svd.png)

```julia
inds3 = uniqueinds(psi[3],psi[4])
U,S,V = svd(wf,inds3,cutoff=1E-8)
psi[3] = U
psi[4] = S*V
```

The call to `uniqueinds(psi[3])` analyzes the indices of `psi[3]` and `psi[4]` 
and finds any which are unique to just `psi[3]`, saving this collection of indices as `inds3`.
Passing this collection of indices to the `svd` function tells it to treat any indices 
that are unique to `psi[3]` as the indices which should go onto the `U` tensor afterward.
We also set a truncation error cutoff of 1E-8 in the call to `svd` to truncate 
the smallest singular values and control the size of the resulting MPS.
Other cutoff values can be used, depending on the desired accuracy,
as well as limits on the maximum bond dimension (`maxdim` keyword argument).

**Complete code example**

```julia
orthogonalize!(psi,3)

wf = (psi[3] * psi[4]) * G
noprime!(wf)

inds3 = uniqueinds(psi[3],psi[4])
U,S,V = svd(wf,inds3,cutoff=1E-8)
psi[3] = U
psi[4] = S*V
```

## Computing the Entanglement Entropy of an MPS

A key advantage of using the matrix product state (MPS) format to represent quantum wavefunctions is that it allows one to efficiently compute the entanglement entropy of any left-right bipartition of the system in one dimension, or for a two-dimensional system any "cut" along the MPS path.

Say that we have obtained an MPS `psi` of length N and we wish to compute the entanglement entropy of a bipartition of the system into a region "A" which consists of sites 1,2,...,b and a region B consisting of sites b+1,b+2,...,N.

Then the following code formula can be used to accomplish this task:

```julia
orthogonalize!(psi, b)
U,S,V = svd(psi[b], (linkind(psi, b-1), siteind(psi,b)))
SvN = 0.0
for n=1:dim(S, 1)
  p = S[n,n]^2
  SvN -= p * log(p)
end
```
    
As a brief explanation of the code above, the call to `orthogonalize!(psi,b)`
shifts the orthogonality center to site `b` of the MPS. 

The call to the `svd` routine says to treat the link (virtual or bond) Index connecting the b'th MPS tensor `psi[b]` and the b'th physical Index as "row" indices for the purposes of the SVD (these indices will end up on `U`, along with the Index connecting `U` to `S`).

The code in the `for` loop iterates over the diagonal elements of the `S` tensor (which are the singular values from the SVD), computes their squares to obtain the probabilities of observing the various states in the Schmidt basis (i.e. eigenvectors of the left-right bipartition reduced density matrices), and puts them into the von Neumann entanglement entropy formula ``S_\text{vN} = - \sum_{n} p_{n} \log{p_{n}}``.


## Write and Read an MPS or MPO to Disk with HDF5

**Writing an MPS to an HDF5 File**

Let's say you have an MPS `psi` which you have made or obtained
from a calculation. To write it to an HDF5 file named "myfile.h5"
you can use the following pattern:

```julia
using ITensors.HDF5
f = h5open("myfile.h5","w")
write(f,"psi",psi)
close(f)
```

Above, the string "psi" can actually be any string you want such as "MPS psi"
or "Result MPS" and doesn't have to have the same name as the reference `psi`.
Closing the file `f` is optional and you can also write other objects to the same
file before closing it.

[*Above we did `using ITensors.HDF5` since HDF5 is already included as a dependency with ITensor. You can also do `using HDF5` but must add the HDF5 package beforehand for that to work.*]

**Reading an MPS from an HDF5 File**

Say you have an HDF5 file "myfile.h5" which contains an MPS stored as a dataset with the
name "psi". (Which would be the situation if you wrote it as in the example above.)
To read this ITensor back from the HDF5 file, use the following pattern:

```julia
using ITensors.HDF5
f = h5open("myfile.h5","r")
psi = read(f,"psi",MPS)
close(f)
```

Many functions which involve MPS, such as the `dmrg` function or the `AutoMPO` system
require that you use an array of site indices which match the MPS. So when reading in
an MPS from disk, do not construct a new array of site indices. Instead, you can
obtain them like this: `sites = siteinds(psi)`.

So for example, to create an MPO from an AutoMPO which has the same site indices
as your MPS `psi`, do the following:

```julia
ampo = AutoMPO()
# Then put operators into ampo...

sites = siteinds(psi) # Get site indices from your MPS
H = MPO(ampo,sites)

# Compute <psi|H|psi>
energy_psi = inner(psi,H,psi)
```


Note the `MPS` argument to the read function, which tells Julia which read function
to call and how to interpret the data stored in the HDF5 dataset named "psi". In the 
future we might lift the requirement of providing the type and have it be detected
automatically from the data stored in the file.


**Writing and Reading MPOs**

To write or read MPOs to or from HDF5 files, just follow the examples above but use
the type `MPO` when reading an MPO from the file instead of the type `MPS`.
