#!/usr/bin/env julia

using LLVM
ctx = LLVM.Context(cglobal(:jl_LLVMContext, Void))

# Native method
include("0_native.jl")

# Manually construct LLVM IR
include("1_manual_llvm.jl")

# Use clang to compile C-implementation to LLVM IR
include("2_clang_llvmir.jl")

# ccall clang-compiled .so
include("3_ccall.jl")


using BenchmarkTools
function test_all_methods(;N::Int64 = 100000)
    a = rand(Int32, N)
    b = rand(Int32, N)

    methods = [
        # native julia
        native_addi32,

        # LLVM.jl IR Builder-based
        manual_llvm_addi32,

        # Clang-compiled LLVM IR from C, both inlineable and noninlineable
        clang_llvmir_addi32,
        clang_noninlined_llvmir_addi32,

        # ccall'ing into a .so compiled through clang
        ccall_addi32
    ]
    results = Any[]
    for idx in 1:length(methods)
        push!(results, (methods[idx], @benchmark $methods[$idx]($a, $b)))
    end
    return results
end

# Results are available within the variable "results"
results = test_all_methods()
