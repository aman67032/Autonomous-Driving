import os
import time
import numpy as np
import scipy.io as sio
import matplotlib.pyplot as plt
import torch

def plot_and_benchmark():
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    mat_path = os.path.join(base_dir, 'models', 'traPHic_training_metrics.mat')
    pt_path  = os.path.join(base_dir, 'models', 'traPHic_predictor_rtx4060.pt')
    
    data = sio.loadmat(mat_path)
    train_losses = data['train_losses'].flatten()
    val_losses   = data['val_losses'].flatten()
    val_ades     = data['val_ade'].flatten()
    val_fdes     = data['val_fde'].flatten()
    epochs       = len(train_losses)
    
    print(f"Loaded training results: {epochs} epochs.")
    print(f"Final Validation ADE: {val_ades[-1]:.2f} m | Final FDE: {val_fdes[-1]:.2f} m")

    # Benchmarking latency
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Benchmarking on {device}...")

    # Plot
    plt.figure(figsize=(12, 5), dpi=200)
    plt.style.use('seaborn-v0_8-whitegrid' if 'seaborn-v0_8-whitegrid' in plt.style.available else 'default')

    # Subplot 1: Loss
    plt.subplot(1, 2, 1)
    plt.plot(range(1, epochs + 1), train_losses, 'b-o', linewidth=2, label='Training Loss (Smooth L1)')
    plt.plot(range(1, epochs + 1), val_losses, 'r--s', linewidth=2, label='Validation Loss')
    plt.title('TraPHic-Net Loss Convergence (NVIDIA RTX 4060 GPU)', fontsize=11, fontweight='bold')
    plt.xlabel('Epoch', fontsize=10)
    plt.ylabel('Loss', fontsize=10)
    plt.legend(frameon=True)

    # Subplot 2: Displacement Errors
    plt.subplot(1, 2, 2)
    plt.plot(range(1, epochs + 1), val_ades, 'g-^', linewidth=2, label='Average Displacement Error (ADE)')
    plt.plot(range(1, epochs + 1), val_fdes, 'm--d', linewidth=2, label='Final Displacement Error (FDE)')
    plt.title(f'Trajectory Prediction Accuracy (Final ADE: {val_ades[-1]:.2f} m, FDE: {val_fdes[-1]:.2f} m)', fontsize=11, fontweight='bold')
    plt.xlabel('Epoch', fontsize=10)
    plt.ylabel('Error (meters)', fontsize=10)
    plt.legend(frameon=True)

    plt.tight_layout()
    out1 = os.path.join(base_dir, 'docs', 'gpu_training_loss_curve.png')
    out2 = os.path.join(os.path.expanduser('~'), 'Downloads', 'gpu_training_loss_curve.png')
    plt.savefig(out1, dpi=200)
    plt.savefig(out2, dpi=200)
    plt.close()
    print(f"[SUCCESS] Saved training curve to: {out1}")
    print(f"[SUCCESS] Copied training curve to: {out2}")

if __name__ == '__main__':
    plot_and_benchmark()
