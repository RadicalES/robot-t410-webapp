#!/bin/bash
#
# batch-deploy.sh - Deploy Robot-T430 webapp to multiple devices
#
# Usage:
#   ./batch-deploy.sh <devices-file> [parallel-count]
#
# The devices file should contain one IP per line.
# Lines starting with # are ignored. Empty lines are skipped.
#
# Example devices.txt:
#   10.224.40.136
#   10.224.41.50
#   192.168.1.100
#
# Environment variables:
#   DEVICE_USER  - SSH user (default: robot)
#   DEVICE_PASS  - SSH password (default: t430)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEVICES_FILE="${1:-}"
PARALLEL="${2:-5}"
DEVICE_USER="${DEVICE_USER:-robot}"
DEVICE_PASS="${DEVICE_PASS:-t430}"
LOG_DIR="$SCRIPT_DIR/deploy-logs"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

if [ -z "$DEVICES_FILE" ]; then
    echo "Usage: $0 <devices-file> [parallel-count]"
    echo ""
    echo "  devices-file    Text file with one device IP per line"
    echo "  parallel-count  Max concurrent deployments (default: 5)"
    echo ""
    echo "Example:"
    echo "  $0 devices.txt 10"
    exit 1
fi

if [ ! -f "$DEVICES_FILE" ]; then
    echo "Error: File not found: $DEVICES_FILE"
    exit 1
fi

# Check sync.sh exists with release build
if [ ! -f "$SCRIPT_DIR/sync.sh" ]; then
    echo "Error: sync.sh not found in $SCRIPT_DIR"
    exit 1
fi

if [ ! -d "$SCRIPT_DIR/html" ]; then
    echo "Error: No release build found. Run 'npm run release' first."
    exit 1
fi

# Check sshpass
if ! command -v sshpass &>/dev/null; then
    echo "Error: sshpass is required. Install with: sudo apt-get install sshpass"
    exit 1
fi

# Read device list (skip comments and empty lines)
DEVICES=()
while IFS= read -r line; do
    line=$(echo "$line" | sed 's/#.*//' | xargs)
    [ -n "$line" ] && DEVICES+=("$line")
done < "$DEVICES_FILE"

TOTAL=${#DEVICES[@]}
if [ "$TOTAL" -eq 0 ]; then
    echo "Error: No devices found in $DEVICES_FILE"
    exit 1
fi

# Create log directory
mkdir -p "$LOG_DIR"

echo "=== Robot-T430 Batch Deployment ==="
echo "Devices:  $TOTAL"
echo "Parallel: $PARALLEL"
echo "User:     $DEVICE_USER"
echo "Logs:     $LOG_DIR/"
echo ""

# Deploy to a single device, logging output
deploy_device() {
    local ip="$1"
    local idx="$2"
    local logfile="$LOG_DIR/${TIMESTAMP}_${ip}.log"

    echo "[$idx/$TOTAL] Starting: $ip"

    DEVICE_USER="$DEVICE_USER" DEVICE_PASS="$DEVICE_PASS" \
        "$SCRIPT_DIR/sync.sh" "$ip" "$DEVICE_USER" > "$logfile" 2>&1

    if [ $? -eq 0 ]; then
        echo "[$idx/$TOTAL] OK:      $ip"
        return 0
    else
        echo "[$idx/$TOTAL] FAILED:  $ip (see $logfile)"
        return 1
    fi
}

# Run deployments with parallel limit
RUNNING=0
FAILED=0
SUCCEEDED=0
IDX=0
PIDS=()
ALL_IPS=()

for ip in "${DEVICES[@]}"; do
    IDX=$((IDX + 1))

    deploy_device "$ip" "$IDX" &
    PIDS+=($!)
    ALL_IPS+=("$ip")

    RUNNING=$((RUNNING + 1))

    # Wait if we hit the parallel limit
    if [ "$RUNNING" -ge "$PARALLEL" ]; then
        # Wait for any one to finish
        for i in "${!PIDS[@]}"; do
            if [ -n "${PIDS[$i]}" ]; then
                wait "${PIDS[$i]}" 2>/dev/null
                if [ $? -eq 0 ]; then
                    SUCCEEDED=$((SUCCEEDED + 1))
                else
                    FAILED=$((FAILED + 1))
                fi
                unset 'PIDS[$i]'
                RUNNING=$((RUNNING - 1))
                break
            fi
        done
    fi
done

# Wait for remaining
for pid in "${PIDS[@]}"; do
    if [ -n "$pid" ]; then
        wait "$pid" 2>/dev/null
        if [ $? -eq 0 ]; then
            SUCCEEDED=$((SUCCEEDED + 1))
        else
            FAILED=$((FAILED + 1))
        fi
    fi
done

echo ""
echo "=== Batch Deployment Complete ==="
echo "Total:     $TOTAL"
echo "Succeeded: $SUCCEEDED"
echo "Failed:    $FAILED"
echo "Logs:      $LOG_DIR/"

# Generate report
REPORT="$LOG_DIR/report-${TIMESTAMP}.txt"
{
    echo "Robot-T430 Batch Deployment Report"
    echo "==================================="
    echo "Date:      $(date)"
    echo "User:      $DEVICE_USER"
    echo "Total:     $TOTAL"
    echo "Succeeded: $SUCCEEDED"
    echo "Failed:    $FAILED"
    echo ""
    echo "Device Results:"
    echo "---------------"
    for ip in "${ALL_IPS[@]}"; do
        logfile="$LOG_DIR/${TIMESTAMP}_${ip}.log"
        if grep -q "Deployment complete" "$logfile" 2>/dev/null; then
            echo "  OK      $ip"
        else
            reason=$(tail -1 "$logfile" 2>/dev/null || echo "unknown error")
            echo "  FAILED  $ip  ($reason)"
        fi
    done
    if [ "$FAILED" -gt 0 ]; then
        echo ""
        echo "Failed Device Logs:"
        echo "-------------------"
        for ip in "${ALL_IPS[@]}"; do
            logfile="$LOG_DIR/${TIMESTAMP}_${ip}.log"
            if ! grep -q "Deployment complete" "$logfile" 2>/dev/null; then
                echo ""
                echo "--- $ip ---"
                cat "$logfile" 2>/dev/null
            fi
        done
    fi
} > "$REPORT"

echo "Report:    $REPORT"

if [ "$FAILED" -gt 0 ]; then
    echo ""
    echo "Failed devices:"
    for ip in "${ALL_IPS[@]}"; do
        logfile="$LOG_DIR/${TIMESTAMP}_${ip}.log"
        if ! grep -q "Deployment complete" "$logfile" 2>/dev/null; then
            echo "  - $ip"
        fi
    done
    exit 1
fi
