#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 3.1.49.38:9000 18ac3e7343f016890c510e93f935261169d9e3f565436429830faf0934f4f8e4"
#    echo "Example: $0 http://your-server-ip:9000 yourpassword"
    exit 1
}

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    usage
fi

# Set variables
GRAYLOG_HTTP_EXTERNAL_URI="$1"
GRAYLOG_PASSWORD_SECRET="$2"

# Install Docker
sudo apt update
sudo apt install -y docker.io
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install -y curl wget
curl -s https://api.github.com/repos/docker/compose/releases/latest | grep browser_download_url  | grep docker-compose-linux-x86_64 | cut -d '"' -f 4 | wget -qi -
chmod +x docker-compose-linux-x86_64
sudo mv docker-compose-linux-x86_64 /usr/local/bin/docker-compose

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker

# Create Docker Compose file
cat <<EOL > docker-compose.yml
version: '2'
services:
  mongodb:
    image: mongo:4.2
    networks:
      - graylog
    volumes:
      - /mongo_data:/data/db
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch-oss:7.10.2
    volumes:
      - /es_data:/usr/share/elasticsearch/data
    environment:
      - http.host=0.0.0.0
      - transport.host=localhost
      - network.host=0.0.0.0
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    mem_limit: 1g
    networks:
      - graylog
  graylog:
    image: graylog/graylog:4.2
    volumes:
      - /graylog_journal:/usr/share/graylog/data/journal
    environment:
      - GRAYLOG_PASSWORD_SECRET=$GRAYLOG_PASSWORD_SECRET
      - GRAYLOG_ROOT_PASSWORD_SHA2=$(echo -n "$GRAYLOG_PASSWORD_SECRET" | sha256sum | cut -d" " -f1)
      - GRAYLOG_HTTP_EXTERNAL_URI=$GRAYLOG_HTTP_EXTERNAL_URI
    entrypoint: /usr/bin/tini -- wait-for-it elasticsearch:9200 --  /docker-entrypoint.sh
    networks:
      - graylog
    links:
      - mongodb:mongo
      - elasticsearch
    restart: always
    depends_on:
      - mongodb
      - elasticsearch
    ports:
      - 9000:9000
      - 1514:1514
      - 1514:1514/udp
      - 12201:12201
      - 12201:12201/udp
volumes:
  mongo_data:
    driver: local
  es_data:
    driver: local
  graylog_journal:
    driver: local
networks:
    graylog:
      driver: bridge
EOL

# Create Persistent volumes
sudo mkdir /mongo_data
sudo mkdir /es_data
sudo mkdir /graylog_journal
sudo chmod 777 -R /mongo_data
sudo chmod 777 -R /es_data
sudo chmod 777 -R /graylog_journal
sudo chmod 777 -R /usr/share/graylog/data/journal

# Run Graylog Server
docker-compose up -d

echo "Graylog setup completed successfully!"

