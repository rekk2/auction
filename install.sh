#!/bin/bash

# Setting the username and project path and title
USERNAME="your_username"
PROJECT_PATH="/auction"
TITLE="Your Title"

# Set Timezone
sudo timedatectl set-timezone America/New_York

# Updating system
sudo apt-get update
sudo apt-get upgrade -y

# Installing necessary packages
sudo apt-get install -y python3-venv python3-pip git nginx

# The path to your HTML file
HTML_FILE="/templates/auction.html"

# Insert the title using sed
sed -i "6s|<title>|<title>$TITLE|" "$HTML_FILE"

# Creating a virtual environment
sudo python3 -m venv venv
source venv/bin/activate

# Installing Python packages
sudo pip install flask
sudo pip install gunicorn

# Creating a systemd service file
echo "[Unit]
Description=Gunicorn instance to serve myproject
After=network.target

[Service]
User=$USERNAME
Group=www-data
WorkingDirectory=$PROJECT_PATH
Environment=\"PATH=$PROJECT_PATH/venv/bin\"
ExecStart=/usr/local/bin/gunicorn -b :8080 auction:app

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/myproject.service

# Symlinking the project to the venv
ln -s $PROJECT_PATH $PROJECT_PATH/venv/bin

# Starting the service
sudo systemctl daemon-reload
sudo systemctl start myproject
sudo systemctl enable myproject

# Checking the status of the service
sudo systemctl status myproject

# Configuring nginx
sudo systemctl start nginx

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
}" | sudo tee /etc/nginx/sites-available/myproject

sudo ln -s /etc/nginx/sites-available/myproject /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
