import os
import time
import torch
import torch.nn as nn
from train_trajectory_predictor import HeterogeneousTraPHicNet

base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
pt_path  = os.path.join(base_dir, 'models', 'traPHic_predictor_rtx4060.pt')

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = HeterogeneousTraPHicNet().to(device)
model.load_state_dict(torch.load(pt_path, map_location=device))
model.eval()

sample_hist = torch.randn(1, 10, 4, device=device)
sample_cid  = torch.tensor([3], dtype=torch.long, device=device)

# Warmup
for _ in range(30):
    with torch.no_grad():
        _ = model(sample_hist, sample_cid)
if torch.cuda.is_available():
    torch.cuda.synchronize()

# Benchmark GPU
N = 200
t0 = time.time()
for _ in range(N):
    with torch.no_grad():
        _ = model(sample_hist, sample_cid)
if torch.cuda.is_available():
    torch.cuda.synchronize()
gpu_lat = ((time.time() - t0) / N) * 1000

# Benchmark CPU
model_cpu = HeterogeneousTraPHicNet().to('cpu')
model_cpu.load_state_dict(torch.load(pt_path, map_location='cpu'))
model_cpu.eval()
hist_cpu = sample_hist.to('cpu')
cid_cpu = sample_cid.to('cpu')

t0 = time.time()
for _ in range(N):
    with torch.no_grad():
        _ = model_cpu(hist_cpu, cid_cpu)
cpu_lat = ((time.time() - t0) / N) * 1000

print(f"RTX 4060 GPU Latency: {gpu_lat:.2f} ms ({1000/gpu_lat:.0f} FPS)")
print(f"Intel/AMD CPU Latency: {cpu_lat:.2f} ms ({1000/cpu_lat:.0f} FPS)")
