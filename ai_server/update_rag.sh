#!/bin/bash

# Reality Lab RAG Auto-Update Script
# Builds knowledge base from local YAML/MD files and rebuilds hierarchical RAG index

SITE_ROOT="/home/i0179/Realitylab-site"
SCRIPT_DIR="$SITE_ROOT/ai_server"
PYTHON="/usr/bin/python3"
export PYTHONPATH="/home/i0179/lib/python3.10/site-packages"
export CUDA_VISIBLE_DEVICES=""

echo ""
echo "========================================"
echo "[$(date)] Starting RAG Update..."
echo "========================================"

# Step 1: Build knowledge base from local data files
echo "[$(date)] Step 1/3: Building knowledge base from local files..."
$PYTHON "$SCRIPT_DIR/build_knowledge_base.py"
if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: Knowledge base build failed!"
    exit 1
fi
echo "[$(date)] Knowledge base built successfully"

# Step 2: Build hierarchical RAG index
echo "[$(date)] Step 2/3: Building hierarchical RAG index..."
$PYTHON "$SCRIPT_DIR/build_hierarchical_rag.py"
if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: Hierarchical RAG build failed!"
    exit 1
fi
echo "[$(date)] Hierarchical RAG index built successfully"

# Step 3: Restart chatbot server only (not llama-server)
echo "[$(date)] Step 3/3: Restarting chatbot server..."
pkill -f "ai_chatbot_server.py"
sleep 3

cd "$SCRIPT_DIR"
PYTHONPATH=/home/i0179/lib/python3.10/site-packages nohup $PYTHON ai_chatbot_server.py --port 4005 >> /tmp/chatbot_server.log 2>&1 &
CHATBOT_PID=$!
sleep 5

if ps -p $CHATBOT_PID > /dev/null 2>&1; then
    echo "[$(date)] Chatbot server restarted (PID: $CHATBOT_PID)"
else
    echo "[$(date)] WARNING: Chatbot server may not have started. Monitor will auto-restart it."
fi

# Summary
KB_FILE="$SITE_ROOT/ai_server/knowledge_base.json"
if [ -f "$KB_FILE" ]; then
    DOCS_COUNT=$($PYTHON -c "import json; f=open('$KB_FILE'); data=json.load(f); print(len(data)); f.close()")
    echo ""
    echo "Summary:"
    echo "  Knowledge base documents: $DOCS_COUNT"
fi

echo ""
echo "========================================"
echo "[$(date)] RAG Update Completed!"
echo "========================================"
