# placeholder

# going to have to do \"docker ps -a\" and search for sd-forge container
# oof not fun start on this one

DOCKER_PSA_LIST=$(docker ps -a --format '{{.Names}}' | grep "sd-forge")

echo "Debug: DOCKER_PSA_LIST:[$DOCKER_PSA_LIST]"

# Loop through each line
while read line; do
    echo "Starting docker container: $line"
    docker start $line
done <<< "$data"

echo "docker ps output"
docker ps

echo "Docker containers started."
