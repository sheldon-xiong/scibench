#!/bin/bash
testdir=$(cd "$(dirname $0)"; pwd)

export CUPY_CACHE_DIR=$testdir/.cupy

# run test graph
pytest $testdir/cupy_test/cupy/tests/cupy_tests/cuda_tests/test_graph.py

# run test raw
pytest $testdir/cupy_test/cupy/tests/cupyx_tests/jit_tests/test_raw.py -k "not test_device_cache"

# run test device function
pytest $testdir/cupy_test/cupy/tests/cupyx_tests/jit_tests/test_device_function.py

# run test pinned array
pytest $testdir/cupy_test/cupy/tests/cupyx_tests/test_pinned_array.py
