#!/bin/bash

curdir=$(pwd)
testdir=$(cd "$(dirname $0)"; pwd)
bandwidthtestdir=$testdir/cuda-samples/Samples/1_Utilities/bandwidthTest/
p2ptestdir=$testdir/cuda-samples/Samples/0_Introduction/simpleP2P/
resultdir=$testdir/result
if [ ! -d $resultdir ]; then
	mkdir -p $resultdir
fi

# run test
cd $bandwidthtestdir && make >& $resultdir/make_bandwidth.log && ./bandwidthTest --start=1000000000 --end=1000000000 --increment=4 --mode=range >& $resultdir/result_bandwidthTest
cd $p2ptestdir && make >& $resultdir/make_p2p.log && ./simpleP2P >& $resultdir/result_p2p

# process result
mapfile -t res < <(grep 1000000000 $resultdir/result_bandwidthTest | awk -F' ' '{print $2}')

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

rp2p=$(grep "cudaMemcpyPeer / cudaMemcpy between" $resultdir/result_p2p | awk -F' ' '{print $8}')

if [ -n "$rp2p" ]; then
	echo P2P: $rp2p
fi
