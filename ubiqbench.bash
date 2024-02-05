#!/bin/bash

testdir=$(cd "$(dirname $0)"; pwd)

device_type="all"
test_type="all"
test_case="all"

function nv_device_test {
	if [ $1 == "all" ]; then
		echo "============ cublasMatmulBench ============"
		bash $testdir/device_test/nv/cublasMatmulBench/run.bash
		echo "=============== stream_test ==============="
		bash $testdir/device_test/nv/stream_test/run.bash
		echo "============== bandwidthTest =============="
		bash $testdir/device_test/nv/bandwidthTest/run.bash
		echo "================ nccl_test ================"
		bash $testdir/device_test/nv/nccl_test/run.bash
		echo "==========================================="
	elif [ $1 == "Gemm" ]; then
                echo "============ cublasMatmulBench ============"
		bash $testdir/device_test/nv/cublasMatmulBench/run.bash
	elif [ $1 == "Stream" ]; then
		echo "=============== stream_test ==============="
                bash $testdir/device_test/nv/stream_test/run.bash
	elif [ $1 == "Bandwidth" ]; then
                echo "============== bandwidthTest =============="
                bash $testdir/device_test/nv/bandwidthTest/run.bash
	elif [ $1 == "Nccl" ]; then
		echo "================ nccl_test ================"
                bash $testdir/device_test/nv/nccl_test/run.bash
	else
		echo "Only 'Gemm', 'Stream', 'Bandwidth', and 'Nccl' are supported"
		echo $1 is not supported
	fi
}

function hw_device_test {
	if [ ! -d $testdir/device_test/hw ]; then
		mkdir -p $testdir/device_test/hw
	fi
	if [ $1 == "all" ]; then
		echo "================ GemmBench ================"
		ascend-dmi -f -t fp32 -d 0 2>&1 | tee $testdir/device_test/hw/gemm_fp32.log
		ascend-dmi -f -t fp16 -d 0 2>&1 | tee $testdir/device_test/hw/gemm_fp16.log
		echo "================ Bandwidth ================"
		ascend-dmi --bw -t h2d -d 0 -s 536870912 --et 100 2>&1 | tee $testdir/device_test/hw/pcie_bw_h2d.log
		ascend-dmi --bw -t d2h -d 0 -s 536870912 --et 100 2>&1 | tee $testdir/device_test/hw/pcie_bw_d2h.log
		ascend-dmi --bw -t d2d -d 0 2>&1 | tee $testdir/device_test/hw/device_bw_d2d.log
		ascend-dmi --bw -t p2p | tee $testdir/device_test/hw/p2p_bw.log
	elif [ $1 == "Gemm" ]; then
		echo "================ GemmBench ================"
		ascend-dmi -f -t fp32 -d 0 2>&1 | tee $testdir/device_test/hw/gemm_fp32.log
		ascend-dmi -f -t fp16 -d 0 2>&1 | tee $testdir/device_test/hw/gemm_fp16.log
	elif [ $1 == "Bandwidth" ]; then
		echo "================ Bandwidth ================"
		ascend-dmi --bw -t h2d -d 0 -s 536870912 --et 100 2>&1 | tee $testdir/device_test/hw/pcie_bw_h2d.log
		ascend-dmi --bw -t d2h -d 0 -s 536870912 --et 100 2>&1 | tee $testdir/device_test/hw/pcie_bw_d2h.log
		ascend-dmi --bw -t d2d -d 0 2>&1 | tee $testdir/device_test/hw/device_bw_d2d.log
		ascend-dmi --bw -t p2p | tee $testdir/device_test/hw/p2p_bw.log
	else
		echo "Only 'Gemm' and 'Bandwidth' are supported"
		echo $1 is not supported
	fi
}

function nv_torchop_test {
	echo "Run PyTorch operator tests on Nvidia GPUs"
	python $testdir/torchop_test/torchops_nv.py 2>&1 | tee $testdir/torchop_test/torchop_nv.log
}

function hw_torchop_test {
	echo "Run PyTorch operator tests on Ascend devices"
	python $testdir/torchop_test/torchops_hw.py 2>&1 | tee $testdir/torchop_test/torchop_hw.log
}

function nv_model_test {
	echo "Run PyTorch model tests on Nvidia GPUs"
	bash $testdir/model_test/run.bash nv
}

function hw_model_test {
	echo "Run PyTorch model tests on Ascend devices"
	bash $testdir/model_test/run.bash hw
}

function nv_ext_lib_test {
	echo "Run ext_lib tests"
	bash $testdir/ext_lib_test/nv/run.bash
}

help() {
	echo "Usage:"
	echo "-dt/--device_type     nv for NVIDIA, hw for HuaWei Ascend Device"
	echo "-tt/--test_type       [all, device, torchop, model, ext_lib]"
	echo "-tc/--test_case       eg:[Gemm, Bandwidth, all] for \"--test_type device\" "
}

while [[ $# -gt 0 ]]
do
	arg="$1"
	case $arg in
		-h | --help)
			help
			exit 0;;
		-dt | --device_type)
			device_type="$2"
			shift
			shift
			;;
		-tt | --test_type)
			test_type="$2"
			shift
			shift
			;;
		-tc | --test_case)
			test_case="$2"
			shift
			shift
			;;
		*)
			echo "Invalid option : $1"
			help
			exit 1
			;;
	esac
done

if [ "$device_type" == "nv" ]; then
	if [ "$test_type" == "device" ]; then
		nv_device_test $test_case
	elif [ "$test_type" == "torchop" ]; then
		nv_torchop_test
	elif [ "$test_type" == "model" ]; then
		nv_model_test
	elif [ "$test_type" == "ext_lib" ]; then
		nv_ext_lib_test
	elif [ "$test_type" == "all" ]; then
		nv_device_test "all"
		nv_torchop_test
		nv_model_test
		nv_ext_lib_test
	else
		echo "Only 'device', 'torchop', 'model', 'ext_lib' and 'all' are supported"
		echo "$test_type" is not supported
	fi
elif [ "$device_type" == "hw" ]; then
	if [ "$test_type" == "device" ]; then
		hw_device_test $test_case
	elif [ "$test_type" == "torchop" ]; then
		hw_torchop_test
	elif [ "$test_type" == "model" ]; then
		hw_model_test
	elif [ "$test_type" == "all" ]; then
		hw_device_test "all"
		hw_torchop_test
		hw_model_test
	else
		echo "Only 'device', 'torchop', 'model' and 'all' are supported"
		echo "$test_type" is not supported
	fi
else
	echo "Only NV(nv) and HW(hw) is supported"
	echo "$device_type" is not supported.
fi
