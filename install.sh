#!/bin/bash

# Setting the username and project path and title
USERNAME=$(whoami)
PROJECT_PATH=$(pwd)

# Prompt the user for the title
echo "Please enter the title for the project:"
read TITLE

# Set Timezone
sudo timedatectl set-timezone America/New_York || exit 1

# Updating system
sudo apt-get update || exit 1
sudo apt-get upgrade -y || exit 1

# Installing necessary packages
sudo apt-get install -y python3-venv python3-pip git nginx || exit 1

# The path to your HTML file
HTML_FILE="${PROJECT_PATH}/templates/auction.html"

# Insert the title using sed
sed -i "s|<title>.*</title>|<title>$TITLE</title>|" "$HTML_FILE" || exit 1

# Creating a virtual environment
python3 -m venv venv || exit 1
source venv/bin/activate || exit 1

# Installing Python packages
pip install -r requirements.txt || exit 1

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
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/myproject.service || exit 1

# Starting the service
sudo systemctl daemon-reload || exit 1
sudo systemctl start myproject || exit 1
sudo systemctl enable myproject || exit 1

# Checking the status of the service
sudo systemctl status myproject || exit 1

# Configuring nginx
sudo systemctl start nginx || exit 1

echo "server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}" | sudo tee /etc/nginx/sites-available/myproject || exit 1

sudo ln -s /etc/nginx/sites-available/myproject /etc/nginx/sites-enabled/ || exit 1

# Remove default Nginx configuration
sudo rm -f /etc/nginx/sites-enabled/default || exit 1

sudo nginx -t || exit 1
sudo systemctl reload nginx || exit 1
