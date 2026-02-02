#!/bin/bash
# llama-server control script for GPT-OSS 120B

ACTION=$1
LLAMA_DIR="/home/i0179/llama.cpp/build/bin"
MODEL_PATH="/data/models/gpt-oss-120b/openai.gpt-oss-120b.MXFP4_MOE-00001-of-00005.gguf"
LOG_FILE="/tmp/llama-server.log"
PORT=8081

case $ACTION in
    start)
        # Check if already running
        if pgrep -f "llama-server.*$PORT" > /dev/null; then
            echo "$(date): llama-server already running"
            exit 0
        fi

        echo "$(date): Starting llama-server (GPT-OSS 120B)..."
        cd $LLAMA_DIR
        CUDA_VISIBLE_DEVICES=0,2 nohup ./llama-server \
            -m $MODEL_PATH \
            --port $PORT \
            -ngl 18 \
            --host 0.0.0.0 \
            -c 4096 \
            > $LOG_FILE 2>&1 &

        echo "$(date): llama-server started (PID: $!)"

        # Wait for server to be ready (max 2 minutes)
        for i in {1..24}; do
            sleep 5
            if curl -s --max-time 5 http://localhost:$PORT/health | grep -q "ok"; then
                echo "$(date): llama-server is ready!"
                exit 0
            fi
            echo "$(date): Waiting for model to load... ($i/24)"
        done
        echo "$(date): Warning - server may still be loading"
        ;;

    stop)
        echo "$(date): Stopping llama-server..."
        pkill -f "llama-server.*$PORT"
        sleep 2

        # Force kill if still running
        if pgrep -f "llama-server.*$PORT" > /dev/null; then
            echo "$(date): Force killing llama-server..."
            pkill -9 -f "llama-server.*$PORT"
        fi

        echo "$(date): llama-server stopped, GPU memory freed"
        ;;

    status)
        if pgrep -f "llama-server.*$PORT" > /dev/null; then
            echo "llama-server is running"
            curl -s http://localhost:$PORT/health
        else
            echo "llama-server is not running"
        fi
        ;;

    restart)
        $0 stop
        sleep 3
        $0 start
        ;;

    *)
        echo "Usage: $0 {start|stop|status|restart}"
        exit 1
        ;;
esac
