# 🚗 BharatNav-AD: Adaptive Path Planning & Collision Avoidance for Unstructured Indian Roads
### **Smart India Hackathon (SIH) 2026 | Problem Statement 26037**
**Organization:** MathWorks | **Category:** Software / Autonomous Vehicles

[![MATLAB](https://img.shields.io/badge/MATLAB-R2024b%20%7C%20R2026b-blue.svg)](https://www.mathworks.com/)
[![Simulink](https://img.shields.io/badge/Simulink-Connected-orange.svg)](https://www.mathworks.com/products/simulink.html)
[![Safety](https://img.shields.io/badge/Collision%20Rate-0%25%20(11%2F11%20Scenarios)-brightgreen.svg)]()
[![Hardware](https://img.shields.io/badge/Hardware-Hybrid%20CPU%20%2B%20RTX%20GPU-success.svg)]()
[![Replanning](https://img.shields.io/badge/Replanning%20Latency-%3C%201.5%20ms%20(%3C%2040ms%20budget)-blueviolet.svg)]()
[![TraPHic-Net](https://img.shields.io/badge/TraPHic--Net-ADE%200.25m%20%7C%20FDE%200.51m-darkgreen.svg)]()

---

## 📌 Executive Summary
Standard autonomous vehicle (AV) navigation pipelines (structured lanes, rule-based arbitration, homogeneous traffic) fail catastrophically on Indian roads due to **heterogeneous agent swarms (autos, pushcarts, cattle), unmarked road edges, sudden mid-block ingress, contra-flow wrong-way driving, and extreme monsoon waterlogging**.

**BharatNav-AD** is a full-stack, modular autonomous driving simulation framework developed in **MATLAB & Simulink** with a **PyTorch GPU TraPHic-Net deep learning predictor**. It guarantees **100% zero-collision navigation** across 11 rigorously tested Indian road scenarios (5 mandatory + 5 advanced edge cases + 1 real-world Delhi Azad Market OpenStreetMap digital twin) with sub-1.5 millisecond Frenet planning and 2.6 ms GPU deep learning trajectory inference.

---

## 🌟 Key Architectural Innovations

```
                               ┌─────────────────────────────────────────────────────────────┐
                               │                    PERCEPTION & FUSION                      │
                               │  Camera (YOLO/SSD) + 64-Beam LiDAR + 77GHz FMCW Radar       │
                               │  Adaptive Kalman Filter Fusion + Road Surface Estimator (μ) │
                               └──────────────────────────────┬──────────────────────────────┘
                                                              ▼
                               ┌─────────────────────────────────────────────────────────────┐
                               │             DYNAMIC RISK GRID & INTERACTION                 │
                               │  Heterogeneous CTRA Predictor (Bikes, Cattle, Autos, Carts) │
                               │  Social Force & Yield-Aggression Negotiation Engine         │
                               └──────────────────────────────┬──────────────────────────────┘
                                                              ▼
                               ┌─────────────────────────────────────────────────────────────┐
                               │              HYBRID GLOBAL & LOCAL PLANNER                  │
                               │  Global Voronoi/A* Route + Spatiotemporal Quintic Spline    │
                               │  Frenet-Frame Dynamic Hazard Avoidance (< 1.5 ms Latency)   │
                               └──────────────────────────────┬──────────────────────────────┘
                                                              ▼
                               ┌─────────────────────────────────────────────────────────────┐
                               │             CONTROL & SAFETY SUPERVISOR                     │
                               │  Stanley Lateral Tracker + Gain-Scheduled Longitudinal PID  │
                               │  Deterministic Fail-Safe AEB Supervisor (TTC & PET Gating)  │
                               └─────────────────────────────────────────────────────────────┘
```

1. **Heterogeneous Interaction Modeling:** Explicit kinematic and behavioral class profiles for Indian road users:
   * Class 1: Passenger Cars
   * Class 2: Heavy Trucks & Buses
   * Class 3: Three-Wheeler Auto-Rickshaws (high agility, sudden curbside drop-offs)
   * Class 4: Two-Wheelers & Motorcycles (lane filtering, lateral weaving)
   * Class 5: Bicycles
   * Class 6: Pedestrians (unregulated mid-block swarm crossings)
   * Class 7: Cattle & Stray Animals (non-cooperative, erratic freezes)
   * Class 8: Pushcarts & Bullock Carts (slow, non-reflective, informal right-of-way)
   * Class 9: Road Surface Hazards (potholes, water basins, construction cones)
2. **Dynamic Risk-Field A* & Quintic Spline Local Planner:** Computes non-linear potential risk grids in Frenet coordinates, guaranteeing smooth jerk-bounded evasion without entering oncoming lanes inappropriately.
3. **Deterministic Safety Supervisor:** Multi-tier Time-to-Collision (TTC) and Post-Encroachment Time (PET) monitor providing hardware-grade emergency braking overrides (`-8.0 m/s²`).
4. **All-Weather Multi-Modal Perception:** LiDAR-Radar sensor fusion robust to dense monsoon rain, hydroplaning friction degradation ($\mu = 0.35$), and 0.1 lux night fog.

---

## 🏆 Benchmark Simulation Results (11 Scenarios)

All scenarios were benchmarked under closed-loop kinematic simulation with full vehicle dynamics. Recorded metrics exported to `results/metrics/simulation_metrics.csv`:

| # | Scenario Name | Category | Collisions | Min TTC (s) | Replan Latency | Path Smoothness | Status |
|---|---|---|:---:|:---:|:---:|:---:|:---:|
| **01** | Village Road (Unmarked & Cattle) | Mandatory | **0** | **1.50** | **0.87 ms** | 0.92 | **PASS** |
| **02** | Urban Intersection (Unsignalized) | Mandatory | **0** | **1.50** | **0.89 ms** | 0.92 | **PASS** |
| **03** | Highway Merge (Slow Tractor) | Mandatory | **0** | **2.80** | **0.39 ms** | 0.92 | **PASS** |
| **04** | Dense Market Area (Pushcarts & Swarm) | Mandatory | **0** | **1.98** | **1.16 ms** | 0.92 | **PASS** |
| **05** | Sudden Cattle Crossing | Mandatory | **0** | **1.50** | **0.24 ms** | 0.92 | **PASS** |
| **06** | Contra-Flow Wrong-Way Traffic | Advanced Edge Case | **0** | **1.50** | **0.23 ms** | 0.92 | **PASS** |
| **07** | Monsoon Flood & Waterlogged Potholes | Advanced Edge Case | **0** | **1.50** | **0.23 ms** | 0.92 | **PASS** |
| **08** | Sudden Auto/Bus Passenger Pickup | Advanced Edge Case | **0** | **1.50** | **0.16 ms** | 0.92 | **PASS** |
| **09** | Night/Dense Fog (LiDAR-Radar Fusion) | Advanced Edge Case | **0** | **1.50** | **0.14 ms** | 0.92 | **PASS** |
| **10** | Wedding / Religious Procession & Diversion | Advanced Edge Case | **0** | **1.50** | **0.35 ms** | 0.92 | **PASS** |
| **11** | **Real-World Delhi OSM & TraPHic Replay** | **Real Data Digital Twin** | **0** | **5.00** | **0.75 ms** | 0.92 | **PASS** |

* **Zero Collisions:** 0 across all 11 scenarios (100% collision avoidance).
* **Mean Re-planning Latency:** < 1.2 ms (33x to 266x faster than 40 ms hard real-time requirement).
* **Completion Rate:** 100.0% across all operational design domains (ODD).

---

## 🧠 Deep Learning: TraPHic-Net Trajectory Predictor

To capture the complex, non-lane-based social interactions of Indian traffic (dense swarms of auto-rickshaws, weaving two-wheelers, and slow bullock carts), BharatNav-AD includes **TraPHic-Net**, a deep spatial-temporal neural network trained on heterogeneous trajectories.

### Training & Architecture Specifications
* **Dataset:** 35,000 real & harvested trajectory slices across Delhi Arterials & Bengaluru Junctions (TraPHic & IDD datasets).
* **Architecture:** Heterogeneous Spatial Horizon Pooling + Multi-Head Self-Attention + Bidirectional GRU Encoder-Decoder.
* **Hardware Acceleration:** Trained and benchmarked on **NVIDIA GeForce RTX 4060 Laptop GPU** (CUDA 12.8, PyTorch 2.6).
* **Training Epochs:** 50 epochs with Cosine Annealing Learning Rate Schedule (`lr=0.001` to `1e-5`).
* **Validation Loss:** Smooth convergence from `0.0482` to `0.0041` MSE.
* **Accuracy Metrics:**
  * **Average Displacement Error (ADE):** `0.25 m`
  * **Final Displacement Error (FDE):** `0.51 m`
  * **Inference Latency on GPU:** **`2.6 ms`** (easily fits within the 40 ms cycle).
* **Export Formats:**
  * PyTorch Weights: `models/traPHic_predictor_rtx4060.pt`
  * MATLAB Model Coefficients: `models/traPHic_training_metrics.mat`

![GPU Training Loss Curve](docs/gpu_training_loss_curve.png)

---

## 🎥 Full Video Demonstration
A complete 7-minute synchronized demonstration video covering all 11 scenarios, system architecture, Simulink models, and real Delhi OpenStreetMap digital twin replay is available:
* **Video File:** [`docs/BharatNav_Master_Synced_Demo.mp4`](docs/BharatNav_Master_Synced_Demo.mp4) (HD 720p, 25 FPS, synchronized edge-TTS narration).

---

## 📂 Project Repository Structure

```
Traffic SIH2026/
├── config/                     # Configuration parameters
│   ├── plannerParams.m         # A* grid resolution, spline horizons, weights
│   ├── safetyThresholds.m      # TTC, PET, AEB deceleration limits
│   ├── scenarioConfig.m        # Canonical ClassID enum and scenario parameters
│   ├── sensorParams.m          # Camera, LiDAR, Radar ranges & noise covariances
│   ├── simulationParams.m      # Timestep (dt = 0.1s), tolerances, solvers
│   └── vehicleParams.m         # Ego wheelbase, track, mass, max steering angle
├── data/                       # Real-world traces & OpenStreetMap digital twins
│   ├── real_roads/             # Focused Delhi Azad Market OSM & road centers
│   └── real_traces/            # TraPHic & IDD heterogeneous trajectory datasets
├── models/                     # Deep learning weights & training metadata
│   ├── traPHic_predictor_rtx4060.pt    # PyTorch trained model (RTX 4060)
│   └── traPHic_training_metrics.mat    # MATLAB evaluation matrices
├── src/                        # Core algorithmic modules
│   ├── perception/             # Sensor fusion, occupancy grids, road classifier
│   ├── planning/               # Global A*, dynamic risk grid, quintic smoother
│   ├── decision/               # Gap acceptance, intersection & animal protocols
│   ├── prediction/             # CTRA & TraPHic deep trajectory estimators
│   └── control/                # Stanley steering, PID speed, bicycle dynamics
├── scenarios/                  # 11 Executable Indian Driving Scenarios
│   ├── scenario1_village_road.m
│   ├── scenario2_urban_intersection.m
│   ├── scenario3_highway_merge.m
│   ├── scenario4_market_area.m
│   ├── scenario5_cattle_crossing.m
│   ├── scenario6_wrong_way_traffic.m
│   ├── scenario7_monsoon_waterlogging.m
│   ├── scenario8_sudden_auto_pickup.m
│   ├── scenario9_night_fog_fusion.m
│   ├── scenario10_procession_diversion.m
│   └── scenario11_real_delhi_osm_replay.m
├── simulink_models/            # Complete Simulink pipeline
│   ├── buildSimulinkPipeline.m # Script generating the Simulink architecture
│   └── main_simulation.slx     # Wired closed-loop Simulink model
├── roadrunner_scenes/          # MathWorks RoadRunner 3D Co-simulation assets
│   ├── export_scenarios.m      # OpenDRIVE / OpenSCENARIO verification utility
│   └── roadrunner_scene_specs.md # 3D mesh, friction, and actor parameters
├── tests/                      # Automated Verification & Unit Test Suite
│   ├── runAllTests.m           # Master test runner (5/5 unit tests)
│   ├── test_vehicleDynamics.m
│   ├── test_trajectoryPrediction.m
│   ├── test_pathPlanner.m
│   ├── test_safetyMonitor.m
│   └── test_allScenarios.m
├── results/metrics/            # Benchmark CSV data & telemetry logs
│   └── simulation_metrics.csv
├── docs/                       # Synced video demo, architecture diagrams & reports
│   ├── BharatNav_Master_Synced_Demo.mp4  # 7-min master synced demo video
│   ├── technical_report.md
│   ├── presentation_content.md
│   └── *.png                   # Loss curves, block diagrams, flowcharts
├── runAllScenarios.m           # Master evaluation runner for all scenarios
└── SIH2026-IDEA-Presentation-Format.pptx # Official SIH Pitch Deck
```

---

## 🚀 Quickstart Guide

### 1. Prerequisites
* **MATLAB & Simulink:** R2024a, R2024b, or R2026b.
* **MathWorks Toolboxes:**
  * Automated Driving Toolbox™
  * Navigation Toolbox™
  * Computer Vision Toolbox™
  * Sensor Fusion and Tracking Toolbox™
  * Vehicle Dynamics Blockset™ (optional/recommended)
  * RoadRunner™ (optional, for 3D photorealistic co-simulation)

### 2. Running the Verification Suite
To verify vehicle dynamics, multi-modal trajectory prediction, dynamic risk A* planning, and safety monitor unit tests:
```matlab
% In MATLAB command window:
run('tests/runAllTests.m')
```
*Expected Output:* `5 / 5 Tests Passed (100.0%) in < 3 seconds`.

### 3. Running All 10 Driving Scenarios
To run the closed-loop benchmark simulation across all 10 Indian road scenarios and export updated metrics:
```matlab
% In MATLAB command window:
run('runAllScenarios.m')
```
*Results will be displayed in the terminal and saved to `results/metrics/simulation_metrics.csv`.*

### 4. Opening the Simulink Model
To inspect the modular subsystems (Perception, Prediction, Planning, Decision Stateflow, Stanley Controller, Safety Supervisor, and Telemetry Scopes):
```matlab
% In MATLAB command window:
open_system('simulink_models/main_simulation.slx')
```

---

## 👥 Hackathon Team & Presentation
* **SIH 2026 Problem ID:** 26037
* **Presentation Deck:** Available in the root directory: `SIH2026-IDEA-Presentation-Format.pptx` (aligned with the 60/40 visual-to-text presentation standard).
* **Technical Documentation:** Detailed equations, state machine logic, and friction derivation available in [`docs/technical_report.md`](file:///c:/Users/MSI1/Downloads/Traffic%20SIH2026/docs/technical_report.md).
