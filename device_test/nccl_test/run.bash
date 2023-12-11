#!/bin/bash

curdir=$(pwd)
testdir=$(cd "$(dirname $0)"; pwd)
nccltestdir=$testdir/nccl-tests/
resultdir=$testdir/result
if [ ! -d $resultdir ]; then
	mkdir -p $resultdir
fi

# run test
cd $nccltestdir && make >& $resultdir/make.log

./build/all_reduce_perf -b 8 -e 8G -f 2 -g 8 >& $resultdir/result_all_reduce_perf
./build/alltoall_perf   -b 8 -e 8G -f 2 -g 8 >& $resultdir/result_alltoall_perf

# process result
rallreduce=$(grep "8589934592.*float"  $resultdir/result_all_reduce_perf | awk -F' ' '{print $8}' ) 
ralltoall=$(grep "8589934592.*float"   $resultdir/result_alltoall_perf   | awk -F' ' '{print $8}' )

# print results
if [ -n "$rallreduce" ]; then
	echo AllReduce: $rallreduce GB/s
fi

if [ -n "$ralltoall" ]; then
	echo AllToAll:  $ralltoall GB/s
fi
