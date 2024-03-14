#!/usr/bin/env bash

umask 022

export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"

# Function to check if Docker is installed
check_docker_installed() {
    if ! command -v docker &> /dev/null; then
        return 1
    else
        return 0
    fi
}

# Function to install Docker
install_docker() {
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    echo "Docker installed successfully."
}

# Function to install Docker Compose
install_docker_compose() {
    echo "Installing Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "Docker Compose installed successfully."
}

# Function to fetch Docker Compose configuration from GitHub repository
fetch_docker_compose_config() {
    echo "Fetching Docker Compose configuration from GitHub repository..."
    curl -fsSL -o docker-compose.yml https://raw.githubusercontent.com/yourusername/your-repo/main/docker-compose.yml
    echo "Docker Compose configuration fetched successfully."
}

# Function to run Docker Compose
run_docker_compose() {
    echo "Running Docker Compose..."
    docker-compose up -d
    echo "Docker Compose setup completed."
}

# Function to create user for Telegraf
create_telegraf_user() {
    echo "Creating user for Telegraf..."
    read -s -p "Enter password for Telegraf user: " telegraf_password
    echo
    docker exec -i influxdb influx -execute "CREATE USER telegraf WITH PASSWORD '$telegraf_password'"
    docker exec -i influxdb influx -execute 'GRANT ALL ON telegraf.* TO telegraf'
    echo "User for Telegraf created successfully."
}

# Check if Docker is installed
if ! check_docker_installed; then
    install_docker
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    install_docker_compose
fi

# Fetch Docker Compose configuration from GitHub repository
fetch_docker_compose_config

# Run Docker Compose to setup InfluxDB
run_docker_compose

# Create user for Telegraf
create_telegraf_user
