**Install instructions**



sudo python3 -m venv venv
source venv/bin/activate
sudo vi /etc/systemd/system/myproject.service

code for myproject.service

[Unit]
Description=Gunicorn instance to serve myproject
After=network.target

[Service]
User=username
Group=www-data
WorkingDirectory=/path/to/your/project
Environment="PATH=/path/to/your/project/venv/bin"
ExecStart=/path/to/your/project/venv/bin/gunicorn -b :8080 auction:app

[Install]
WantedBy=multi-user.target

save and exit by typing :wq

pip install flask
pip install gunicorn
sudo systemctl daemon-reload
sudo systemctl start myproject
sudo systemctl enable myproject
sudo systemctl status myproject

sudo apt-get update
sudo apt-get install nginx
sudo systemctl start nginx

sudo vi /etc/nginx/sites-available/myproject


server {
    listen 80;
    server_name YOUR_IP_ADDRESS;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

save and exit by typing :wq

sudo ln -s /etc/nginx/sites-available/myproject /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx


'''
