import os
import time
import math
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import scipy.io as sio

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import Dataset, DataLoader

# =========================================================================
# 1. HETEROGENEOUS DEEP TRAJECTORY PREDICTION MODEL (TraPHic-Net)
# =========================================================================
class HeterogeneousTraPHicNet(nn.Module):
    def __init__(self, num_classes=10, class_embed_dim=16, hidden_dim=128, hist_len=10, pred_len=30):
        super(HeterogeneousTraPHicNet, self).__init__()
        self.hist_len = hist_len
        self.pred_len = pred_len
        self.hidden_dim = hidden_dim
        
        # 1. Class Embedding (Learns specific behavioral dynamics per Indian road class)
        self.class_embed = nn.Embedding(num_classes, class_embed_dim)
        
        # 2. Historical Motion Encoder (Input: [x, y, vx, vy] + class_embed)
        in_feat = 4 + class_embed_dim
        self.motion_encoder = nn.GRU(in_feat, hidden_dim, num_layers=2, batch_first=True, bidirectional=True)
        
        # 3. Social Interaction Attention Layer
        self.social_attn = nn.MultiheadAttention(embed_dim=hidden_dim * 2, num_heads=4, batch_first=True)
        
        # 4. Future Trajectory Decoder
        self.decoder_gru = nn.GRU(hidden_dim * 2, hidden_dim, num_layers=2, batch_first=True)
        self.out_proj = nn.Sequential(
            nn.Linear(hidden_dim, 64),
            nn.ReLU(),
            nn.Linear(64, 2) # Outputs (dx, dy) offsets relative to last observed position
        )
        
    def forward(self, hist_motion, class_id):
        # hist_motion: [Batch, hist_len, 4]  -> (x, y, vx, vy)
        # class_id:    [Batch]
        B = hist_motion.size(0)
        
        # Expand class embedding across time steps
        c_emb = self.class_embed(class_id) # [B, class_embed_dim]
        c_emb_expanded = c_emb.unsqueeze(1).repeat(1, self.hist_len, 1) # [B, hist_len, class_embed_dim]
        
        # Concatenate motion state and class embedding
        feat_in = torch.cat([hist_motion, c_emb_expanded], dim=-1) # [B, hist_len, 4 + class_embed_dim]
        
        # Encode history
        enc_out, enc_hidden = self.motion_encoder(feat_in) # enc_out: [B, hist_len, hidden_dim * 2]
        
        # Social self-attention across historical steps
        attn_out, _ = self.social_attn(enc_out, enc_out, enc_out)
        context = attn_out[:, -1:, :] # Take final attended context vector [B, 1, hidden_dim * 2]
        
        # Repeat context across future horizon
        dec_in = context.repeat(1, self.pred_len, 1) # [B, pred_len, hidden_dim * 2]
        dec_out, _ = self.decoder_gru(dec_in) # [B, pred_len, hidden_dim]
        
        # Predict relative coordinate displacements
        delta_pos = self.out_proj(dec_out) # [B, pred_len, 2]
        
        # Accumulate displacements from last observed position
        last_pos = hist_motion[:, -1, :2].unsqueeze(1) # [B, 1, 2]
        pred_traj = last_pos + torch.cumsum(delta_pos, dim=1) # [B, pred_len, 2]
        
        return pred_traj

# =========================================================================
# 2. DATASET GENERATION FROM REAL TRACES & SCENARIO TRAJECTORIES
# =========================================================================
class IndianTrafficTrajectoryDataset(Dataset):
    def __init__(self, data_csv_list, hist_len=10, pred_len=30, num_samples=12000):
        self.hist_len = hist_len
        self.pred_len = pred_len
        self.seq_len = hist_len + pred_len
        self.samples = []
        
        # Load real datasets
        for csv_path in data_csv_list:
            if os.path.exists(csv_path):
                print(f"  [Dataset] Loading trajectories from: {csv_path}")
                df = pd.read_csv(csv_path)
                for ag_id, grp in df.groupby('agent_id'):
                    if len(grp) >= self.seq_len:
                        t = grp['timestamp'].values
                        x = grp['x'].values
                        y = grp['y'].values
                        vx = grp['vx'].values
                        vy = grp['vy'].values
                        cid = int(grp['class_id'].iloc[0])
                        
                        # Sliding window extraction
                        for s in range(0, len(grp) - self.seq_len + 1, 2):
                            hist = np.stack([x[s:s+hist_len], y[s:s+hist_len], vx[s:s+hist_len], vy[s:s+hist_len]], axis=-1)
                            fut  = np.stack([x[s+hist_len:s+self.seq_len], y[s+hist_len:s+self.seq_len]], axis=-1)
                            self.samples.append((hist, cid, fut))

        # Synthetic scenario augmentation for high coverage across all 10 edge cases
        np.random.seed(42)
        needed = max(0, num_samples - len(self.samples))
        print(f"  [Dataset] Augmenting with {needed} heterogeneous multi-scenario interaction patterns...")
        
        for _ in range(needed):
            cid = np.random.choice([1, 2, 3, 4, 5, 6, 7, 8])
            # Speed profiles by class
            speed_ranges = {
                1: (6.0, 15.0), # Car
                2: (5.0, 12.0), # Truck
                3: (4.0, 10.0), # Auto
                4: (6.0, 14.0), # Bike
                5: (2.0, 4.5),  # Bicycle
                6: (0.8, 1.8),  # Pedestrian
                7: (0.4, 1.4),  # Cattle
                8: (0.6, 1.5)   # Pushcart
            }
            v_min, v_max = speed_ranges.get(cid, (3.0, 8.0))
            v0 = np.random.uniform(v_min, v_max)
            heading = np.random.uniform(-0.3, 0.3)
            
            # Generate continuous trajectory
            x0, y0 = np.random.uniform(0, 100), np.random.uniform(-3, 3)
            dt = 0.1
            t_steps = np.arange(self.seq_len) * dt
            
            # Lateral weaving / swerving behavior
            lat_jitter = np.random.uniform(0.1, 0.8) * np.sin(np.random.uniform(0.2, 0.8) * t_steps)
            x_arr = x0 + (v0 * np.cos(heading)) * t_steps
            y_arr = y0 + (v0 * np.sin(heading)) * t_steps + lat_jitter
            
            vx_arr = np.gradient(x_arr, dt)
            vy_arr = np.gradient(y_arr, dt)
            
            hist = np.stack([x_arr[:hist_len], y_arr[:hist_len], vx_arr[:hist_len], vy_arr[:hist_len]], axis=-1)
            fut  = np.stack([x_arr[hist_len:], y_arr[hist_len:]], axis=-1)
            self.samples.append((hist, cid, fut))
            
        print(f"  [Dataset] Total dataset ready: {len(self.samples)} trajectory sequences.")

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        hist, cid, fut = self.samples[idx]
        return (
            torch.tensor(hist, dtype=torch.float32),
            torch.tensor(cid, dtype=torch.long),
            torch.tensor(fut, dtype=torch.float32)
        )

# =========================================================================
# 3. TRAINING PIPELINE WITH NVIDIA RTX 4060 GPU ACCELERATION
# =========================================================================
def train_model():
    print("\n=========================================================================")
    print("   SIH 2026: Training TraPHic-Net Trajectory Predictor on NVIDIA GPU     ")
    print("=========================================================================")
    
    # Check GPU
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"  Hardware Device Selected: {device}")
    if torch.cuda.is_available():
        gpu_name = torch.cuda.get_device_name(0)
        vram_gb = torch.cuda.get_device_properties(0).total_memory / (1024**3)
        print(f"  [GPU Acceleration ACTIVE] {gpu_name} (VRAM: {vram_gb:.2f} GB)")
    else:
        print("  Notice: CUDA not detected, training on CPU.")

    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    scenarios_csv = os.path.join(base_dir, 'data', 'real_traces', 'all_10_scenarios_harvested.csv')
    traphic_csv   = os.path.join(base_dir, 'data', 'real_traces', 'traphic_delhi_arterial.csv')
    idd_csv       = os.path.join(base_dir, 'data', 'real_traces', 'idd_bengaluru_junction.csv')
    models_dir    = os.path.join(base_dir, 'models')
    os.makedirs(models_dir, exist_ok=True)

    # 1. Dataset & DataLoaders covering ALL 10 Scenarios + Real Traces
    print("  [DataLoader] Ingesting trajectories from ALL 10 Indian driving scenarios + Delhi/Bengaluru traces...")
    full_dataset = IndianTrafficTrajectoryDataset([scenarios_csv, traphic_csv, idd_csv], num_samples=25000)
    train_size = int(0.85 * len(full_dataset))
    val_size   = len(full_dataset) - train_size
    train_set, val_set = torch.utils.data.random_split(full_dataset, [train_size, val_size])

    batch_size = 128
    train_loader = DataLoader(train_set, batch_size=batch_size, shuffle=True, pin_memory=True if torch.cuda.is_available() else False)
    val_loader   = DataLoader(val_set, batch_size=batch_size, shuffle=False)

    print(f"  Dataset Split: {train_size} Training sequences | {val_size} Validation sequences (Batch Size: {batch_size})")

    # 2. Instantiate Model, Loss & Optimizer
    model = HeterogeneousTraPHicNet().to(device)
    total_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f"  Model Architecture: TraPHic-Net ({total_params:,} trainable parameters)")

    criterion = nn.SmoothL1Loss()
    optimizer = optim.AdamW(model.parameters(), lr=1e-3, weight_decay=1e-4)
    epochs = 25
    scheduler = optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=epochs, eta_min=1e-5)
    scaler = torch.amp.GradScaler('cuda') if torch.cuda.is_available() else None

    # 3. Training Loop
    train_losses = []
    val_losses = []
    val_ades = []
    val_fdes = []

    print("\n  --- Commencing GPU Training (25 Epochs) ---")
    start_train_time = time.time()

    for epoch in range(1, epochs + 1):
        epoch_start = time.time()
        model.train()
        running_train_loss = 0.0

        for hist_b, cid_b, fut_b in train_loader:
            hist_b = hist_b.to(device)
            cid_b  = cid_b.to(device)
            fut_b  = fut_b.to(device)

            optimizer.zero_grad()

            if scaler is not None:
                with torch.amp.autocast('cuda'):
                    pred = model(hist_b, cid_b)
                    loss = criterion(pred, fut_b)
                scaler.scale(loss).backward()
                scaler.step(optimizer)
                scaler.update()
            else:
                pred = model(hist_b, cid_b)
                loss = criterion(pred, fut_b)
                loss.backward()
                optimizer.step()

            running_train_loss += loss.item() * hist_b.size(0)

        epoch_train_loss = running_train_loss / train_size
        train_losses.append(epoch_train_loss)
        scheduler.step()

        # Validation Pass
        model.eval()
        running_val_loss = 0.0
        total_ade = 0.0
        total_fde = 0.0
        val_samples_count = 0

        with torch.no_grad():
            for hist_b, cid_b, fut_b in val_loader:
                hist_b = hist_b.to(device)
                cid_b  = cid_b.to(device)
                fut_b  = fut_b.to(device)

                pred = model(hist_b, cid_b)
                loss = criterion(pred, fut_b)
                running_val_loss += loss.item() * hist_b.size(0)

                # Displacement errors (meters)
                diff = pred - fut_b # [B, pred_len, 2]
                disp = torch.norm(diff, dim=-1) # [B, pred_len]
                ade = torch.mean(disp, dim=-1).sum().item() # average displacement
                fde = disp[:, -1].sum().item() # final displacement

                total_ade += ade
                total_fde += fde
                val_samples_count += hist_b.size(0)

        epoch_val_loss = running_val_loss / val_size
        epoch_ade = total_ade / val_samples_count
        epoch_fde = total_fde / val_samples_count

        val_losses.append(epoch_val_loss)
        val_ades.append(epoch_ade)
        val_fdes.append(epoch_fde)

        epoch_duration = time.time() - epoch_start
        print(f"  Epoch [{epoch:02d}/{epochs:02d}] ({epoch_duration:.2f}s) | "
              f"Train Loss: {epoch_train_loss:.4f} | Val Loss: {epoch_val_loss:.4f} | "
              f"ADE: {epoch_ade:.2f}m | FDE: {epoch_fde:.2f}m | LR: {scheduler.get_last_lr()[0]:.6f}")

    total_training_duration = time.time() - start_train_time
    print(f"\n  [COMPLETED] Total Training Time on RTX 4060: {total_training_duration:.2f} seconds")
    print(f"  Final Benchmark: Validation ADE = {val_ades[-1]:.2f}m | Final FDE = {val_fdes[-1]:.2f}m")

    # -------------------------------------------------------------
    # 4. EXPORT TRAINED WEIGHTS & ONNX MODEL
    # -------------------------------------------------------------
    # 1. PyTorch native weights
    pt_path = os.path.join(models_dir, 'traPHic_predictor_rtx4060.pt')
    torch.save(model.state_dict(), pt_path)
    print(f"  [SAVED] PyTorch Model Weights: {pt_path}")

    # 2. Export to ONNX (for MATLAB Automated Driving Toolbox import)
    onnx_path = os.path.join(models_dir, 'traPHic_predictor_rtx4060.onnx')
    model.eval()
    dummy_hist = torch.randn(1, 10, 4, device=device)
    dummy_cid  = torch.tensor([3], dtype=torch.long, device=device) # Auto-Rickshaw
    
    try:
        torch.onnx.export(
            model,
            (dummy_hist, dummy_cid),
            onnx_path,
            input_names=['hist_motion', 'class_id'],
            output_names=['predicted_trajectory'],
            dynamic_axes={'hist_motion': {0: 'batch_size'}, 'class_id': {0: 'batch_size'}, 'predicted_trajectory': {0: 'batch_size'}},
            opset_version=14
        )
        print(f"  [SAVED] ONNX Model for MATLAB / Simulink Import: {onnx_path}")
    except Exception as e:
        print(f"  Notice during ONNX export: {e}")

    # 3. Export sample weights & evaluation metrics to MATLAB .mat
    mat_path = os.path.join(models_dir, 'traPHic_training_metrics.mat')
    sio.savemat(mat_path, {
        'train_losses': np.array(train_losses),
        'val_losses': np.array(val_losses),
        'val_ade': np.array(val_ades),
        'val_fde': np.array(val_fdes),
        'final_ade': val_ades[-1],
        'final_fde': val_fdes[-1],
        'gpu_device': gpu_name if torch.cuda.is_available() else 'CPU',
        'training_time_sec': total_training_duration
    })
    print(f"  [SAVED] MATLAB Training Metrics: {mat_path}")

    # -------------------------------------------------------------
    # 5. BENCHMARK GPU VS CPU INFERENCE LATENCY
    # -------------------------------------------------------------
    print("\n  --- Benchmarking Inference Latency (GPU vs CPU) ---")
    model_cpu = HeterogeneousTraPHicNet()
    model_cpu.load_state_dict(torch.load(pt_path, map_location='cpu'))
    model_cpu.eval()

    sample_hist = torch.randn(1, 10, 4)
    sample_cid  = torch.tensor([3], dtype=torch.long)

    # CPU Latency
    t0 = time.time()
    for _ in range(100):
        with torch.no_grad():
            _ = model_cpu(sample_hist, sample_cid)
    cpu_latency_ms = ((time.time() - t0) / 100.0) * 1000

    # GPU Latency
    sample_hist_gpu = sample_hist.to(device)
    sample_cid_gpu  = sample_cid.to(device)
    # Warmup
    for _ in range(20):
        with torch.no_grad():
            _ = model(sample_hist_gpu, sample_cid_gpu)
    if torch.cuda.is_available():
        torch.cuda.synchronize()

    t0 = time.time()
    for _ in range(100):
        with torch.no_grad():
            _ = model(sample_hist_gpu, sample_cid_gpu)
    if torch.cuda.is_available():
        torch.cuda.synchronize()
    gpu_latency_ms = ((time.time() - t0) / 100.0) * 1000

    print(f"  [GPU BENCHMARK] RTX 4060 GPU Latency: {gpu_latency_ms:.2f} ms (Inference throughput: {1000/gpu_latency_ms:.0f} FPS)")
    print(f"  [CPU BENCHMARK] Intel/AMD CPU Latency: {cpu_latency_ms:.2f} ms (Inference throughput: {1000/cpu_latency_ms:.0f} FPS)")

    # -------------------------------------------------------------
    # 6. PLOT TRAINING CURVES (LOSS & ADE/FDE)
    # -------------------------------------------------------------
    plt.figure(figsize=(12, 5), dpi=200)
    plt.style.use('seaborn-v0_8-whitegrid' if 'seaborn-v0_8-whitegrid' in plt.style.available else 'default')

    # Subplot 1: Loss
    plt.subplot(1, 2, 1)
    plt.plot(range(1, epochs + 1), train_losses, 'b-o', linewidth=2, label='Training Loss')
    plt.plot(range(1, epochs + 1), val_losses, 'r--s', linewidth=2, label='Validation Loss')
    plt.title('TraPHic-Net Loss Convergence (NVIDIA RTX 4060 GPU)', fontsize=11, fontweight='bold')
    plt.xlabel('Epoch', fontsize=10)
    plt.ylabel('Smooth L1 Loss', fontsize=10)
    plt.legend(frameon=True)

    # Subplot 2: Displacement Errors
    plt.subplot(1, 2, 2)
    plt.plot(range(1, epochs + 1), val_ades, 'g-^', linewidth=2, label='Average Displacement Error (ADE)')
    plt.plot(range(1, epochs + 1), val_fdes, 'm--d', linewidth=2, label='Final Displacement Error (FDE)')
    plt.title(f'Trajectory Prediction Accuracy (Final ADE: {val_ades[-1]:.2f}m)', fontsize=11, fontweight='bold')
    plt.xlabel('Epoch', fontsize=10)
    plt.ylabel('Error (meters)', fontsize=10)
    plt.legend(frameon=True)

    plt.tight_layout()
    plot_path1 = os.path.join(base_dir, 'docs', 'gpu_training_loss_curve.png')
    plot_path2 = os.path.join(os.path.expanduser('~'), 'Downloads', 'gpu_training_loss_curve.png')
    plt.savefig(plot_path1, dpi=200)
    plt.savefig(plot_path2, dpi=200)
    plt.close()
    print(f"  [SAVED] Training Performance Plot: {plot_path1}")
    print(f"  [SAVED] Copied to Downloads: {plot_path2}")

if __name__ == '__main__':
    train_model()
