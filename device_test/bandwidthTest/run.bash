#!/bin/bash

curdir=$(pwd)
testdir=$(cd "$(dirname $0)"; pwd)
bandwidthtestdir=$testdir/cuda-samples/Samples/1_Utilities/bandwidthTest/
resultdir=$testdir/result
if [ ! -d $resultdir ]; then
	mkdir -p $resultdir
fi

# run test
cd $bandwidthtestdir && make >& $resultdir/make.log && ./bandwidthTest >& $resultdir/result_bandwidthTest

# process result
mapfile -t res < <(grep 32000000 $resultdir/result_bandwidthTest | awk -F' ' '{print $2}')

# print results
if [ -n "${res[0]}" ]; then
	echo H2D: ${res[0]} GB/s
fi

if [ -n "${res[1]}" ]; then
	echo D2H: ${res[1]} GB/s
fi

if [ -n "${res[2]}" ]; then
	echo D2D: ${res[2]} GB/s
fi
