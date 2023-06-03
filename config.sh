#!/bin/bash

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

# Test Nginx configuration 
sudo nginx -t

# Configuring nginx
sudo systemctl start nginx
sudo systemctl reload nginx
