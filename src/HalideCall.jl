module HalideCall

export HalideBuffer

const libname = "libhalidecall.so"
const libHalideCall = find_library([libname], [Pkg.dir("HalideCall", "deps")])
isempty(libHalideCall) && error("Can't find $libname")

immutable HalideBuffer
    dev::Uint64
    host::Ptr{Uint8}
    extent0::Cint
    extent1::Cint
    extent2::Cint
    extent3::Cint
    stride0::Cint
    stride1::Cint
    stride2::Cint
    stride3::Cint
    min0::Cint
    min1::Cint
    min2::Cint
    min3::Cint
    elem_size::Cint
    host_dirty::Bool
    dev_dirty::Bool
end
HalideBuffer(A::Array) = HalideBuffer(A, zeros(Int,4))
HalideBuffer(A::Array, pad) = HalideBuffer(A, pad, pad)
function HalideBuffer(A::Array, padmin, padmax)
    sz = growto4(size(A))
    st = growto4(strides(A))
    pmn = growto4(padmin)
    pmx = growto4(padmax)
    extent = sz - pmn - pmx
    HalideBuffer(0, pointer(A),
                 extent[1], extent[2], extent[3], extent[4],
                 st[1], st[2], st[3], st[4],
                 pmn[1], pmn[2], pmn[3], pmn[4],
                 sizeof(eltype(A)), false, false)
end

growto4(v::Vector) = growto4!(copy(v))
growto4(t::Tuple) = growto4!([t...])
function growto4!(v::Vector)
    length(v) <= 4 || error("Vector is too large")
    while length(v) < 4
        push!(v, 0)
    end
    v
end

end # module
