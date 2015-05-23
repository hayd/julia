# This file is a part of Julia. License is MIT: http://julialang.org/license

module SparseMatrix

using Base: Func, AddFun, OrFun
using Base.Sort: Forward
using Base.LinAlg: AbstractTriangular

importall Base
importall Base.LinAlg
import Base.promote_eltype
import Base.@get!
import Base.Broadcast.eltype_plus, Base.Broadcast.broadcast_shape

export AbstractSparseArray, AbstractSparseMatrix, AbstractSparseVector, SparseMatrixCSC,
       blkdiag, dense, droptol!, dropzeros!, etree, issparse, nnz, nonzeros, nzrange,
       rowvals, sparse, sparsevec, spdiagm, speye, spones, sprand, sprandbool, sprandn,
       spzeros, symperm

include("abstractsparse.jl")
include("sparsematrix.jl")
include("csparse.jl")

include("linalg.jl")
if Base.USE_GPL_LIBS
    include("umfpack.jl")
    include("cholmod.jl")
    include("spqr.jl")
end

end # module SparseMatrix
