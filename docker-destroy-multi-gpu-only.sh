#!/usr/bin/env bash

# simple destroy script
docker compose -f docker-compose.yaml -f docker-compose.multi-gpu.nvidia.yaml down
