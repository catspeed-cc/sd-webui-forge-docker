#!/usr/bin/env bash

# docker-init-single-gpu-only.sh: create and start container for single GPU only

# simple init but there is config in related docker-compose file(s)
docker compose -f docker-compose.yaml -f docker-compose.single-gpu.nvidia.yaml up -d
