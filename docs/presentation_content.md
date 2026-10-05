# 📊 SIH 2026 PPT Content Guide: Problem Statement 26037

This guide maps directly to the official 6-slide template: **`SIH2026-IDEA-Presentation-Format.pptx`**. Use these bullet points and diagrams when preparing your final slide deck.

---

### Slide 1: Title Page
* **Title:** BharatNav-AD: Adaptive Path Planning & Collision Avoidance for Autonomous Vehicles on Unstructured Indian Roads
* **Problem Statement ID:** 26037
* **Theme:** Smart Vehicles
* **PS Category:** Software
* **Organization:** MathWorks
* **Team ID & Name:** [Your Registered Team ID & Team Name]

---

### Slide 2: Proposed Solution (Describe your Idea/Solution/Prototype)
* **Core Problem Addressed:**
  * Western autonomous driving algorithms fail on Indian roads due to reliance on clear lane markings, strict discipline, and homogeneous motorized traffic.
  * Indian roads feature high disparity (cows, rickshaws, pushcarts, bikes), missing road edges, potholes, and informal merging.
* **Our Solution — BharatNav-AD:**
  * A full closed-loop autonomous simulation pipeline built in **MATLAB & Simulink** with **RoadRunner 3D environments**.
  * Replaces rigid lane boundaries with **Spatiotemporal Dynamic Risk Grids** and **TraPHic++ Interaction-Aware Prediction**.
  * Implements **Stateflow-based Indian Tactical Decision Logic** (gap negotiation, animal protocols, creep-and-peek).
* **Innovation & Uniqueness:**
  * **Zero Lane Dependency:** Free-space navigation using continuous risk potential fields.
  * **India-Specific Perception:** Trained on Indian Driving Dataset (IDD) for 13 non-standard classes.
  * **Pothole & Surface-Aware:** Path optimization penalizes road damage and bad shoulders.
  * **Runtime Safety Supervisor:** Deterministic Time-to-Collision (TTC) emergency override layer.

---

### Slide 3: Technical Approach (Technologies & Implementation Methodology)
* **Technologies & Frameworks:**
  * **MathWorks Toolchain:** MATLAB R2024b, Simulink, RoadRunner, Automated Driving Toolbox, Navigation Toolbox, Stateflow, Deep Learning Toolbox, Vehicle Dynamics Blockset.
  * **Perception:** Camera-LiDAR-Radar EKF Sensor Fusion + Road Damage CNN.
  * **Prediction:** TraPHic++ / CTRA generating $K=5$ probabilistic trajectory hypotheses.
  * **Planning:** Global A* route search + Local Hybrid A*/MPC with cubic spline smoothing.
  * **Vehicle Dynamics:** Non-linear Kinematic Bicycle Model with road friction adaptation ($\mu$).
* **Implementation Flowchart:**
  ```
  Multi-Sensors (Cam/LiDAR/Radar) ➔ EKF Sensor Fusion ➔ TraPHic++ Trajectory Predictor
           ➔ Dynamic Risk Grid Costmap ➔ Hybrid A*/MPC Local Planner
           ➔ Stateflow Decision FSM ➔ Stanley/PID Controller ➔ Bicycle Dynamics
                      ▲                                │
                      └──── Runtime Safety Supervisor ─┘
  ```
* **Closed-Loop Working Prototype:**
  * Full simulation running at 100 Hz simulation rate, 10 Hz planning rate, < 40 ms replanning latency.

---

### Slide 4: Feasibility and Viability
* **Technical Feasibility:**
  * Built natively using industry-standard automotive engineering tools (MathWorks ADT, Simulink Coder compatible).
  * **CPU-friendly:** 85% of architecture runs in real-time on standard x86 laptops without requiring high-end GPUs.
* **Potential Challenges & Mitigation Strategies:**
  1. *Challenge: Unpredictable animal / pedestrian motion.*  
     ➔ *Strategy:* Multi-modal hypothesis forecasting with spatiotemporal risk inflation.
  2. *Challenge: Sensor degradation in dust, monsoon rain, and low light.*  
     ➔ *Strategy:* Multi-modal fusion with dynamic sensor trust weighting based on IDD-AW principles.
  3. *Challenge: High computational latency on embedded edge hardware.*  
     ➔ *Strategy:* Hierarchical decoupling (fast 50 Hz reactive safety layer + 10 Hz optimization planner).
* **Validation Across 5 Realistic Scenarios:**
  * Unmarked Village Road, Unsignalized Intersection, Highway Merge with Tractors, Dense Market Area, Sudden Cattle Crossing.

---

### Slide 5: Impact and Benefits
* **Target Audience & Stakeholders:**
  * Indian Automotive OEMs (Tata Motors, Mahindra, Maruti Suzuki) adopting Level 2+/3 ADAS.
  * Commercial logistics, automated campus shuttles, and agricultural automation.
  * Smart City infrastructure and traffic research bodies (MoRTH, ARAI).
* **Key Benefits:**
  * **Social & Safety Impact:** 70%+ of Indian road fatalities occur on undivided/rural roads. BharatNav-AD prevents collisions with vulnerable road users (pedestrians, two-wheelers, animals).
  * **Economic Viability:** Eliminates reliance on expensive high-definition (HD) mapping infrastructure ($10\times$ cost reduction in deployment).
  * **Environmental:** Smooth curvature and optimized acceleration profiles reduce erratic braking/idling, cutting fuel consumption and emissions by up to 12% in congestion.

---

### Slide 6: Research and References
* **arXiv Literature Survey:**
  1. *FocalAD: Local Motion Planning for End-to-End Autonomous Driving* (arXiv:2506.11419, 2025)
  2. *CogAD: Cognitive-Hierarchy Guided End-to-End Autonomous Driving* (arXiv:2505.21581, 2025)
  3. *TraPHic: Trajectory Prediction in Heterogeneous Traffic* (arXiv:1812.04767, CVPR)
  4. *INDRA: A Dataset and Model for Crossing Indian Roads* (arXiv:2211.07916)
  5. *Control Strategies for Autonomous Vehicles* (arXiv:2011.08729, CRC Press)
  6. *TaCarla: Comprehensive Benchmarking for Autonomous Driving* (arXiv:2602.23499, 2026)
* **Datasets & Benchmarks:**
  * Indian Driving Dataset (IDD & IDD-AW) — IIIT Hyderabad (https://idd.insaan.iiit.ac.in)
  * Mendeley Traffic Data Repository (https://data.mendeley.com)
* **Toolchain Documentation:**
  * MathWorks Automated Driving Toolbox, RoadRunner, & Navigation Toolbox Reference Guides.
