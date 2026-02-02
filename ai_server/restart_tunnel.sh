#!/bin/bash

# Cloudflare Tunnel Auto-Restart Script with Retry Logic
# Handles Cloudflare API outages with automatic retries

WORK_DIR="/home/i0179/Realitylab-site"
LOG_FILE="$WORK_DIR/ai_server/tunnel_cron.log"
CHATBOT_FILE="$WORK_DIR/_includes/chatbot.html"
BUGREPORT_FILE="$WORK_DIR/_includes/bug-report.html"
PID_FILE="$WORK_DIR/ai_server/cloudflared.pid"
TEMP_LOG="$WORK_DIR/ai_server/tunnel_temp.log"
CLOUDFLARED="$WORK_DIR/ai_server/cloudflared.new"

# Port for ai_chatbot_server.py
AI_SERVER_PORT=4005

# Retry settings
MAX_RETRIES=60        # Max retry attempts (60 * 2min = 2 hours max)
RETRY_DELAY=120       # 2 minutes between retries

cd "$WORK_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "========================================"
log "Starting Cloudflare Tunnel restart with retry logic..."

# Kill existing cloudflared processes
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p $OLD_PID > /dev/null 2>&1; then
        log "Killing old cloudflared process (PID: $OLD_PID)"
        kill $OLD_PID 2>/dev/null
        sleep 2
    fi
fi
pkill -f "cloudflared.*tunnel" 2>/dev/null
sleep 2

# Retry loop
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    log "Attempt $RETRY_COUNT/$MAX_RETRIES - Creating tunnel..."

    rm -f "$TEMP_LOG"

    # Start tunnel
    nohup $CLOUDFLARED tunnel --url http://localhost:$AI_SERVER_PORT > "$TEMP_LOG" 2>&1 &
    NEW_PID=$!
    echo $NEW_PID > "$PID_FILE"

    # Wait for URL (max 45 seconds)
    MAX_WAIT=45
    WAIT_COUNT=0
    NEW_URL=""

    while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
        sleep 1
        WAIT_COUNT=$((WAIT_COUNT + 1))

        if [ -f "$TEMP_LOG" ]; then
            # Check for successful URL
            NEW_URL=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' "$TEMP_LOG" | head -1)
            if [ -n "$NEW_URL" ]; then
                break
            fi

            # Check for Cloudflare API error (service outage)
            if grep -q "Error unmarshaling QuickTunnel" "$TEMP_LOG" 2>/dev/null; then
                log "Cloudflare API error detected (service outage)"
                pkill -f "cloudflared" 2>/dev/null
                break
            fi

            if grep -q "failed to unmarshal quick Tunnel" "$TEMP_LOG" 2>/dev/null; then
                log "Cloudflare API error detected (service outage)"
                pkill -f "cloudflared" 2>/dev/null
                break
            fi
        fi
    done

    # If we got a URL, verify and update
    if [ -n "$NEW_URL" ]; then
        log "Tunnel URL obtained: $NEW_URL"

        # Wait for tunnel to stabilize
        sleep 5

        # Verify tunnel works
        HEALTH_CHECK=$(curl -s --connect-timeout 10 "$NEW_URL/health" 2>/dev/null)
        if echo "$HEALTH_CHECK" | grep -q "healthy"; then
            log "Tunnel health check PASSED!"

            # Get old URL
            OLD_URL=$(grep -oE "DIRECT_AI_SERVER_URL = 'https://[a-z0-9-]+\.trycloudflare\.com'" "$CHATBOT_FILE" | grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com')

            if [ "$OLD_URL" == "$NEW_URL" ]; then
                log "URL unchanged, no update needed"
            else
                log "Updating URLs: $OLD_URL -> $NEW_URL"

                # Update chatbot.html
                sed -i "s|DIRECT_AI_SERVER_URL = '$OLD_URL'|DIRECT_AI_SERVER_URL = '$NEW_URL'|g" "$CHATBOT_FILE"

                # Update bug-report.html
                if [ -f "$BUGREPORT_FILE" ]; then
                    sed -i "s|DIRECT_AI_SERVER_URL = '$OLD_URL'|DIRECT_AI_SERVER_URL = '$NEW_URL'|g" "$BUGREPORT_FILE"
                fi

                # Git commit and push
                git add -A
                git commit -m "Auto-update Cloudflare Tunnel URL" >> "$LOG_FILE" 2>&1
                git push origin main >> "$LOG_FILE" 2>&1

                if [ $? -eq 0 ]; then
                    log "Successfully pushed to GitHub!"
                else
                    log "WARNING: Failed to push to GitHub"
                fi
            fi

            log "Tunnel restart completed successfully!"
            log "========================================"
            exit 0
        else
            log "Health check FAILED, will retry..."
            pkill -f "cloudflared" 2>/dev/null
        fi
    fi

    # Wait before retry
    if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
        log "Waiting ${RETRY_DELAY}s before next attempt..."
        sleep $RETRY_DELAY
    fi
done

log "ERROR: Failed to create tunnel after $MAX_RETRIES attempts!"
log "========================================"
exit 1
