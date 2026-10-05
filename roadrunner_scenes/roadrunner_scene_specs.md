# 🛣️ RoadRunner Scene Design Specifications for Unstructured Indian Roads
# Problem Statement 26037: Adaptive Path Planning and Collision Avoidance for Autonomous Vehicles on Unstructured Indian Roads

This document details the exact 3D scene specifications for modeling all **10 Indian road scenarios** using **MathWorks RoadRunner**, exporting them to **ASAM OpenDRIVE (.xodr)** and **OpenSCENARIO (.xosc)**, and co-simulating with MATLAB/Simulink and the Automated Driving Toolbox.

---

## 1. Scene 1: Unmarked Village Road (`village_road.rrscene`)
* **Geometry:** Single undivided bi-directional carriageway, 400m length, 6.0m total width (Indian Keep-Left, Ego at $y = +1.5\text{m}$, Oncoming at $y = -1.5\text{m}$).
* **Surface & Shoulders:** Unmarked asphalt (transparency 0%), unpaved gravel/earthen shoulders (1.5m wide, $\mu = 0.55$), roadside drainage ditches ($0.8\text{m}$ depth). 3 pothole depressions at $x = 45\text{m}, 90\text{m}, 140\text{m}$ (depth 8–10 cm).
* **Props & Foliage:** Acacia and Neem roadside trees, clay village huts, brick boundary walls, hand-pump stall.
* **Dynamic Actors:**
  * Slow Preceding Bicycle: $x=20\text{m}, y=+2.2\text{m}$, speed $3.0\text{ m/s}$ ($10.8\text{ km/h}$).
  * Oncoming Tata 407 Truck: $x=180\text{m}, y=-1.5\text{m}$, speed $10.0\text{ m/s}$ ($36\text{ km/h}$).
  * Crossing Cow: $x=85\text{m}$, crosses from $y=+5.5\text{m} \to -4.0\text{m}$ at $1.0\text{ m/s}$.
  * Village Pedestrians: Walking along shoulder facing traffic.

---

## 2. Scene 2: Busy Urban Unsignalized Intersection (`urban_intersection.rrscene`)
* **Geometry:** 4-way unsignalized cross intersection. Main north-south arterial (14.0m width, undivided 4-lane informal), cross commercial street (10.0m width). Curb radius 6.0m.
* **Props & Occlusions:** Curbside fruit cart (thela) and blue tarpaulin awning at northeast corner obstructing line of sight. Concrete utility poles with overhead dangling cables.
* **Dynamic Heterogeneous Actors:**
  * 3 Autorickshaws (yellow/green Bajaj RE): Weaving patterns, abrupt turn execution ($18–25\text{ km/h}$).
  * 4 Motorcycles: Informal gap cutting across intersection without lane discipline.
  * 1 Heavy Wooden Pushcart: Crossing diagonally at $1.0\text{ m/s}$.
  * 6 Pedestrians: Swarming crosswalks and mid-block crossings.

---

## 3. Scene 3: Highway Merge with Slow Tractor (`highway_merge.rrscene`)
* **Geometry:** 600m dual-carriageway divided expressway with 2 main lanes ($3.5\text{m}$ each) and an Indian left-hand slip on-ramp ($180\text{m}$ taper).
* **Surface & Infrastructure:** High-speed concrete/asphalt ($\mu = 0.85$), W-beam guardrails, overhead gantry signage.
* **Dynamic Actors:**
  * Slow Farm Tractor & Trolley: Cruising left lane at $4.0\text{ m/s}$ ($14.4\text{ km/h}$) with sugarcane overhang.
  * Fast Right-Lane Car: Approaching in outer lane at $22.0\text{ m/s}$ ($79.2\text{ km/h}$).
  * Ego Vehicle: Merging from acceleration ramp at $14.0\text{ m/s}$ requiring dynamic gap evaluation.

---

## 4. Scene 4: Dense Market Area & Pedestrian Swarm (`market_area.rrscene`)
* **Geometry:** Dense commercial bazaar street, 200m length, narrow 5.5m roadway enclosed by closely packed commercial shopfronts.
* **Props & Encroachments:** Parked delivery truck ($x=85\text{m}, y=+2.2\text{m}$), roadside vegetable baskets, display stalls encroaching 1m into asphalt.
* **Dynamic Actors:**
  * 16 Random-Walking Pedestrians (shoppers, children, elders) crossing organically (seeded `rng(42)`).
  * 2 Pushcarts moving along road edges.
  * 4 Delivery Motorcycles and 3 Autorickshaws weaving between pedestrians.
  * Ego Vehicle: Crawling at safe speed ($2–3\text{ m/s}$), computing dynamic repulsive risk fields.

---

## 5. Scene 5: Sudden Cattle Crossing (`cattle_crossing.rrscene`)
* **Geometry:** 350m peri-urban state highway, 7.0m two-lane undivided asphalt ($\mu = 0.80$).
* **Foliage & Concealment:** Dense roadside shrubs at $x=65–75\text{m}$ concealing entering animals.
* **Dynamic Actors:**
  * Cattle Herd (5 Cows + 1 Herder): Stationary/slowly moving cows on shoulder that abruptly enter Ego lane at $t=3.5–6.5\text{s}$ at $0.8–1.2\text{ m/s}$.
  * Oncoming Car: Approaching in opposite lane ($y=-1.75\text{m}$) at $12.0\text{ m/s}$, preventing lateral lane change.
  * Ego Vehicle: Requires strict in-lane AEB deceleration to a complete standstill without rear-end risk.

---

## 6. Scene 6: Contra-Flow Wrong-Way Traffic (`wrong_way_traffic.rrscene`)
* **Geometry:** 300m arterial road with raised central median curb, 2 lanes per carriageway ($7.0\text{m}$ total one-way).
* **Dynamic Actors:**
  * Wrong-Way Autorickshaw: Traveling against legal flow at $-7.0\text{ m/s}$ in Ego's lane ($y=+1.75\text{m}$).
  * Lead Vehicle: Travelling ahead of Ego, performs sudden evasion swerve to the left shoulder at $t=4.5\text{s}$, abruptly revealing the wrong-way auto.
  * Oncoming Lane Traffic: Heavy flow in opposite carriageway; right lane clear window exists between $t=8\text{s}$ and $t=14\text{s}$ for Ego evasion.

---

## 7. Scene 7: Monsoon Waterlogging & Submerged Potholes (`monsoon_waterlogging.rrscene`)
* **Geometry:** 350m urban arterial road under heavy monsoon precipitation.
* **Environmental & Surface Features:**
  * Roadway friction degraded to $\mu = 0.35$ (wet asphalt / hydroplaning risk).
  * Standing Waterlogged Basin: $16\text{m} \times 3.2\text{m}$ puddle (depth 12 cm) covering left lane at $x=100\text{m}$.
  * Submerged Severe Pothole: $1.2\text{m}$ diameter, 15 cm rim drop hidden under water surface.
* **Dynamic Actors:**
  * Oncoming City Bus: Passing on right lane at $8.0\text{ m/s}$.
  * Ego Vehicle: Employs surface friction estimator, reduces speed, and negotiates lane edge around waterlogged hazard.

---

## 8. Scene 8: Sudden Auto/Bus Passenger Pickup (`sudden_auto_pickup.rrscene`)
* **Geometry:** 300m multi-lane urban transit corridor, curbside bus shelters.
* **Dynamic Actors:**
  * Preceding Autorickshaw: Cruising at $11.0\text{ m/s}$ in front of Ego ($x=60\text{m}$).
  * Hailer/Passenger: Waving on roadside at $x=110\text{m}$.
  * Auto Action: Drops speed abruptly from $11\text{ m/s} \to 0$ at $-5.5\text{ m/s}^2$, swerving across Ego lane to curb.
  * Tailgating Two-Wheeler: Motorcycle following Ego closely ($1.2\text{s}$ headway) offset by $0.6\text{m}$.
  * Ego Vehicle: Senses abrupt deceleration, initiates progressive braking avoiding both rear-end collision from motorcycle and frontend crash with auto.

---

## 9. Scene 9: Night & Dense Fog with LiDAR-Radar Fusion (`night_fog_fusion.rrscene`)
* **Geometry:** 350m unlit rural bypass road, dark environment (0.1 lux ambient illumination).
* **Weather & Atmospheric:** Dense advection fog, meteorological optical range (MOR) $< 20\text{m}$.
* **Sensor Degradation Modeling:**
  * Monocular Camera: Range reduced from $120\text{m} \to 15\text{m}$, SNR degraded by 85%.
  * 64-Beam LiDAR: Atmospheric scattering, max detection range $80\text{m}$.
  * 77 GHz FMCW Radar: Unaffected by fog, penetration range $110\text{m}$.
* **Dynamic Actors:**
  * Unlit Bullock Cart: Wooden cart with no tail reflectors moving at $2.5\text{ m/s}$ ($9\text{ km/h}$).
  * Oncoming Car: Approaching with high-beam headlights causing optical camera blooming.
  * Ego Vehicle: Uses EKF sensor fusion to reliably detect cart at $60\text{m}$ via Radar+LiDAR and safely overtake.

---

## 10. Scene 10: Wedding / Religious Procession Diversion (`procession_diversion.rrscene`)
* **Geometry:** 400m urban boulevard, divided carriageway with construction cones setting up a temporary choke point.
* **Props & Decor:** Festive shamiana / tent, floral carts, band trolley, 12 traffic cones channeling traffic from $y=+1.5\text{m}$ into single shared corridor ($y=-1.0\text{m}$).
* **Dynamic Actors:**
  * 14 Procession Celebrants: Moving slowly forward at $0.6\text{ m/s}$ with high lateral jitter/dancing.
  * Generator Band Cart: $3.0\text{m} \times 1.6\text{m}$ slow trailer at $0.5\text{ m/s}$.
  * Cooperative Opposite Vehicle: Yielding before choke point at $x=145\text{m}$.
  * Ego Vehicle: Yields, follows funneling cones, passes procession safely at $4\text{ m/s}$ through shared lane bottleneck.

---

## 11. RoadRunner to MATLAB/Simulink Co-Simulation Workflow

### Step 1: Exporting from RoadRunner
In the MathWorks RoadRunner application:
1. Open the respective `.rrscene` file.
2. Select `File -> Export -> ASAM OpenDRIVE (.xodr)`.
3. Select `File -> Export -> ASAM OpenSCENARIO (.xosc)`.
4. Export assets to `roadrunner_scenes/<scenario_name>/`.

### Step 2: Programmatic Import into MATLAB Driving Scenario
```matlab
% In MATLAB command prompt:
scenario = drivingScenario;
roadNetwork(scenario, 'OpenDRIVE', 'roadrunner_scenes/village_road/village_road.xodr');

% Add ego vehicle with Automated Driving Toolbox sensors
ego = vehicle(scenario, 'ClassID', 1, 'Position', [0 1.5 0], 'Velocity', [8 0 0]);
```

### Step 3: Closed-Loop Simulink Pipeline
1. Open `simulink_models/main_simulation.slx`.
2. Connect the **RoadRunner Scenario** block (`automateddriving/Scenario Simulation`).
3. Stream dynamic ego commands (acceleration $a_x$, steering angle $\delta$) directly into RoadRunner 3D engine in real time.
