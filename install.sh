#!/bin/bash

# Setting the username and project path and title
USERNAME=$(whoami)
PROJECT_PATH=$(pwd)

# Prompt the user for the title
echo "Please enter the title for the project:"
read TITLE

# Set Timezone
sudo timedatectl set-timezone America/New_York

# Updating system
sudo apt-get update
sudo apt-get upgrade -y

# Installing necessary packages
sudo apt-get install -y python3-venv python3-pip git nginx

# The path to your HTML file
HTML_FILE="${PROJECT_PATH}/templates/auction.html"

# Insert the title using sed
sed -i "s|<title>.*</title>|<title>$TITLE</title>|" "$HTML_FILE"

# Creating a virtual environment
python3 -m venv venv
source venv/bin/activate

# Installing Python packages
pip install -r requirements.txt

# Creating a systemd service file
echo "[Unit]
Description=Gunicorn instance to serve myproject
After=network.target

[Service]
User=$USERNAME
Group=www-data
WorkingDirectory=$PROJECT_PATH
ExecStart=${PROJECT_PATH}/venv/bin/gunicorn -b :8080 auction:app

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/myproject.service

# Starting the service
sudo systemctl daemon-reload
sudo systemctl start myproject
sudo systemctl enable myproject
