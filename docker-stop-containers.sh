# placeholder

# going to have to do \"docker ps -a\" and search for sd-forge container
# oof not fun start on this one

DOCKER_PSA_LIST=$(docker ps -a --format '{{.Names}}' | grep "sd-forge")

echo "Debug: DOCKER_PSA_LIST:[$DOCKER_PSA_LIST]"

# Loop through each line
while read line; do
    echo "Stopping docker container: $line"
    # You can now use "$line" as a variable
    docker start $line
done <<< "$DOCKER_PSA_LIST"

echo "docker ps -a output:"
docker ps -a

echo "Docker containers stopped."

