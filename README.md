# TIG STACK
Telegraf,Influx and grafana configuration to monitor linux server performance metrics


# InfluxDB Setup Script

This script automates the setup of InfluxDB using Docker Compose.

## Optional Prerequisites

- Docker: Ensure Docker is installed on your system. You can install Docker by following the instructions on the [official Docker website](https://docs.docker.com/get-docker/).
- Docker Compose: Ensure Docker Compose is installed on your system. You can install Docker Compose by following the instructions on the [official Docker Compose website](https://docs.docker.com/compose/install/).
- If both docker and docker compose are not installed, the script will do that for you

## Usage

1. Clone this repository to your local machine:

   ```bash
   git clone https://github.com/kjain003/TIG-STACK.git
   ```
2. Navigate to the cloned directory:
   ```bash
   cd TIG-STACK
   ```
3. Make Script executable and run it
   ```bash
   chmod +x influxdbInstaller.sh
   ./influxdbInstaller.sh
   ```

The script will check if Docker and Docker Compose are installed. If not, it will install them. It will then fetch the Docker Compose configuration from this GitHub repository, run Docker Compose to set up InfluxDB, and create a user for Telegraf to ingest data into InfluxDB.
4. Follow the on-screen prompts to enter the password for the Telegraf user.

# Telegraf Installer Script

This script allows you to install and  update the Telegraf configuration file with your InfluxDB URL, username, and password. It downloads the Telegraf configuration from this GitHub repository(telegraf.conf), updates it with the provided InfluxDB credentials, and restarts the Telegraf service to apply the changes.

## Usage

Make sure you have root privileges to run the script. Execute the script with the following command:

```bash
sudo ./telegrafInstaller.sh -i <influx_url> -u telegraf -p <password>
```
Replace <influx_url> and and <password> with your InfluxDB URL, username, and password, respectively.(user is set to telegraf by default)

For example:
```bash
sudo ./telegrafInstaller.sh -i http://localhost:8086 -u telegraf -p my_password
```
### Restrict Telegraf to Consume Less CPU Resources (Optional)
Uncomment below part in telegrafInstaller.sh file to enable this and bind telegraf to single core
```bash
   # Bind Telegraf to a specific CPU core (e.g., core 0)
  #taskset -c 0 -p $(pgrep telegraf)

  #echo "Telegraf restricted to use a single CPU core."
```

Script Features
- Downloads the Telegraf configuration file from this GitHub repository.
- Updates the configuration file with the provided InfluxDB URL, username, and password.
- Restarts the Telegraf service to apply the changes.
- Restricts Telegraf to use a single CPU core after restarting (optional).

