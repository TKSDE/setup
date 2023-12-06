#!/bin/bash

# Stop and remove the Jenkins Docker container
sudo docker stop jenkins-blueocean
sudo docker rm jenkins-blueocean

# Stop and remove the Jenkins Docker-in-Docker container
sudo docker stop jenkins-docker
sudo docker rm jenkins-docker

# Remove the Docker network
sudo docker network rm jenkins

# Remove the custom Jenkins Docker image
sudo docker rmi myjenkins-blueocean:2.414.3-1

# Remove Docker volumes
sudo docker volume rm jenkins-data
sudo docker volume rm jenkins-docker-certs

# Remove the Dockerfile
rm Dockerfile

