#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker and Docker Compose and run this script again."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Please install Docker Compose and run this script again."
    exit 1
fi

# Create a directory for SonarQube and PostgreSQL setup
mkdir -p ~/sonarqube
cd ~/sonarqube

# Create a Docker Compose file (docker-compose.yml)
cat <<EOL > docker-compose.yml
version: "3"

services:
  sonarqube:
    image: sonarqube:community
    container_name: sonarqube
    ports:
      - "9010:9000"
    networks:
      - sonarqube_network
    environment:
      - SONARQUBE_JDBC_URL=jdbc:postgresql://db:5432/sonar
      - SONARQUBE_JDBC_USERNAME=sonar
      - SONARQUBE_JDBC_PASSWORD=sonar
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions

  db:
    image: postgres:12
    container_name: postgres
    networks:
      - sonarqube_network
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
    volumes:
      - postgres_data:/var/lib/postgresql/data

networks:
  sonarqube_network:
    driver: bridge

volumes:
  sonarqube_data:
  sonarqube_extensions:
  postgres_data:
EOL

# Start SonarQube and PostgreSQL containers
docker-compose up -d

echo "SonarQube and PostgreSQL containers have been started."

