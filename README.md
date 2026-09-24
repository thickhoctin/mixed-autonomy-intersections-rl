# Multi-Agent Reinforcement Learning for Mixed-Autonomy Unsignalized Intersections

**Master's Thesis Project — Thanh Tung Nguyen**  
Technische Hochschule Ingolstadt (THI) · Automated Driving and Vehicle Safety  
Submitted: May 2026

This repository contains the implementation, experiments, evaluation scripts, and selected results from my master's thesis on **multi-agent reinforcement learning (MARL) for behavioral control in mixed-autonomy, unsignalized intersections**.

The project investigates how reinforcement-learning-controlled autonomous vehicles can coordinate traffic flow in a realistic mixed-autonomy setting with **human-driven vehicles, stochastic traffic demand, turning maneuvers, imperfect V2V communication, and safety constraints**.

> **Research basis:** this work extends the open-source framework from Zhongxia Yan and Cathy Wu, *Reinforcement Learning for Mixed Autonomy Intersections* (IEEE ITSC 2021).  
> Original repository: https://github.com/ZhongxiaYan/mixed_autonomy_intersections

---

## Research Question

Can decentralized reinforcement-learning agents coordinate a mixed-autonomy intersection safely and efficiently when the environment is made substantially more realistic than the original straight-traffic, deterministic setting?

The thesis focuses on four major extensions:

- **Free vehicle movement** — left, straight, and right turns instead of through-traffic only
- **Stochastic traffic demand** — Poisson-distributed vehicle arrivals instead of deterministic inflow
- **Richer spatial reasoning** — comparison of MLP and Transformer feature extractors
- **Communication robustness** — evaluation under simulated V2V packet loss

The system is trained and evaluated at **50% autonomous-vehicle penetration** in a four-way unsignalized intersection.

---

## My Contributions

I extended the original research codebase and built a larger experimental pipeline around it.

### 1. More realistic SUMO traffic environment

I modified the intersection scenario to support:

- left, straight, and right-turn maneuvers
- 12 valid route combinations through the four-way junction
- Poisson-distributed vehicle generation
- 50% AV / 50% human-driven mixed traffic
- IDM-based human drivers
- stochastic traffic interactions in SUMO
- route-intention encoding for surrounding vehicles

The reinforcement-learning agents control the **longitudinal acceleration** of AVs while human-driven vehicles remain governed by SUMO traffic models.

### 2. PPO-based multi-agent reinforcement learning

The project progresses from a basic Policy Gradient / REINFORCE implementation toward a more stable **Proximal Policy Optimization (PPO)** pipeline using:

- clipped PPO objective
- Actor-Critic architecture
- Generalized Advantage Estimation (GAE)
- Adam optimization
- entropy regularization
- value-function learning
- mini-batch training
- multi-rollout data collection
- shared policy parameters across autonomous vehicles

I iteratively tuned learning rate, clipping, entropy, rollout count, network size, optimization epochs, and reward coefficients based on observed training behavior.

### 3. MLP vs. Transformer feature extraction

Two policy backbones were evaluated.

#### MLP baseline

A conventional Multi-Layer Perceptron processes flattened traffic observations before feeding shared features into Actor and Critic heads.

#### Embedded Transformer

I implemented a Transformer-based feature extractor to model interactions between the ego AV and surrounding vehicles using:

- learnable vehicle embeddings
- Leaky ReLU activation
- multi-head self-attention
- stacked Transformer encoder layers
- shared latent representation for Actor and Critic
- ego-centric contextual feature extraction

The goal was to allow the policy to learn **which neighboring vehicles matter most** rather than treating every input slot equally.

---

## Observation-Space Design

One of the central parts of the thesis was redesigning how the environment is represented to the RL agents.

### Platoon-based observation

The first approach extends the platoon/chain representation used in the original research. Vehicles are grouped into controllable and uncontrollable traffic chains around the intersection.

Features include:

- vehicle speed
- distance to junction
- turning intention
- distance to ego vehicle

This representation is compact, but it can miss important crossing vehicles in complex turning scenarios.

### K-Nearest-Neighbor observation

To reduce those blind spots, I redesigned the observation space around a **K-Nearest-Neighbor (KNN)** formulation.

For every ego AV, the system:

1. queries nearby vehicles,
2. computes spatial distance using vehicle geometry,
3. filters irrelevant vehicles based on heading and relative motion,
4. sorts candidates by proximity,
5. selects the K most relevant neighbors,
6. normalizes all features,
7. pads sparse observations to a fixed-size tensor.

Each observed vehicle is represented using a 7-dimensional feature vector containing:

- relative distance
- speed
- left / straight / right route intention
- heading angle
- distance to the junction

This representation was designed specifically to work with the Transformer's self-attention mechanism.

---

## Action Space

The original 3-action longitudinal controller was expanded to a 5-action discrete control space:

```text
-4.5 m/s²
-3.5 m/s²
 0.0 m/s²
+1.5 m/s²
+2.6 m/s²
```

This gave the agents more control authority for gap acceptance, braking, and acceleration in dense multi-directional traffic.

---

## Reward Engineering

A major part of the project involved diagnosing and correcting undesirable learned behavior.

The reward design evolved from a simple global throughput reward toward an individualized cooperative structure containing:

- successful-arrival reward
- cooperative reward for human-vehicle throughput
- direct collision penalty
- spatially distributed indirect collision penalty
- adaptive collision-penalty growth
- stagnation penalty
- speed reward when the forward path is clear

During training, I observed two important failure modes:

- **reward hacking** — agents increased throughput by driving too aggressively and accepting collisions
- **parking behavior** — excessively large collision penalties caused agents to stop moving entirely

These experiments showed that safety could not be solved by simply increasing a scalar collision penalty; better state representation and feature extraction were required.

---

## Experimental Progression

The project was developed through a sequence of controlled experiments rather than a single training run.

Key stages included:

1. Policy Gradient + RMSProp
2. Policy Gradient + Adam
3. PPO + MLP
4. stochastic Poisson traffic
5. richer turning-information features
6. expanded 5-action control space
7. adaptive / distributed reward shaping
8. deeper MLP baselines
9. PPO + Embedded Transformer
10. Transformer + platoon observation
11. Transformer + KNN observation
12. robustness testing with V2V packet loss

The repository contains the associated training, evaluation, plotting, and result-generation code.

---

## Selected Results

### KNN-Transformer representation improved value-function understanding

With the KNN + Transformer architecture, the Critic achieved **explained variance as high as ~0.90** during training, compared with much weaker value prediction in earlier MLP experiments.

This was one of the clearest indications that the redesigned observation space and self-attention architecture captured more useful structure from the traffic environment.

### Transformer policies reached high throughput

The high-throughput Transformer configurations exceeded **2,200 vehicles/hour** in some evaluations.

However, these aggressive policies could also produce unacceptable collision rates. This exposed a strong **throughput-vs-safety trade-off** rather than a deployment-ready solution.

### MLP policies were more conservative

Well-tuned MLP policies provided a more balanced operating point, reaching approximately:

- **~1,700 vehicles/hour with zero or near-zero collisions**
- **~1,800 vehicles/hour with only low collision counts**

### V2V packet-loss robustness

The highest-performing KNN-Transformer model was stress-tested under simulated communication loss:

- 5% packet loss
- 10% packet loss
- 20% packet loss
- 50% packet loss

The policy remained operational under moderate packet loss. At **10–20% loss**, throughput degradation was only a few percent in the evaluated scenarios.

At **50% loss**, performance degraded substantially, as expected, because the agents no longer had enough reliable neighboring-vehicle information.

---

## Baselines

The learned policies were compared against traditional traffic-control strategies, including:

- equal-phase traffic signals
- Max-Pressure control
- horizontal-priority rules
- vertical-priority rules

Evaluation focused primarily on:

- hourly throughput
- collision rate
- average traffic speed
- training stability
- generalization across traffic-flow configurations

---

## Technology Stack

- **Python**
- **PyTorch**
- **SUMO**
- **TraCI**
- **Multi-Agent Reinforcement Learning**
- **Proximal Policy Optimization (PPO)**
- **Policy Gradient / REINFORCE**
- **Actor-Critic**
- **Generalized Advantage Estimation**
- **Transformers / Multi-Head Attention**
- **K-Nearest-Neighbor state representation**
- **Ray / distributed rollout experiments**
- **NumPy / Pandas**
- **Jupyter Notebook**
- **Matplotlib**

---

## Repository Structure

```text
.
├── intersection.py           # training / evaluation entry point
├── env.py                    # mixed-autonomy traffic environment
├── exp.py                    # experiment configuration and training logic
├── model_parameters.py       # neural network / model components
├── auto_eval.py              # automated evaluation
├── auto_eval_baseline.py     # baseline evaluation
├── check_model.py            # model inspection utilities
├── launch_train.sh           # training launcher
├── launch_eval.sh            # evaluation launcher
├── results/                  # selected experiment outputs and configs
├── images/                   # evaluation and thesis figures
├── videos/                   # SUMO visualizations
├── training_plot.ipynb       # training/result analysis
├── figures.ipynb             # result visualization
└── MasterThesis_ThanhTungNguyen_00146349.pdf
```

Large PyTorch checkpoint files (`*.pth`) are intentionally excluded from this repository.

---

## Thesis

**Multi-Agent Reinforcement Learning for Behavioral Control in Mixed-Autonomy Unsignalized Intersections**

Master's degree program: **Automated Driving and Vehicle Safety**  
Technische Hochschule Ingolstadt

The full thesis is included in this repository:

`MasterThesis_ThanhTungNguyen_00146349.pdf`

---

## Limitations

This project is simulation-based research and is **not a production or safety-certified autonomous-driving controller**.

Important limitations include:

- human behavior modeled through SUMO / IDM
- limited intersection topology
- discrete longitudinal control
- simplified V2V packet-loss modeling
- no real-vehicle validation
- unresolved safety-throughput trade-offs in the most aggressive Transformer policies
- sim-to-real distribution shift

The results should therefore be interpreted as research into RL architecture, observation design, robustness, and traffic coordination rather than as a deployable intersection-control system.

---

## Future Work

The thesis identifies several promising directions:

- explicit safety layers or constrained RL
- richer temporal representations
- graph-based or spatio-temporal attention
- curriculum learning
- larger road-network topologies
- more realistic human-driver behavior
- communication latency and correlated packet-loss models
- real-world or hardware-in-the-loop validation

---

## Acknowledgment of Original Research

This project builds upon the framework introduced by:

**Zhongxia Yan and Cathy Wu**  
*Reinforcement Learning for Mixed Autonomy Intersections*  
IEEE International Intelligent Transportation Systems Conference (ITSC), 2021

Original repository:  
https://github.com/ZhongxiaYan/mixed_autonomy_intersections

My thesis extends that framework with a substantially modified traffic environment, training pipeline, observation representations, reward design, neural architectures, evaluation methodology, and robustness experiments.

---

## Author

**Thanh Tung Nguyen**

Focus areas:

- Reinforcement Learning
- Autonomous Driving
- Robotics
- Machine Learning
- Intelligent Transportation Systems
- Python / PyTorch

