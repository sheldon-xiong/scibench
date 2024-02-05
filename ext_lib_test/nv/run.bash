#!/bin/bash
testdir=$(cd "$(dirname $0)"; pwd)
resultdir=$testdir/result
if [ ! -d $resultdir ]; then
	mkdir -p $resultdir
fi

export CUPY_CACHE_DIR=$testdir/.cupy

# run test graph
pytest $testdir/cupy_test/cupy/tests/cupy_tests/cuda_tests/test_graph.py | tee -a $resultdir/ext_lib_nv.log

# run test raw
pytest $testdir/cupy_test/cupy/tests/cupyx_tests/jit_tests/test_raw.py -k "not test_device_cache" | tee -a $resultdir/ext_lib_nv.log

# run test device function
pytest $testdir/cupy_test/cupy/tests/cupyx_tests/jit_tests/test_device_function.py | tee -a $resultdir/ext_lib_nv.log

# run test pinned array
pytest $testdir/cupy_test/cupy/tests/cupyx_tests/test_pinned_array.py | tee -a $resultdir/ext_lib_nv.log
