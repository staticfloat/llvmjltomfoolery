libtest = Libdl.dlopen("./libtest.so")
ccall_addi32_fn = Libdl.dlsym(libtest, :add_i32)

function ccall_addi32(a::Vector{Int32}, b::Vector{Int32})
    @assert length(a) == length(b)

    sum = Int32(0)
    for idx in 1:length(a)
        sum += ccall(ccall_addi32_fn, Int32, (Int32, Int32), a[idx], b[idx])
    end
    return sum
end
