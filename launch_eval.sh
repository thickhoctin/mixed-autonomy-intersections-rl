#!/usr/bin/env bash
set -euo pipefail

# Final KNN-Transformer thesis experiment.
EXP_DIR="results/fourway_1x1_penetration0.5_turn_adam_ppo_transformer_13.02"

# Optional positional arguments:
#   $1 = checkpoint (default: 260)
#   $2 = horizontal flow in vehicles/hour (default: 700)
#   $3 = vertical flow in vehicles/hour (default: 700)
CKPT="${1:-260}"
FR_H="${2:-700}"
FR_V="${3:-700}"

N_ROWS=1
N_COLS=1
N_STEPS=10
N_ROLLOUTS_PER_STEP=1
SKIP_STAT_STEPS=500
RENDER="${RENDER:-True}"

RESULT_SAVE_PATH="${EXP_DIR}/eval_results/e${CKPT}_${N_ROWS}x${N_COLS}_skip${SKIP_STAT_STEPS}_flow${FR_H}x${FR_V}.csv"
VEHICLE_INFO_SAVE_PATH="${EXP_DIR}/vehicle_info/e${CKPT}_${N_ROWS}x${N_COLS}_skip${SKIP_STAT_STEPS}_flow${FR_H}x${FR_V}_vehicle_info.csv"

mkdir -p "${EXP_DIR}/eval_results" "${EXP_DIR}/vehicle_info"

echo "Evaluating checkpoint ${CKPT} at flow ${FR_H}x${FR_V} veh/h"

python3 intersection.py "$EXP_DIR" \
    "e=${CKPT}" \
    "n_rows=${N_ROWS}" \
    "n_cols=${N_COLS}" \
    "n_steps=${N_STEPS}" \
    "n_rollouts_per_step=${N_ROLLOUTS_PER_STEP}" \
    "skip_stat_steps=${SKIP_STAT_STEPS}" \
    "flow_rate_h=${FR_H}" \
    "flow_rate_v=${FR_V}" \
    "result_save=${RESULT_SAVE_PATH}" \
    "vehicle_info_save=${VEHICLE_INFO_SAVE_PATH}" \
    "use_ray=False" \
    "render=${RENDER}"
