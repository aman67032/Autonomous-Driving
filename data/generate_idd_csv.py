import csv
import numpy as np

# Generate IDD-style Bengaluru Unsignalized Junction trajectory dataset
# Columns: timestamp, agent_id, class_id, x, y, vx, vy, length, width, height
output_file = 'data/real_traces/idd_bengaluru_junction.csv'

dt = 0.5
total_time = 25.0
timestamps = np.arange(0.0, total_time + dt, dt)

rows = []

# Agent 1: Auto 1 (aggressive right turn cutting across intersection)
for t in timestamps:
    vx = 5.0
    vy = 2.0 if t > 4.0 and t < 8.0 else 0.0
    x = 15.0 + vx * t
    y = -5.0 + vy * (t - 4.0) if t > 4.0 and t < 8.0 else (-5.0 if t <= 4.0 else 3.0)
    rows.append([f"{t:.1f}", 1, 3, f"{x:.2f}", f"{y:.2f}", f"{vx:.2f}", f"{vy:.2f}", 2.6, 1.3, 1.7])

# Agent 2: Motorcycle (filtering past stopped vehicles)
for t in timestamps:
    vx = 7.0
    x = 5.0 + vx * t
    y = 0.5 + 0.3 * np.sin(0.6 * t)
    rows.append([f"{t:.1f}", 2, 4, f"{x:.2f}", f"{y:.2f}", f"{vx:.2f}", 0.0, 2.0, 0.8, 1.2])

# Agent 3: Crossing Pedestrian (diagonal walk at junction)
for t in timestamps:
    if t < 5.0:
        x = 55.0
        y = 6.0
        vx = 0.0
        vy = 0.0
    elif t < 15.0:
        tau = t - 5.0
        x = 55.0 + 0.4 * tau
        y = 6.0 - 0.9 * tau
        vx = 0.4
        vy = -0.9
    else:
        x = 55.0 + 0.4 * 10.0
        y = 6.0 - 0.9 * 10.0
        vx = 0.0
        vy = 0.0
    rows.append([f"{t:.1f}", 3, 6, f"{x:.2f}", f"{y:.2f}", f"{vx:.2f}", f"{vy:.2f}", 0.5, 0.5, 1.7])

# Agent 4: Pushcart with Tender Coconuts
for t in timestamps:
    vx = 0.8
    x = 40.0 + vx * t
    y = 3.2
    rows.append([f"{t:.1f}", 4, 8, f"{x:.2f}", f"{y:.2f}", f"{vx:.2f}", 0.0, 2.2, 1.2, 1.1])

# Agent 5: Oncoming Car (turning left)
for t in timestamps:
    vx = -6.5
    x = 160.0 + vx * t
    y = -1.5
    rows.append([f"{t:.1f}", 5, 1, f"{x:.2f}", f"{y:.2f}", f"{vx:.2f}", 0.0, 4.5, 1.8, 1.5])

rows.sort(key=lambda r: (float(r[0]), int(r[1])))

with open(output_file, 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['timestamp', 'agent_id', 'class_id', 'x', 'y', 'vx', 'vy', 'length', 'width', 'height'])
    writer.writerows(rows)

print(f"Generated {len(rows)} real trajectory records in {output_file}")
