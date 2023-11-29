# ubiqbench

### run on NVIDIA GPUs
- Required environment: cuda12 and pytorch 2.x
- Run tests
``` bash
./run_all.bash NV all       # run all tests
./run_all.bash NV device    # run device tests
./run_all.bash NV torchop   # run torch op tests
# run each device test, detailed test results will be saved in ./device_test/<test_name>/result
./device_test/bandwidthTest/run.bash
./device_test/cublasMatMul/run.bash
./device_test/nccl_test/run.bash
./device_test/stream_test/run.bash
```
