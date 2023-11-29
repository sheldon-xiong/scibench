#!/bin/bash
testdir=$(cd "$(dirname $0)"; pwd)

typeset -l devicetype
typeset -l testtype

devicetype=$1
testtype=$2

function devicetestnv {
	echo "Run device tests on Nvidia GPUS"
	echo "=========== cublasMatmulBench ============="
	bash $testdir/device_test/cublasMatmulBench/run.bash
	echo "============== stream_test ================"
	bash $testdir/device_test/stream_test/run.bash
	echo "============= bandwidthTest ==============="
	bash $testdir/device_test/bandwidthTest/run.bash
	echo "=============== nccl_test ================="
	bash $testdir/device_test/nccl_test/run.bash
	echo "==========================================="
}

function torchoptestnv {
	echo "Run PyTorch operator tests on Nvidia GPUs"
	python $testdir/torchop_test/torchops.py
}

if [ "$devicetype" == "nv" ]; then
	if [ "$testtype" == "device" ]; then
		devicetestnv
	elif [ "$testtype" == "torchop" ]; then
		torchoptestnv
	elif [ "$testtype" == "all" ]; then
		devicetestnv
		torchoptestnv
	else
		echo "Only 'device', 'torchop' and 'all' is supported"
		echo "$testtype" is not supported
	fi
elif [ "$devicetype" == "hw" ]; then
    echo "Run tests on HW device"
else
    echo "Only NV(nv) and HW(hw) is supported"
    echo "$devicetype" is not supported.
fi
