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
        
        # Create a temp file to track last output time (using file modification time)
        local marker_file=$(mktemp)
        
        # Run command, update marker file on each output line
        # Use process substitution to avoid subshell issues
        local cmd_pid
        "${cmd[@]}" 2>&1 &
        cmd_pid=$!
        
        # Process output in background, touching marker file on each line
        {
            while IFS= read -r line; do
                echo "$line"
                touch "$marker_file"
            done < <(tail -f /proc/$cmd_pid/fd/1 2>/dev/null || cat /proc/$cmd_pid/fd/1 2>/dev/null)
        } 2>/dev/null &
        local reader_pid=$!
        
        # Alternative: simpler approach using a FIFO
        kill $reader_pid 2>/dev/null
        
        # Use a named pipe for reliable output tracking
        local fifo=$(mktemp -u)
        mkfifo "$fifo"
        
        # Run command with output to fifo
        ("${cmd[@]}" 2>&1; echo "___CMD_DONE___") > "$fifo" &
        cmd_pid=$!
        
        local timed_out=false
        local cmd_finished=false
        
        # Read from fifo with timeout checks
        while true; do
            # Read with timeout using read -t
            if IFS= read -r -t "$timeout_seconds" line < "$fifo"; then
                if [ "$line" = "___CMD_DONE___" ]; then
                    cmd_finished=true
                    break
                fi
                echo "$line"
            else
                # Timeout occurred
                timed_out=true
                break
            fi
        done
        
        # Cleanup
        rm -f "$fifo" "$marker_file"
        
        if [ "$cmd_finished" = true ]; then
            # Wait for command and check exit status
            if wait $cmd_pid 2>/dev/null; then
                echo "=== Command completed successfully ==="
                return 0
            else
                echo "=== Command failed with non-zero exit ==="
                return 1
            fi
        fi
        
        if [ "$timed_out" = true ]; then
            echo ""
            echo "=== No output for ${timeout_seconds}s. Restarting... ==="
            # Kill the command and all its children
            pkill -P $cmd_pid 2>/dev/null
            kill $cmd_pid 2>/dev/null
            wait $cmd_pid 2>/dev/null
            
            if [ $attempt -lt $max_retries ]; then
                echo "=== Retrying in 5 seconds... ==="
                sleep 5
            fi
        fi
    done
    
    echo "=== Command failed after $max_retries attempts ==="
    return 1
}