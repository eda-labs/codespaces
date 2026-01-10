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
        
        # Create a temp file to track last output time
        local last_output_file=$(mktemp)
        date +%s > "$last_output_file"
        
        # Run command in background, updating timestamp on each output line
        ("${cmd[@]}" 2>&1) | while IFS= read -r line; do
            echo "$line"
            date +%s > "$last_output_file"
        done &
        local pipe_pid=$!
        
        # Monitor for inactivity
        while kill -0 $pipe_pid 2>/dev/null; do
            sleep 5
            local last_output=$(cat "$last_output_file")
            local now=$(date +%s)
            local idle_time=$((now - last_output))
            
            if [ $idle_time -ge $timeout_seconds ]; then
                echo ""
                echo "=== No output for ${idle_time}s (timeout: ${timeout_seconds}s). Restarting... ==="
                # Kill the pipeline and any child processes
                pkill -P $pipe_pid 2>/dev/null
                kill $pipe_pid 2>/dev/null
                wait $pipe_pid 2>/dev/null
                rm -f "$last_output_file"
                break
            fi
        done
        
        # Check if command completed successfully
        if wait $pipe_pid 2>/dev/null; then
            rm -f "$last_output_file"
            echo "=== Command completed successfully ==="
            return 0
        fi
        
        rm -f "$last_output_file"
        
        # If we're here due to timeout, continue to next attempt
        if [ $attempt -lt $max_retries ]; then
            echo "=== Retrying in 5 seconds... ==="
            sleep 5
        fi
    done
    
    echo "=== Command failed after $max_retries attempts ==="
    return 1
}