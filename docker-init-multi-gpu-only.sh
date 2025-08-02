#!/usr/bin/env bash

# simple init but there is config in related docker-compose file(s)
docker compose -f docker-compose.yaml -f docker-compose.multi-gpu.nvidia.yaml up
