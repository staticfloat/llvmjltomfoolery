clang_llvmir_mod = parse(LLVM.Module, readstring("libtest.ll"), ctx)
clang_llvmir_addi32_fn = get(functions(clang_llvmir_mod), "add_i32")
push!(function_attributes(clang_llvmir_addi32_fn), EnumAttribute("alwaysinline"))

function clang_llvmir_addi32(a::Vector{Int32}, b::Vector{Int32})
    @assert length(a) == length(b)

    sum = Int32(0)
    for idx in 1:length(a)
        sum += Base.llvmcall(LLVM.ref(clang_llvmir_addi32_fn), Int32, Tuple{Int32, Int32}, a[idx], b[idx])
    end
    return sum
end


# Also do a non-inlined version to show how much that sucks
clang_noninlined_llvmir_mod = parse(LLVM.Module, readstring("libtest.ll"), ctx)
clang_noninlined_llvmir_addi32_fn = get(functions(clang_noninlined_llvmir_mod), "add_i32")

function clang_noninlined_llvmir_addi32(a::Vector{Int32}, b::Vector{Int32})
    @assert length(a) == length(b)

    sum = Int32(0)
    for idx in 1:length(a)
        sum += Base.llvmcall(LLVM.ref(clang_noninlined_llvmir_addi32_fn), Int32, Tuple{Int32, Int32}, a[idx], b[idx])
    end
    return sum
end
