# Setup manually constructed LLVM method
llvm_mod = LLVM.Module("llvm_mod", ctx)
param_types = [LLVM.Int32Type(ctx), LLVM.Int32Type(ctx)]
manual_llvm_addi32_fn = LLVM.Function(llvm_mod, "add_i32", LLVM.FunctionType(LLVM.Int32Type(ctx), param_types))
Builder(ctx) do builder
    entry = BasicBlock(manual_llvm_addi32_fn, "entry")
    position!(builder, entry)

    params = parameters(manual_llvm_addi32_fn)
    tmp_sum = add!(builder, params[1], params[2], "tmp_sum")
    ret!(builder, tmp_sum)
    verify(llvm_mod)
end

# Enable inlining for this method
push!(function_attributes(manual_llvm_addi32_fn), EnumAttribute("alwaysinline"))


function manual_llvm_addi32(a::Vector{Int32}, b::Vector{Int32})
    @assert length(a) == length(b)
    sum = Int32(0)
    for idx in 1:length(a)
        sum += Base.llvmcall(LLVM.ref(manual_llvm_addi32_fn), Int32, Tuple{Int32, Int32}, a[idx], b[idx])
    end
    return sum
end
