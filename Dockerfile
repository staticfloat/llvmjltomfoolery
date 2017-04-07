FROM ubuntu

# These are the build dependencies for Julia
RUN apt update && \
    apt install -y build-essential gfortran m4 python python-dev cmake \
                   curl git libncurses-dev swig libreadline6-dev libedit-dev vim

# Clone julia and build
RUN git clone  -b sf/openblas_no_patches https://github.com/JuliaLang/julia.git /julia
WORKDIR /julia
RUN make DEPS_GIT=1 OPENBLAS_SHA1=99880f79068fc12b3025840671a838f0d4be3c9e LLVM_VER=3.9.1 BUILD_POLLY=1 BUILD_LLVM_CLANG=1 BUILD_LLDB=1 -j4 release debug
ENV PATH $PATH:/julia/usr/bin:/julia/usr/tools

RUN apt install -y libpng-dev libjpeg-dev hdf5-tools
RUN ./julia -e 'Pkg.add("LLVM")'
RUN ./julia -e 'Pkg.add("Cxx")'
RUN ./julia -e 'Pkg.add("BenchmarkTools")'
RUN ./julia -e 'using LLVM; using Cxx; using BenchmarkTools'

# Clone halide, build libhalide and install
RUN git clone https://github.com/halide/Halide /halide
WORKDIR /halide
RUN make LLVM_AS=$(which llvm-as) LLVM_NM=$(which llvm-nm) -j4 install

# Copy our code in
COPY src /src
WORKDIR /src
CMD ["julia", "-i", "libtest.jl"]
