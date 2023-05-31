Auction

Requirements:

install python

sudo apt update

sudo apt install python3-pip

pip3 install flask

pip3 install waitress



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
