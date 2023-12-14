import torch
import torch_npu
import torch.nn as nn

# lstm
WARMUP = 50
REPEAT = 500
def measure(func, inputs):
    for _ in range(WARMUP):
        outputs = func(*inputs)
    torch.npu.synchronize()

    start = torch.npu.Event()
    end = torch.npu.Event()
    start.record()
    for i in range(REPEAT):
        outputs = func(*inputs)
    end.record()
    torch.npu.synchronize()
    total_time = start.elapsed_time(end)
    return total_time / REPEAT
   
def lstmcell_test(input_size=1000, hidden_size=512, batch_size=50000):
    input_shape = (batch_size, input_size)
    lstmcell = nn.LSTMCell(input_size, hidden_size).eval().npu()
    input_data = torch.rand(input_shape)
    # fp32
    input_data_fp32 = input_data.npu().to(torch.float32)
    time_elapsed_fp32 = measure(lstmcell, (input_data_fp32,))
    print(f"LSTMCell-fp32: {time_elapsed_fp32:.4f} ms")
    #fp16
    lstmcell = nn.LSTMCell(input_size, hidden_size).eval().npu().half()
    input_data_fp16 = input_data.npu().to(torch.half)
    time_elapsed_fp16 = measure(lstmcell, (input_data_fp16,))
    print(f"LSTMCell-fp16: {time_elapsed_fp16:.4f} ms")

def lstm_test(input_size=1000, hidden_size=512, num_layers=3, sequence_length=2400, batch_size=100):
    input_shape = (sequence_length, batch_size, input_size)
    input_data = torch.rand(input_shape)
    # fp32
    lstm = nn.LSTM(input_size, hidden_size, num_layers).eval().npu()
    input_data_fp32 = input_data.npu().to(torch.float32)
    time_elapsed_fp32 = measure(lstm, (input_data_fp32,))
    print(f"LSTM-fp32: {time_elapsed_fp32:.4f} ms")
    # fp16
    lstm = nn.LSTM(input_size, hidden_size, num_layers).eval().npu().half()
    input_data_fp16 = input_data.npu().to(torch.half)
    time_elapsed_fp16 = measure(lstm, (input_data_fp16,))
    print(f"LSTM-fp16: {time_elapsed_fp16:.4f} ms")

def linear_test(in_features=1024, out_features=512, batch_size=5000):
    data_shape = (batch_size, in_features)
    input_data = torch.rand(data_shape)
    # fp32
    linear_fn = nn.Linear(in_features, out_features).eval().npu()
    input_data_fp32 = input_data.npu().to(torch.float32)
    time_elapsed_fp32 = measure(linear_fn, (input_data_fp32,))
    print(f"Linear-fp32: {time_elapsed_fp32:.4f} ms")
    #fp16
    linear_fn = nn.Linear(in_features, out_features).eval().npu().half()
    input_data_fp16 = input_data.npu().to(torch.half)
    time_elapsed_fp16 = measure(linear_fn, (input_data_fp16,))
    print(f"Linear-fp16: {time_elapsed_fp16:.4f} ms")

if __name__ == "__main__":
    #lstmcell_test()
    lstm_test()
    linear_test()
