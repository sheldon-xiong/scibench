import torch
import time

torch.set_float32_matmul_precision('high')

torch.backends.cuda.matmul.allow_tf32 = True
torch.backends.cudnn.allow_tf32 = True

def benchmark_gemm(dtype, size=16384, iterations=20):
    a = torch.randn(size, size, device='cuda', dtype=dtype)
    b = torch.randn(size, size, device='cuda', dtype=dtype)
    torch.cuda.synchronize()

    # Warmup
    for _ in range(5):
        if dtype in [torch.bfloat16, torch.float16]:
            with torch.autocast(device_type='cuda', dtype=dtype):
                c = torch.mm(a, b)
        else:
            c = torch.mm(a, b)
    torch.cuda.synchronize()

    start = time.time()
    for _ in range(iterations):
        if dtype in [torch.bfloat16, torch.float16]:
            with torch.autocast(device_type='cuda', dtype=dtype):
                c = torch.mm(a, b)
        else:
            c = torch.mm(a, b)
    torch.cuda.synchronize()
    end = time.time()

    elapsed = (end - start) / iterations
    flops = 2 * size**3 / elapsed / 1e12  # in TFLOPS
    print(f"{dtype}: {flops:.2f} TFLOPS")

benchmark_gemm(torch.float32)
benchmark_gemm(torch.float16)
benchmark_gemm(torch.bfloat16)

