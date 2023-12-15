#!/bin/bash

curdir=$(pwd)
testdir=$(cd "$(dirname $0)"; pwd)
bandwidthtestdir=$testdir/cuda-samples/Samples/1_Utilities/bandwidthTest/
ip2ptestdir=$testdir/cuda-samples/Samples/0_Introduction/simpleP2P/
resultdir=$testdir/result
if [ ! -d $resultdir ]; then
	mkdir -p $resultdir
fi

# run test
cd $bandwidthtestdir && make >& $resultdir/make_bandwidth.log && ./bandwidthTest >& $resultdir/result_bandwidthTest
cd $p2ptestdir && make >& $resultdir/make_p2p.log && ./simpleP2P >& $resultdir/result_p2p

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

rp2p=$(grep "cudaMemcpyPeer / cudaMemcpy between" $resultdir/result_p2p | awk -F' ' '{print $8}')

if [ -n "$rp2p" ]; then
	echo P2P: $rp2p
fi
