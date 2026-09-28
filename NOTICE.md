# Attribution and Licensing Notice

This repository contains an extended implementation derived from the research code associated with:

**Zhongxia Yan and Cathy Wu**  
*Reinforcement Learning for Mixed Autonomy Intersections*  
IEEE International Intelligent Transportation Systems Conference (ITSC), 2021

Original repository:  
https://github.com/ZhongxiaYan/mixed_autonomy_intersections

The upstream GitHub repository did not include an explicit software license when this portfolio repository was prepared. On 28 September 2026, Zhongxia Yan confirmed by email that the MIT License was acceptable and that Thanh Tung Nguyen could publish this extended implementation.

The MIT License in this repository therefore applies to the published implementation, while preserving attribution to the upstream research and code.

Substantial extensions and modifications by Thanh Tung Nguyen include, among other work:

- left / straight / right-turn traffic handling
- stochastic Poisson traffic arrivals
- PPO Actor-Critic training and tuning
- expanded longitudinal action space
- redesigned cooperative and safety-aware rewards
- Transformer-based feature extraction
- K-nearest-neighbor traffic observations
- automated evaluation across traffic-flow conditions
- V2V packet-loss robustness experiments

See [README.md](README.md) for technical details and [LICENSE](LICENSE) for the license terms.
