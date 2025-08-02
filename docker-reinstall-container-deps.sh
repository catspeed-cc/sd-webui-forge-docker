# docker-reinstall-container-deps.sh

# docker exec the sauce!
# Get the list of ALL containers `docker ps -a`
DOCKER_PSA_LIST=$(docker ps -a --format '{{.Names}}' | grep "sd-forge")

# Loop through each container
while read container; do
    echo "Stopping docker container: $container"
    docker exec $container /app/sauces/secretsauce.sh
done <<< "$DOCKER_PSA_LIST"

echo ""
echo "all containers have reinstalled their dependencies"
echo ""


