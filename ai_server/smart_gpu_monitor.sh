#!/bin/bash

# Smart GPU Monitor for llama-server
# - Checks if llama-server is running
# - If not, finds 2 free GPUs and starts it
# - Also restarts ai_chatbot_server if needed
# - Designed to run twice daily + as 30-min fallback monitor

WORK_DIR="/home/i0179/Realitylab-site"
LOG_FILE="$WORK_DIR/ai_server/gpu_monitor.log"
LLAMA_DIR="/home/i0179/llama.cpp/build/bin"
MODEL_PATH="/data/models/gpt-oss-120b/openai.gpt-oss-120b.MXFP4_MOE-00001-of-00005.gguf"
PYTHON="/usr/bin/python3"
CHATBOT_SERVER="$WORK_DIR/ai_server/ai_chatbot_server.py"

# Minimum free GPU memory required per GPU (in MiB)
MIN_FREE_MEM=10000
# Number of GPUs needed
NUM_GPUS=2

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Skip during rest time (04:00-08:00 KST)
HOUR=$(TZ=Asia/Seoul date +%H)
if [ "$HOUR" -ge 4 ] && [ "$HOUR" -lt 8 ]; then
    exit 0
fi

# === 1. Check llama-server ===
if pgrep -f "llama-server.*8081" > /dev/null; then
    # Verify it's actually responding
    if curl -s --max-time 5 http://localhost:8081/health | grep -q "ok"; then
        log "OK: llama-server healthy"
    else
        log "WARN: llama-server process exists but not responding, killing..."
        pkill -f "llama-server.*8081"
        sleep 3
    fi
fi

# === 2. If llama-server is not running, find free GPUs ===
if ! pgrep -f "llama-server.*8081" > /dev/null; then
    log "llama-server not running. Checking GPU availability..."

    # Get free memory for each GPU
    FREE_GPUS=""
    GPU_COUNT=0

    while IFS=', ' read -r idx free_mem; do
        # Clean whitespace
        idx=$(echo "$idx" | tr -d ' ')
        free_mem=$(echo "$free_mem" | tr -d ' MiB')

        if [ "$free_mem" -ge "$MIN_FREE_MEM" ]; then
            if [ -z "$FREE_GPUS" ]; then
                FREE_GPUS="$idx"
            else
                FREE_GPUS="$FREE_GPUS,$idx"
            fi
            GPU_COUNT=$((GPU_COUNT + 1))
            log "  GPU $idx: ${free_mem} MiB free (OK)"
        else
            log "  GPU $idx: ${free_mem} MiB free (not enough)"
        fi
    done < <(nvidia-smi --query-gpu=index,memory.free --format=csv,noheader,nounits)

    if [ "$GPU_COUNT" -ge "$NUM_GPUS" ]; then
        # Pick first NUM_GPUS GPUs
        SELECTED_GPUS=$(echo "$FREE_GPUS" | cut -d',' -f1-${NUM_GPUS})
        log "Starting llama-server on GPUs: $SELECTED_GPUS"

        cd "$LLAMA_DIR"
        CUDA_VISIBLE_DEVICES=$SELECTED_GPUS nohup ./llama-server \
            -m "$MODEL_PATH" \
            --port 8081 \
            -ngl 18 \
            --host 0.0.0.0 \
            -c 4096 \
            > /tmp/llama-server.log 2>&1 &

        LLAMA_PID=$!
        log "llama-server starting (PID: $LLAMA_PID, GPUs: $SELECTED_GPUS)"

        # Wait for ready (max 2 minutes)
        for i in {1..24}; do
            sleep 5
            if curl -s --max-time 5 http://localhost:8081/health | grep -q "ok"; then
                log "llama-server is ready!"
                break
            fi
        done

        if ! curl -s --max-time 5 http://localhost:8081/health | grep -q "ok"; then
            log "WARN: llama-server may still be loading"
        fi
    else
        log "Not enough free GPUs (need $NUM_GPUS, found $GPU_COUNT with >=${MIN_FREE_MEM}MiB free). Skipping."
    fi
fi

# === 3. Check ai_chatbot_server ===
if ! pgrep -f "ai_chatbot_server.py" > /dev/null; then
    log "ai_chatbot_server not running. Starting..."
    cd "$WORK_DIR/ai_server"
    PYTHONPATH=/home/i0179/lib/python3.10/site-packages CUDA_VISIBLE_DEVICES="" \
        nohup "$PYTHON" "$CHATBOT_SERVER" --port 4005 >> /tmp/chatbot_server.log 2>&1 &
    log "ai_chatbot_server starting (PID: $!)"

    sleep 8
    if curl -s --max-time 3 http://localhost:4005/health | grep -q "healthy"; then
        log "ai_chatbot_server is ready!"
    else
        log "WARN: ai_chatbot_server may not have started"
    fi
else
    log "OK: ai_chatbot_server running"
fi

# === 4. Check tunnel ===
if ! pgrep -f "cloudflared.*tunnel" > /dev/null; then
    log "cloudflared not running. Starting restart_tunnel.sh..."
    cd "$WORK_DIR"
    nohup "$WORK_DIR/ai_server/restart_tunnel.sh" >> "$LOG_FILE" 2>&1 &
fi
