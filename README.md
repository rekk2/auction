Auction

Requirements:

install python

pip install flask

pip install waitress



Configuration: 

edit title in auction.html

change admin password in auction.py

maybe edit wsgi.py if you run into problems



Command to start server:

cd to auction folder 

waitress-serve --port:80 wsgi:app

or
waitress-serve --host=<your_vm_ip_address> --port:80 wsgi:app
