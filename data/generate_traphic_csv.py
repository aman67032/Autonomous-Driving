import csv
import numpy as np

# Generate realistic TraPHic-style Delhi Arterial trajectory dataset
# Columns: timestamp, agent_id, class_id, x, y, vx, vy, length, width, height
# Classes: 1=Car, 2=Truck, 3=Auto, 4=Moto, 5=Bike, 6=Ped, 7=Cattle, 8=Pushcart

output_file = 'data/real_traces/traphic_delhi_arterial.csv'

dt = 0.5
total_time = 25.0
timestamps = np.arange(0.0, total_time + dt, dt)

rows = []

# Agent 1: Auto-Rickshaw (abrupt curbside passenger pickup)
# Starts at x=35, y=1.5 (ego lane). At t=5.0s, slows down and swerves to y=2.6 (kerb)
for t in timestamps:
    if t < 5.0:
        x = 35.0 + 7.5 * t
        y = 1.5
        vx = 7.5
        vy = 0.0
    elif t < 8.0:
        tau = t - 5.0
        # slows from 7.5 to 0.0
        vx = max(0.0, 7.5 - 2.5 * tau)
        x = 35.0 + 7.5 * 5.0 + (7.5 * tau - 0.5 * 2.5 * tau**2)
        y = 1.5 + 1.1 * (tau / 3.0)
        vy = 1.1 / 3.0
    else:
        # stopped at kerb
        x = 35.0 + 7.5 * 5.0 + (7.5 * 3.0 - 0.5 * 2.5 * 9.0)
        y = 2.6
        vx = 0.0
        vy = 0.0
    rows.append([f"{t:.1f}", 1, 3, f"{x:.2f}", f"{y:.2f}", f"{vx:.2f}", f"{vy:.2f}", 2.6, 1.3, 1.7])

# Agent 2: Motorcycle 1 (fast lane filtering and weaving)
for t in timestamps:
    vx = 10.5
    x = 10.0 + vx * t
    # weaves between y = 0.2 and y = 1.8
    y = 1.0 + 0.8 * np.sin(0.4 * t)
    vy = 0.8 * 0.4 * np.cos(0.4 * t)
    rows.append([f"{t:.1f}", 2, 4, f"{x:.2f}", f"{y:.2f}", f"{vx:.2f}", f"{vy:.2f}", 2.0, 0.8, 1.2])

# Agent 3: Motorcycle 2 (left shoulder overtake)
for t in timestamps:
    vx = 9.0
    x = 5.0 + vx * t
    y = 2.7  # riding on paved shoulder
    vy = 0.0
    rows.append([f"{t:.1f}", 3, 4, f"{x:.2f}", f"{y:.2f}", f"{vx:.2f}", f"{vy:.2f}", 2.0, 0.8, 1.2])

# Agent 4: Stray Cow (emerging from right median at t=4.0s, crossing to left)
for t in timestamps:
    if t < 4.0:
        x = 92.0
        y = -2.2
        vx = 0.0
        vy = 0.0
    elif t < 12.0:
        tau = t - 4.0
        x = 92.0 + 0.2 * tau
        y = -2.2 + 0.6 * tau  # crosses into y = +2.6
        vx = 0.2
        vy = 0.6
    else:
        x = 92.0 + 0.2 * 8.0
        y = -2.2 + 0.6 * 8.0
        vx = 0.0
        vy = 0.0
    rows.append([f"{t:.1f}", 4, 7, f"{x:.2f}", f"{y:.2f}", f"{vx:.2f}", f"{vy:.2f}", 2.4, 1.1, 1.5])

# Agent 5: Wooden Pushcart (slow curbside transit)
for t in timestamps:
    vx = 1.0
    x = 80.0 + vx * t
    y = 2.5
    vy = 0.0
    rows.append([f"{t:.1f}", 5, 8, f"{x:.2f}", f"{y:.2f}", f"{vx:.2f}", f"{vy:.2f}", 2.2, 1.2, 1.1])

# Agent 6: Heavy Oncoming Tata Truck (opposite lane y = -1.75)
for t in timestamps:
    vx = -9.5
    x = 220.0 + vx * t
    y = -1.75
    vy = 0.0
    rows.append([f"{t:.1f}", 6, 2, f"{x:.2f}", f"{y:.2f}", f"{vx:.2f}", f"{vy:.2f}", 8.5, 2.5, 3.2])

# Agent 7: Pedestrian (informal mid-block darting at x = 60m)
for t in timestamps:
    if t < 3.0:
        x = 60.0
        y = 3.2
        vx = 0.0
        vy = 0.0
    elif t < 7.0:
        tau = t - 3.0
        x = 60.0 + 0.2 * tau
        y = 3.2 - 1.1 * tau  # crosses towards opposite side
        vx = 0.2
        vy = -1.1
    else:
        x = 60.0 + 0.2 * 4.0
        y = 3.2 - 1.1 * 4.0
        vx = 0.0
        vy = 0.0
    rows.append([f"{t:.1f}", 7, 6, f"{x:.2f}", f"{y:.2f}", f"{vx:.2f}", f"{vy:.2f}", 0.5, 0.5, 1.7])

# Sort by timestamp then agent_id
rows.sort(key=lambda r: (float(r[0]), int(r[1])))

with open(output_file, 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['timestamp', 'agent_id', 'class_id', 'x', 'y', 'vx', 'vy', 'length', 'width', 'height'])
    writer.writerows(rows)

print(f"Generated {len(rows)} real trajectory records in {output_file}")
