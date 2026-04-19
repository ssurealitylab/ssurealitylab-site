#!/bin/bash
# Start llama-server, chatbot server, and tunnel after rest time (8 AM KST)

LOG_FILE="/home/i0179/Realitylab-site/ai_server/rest_time.log"
LLAMA_DIR="/home/i0179/llama.cpp/build/bin"
MODEL_PATH="/data/models/gpt-oss-120b/openai.gpt-oss-120b.MXFP4_MOE-00001-of-00005.gguf"
WORK_DIR="/home/i0179/Realitylab-site"
CHATBOT_SERVER="$WORK_DIR/ai_server/ai_chatbot_server.py"

echo "$(date): === REST TIME END ===" >> $LOG_FILE

# === 1. Start llama-server (smart GPU selection) ===
if pgrep -f "llama-server.*8081" > /dev/null; then
    echo "$(date): llama-server already running, skipping start" >> $LOG_FILE
else
    echo "$(date): Starting llama-server (GPT-OSS 120B) - finding free GPUs..." >> $LOG_FILE

    # Find 2 GPUs with enough free memory AND no other users' processes
    MIN_FREE_MEM=10000
    NUM_GPUS=2
    MY_USER="i0179"
    FREE_GPUS=""
    GPU_COUNT=0

    # First: find GPUs occupied by other users
    OCCUPIED_GPUS=""
    while IFS=',' read -r pid gpu_uuid used_mem pname; do
        pid=$(echo "$pid" | tr -d ' ')
        gpu_uuid=$(echo "$gpu_uuid" | tr -d ' ')
        PROC_USER=$(ps -o user= -p "$pid" 2>/dev/null | tr -d ' ')
        if [ -n "$PROC_USER" ] && [ "$PROC_USER" != "$MY_USER" ]; then
            GPU_IDX=$(nvidia-smi --query-gpu=index,gpu_uuid --format=csv,noheader | grep "$gpu_uuid" | cut -d',' -f1 | tr -d ' ')
            OCCUPIED_GPUS="$OCCUPIED_GPUS $GPU_IDX"
            echo "$(date): GPU $GPU_IDX: occupied by user '$PROC_USER' - SKIP" >> $LOG_FILE
        fi
    done < <(nvidia-smi --query-compute-apps=pid,gpu_uuid,used_memory,name --format=csv,noheader 2>/dev/null)

    # Then: find GPUs with enough free memory and not occupied
    while IFS=', ' read -r idx free_mem; do
        idx=$(echo "$idx" | tr -d ' ')
        free_mem=$(echo "$free_mem" | tr -d ' MiB')
        if echo "$OCCUPIED_GPUS" | grep -qw "$idx"; then
            echo "$(date): GPU $idx: ${free_mem}MiB free but other user present - SKIP" >> $LOG_FILE
            continue
        fi
        if [ "$free_mem" -ge "$MIN_FREE_MEM" ]; then
            if [ -z "$FREE_GPUS" ]; then
                FREE_GPUS="$idx"
            else
                FREE_GPUS="$FREE_GPUS,$idx"
            fi
            GPU_COUNT=$((GPU_COUNT + 1))
            echo "$(date): GPU $idx: ${free_mem}MiB free, no other users (OK)" >> $LOG_FILE
        else
            echo "$(date): GPU $idx: ${free_mem}MiB free (not enough)" >> $LOG_FILE
        fi
    done < <(nvidia-smi --query-gpu=index,memory.free --format=csv,noheader,nounits)

    if [ "$GPU_COUNT" -ge "$NUM_GPUS" ]; then
        SELECTED_GPUS=$(echo "$FREE_GPUS" | cut -d',' -f1-${NUM_GPUS})
        echo "$(date): Selected GPUs: $SELECTED_GPUS" >> $LOG_FILE

        cd $LLAMA_DIR
        CUDA_VISIBLE_DEVICES=$SELECTED_GPUS nohup ./llama-server \
            -m $MODEL_PATH \
            --port 8081 \
            -ngl 18 \
            --host 0.0.0.0 \
            -c 4096 \
            > /tmp/llama-server.log 2>&1 &

        echo "$(date): llama-server starting (PID: $!, GPUs: $SELECTED_GPUS)" >> $LOG_FILE

        for i in {1..24}; do
            sleep 5
            if curl -s --max-time 5 http://localhost:8081/health | grep -q "ok"; then
                echo "$(date): llama-server is ready!" >> $LOG_FILE
                break
            fi
            echo "$(date): Waiting for model to load... ($i/24)" >> $LOG_FILE
        done

        if ! curl -s --max-time 5 http://localhost:8081/health | grep -q "ok"; then
            echo "$(date): Warning - llama-server may still be loading" >> $LOG_FILE
        fi
    else
        echo "$(date): Not enough free GPUs (need $NUM_GPUS, found $GPU_COUNT). Skipping llama-server." >> $LOG_FILE
        echo "$(date): smart_gpu_monitor will retry later when GPUs become available." >> $LOG_FILE
    fi
fi

# Log GPU status
echo "$(date): GPU status after start:" >> $LOG_FILE
nvidia-smi --query-gpu=index,memory.used --format=csv >> $LOG_FILE 2>&1

# === 2. Start ai_chatbot_server.py ===
if pgrep -f "ai_chatbot_server.py" > /dev/null; then
    echo "$(date): ai_chatbot_server already running, skipping" >> $LOG_FILE
else
    echo "$(date): Starting ai_chatbot_server.py (port 4005)..." >> $LOG_FILE
    cd $WORK_DIR/ai_server
    PYTHONPATH=/home/i0179/lib/python3.10/site-packages nohup python3 $CHATBOT_SERVER --port 4005 > /tmp/chatbot_server.log 2>&1 &
    echo "$(date): ai_chatbot_server starting (PID: $!)" >> $LOG_FILE

    # Wait for chatbot server
    for i in {1..10}; do
        sleep 2
        if curl -s --max-time 3 http://localhost:4005/health | grep -q "healthy"; then
            echo "$(date): ai_chatbot_server is ready!" >> $LOG_FILE
            break
        fi
        echo "$(date): Waiting for chatbot server... ($i/10)" >> $LOG_FILE
    done
fi

# === 3. Start new tunnel and update URL ===
echo "$(date): Starting new cloudflared tunnel..." >> $LOG_FILE
cd $WORK_DIR
$WORK_DIR/ai_server/restart_tunnel.sh >> $LOG_FILE 2>&1

echo "$(date): All services started" >> $LOG_FILE
