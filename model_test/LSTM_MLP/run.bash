#!/bin/bash

typeset -l devicetype
devicetype=$1

testdir=$(cd "$(dirname $0)"; pwd)
resultdir=$testdir/result
if [ ! -d $resultdir ]; then
    mkdir -p $resultdir
fi

# run 
if [ "$devicetype" == "nv" ]; then
    python3 $testdir/train_nv.py --precision fp32 2>&1 >& $resultdir/nv_fp32.log
    python3 $testdir/train_nv.py --precision fp16 2>&1 >& $resultdir/nv_fp16.log
elif [ "$devicetype" == "hw" ]; then
    python3 $testdir/train_hw.py --precision fp16 2>&1 >& $resultdir/hw_fp16.log
    python3 $testdir/train_hw.py --precision fp32 2>&1 >& $resultdir/hw_fp32.log
    rfp32=$(grep "avg epoch training time"  $resultdir/hw_fp32.log | awk -F' ' '{print $5}' )
    rfp16=$(grep "avg epoch training time"  $resultdir/hw_fp16.log | awk -F' ' '{print $5}' )
    if [ -n "$rfp32" ]; then
        echo hw_device training with fp32: $rfp32 ms/epoch
    fi
    if [ -n "$rfp16" ]; then
        echo hw_device training with fp16: $rfp16 ms/epoch
    fi
else
    echo "Only NV(nv) and HW(hw) is supported"
    echo "$devicetype" is not supported.
fi


