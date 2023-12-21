#!/bin/bash

testdir=$(cd "$(dirname $0)"; pwd)
resultdir=$testdir/result
if [ ! -d $resultdir ]; then
    mkdir -p $resultdir
fi

# run tests
$testdir/cublasMatmulBench -P=qqssq          -m=4224  -n=2048 -k=16384 -T=1000 -ta=1 -B=0 >& $resultdir/result_cublasMatmulBench_fp8
$testdir/cublasMatmulBench -P=bisb_imma      -m=8192  -n=4224 -k=16384 -T=1000 -tb=1 -B=0 >& $resultdir/result_cublasMatmulBench_int8
$testdir/cublasMatmulBench -P=hsh            -m=12288 -n=9216 -k=32768 -T=1000 -tb=1 -B=0 >& $resultdir/result_cublasMatmulBench_fp16
$testdir/cublasMatmulBench -P=sss_fast_tf32  -m=8192  -n=4224 -k=16384 -T=1000 -ta=1 -B=0 >& $resultdir/result_cublasMatmulBench_tf32
$testdir/cublasMatmulBench -P=ddd            -m=4224  -n=2048 -k=16384 -T=1000 -tb=1 -B=0 >& $resultdir/result_cublasMatmulBench_fp64
$testdir/cublasMatmulBench -P=sss            -m=4224  -n=2048 -k=16384 -T=1000 -tb=1 -B=0 >& $resultdir/result_cublasMatmulBench_fp32

# parse results
rfp8=$(grep "Gflops = "   $resultdir/result_cublasMatmulBench_fp8  | awk -F'Gflops = ' '{print $2}')
rint8=$(grep "Gflops = "  $resultdir/result_cublasMatmulBench_int8 | awk -F'Gflops = ' '{print $2}')
rfp16=$(grep "Gflops = "  $resultdir/result_cublasMatmulBench_fp16 | awk -F'Gflops = ' '{print $2}')
rtf32=$(grep "Gflops = "  $resultdir/result_cublasMatmulBench_tf32 | awk -F'Gflops = ' '{print $2}')
rfp32=$(grep "Gflops = "  $resultdir/result_cublasMatmulBench_fp32 | awk -F'Gflops = ' '{print $2}')
rfp64=$(grep "Gflops = "  $resultdir/result_cublasMatmulBench_fp64 | awk -F'Gflops = ' '{print $2}')


# print results
if [ -n "$rfp8" ]; then
	echo FP8: $rfp8 Gflops
fi
if [ -n "$rint8" ]; then
	echo INT8: $rint8 Gflops
fi

if [ -n "$rfp16" ]; then
	echo FP16: $rfp16 Gflops
fi

if [ -n "$rtf32" ]; then
	echo TF32: $rtf32 Gflops
fi

if [ -n "$rfp32" ]; then
	echo FP32: $rfp32 Gflops
fi

if [ -n "$rfp64" ]; then
	echo FP64: $rfp64 Gflops
fi
