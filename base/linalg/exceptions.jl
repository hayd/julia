export LAPACKException,
       ARPACKException,
       SingularException,
       PosDefException,
       RankDeficientException,
       DimensionMismatch

type LAPACKException <: Exception
    info::BlasInt
end

type ARPACKException <: Exception
    info::BlasInt
end

type SingularException <: Exception
    info::BlasInt
end

type PosDefException <: Exception
    info::BlasInt
end

type RankDeficientException <: Exception
    info::BlasInt
end

type DimensionMismatch <: Exception
    name::ASCIIString
end
macro assertsquare(A)
    :(size($A,1)==size($A,2) ? size($A, 1) : throw(DimensionMismatch("Matrix must be square")))
end

