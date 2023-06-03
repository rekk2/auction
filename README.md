
Requirements:

install python

sudo apt update

sudo apt install python3-pip

pip3 install flask

pip3 install waitress

or

pip3 install gunicorn


Configuration: 

set local time zone of server, example: sudo timedatectl set-timezone America/New_York

edit title in auction.html

change admin password in auction.py




Command to start server:

cd to auction folder 

sudo waitress-serve --port=80 wsgi:app

or
sudo waitress-serve --host=<your_vm_ip_address> --port=80 wsgi:app

or
sudo gunicorn -b :80 auction:app



**Virtual Enviornment Install Instructions**

sudo apt update

sudo apt upgrade

sudo apt install python3-venv

sudo apt-get install python3-pip

sudo apt install git

git clone https://rekk2/auction.git

cd auction

pwd

shows full path of auction folder, it will be copied into your service config file

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

WorkingDirectory=/path/to/your/project

ExecStart=/usr/local/bin/gunicorn -b :8080 auction:app

[Install]

WantedBy=multi-user.target

save by hitting esc then :wq

ln -s /path/to/your/project /path/to/your/project/venv/bin

sudo pip install flask

sudo pip install gunicorn

sudo systemctl daemon-reload

sudo systemctl start myproject

sudo systemctl enable myproject

sudo systemctl status myproject


sudo apt-get install nginx

sudo systemctl start nginx

sudo vi /etc/nginx/sites-available/myproject


server {
    listen 80;
    server_name ip.add.re.ss

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}


save and exit by hitting esc then :wq


sudo ln -s /etc/nginx/sites-available/myproject /etc/nginx/sites-enabled/

sudo nginx -t

sudo systemctl reload nginx


Configuration: 

set local time zone of server, example: sudo timedatectl set-timezone America/New_York

edit title in auction.html

change admin password in auction.py

