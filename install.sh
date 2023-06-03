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

# Checking the status of the service
sudo systemctl status myproject

# Configuring nginx
sudo systemctl start nginx

# Write to Nginx configuration for the project
sudo bash -c "echo 'server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}' > /etc/nginx/sites-available/myproject"

# Creating a symbolic link
sudo ln -s /etc/nginx/sites-available/myproject /etc/nginx/sites-enabled/

# Remove default Nginx configuration if it exists
if [ -e /etc/nginx/sites-enabled/default ]; then
    sudo rm /etc/nginx/sites-enabled/default
fi

# Test Nginx configuration and reload if it's okay
sudo nginx -t && sudo systemctl reload nginx
