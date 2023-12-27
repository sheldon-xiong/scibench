#!/bin/bash

testdir=$(cd "$(dirname $0)"; pwd)
resultdir=$testdir/result
if [ ! -d $resultdir ]; then
	mkdir -p $resultdir
fi

# run test
$testdir/stream_vectorized_double_test -n608622848 >& $resultdir/result_stream_vectorized_double_test
# parse result
rcopy=$(grep   "Copy:"  $resultdir/result_stream_vectorized_double_test | awk -F' ' '{print $2}')
rscale=$(grep  "Scale:" $resultdir/result_stream_vectorized_double_test | awk -F' ' '{print $2}')
radd=$(grep    "Add:"   $resultdir/result_stream_vectorized_double_test | awk -F' ' '{print $2}')
rtriad=$(grep  "Triad:" $resultdir/result_stream_vectorized_double_test | awk -F' ' '{print $2}')
rread=$(grep   "Read:"  $resultdir/result_stream_vectorized_double_test | awk -F' ' '{print $2}')
rwrite=$(grep  "Write:" $resultdir/result_stream_vectorized_double_test | awk -F' ' '{print $2}')

# print result
if [ -n "$rcopy" ]; then
	echo Copy: $rcopy MB/s
fi

if [ -n "$rscale" ]; then
	echo Scale: $rscale MB/s
fi

if [ -n "$radd" ]; then
	echo Add: $radd MB/s
fi

if [ -n "$rtriad" ]; then
	echo Triad: $rtriad MB/s
fi

if [ -n "$rread" ]; then
	echo Read: $rread MB/s
fi

if [ -n "$rwrite" ]; then
	echo Write: $rwrite MB/s
fi
