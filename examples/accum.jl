using HalideCall
const libaccum = "./libaccum.so"
A = rand(Float32,2000,3000);
out = similar(A);
Abuf = HalideBuffer(A)
outbuf = HalideBuffer(out, (1,1))
fill!(out, 0);
ccall((:accum_vectorized,libaccum), Void, (Ptr{Void}, Ptr{Void}), [Abuf], [outbuf])
@time (for i = 1:10; ccall((:accum_vectorized,libaccum), Void, (Ptr{Void}, Ptr{Void}), [Abuf], [outbuf]); end)
@time (for i = 1:10; ccall((:accum_tiled,libaccum), Void, (Ptr{Void}, Ptr{Void}), [Abuf], [outbuf]); end)


using KernelTools

function accum_vectorized!(out, A)
    for y = 1:size(A, 2), x = 1:size(A, 1)
        @inbounds out[x, y] += A[x, y]
    end
    out
end

function accum_tiled_byhand!(out, A)
    for y = 1:size(A, 2), x = 1:32:size(A, 1)
        for xi = x:min(x+31, size(A, 1))
            @inbounds out[xi, y] += A[xi, y]
        end
    end
    out
end

function accum_tiled!(out, A)
    KernelTools.@tile (y,32,x,256) begin
        for y = 1:size(A, 2), x = 1:size(A, 1)
            @inbounds out[x, y] += A[x, y]
        end
    end
    out
end

function accum_tiledx!(out, A)
    for y = 1:size(A, 2)
        KernelTools.@tile (x,32) begin
            for x = 1:size(A, 1)
                @inbounds out[x, y] += A[x, y]
            end
        end
    end
    out
end

accum_vectorized!(out, A)
gc()
@time (for i = 1:10; accum_vectorized!(out, A); end)
accum_tiled_byhand!(out, A)
@time (for i = 1:10; accum_tiled_byhand!(out, A); end)
accum_tiled!(out, A)
@time (for i = 1:10; accum_tiled!(out, A); end)
accum_tiledx!(out, A)
@time (for i = 1:10; accum_tiledx!(out, A); end)
