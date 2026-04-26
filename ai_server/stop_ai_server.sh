#!/bin/bash
# Stop llama-server, chatbot server, and tunnel for rest time (4 AM - 8 AM KST)
# This frees up GPU memory during rest hours

LOG_FILE="/home/i0179/Realitylab-site/ai_server/rest_time.log"

echo "$(date): === REST TIME START ===" >> $LOG_FILE

# Stop ai_chatbot_server.py
echo "$(date): Stopping ai_chatbot_server..." >> $LOG_FILE
pkill -f "ai_chatbot_server.py"
sleep 1

# Stop llama-server
echo "$(date): Stopping llama-server to free GPU memory..." >> $LOG_FILE
pkill -f "llama-server.*8081"
sleep 2

# Force kill if still running
if pgrep -f "llama-server.*8081" > /dev/null; then
    echo "$(date): Force killing llama-server..." >> $LOG_FILE
    pkill -9 -f "llama-server.*8081"
fi

echo "$(date): llama-server stopped, GPU 0,2 freed" >> $LOG_FILE

# Stop chatbot cloudflared tunnel only (port 4005), keep admin tunnel running
echo "$(date): Stopping chatbot cloudflared tunnel..." >> $LOG_FILE
pkill -f "cloudflared.*url http://localhost:4005"
sleep 1

echo "$(date): All services stopped" >> $LOG_FILE

# Verify GPU is freed
echo "$(date): GPU status after stop:" >> $LOG_FILE
nvidia-smi --query-gpu=index,memory.used --format=csv >> $LOG_FILE 2>&1

echo "$(date): Rest time active until 8 AM KST" >> $LOG_FILE
