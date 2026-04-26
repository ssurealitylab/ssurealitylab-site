#!/bin/bash

# Tunnel Health Monitor Script
# - Checks if tunnel is actually working
# - Respects rate limit cooldown
# - Prevents duplicate restart attempts

WORK_DIR="/home/i0179/Realitylab-site"
LOG_FILE="$WORK_DIR/ai_server/tunnel_monitor.log"
CHATBOT_FILE="$WORK_DIR/_includes/chatbot.html"
LOCK_FILE="$WORK_DIR/ai_server/restart_tunnel.lock"
RATE_LIMIT_FILE="$WORK_DIR/ai_server/rate_limit_until.txt"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Check if restart is already running
if [ -f "$LOCK_FILE" ]; then
    LOCK_PID=$(cat "$LOCK_FILE" 2>/dev/null)
    if ps -p "$LOCK_PID" > /dev/null 2>&1; then
        log "SKIP: restart_tunnel.sh already running (PID: $LOCK_PID)"
        exit 0
    fi
fi

# Check rate limit cooldown
if [ -f "$RATE_LIMIT_FILE" ]; then
    RATE_LIMIT_UNTIL=$(cat "$RATE_LIMIT_FILE" 2>/dev/null)
    CURRENT_TIME=$(date +%s)
    if [ "$CURRENT_TIME" -lt "$RATE_LIMIT_UNTIL" ]; then
        WAIT_MINS=$(( (RATE_LIMIT_UNTIL - CURRENT_TIME) / 60 ))
        log "SKIP: Rate limit cooldown active (${WAIT_MINS}min remaining)"
        exit 0
    fi
fi

# Get current tunnel URL from chatbot.html
CURRENT_URL=$(grep -oE "DIRECT_AI_SERVER_URL = 'https://[a-z0-9-]+\.trycloudflare\.com'" "$CHATBOT_FILE" | grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com')

if [ -z "$CURRENT_URL" ]; then
    log "ERROR: Could not find tunnel URL in chatbot.html"
    exit 1
fi

# Check if cloudflared process is running
if ! pgrep -f "cloudflared.*tunnel" > /dev/null; then
    log "ALERT: cloudflared process not running! Starting restart_tunnel.sh..."
    nohup $WORK_DIR/ai_server/restart_tunnel.sh >> "$LOG_FILE" 2>&1 &
    exit 0
fi

# Check if tunnel URL is actually responding
HEALTH_RESPONSE=$(curl -s --connect-timeout 15 --max-time 30 "$CURRENT_URL/health" 2>/dev/null)

if echo "$HEALTH_RESPONSE" | grep -q "healthy"; then
    # Tunnel is working fine
    log "OK: Tunnel healthy - $CURRENT_URL"
    exit 0
fi

# Tunnel URL not responding - could be expired or Cloudflare issue
log "ALERT: Tunnel not responding! URL: $CURRENT_URL"
log "Response: $HEALTH_RESPONSE"

# Kill existing tunnel and restart
log "Killing existing tunnel and restarting..."
pkill -f "cloudflared.*url http://localhost:4005" 2>/dev/null
sleep 3

# Start restart script (which has retry logic)
nohup $WORK_DIR/ai_server/restart_tunnel.sh >> "$LOG_FILE" 2>&1 &

log "restart_tunnel.sh started in background"
