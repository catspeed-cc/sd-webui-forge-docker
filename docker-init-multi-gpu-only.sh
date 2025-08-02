#!/usr/bin/env bash

# docker-init-multi-gpu-only.sh: create and start container for single GPU of many only

# simple init but there is config in related docker-compose file(s)
docker compose -f docker-compose.yaml -f docker-compose.multi-gpu.nvidia.yaml up -d
