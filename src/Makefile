all: libtest.so libtest.ll

libtest.ll: libtest.c Makefile
	clang -S -emit-llvm libtest.c

libtest.so: libtest.c Makefile
	clang -shared -O2 -o libtest.so libtest.c
