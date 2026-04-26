#!/bin/bash

# Smart GPU Monitor for llama-server
# - NEVER uses GPUs that other users are using
# - Only starts on GPUs with NO other users' processes AND enough free memory
# - Checks if llama-server/chatbot/tunnel are running

WORK_DIR="/home/i0179/Realitylab-site"
LOG_FILE="$WORK_DIR/ai_server/gpu_monitor.log"
LLAMA_DIR="/home/i0179/llama.cpp/build/bin"
MODEL_PATH="/data/models/gpt-oss-120b/openai.gpt-oss-120b.MXFP4_MOE-00001-of-00005.gguf"
PYTHON="/usr/bin/python3"
CHATBOT_SERVER="$WORK_DIR/ai_server/ai_chatbot_server.py"
MY_USER="i0179"

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

# === 2. If llama-server is not running, find TRULY free GPUs ===
if ! pgrep -f "llama-server.*8081" > /dev/null; then
    log "llama-server not running. Checking GPU availability..."

    # Step A: Find which GPUs have OTHER users' processes (not ours)
    OCCUPIED_GPUS=""
    while IFS=',' read -r pid gpu_uuid used_mem pname; do
        pid=$(echo "$pid" | tr -d ' ')
        gpu_uuid=$(echo "$gpu_uuid" | tr -d ' ')

        # Check if this process belongs to another user
        PROC_USER=$(ps -o user= -p "$pid" 2>/dev/null | tr -d ' ')
        if [ -n "$PROC_USER" ] && [ "$PROC_USER" != "$MY_USER" ]; then
            # Find GPU index from UUID
            GPU_IDX=$(nvidia-smi --query-gpu=index,gpu_uuid --format=csv,noheader | grep "$gpu_uuid" | cut -d',' -f1 | tr -d ' ')
            OCCUPIED_GPUS="$OCCUPIED_GPUS $GPU_IDX"
            log "  GPU $GPU_IDX: occupied by user '$PROC_USER' (pid $pid, $(echo $pname | tr -d ' '))"
        fi
    done < <(nvidia-smi --query-compute-apps=pid,gpu_uuid,used_memory,name --format=csv,noheader 2>/dev/null)

    # Step B: Find GPUs with enough free memory AND not occupied by others
    FREE_GPUS=""
    GPU_COUNT=0

    while IFS=', ' read -r idx free_mem; do
        idx=$(echo "$idx" | tr -d ' ')
        free_mem=$(echo "$free_mem" | tr -d ' MiB')

        # Check if this GPU is occupied by another user
        if echo "$OCCUPIED_GPUS" | grep -qw "$idx"; then
            log "  GPU $idx: ${free_mem}MiB free but OTHER USER is using it - SKIP"
            continue
        fi

        if [ "$free_mem" -ge "$MIN_FREE_MEM" ]; then
            if [ -z "$FREE_GPUS" ]; then
                FREE_GPUS="$idx"
            else
                FREE_GPUS="$FREE_GPUS,$idx"
            fi
            GPU_COUNT=$((GPU_COUNT + 1))
            log "  GPU $idx: ${free_mem}MiB free, no other users (OK)"
        else
            log "  GPU $idx: ${free_mem}MiB free (not enough memory)"
        fi
    done < <(nvidia-smi --query-gpu=index,memory.free --format=csv,noheader,nounits)

    if [ "$GPU_COUNT" -ge "$NUM_GPUS" ]; then
        SELECTED_GPUS=$(echo "$FREE_GPUS" | cut -d',' -f1-${NUM_GPUS})
        log "Starting llama-server on GPUs: $SELECTED_GPUS (verified no other users)"

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
        log "Not enough exclusive GPUs (need $NUM_GPUS, found $GPU_COUNT). Other users are using GPUs. Skipping."
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

# === 4. Check chatbot tunnel (port 4005) ===
if ! pgrep -f "cloudflared.*url http://localhost:4005" > /dev/null; then
    log "Chatbot tunnel not running. Starting restart_tunnel.sh..."
    cd "$WORK_DIR"
    nohup "$WORK_DIR/ai_server/restart_tunnel.sh" >> "$LOG_FILE" 2>&1 &
fi

# === 5. Check admin CMS server (port 4010) ===
if ! pgrep -f "admin_server.py" > /dev/null; then
    log "admin_server (CMS) not running. Starting..."
    cd "$WORK_DIR/admin_cms" 2>/dev/null || cd "/data2/i0179/Realitylab-site/admin_cms"
    PYTHONPATH=/home/i0179/lib/python3.10/site-packages \
        nohup "$PYTHON" admin_server.py --port 4010 >> /tmp/admin_cms.log 2>&1 &
    log "admin_server starting (PID: $!)"
    sleep 5
fi

# === 6. Check admin tunnel (port 4010) ===
if ! pgrep -f "cloudflared.*url http://localhost:4010" > /dev/null; then
    log "Admin tunnel not running. Starting restart_admin_tunnel.sh..."
    nohup "$WORK_DIR/ai_server/restart_admin_tunnel.sh" >> "$LOG_FILE" 2>&1 &
fi
