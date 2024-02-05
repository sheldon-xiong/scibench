# ubiqbench

### run on NVIDIA GPUs
- Required environment: cuda12 and pytorch 2.x
- Run tests
``` bash
./ubiqbench.bash -dt nv -tt all     # run all tests
./ubiqbench.bash -dt nv -tt device  # run device tests
./ubiqbench.bash -dt nv --tt torchop # run torch op tests
./ubiqbench.bash -dt nv --tt ext_lib # run ext_lib tests
# run each device test, detailed test results will be saved in ./device_test/<test_name>/result
./device_test/nv/bandwidthTest/run.bash
./device_test/nv/cublasMatMul/run.bash
./device_test/nv/nccl_test/run.bash
./device_test/nv/stream_test/run.bash
```

### run on HuaWei Ascend devices
- Run tests
``` bash
./ubiqbench.bash -dt hw -tt all
./ubiqbench.bash -dt hw -tt device
./ubiqbench.bash -dt hw -tt torchop
```
