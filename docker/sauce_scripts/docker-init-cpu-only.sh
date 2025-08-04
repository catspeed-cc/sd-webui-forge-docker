#!/usr/bin/env bash

# docker-init-cpu-only.sh: create and start container for CPU only

# simple should not be config req'd
docker compose -f ./docker/compose_files/docker-compose.yaml up -d
