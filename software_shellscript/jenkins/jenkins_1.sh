#!/bin/bash

# Update the system and install necessary packages
sudo apt update
sudo apt-get update

# Create Docker network
sudo docker network create jenkins

# Start the Jenkins Docker container with docker:dind
sudo docker run --name jenkins-docker --rm --detach --privileged \
--network jenkins --network-alias docker --env DOCKER_TLS_CERTDIR=/certs \
--volume jenkins-docker-certs:/certs/client --volume jenkins-data:/var/jenkins_home \
--publish 2376:2376 docker:dind --storage-driver overlay2

# Create a Dockerfile
cat <<EOL > Dockerfile
FROM jenkins/jenkins:2.414.3-jdk17
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=\$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
https://download.docker.com/linux/debian \
\$(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
EOL

# Build the custom Jenkins image
sudo docker build -t myjenkins-blueocean:2.414.3-1 .

# Start Jenkins with the custom image
sudo docker run --name jenkins-blueocean --restart=on-failure --detach \
--network jenkins --env DOCKER_HOST=tcp://docker:2376 --env DOCKER_CERT_PATH=/certs/client \
--env DOCKER_TLS_VERIFY=1 --publish 0.0.0.0:8081:8080 --publish 50000:50000 \
--volume jenkins-data:/var/jenkins_home --volume jenkins-docker-certs:/certs/client:ro \
myjenkins-blueocean:2.414.3-1

