# Pull official base image from DockerHub
FROM leastauthority/magic-wormhole:23.5.0

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh "/entrypoint.sh"

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
