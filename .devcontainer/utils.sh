#!/bin/bash

function ensure-docker-is-ready {
    echo "Ensuring docker daemon is available"
    until docker info > /dev/null 2>&1; do
        sleep 1
    done
    echo "Docker is ready"
}