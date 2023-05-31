Auction

Requirements:

install python

pip3 install flask

pip3 install waitress



Configuration: 
set local time zone of server, example: sudo timedatectl set-timezone America/New_York

edit title in auction.html

change admin password in auction.py

maybe edit wsgi.py if you run into problems with waitress.  or you can run auction.py from gunicorn



Command to start server:

cd to auction folder 

sudo waitress-serve --port=80 wsgi:app

or
sudo waitress-serve --host=<your_vm_ip_address> --port=80 wsgi:app
