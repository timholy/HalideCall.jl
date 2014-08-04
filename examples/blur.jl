using HalideCall
const libblur = "./libblur.so"
A = rand(Float32,2000,3000);
out = similar(A);
Abuf = HalideBuffer(A)
outbuf = HalideBuffer(out, (1,1))
fill!(out, 0);
ccall((:blur_twopasses,libblur), Void, (Ptr{Void}, Ptr{Void}), [Abuf], [outbuf])
@time (for i = 1:10; ccall((:blur_twopasses,libblur), Void, (Ptr{Void}, Ptr{Void}), [Abuf], [outbuf]); end)
@time (for i = 1:10; ccall((:blur_twopasses_vectorized,libblur), Void, (Ptr{Void}, Ptr{Void}), [Abuf], [outbuf]); end)
@time (for i = 1:10; ccall((:blur_tiled,libblur), Void, (Ptr{Void}, Ptr{Void}), [Abuf], [outbuf]); end)


using KernelTools

function blur_twopasses!(blur_xy, blur_y, A)
    interior_x, interior_y = 2:size(A,1)-1, 2:size(A,2)-1
    for y = interior_y, x = 1:size(A,1)
        @inbounds blur_y[x,y] = A[x,y-1]+A[x,y]+A[x,y+1]
    end
    for y = interior_y, x = interior_x
        @inbounds blur_xy[x,y] = (one(eltype(A))/9)*(blur_y[x-1,y] + blur_y[x,y] + blur_y[x+1,y])
    end
    blur_xy
end
blur_twopasses!(output, A) = blur_twopasses!(output, similar(A), A)
blur_twopasses(A) = blur_twopasses!(similar(A), similar(A), A)

function blur_tiled!(blur_xy, A)
    interior_x, interior_y = 2:size(A,1)-1, 2:size(A,2)-1
    KernelTools.@tile (x,256,y,8) (@inbounds blur_y[x,y] = A[x,y-1]+A[x,y]+A[x,y+1]) begin
        for y = interior_y, x = interior_x
            @inbounds blur_xy[x,y] = (one(eltype(A))/9)*(blur_y[x-1,y] + blur_y[x,y] + blur_y[x+1,y])
        end
    end
    blur_xy
end
blur_tiled(A) = blur_tiled!(similar(A), A)

blur_twopasses!(out, A)
gc()
@time (for i = 1:10; blur_twopasses!(out, A); end)
tmp = similar(A)
gc()
@time (for i = 1:10; blur_twopasses!(out, tmp, A); end)
blur_tiled!(out, A)
@time (for i = 1:10; blur_tiled!(out, A); end)
