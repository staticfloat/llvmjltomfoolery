`LLVM.jl` experimentation
=======================

## Phase 1
[`LLVM.jl`](https://github.com/maleadt/LLVM.jl) is great. `@staticfloat` was interested in whether it was possible to speed up invocations of external dependencies through the proper application of LLVM wizardry.  The first step toward figuring this out was to learn how to take LLVM IR and force it into Julia's JIT-land.  The first experiment is performed by creating an extremely simple function in Julia and C, and measuring the performance impact moving along continuum from Native Julia to ccall'ing compiled C code.  We compare four methods:

* Native Julia code

* Manually built LLVM IR through `LLVM.jl`'s interface to the IR Builder API

* `clang`-generated LLVM IR from the C source code (inlineable)

* `clang`-generated LLVM IR from the C source code (non-inlineable)

* `clang`-generated `.so` file that gets `ccall`'ed into

A docker container is provided that has all of this embedded within it, just run `make pull` within this directory to download a prebuilt version of Julia with LLVM.jl prebuilt and ready to go (Warning, it's >6GB).  Running `make run` will launch the comparison script, run the benchmarks, then launch into an interactive Julia session, allowing you to inspect the benchmark results (available in `results`).  You can also just use `julia -i libtest.jl` within the `src/` directory to get the same effect, if you have your own environment setup properly.

```julia
julia> results
5-element Array{Any,1}:
 (native_addi32, Trial(65.849 μs))
 (manual_llvm_addi32, Trial(66.808 μs))
 (clang_llvmir_addi32, Trial(67.437 μs))
 (clang_noninlined_llvmir_addi32, Trial(146.483 μs))
 (ccall_addi32, Trial(190.640 μs))
```

This shows that allowing the Julia JIT to inline a trivial, synthetic benchmark like this has a significant effect, shaving off over half of the runtime, and there is some residual overhead within `ccall` itself.  Incredibly, external LLVM IR can be integrated within Julia with essentially indistinguishable performance from native Julia code itself, and with a minimum of effort at that.

## Phase 2

Phase 2 will be to figure out how to compile medium-sized projects that we have the source code to (a la [openlibm](https://github.com/JuliaLang/openlibm) or [openspecfun](https://github.com/JuliaLang/openspecfun)) down to LLVM IR, and forcibly replace the Julia bindings that used to `ccall` out to them with the LLVM IR blobs, and measure the performance difference.  Essentially, when we have the source code, to translate `ccall` to `llvmcall` as much as possible.

## Phase 3

Phase 3 will be to integrate [`mcsema`](https://github.com/trailofbits/mcsema) and [`radare2`](https://github.com/radare/radare2) into this to lift arbitrary libraries into LLVM IR, then throw this at something like [openlibm](https://github.com/JuliaLang/openlibm) or [openspecfun](https://github.com/JuliaLang/openspecfun) to see if we can obliterate the JIT <---> Native barrier.  NOTE: this may currently be impossible.  Just how I like it.
