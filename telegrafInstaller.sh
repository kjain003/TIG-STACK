#!/usr/bin/env bash

umask 022

export PATH="/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"


# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Function to display usage information
usage() {
  echo "Usage: $0 -i <influx_url> -u <username> -p <password>"
  exit 1
}

### Parse command-line options
while getopts ":i:u:p:h" opt; do
  case $opt in
    i)
      influx_url="$OPTARG"
      ;;
    u)
      username="$OPTARG"
      ;;
    p)
      password="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
	h)
	  usage
      ;;	  
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

# Check if InfluxDB URL, username, and password are provided
if [ -z "$influx_url" ] || [ -z "$username" ] || [ -z "$password" ]; then
  echo "Error: InfluxDB URL, username, and password must be provided."
  usage
fi

### Add Telegraf repository
### Add Telegraf repository
REPO_URL="https://raw.githubusercontent.com/kjain003/telegraf-config/main/influxdata.repo"
REPO_CFG="/etc/yum.repos.d/influxdata.repo"
curl -sSfLJO "$REPO_URL" -o $REPO_CFG

cd /var/tmp
### Update packages
yum update -y

### Install Telegraf
yum install telegraf -y

### Start Telegraf service
systemctl start telegraf

### Enable Telegraf to start on boot
systemctl enable telegraf

TELEGRAFCFG="/etc/telegraf/telegraf.conf"
### Backup default Telegraf configuration
mv ${TELEGRAFCFG} ${TELEGRAFCFG}.backup
touch ${TELEGRAFCFG}



# Define the URL of the Telegraf configuration on GitHub
CONFIG_URL="https://raw.githubusercontent.com/kjain003/telegraf-config/main/telegraf.conf"

# Download Telegraf configuration from GitHub repository
echo "Downloading Telegraf configuration from GitHub repository..."
curl -sSfLJO "$CONFIG_URL" -o /tmp/telegraf.conf

# Check if download was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to download Telegraf configuration from GitHub repository."
  exit 1
fi

# Update Telegraf configuration with influx url,username and password for telegraf db
sed -i "s#urls = \[\"http://localhost:8086\"\]#urls = [\"$influx_url\"]#" /tmp/telegraf.conf
sed -i "s/database = \"telegraf\"/database = \"telegraf\"\\n  username = \"$username\"\\n  password = \"$password\"/" /tmp/telegraf.conf

#Update configuration to add ip address of given device
sed -i -e "s/__ip__/$(hostname -i | cut -d ' ' -f 1)/g" /tmp/telegraf.conf

# Replace existing Telegraf configuration with the updated one
mv /tmp/telegraf.conf ${TELEGRAFCFG}

# Restart Telegraf service to apply changes
systemctl restart telegraf

# Check if Telegraf restarted successfully
if systemctl is-active --quiet telegraf; then
  echo "Telegraf configuration updated successfully."
  
  # Bind Telegraf to a specific CPU core (e.g., core 0)
  #taskset -c 0 -p $(pgrep telegraf)
  #echo "Telegraf restricted to use a single CPU core."
else
  echo "Error: Telegraf failed to restart."
  exit 1
fi
