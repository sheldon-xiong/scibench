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

function devicetesthw {
	echo “Run device tests on Ascend devices”
	echo "============== GemmBench =================="
	ascend-dmi -f -t fp32 -d 0
	ascend-dmi -f -t fp16 -d 0
	echo "============ PCIE Bandwidth ==============="
	ascend-dmi --bw -t h2d -d 0 -s 536870912 --et 100
	ascend-dmi --bw -t d2h -d 0 -s 536870912 --et 100
	echo "========= Device Memory Bandwidth ========="
	ascend-dmi --bw -t d2d -d 0
	echo "============= P2P Bandwidth ==============="
	ascend-dmi --bw -t p2p
}

function torchoptestnv {
	echo "Run PyTorch operator tests on Nvidia GPUs"
	python $testdir/torchop_test/torchops_nv.py
}

function torchoptestnv {
	echo "Run PyTorch operator tests on Nvidia GPUs"
	python $testdir/torchop_test/torchops_hw.py
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
	if [ "$testtype" == "device" ]; then
		devicetesthw
	elif [ "$testtype" == "torchop" ]; then
		torchoptesthw
	elif [ "$testtype" == "all" ]; then
		devicetesthw
		torchoptesthw
	else
		echo "Only 'device', 'torchop' and 'all' is supported"
                echo "$testtype" is not supported
	fi
    echo "Run tests on HW device"
else
    echo "Only NV(nv) and HW(hw) is supported"
    echo "$devicetype" is not supported.
fi
