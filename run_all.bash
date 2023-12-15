#!/bin/bash
testdir=$(cd "$(dirname $0)"; pwd)

typeset -l devicetype
typeset -l testtype

devicetype=$1
testtype=$2

function devicetestnv {
	echo "Run device tests on Nvidia GPUS"
	echo "=========== cublasMatmulBench ============="
	bash $testdir/device_test/nv/cublasMatmulBench/run.bash
	echo "============== stream_test ================"
	bash $testdir/device_test/nv/stream_test/run.bash
	echo "============= bandwidthTest ==============="
	bash $testdir/device_test/nv/bandwidthTest/run.bash
	echo "=============== nccl_test ================="
	bash $testdir/device_test/nv/nccl_test/run.bash
	echo "==========================================="
}

function devicetesthw {
	echo "Run device tests on Ascend devices"
	echo "============== GemmBench =================="
	ascend-dmi -f -t fp32 -d 0 2>&1 | tee $testdir/device_test/hw/gemm_fp32.log
	ascend-dmi -f -t fp16 -d 0 2>&1 | tee $testdir/device_test/hw/gemm_fp16.log
	echo "============ PCIE Bandwidth ==============="
	ascend-dmi --bw -t h2d -d 0 -s 536870912 --et 100 2>&1 | tee $testdir/device_test/hw/pcie_bw_h2d.log
	ascend-dmi --bw -t d2h -d 0 -s 536870912 --et 100 2>&1 | tee $testdir/device_test/hw/pcie_bw_d2h.log
	echo "========= Device Memory Bandwidth ========="
	ascend-dmi --bw -t d2d -d 0 2>&1 | tee $testdir/device_test/hw/device_bw_d2d.log
	echo "============= P2P Bandwidth ==============="
	ascend-dmi --bw -t p2p | tee $testdir/device_test/hw/p2p_bw.log
}

function torchoptestnv {
	echo "Run PyTorch operator tests on Nvidia GPUs"
	python $testdir/torchop_test/torchops_nv.py 2>&1 | tee $testdir/torchop_test/torchop_nv.log
}

function torchoptesthw {
	echo "Run PyTorch operator tests on Ascend devices"
	python $testdir/torchop_test/torchops_hw.py 2>&1 | tee $testdir/torchop_test/torchop_hw.log
}

function modeltestnv {
	echo "Run PyTorch model tests on Nvidia GPUs"
	bash $testdir/model_test/run.bash nv
}

function modeltesthw {
	echo "Run PyTorch model tests on Ascend devices"
	bash $testdir/model_test/run.bash hw
}

function ext_libnv {
	echo "Run ext_lib tests"
	bash $testdir/ext_lib_test/nv/run.bash
}

if [ "$devicetype" == "nv" ]; then
	if [ "$testtype" == "device" ]; then
		devicetestnv
	elif [ "$testtype" == "torchop" ]; then
		torchoptestnv
	elif [ "$testtype" == "ext_lib" ]; then
		ext_libnv
	elif [ "$testtype" == "model_test" ]; then
		modeltestnv
	elif [ "$testtype" == "all" ]; then
		devicetestnv
		torchoptestnv
		modeltestnv
		ext_libnv
	else
		echo "Only 'device', 'torchop', 'model_test', 'ext_lib' and 'all' is supported"
		echo "$testtype" is not supported
	fi
elif [ "$devicetype" == "hw" ]; then
	if [ "$testtype" == "device" ]; then
		devicetesthw
	elif [ "$testtype" == "torchop" ]; then
		torchoptesthw
	elif [ "$testtype" == "model_test" ]; then
		modeltesthw
	elif [ "$testtype" == "all" ]; then
		devicetesthw
		torchoptesthw
		modeltesthw
	else
		echo "Only 'device', 'torchop', 'model_test' and 'all' is supported"
                echo "$testtype" is not supported
	fi
else
    echo "Only NV(nv) and HW(hw) is supported"
    echo "$devicetype" is not supported.
fi
