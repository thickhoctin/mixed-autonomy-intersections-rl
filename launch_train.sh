#!/usr/bin/env bash
set -euo pipefail

# Final KNN-Transformer experiment.
EXP_DIR="results/fourway_1x1_penetration0.5_turn_adam_ppo_transformer_13.02"

if [[ $# -gt 1 ]]; then
    echo "Usage: $0 [LOAD_STEP]"
    echo "  no argument : start from scratch (load_step=0)"
    echo "  LOAD_STEP   : resume from that local checkpoint, e.g. $0 300"
    exit 1
fi

if [[ $# -eq 1 ]]; then
    LOAD_STEP="$1"

    if ! [[ "$LOAD_STEP" =~ ^[0-9]+$ ]]; then
        echo "Error: LOAD_STEP must be a non-negative integer."
        exit 1
    fi

    echo "Resuming training from checkpoint ${LOAD_STEP}"
    python3 intersection.py "$EXP_DIR" "load_step=${LOAD_STEP}"
else
    echo "Starting training from scratch"
    python3 intersection.py "$EXP_DIR" "load_step=0"
fi