#!/bin/bash

function ensure-docker-is-ready {
    echo "Ensuring docker daemon is available"
    until docker info > /dev/null 2>&1; do
        sleep 1
    done
    echo "Docker is ready"
}

# Run a command with inactivity timeout - restarts if no output for specified seconds
# Usage: run-with-inactivity-timeout <timeout_seconds> <max_retries> <command> [args...]
function run-with-inactivity-timeout {
    local timeout_seconds=$1
    local max_retries=$2
    shift 2
    local cmd=("$@")
    local attempt=0

    while [ $attempt -lt $max_retries ]; do
        attempt=$((attempt + 1))
        echo "=== Attempt $attempt/$max_retries: ${cmd[*]} ==="
        
        # Create marker file - we'll use its modification time
        local marker_file=$(mktemp)
        touch "$marker_file"
        
        # Start the command, piping through a while loop that touches the marker
        # Using stdbuf to disable buffering
        stdbuf -oL -eL "${cmd[@]}" 2>&1 | while IFS= read -r line; do
            echo "$line"
            touch "$marker_file"
        done &
        local pipe_pid=$!
        
        local timed_out=false
        
        # Monitor loop - check marker file modification time
        while kill -0 $pipe_pid 2>/dev/null; do
            sleep 5
            
            # Get seconds since marker was last modified
            local now=$(date +%s)
            local last_mod=$(stat -c %Y "$marker_file" 2>/dev/null || echo "$now")
            local idle_time=$((now - last_mod))
            
            if [ $idle_time -ge $timeout_seconds ]; then
                timed_out=true
                echo ""
                echo "=== No output for ${idle_time}s (timeout: ${timeout_seconds}s). Restarting... ==="
                
                # Kill the entire process group
                kill -- -$pipe_pid 2>/dev/null || true
                # Kill by parent
                pkill -P $pipe_pid 2>/dev/null || true
                # Direct kill
                kill $pipe_pid 2>/dev/null || true
                # Kill any remaining make/kpt processes from this session
                pkill -f "kpt live apply" 2>/dev/null || true
                
                sleep 2
                break
            fi
        done
        
        wait $pipe_pid 2>/dev/null
        local exit_code=$?
        
        rm -f "$marker_file"
        
        if [ "$timed_out" = false ]; then
            if [ $exit_code -eq 0 ]; then
                echo "=== Command completed successfully ==="
                return 0
            else
                echo "=== Command failed with exit code $exit_code ==="
                return $exit_code
            fi
        fi
        
        # Timed out - retry
        if [ $attempt -lt $max_retries ]; then
            echo "=== Retrying in 5 seconds... ==="
            sleep 5
        fi
    done
    
    echo "=== Command failed after $max_retries attempts ==="
    return 1
}