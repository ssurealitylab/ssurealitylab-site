#!/bin/bash
# Start llama-server, chatbot server, and tunnel after rest time (8 AM KST)

LOG_FILE="/home/i0179/Realitylab-site/ai_server/rest_time.log"
LLAMA_DIR="/home/i0179/llama.cpp/build/bin"
MODEL_PATH="/data/models/gpt-oss-120b/openai.gpt-oss-120b.MXFP4_MOE-00001-of-00005.gguf"
WORK_DIR="/home/i0179/Realitylab-site"
CHATBOT_SERVER="$WORK_DIR/ai_server/ai_chatbot_server.py"

echo "$(date): === REST TIME END ===" >> $LOG_FILE

# === 1. Start llama-server ===
if pgrep -f "llama-server.*8081" > /dev/null; then
    echo "$(date): llama-server already running, skipping start" >> $LOG_FILE
else
    echo "$(date): Starting llama-server (GPT-OSS 120B)..." >> $LOG_FILE
    cd $LLAMA_DIR
    CUDA_VISIBLE_DEVICES=0,2 nohup ./llama-server \
        -m $MODEL_PATH \
        --port 8081 \
        -ngl 18 \
        --host 0.0.0.0 \
        -c 4096 \
        > /tmp/llama-server.log 2>&1 &

    echo "$(date): llama-server starting (PID: $!)" >> $LOG_FILE

    # Wait for server to be ready (max 2 minutes)
    for i in {1..24}; do
        sleep 5
        if curl -s --max-time 5 http://localhost:8081/health | grep -q "ok"; then
            echo "$(date): llama-server is ready!" >> $LOG_FILE
            break
        fi
        echo "$(date): Waiting for model to load... ($i/24)" >> $LOG_FILE
    done

    if curl -s --max-time 5 http://localhost:8081/health | grep -q "ok"; then
        echo "$(date): llama-server fully operational" >> $LOG_FILE
    else
        echo "$(date): Warning - llama-server may still be loading" >> $LOG_FILE
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
