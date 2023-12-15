#!/bin/bash
testdir=$(cd "$(dirname $0)"; pwd)
resultdir=$testdir/result
if [ ! -d $resultdir ]; then
	mkdir -p $resultdir
fi

# run test graph
pytest $testdir/cupy/tests/cupy_tests/cuda_tests/test_graph.py >& $resultdir/result_test_graph

# run test raw
pytest $testdir/cupy/tests/cupyx_tests/jit_tests/test_raw.py -k "not test_device_cache" >& $resultdir/result_test_raw

# run test device function
pytest $testdir/cupy/tests/cupyx_tests/jit_tests/test_device_function.py >& $resultdir/result_test_device_function

# run test pinned array
pytest $testdir/cupy/tests/cupyx_tests/test_pinned_array.py >& $resultdir/result_test_pinned_array
