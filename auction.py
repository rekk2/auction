from flask import Flask, render_template, request, redirect, url_for
from datetime import datetime, timedelta
import json
import atexit
import os
from werkzeug.utils import secure_filename

app = Flask(__name__)

# Define the admin password
ADMIN_PASSWORD = "admin"

# Variable to track if the user is authenticated as admin
admin_authenticated = False

# Define the upload folder
UPLOAD_FOLDER = os.path.join(os.path.abspath(os.path.dirname(__file__)), 'static', 'images')

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Create the upload folder if it doesn't exist
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)
    

ALLOWED_EXTENSIONS = {'jpg', 'jpeg', 'png', 'gif'}

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS
           
class AuctionItem:
    def __init__(self, name, starting_price, end_time, image_filename, description):
        self.name = name
        self.starting_price = starting_price
        self.current_price = starting_price
        self.highest_bidder = None
        self.end_time = end_time
        self.image_url = f"images/{image_filename}"
        self.description = description.replace('\n', '<br>')
        self.time_increases = 0

    def time_remaining(self):
        return self.end_time - datetime.now()

    def place_bid(self, bidder, bid_amount):
        if bid_amount > self.current_price:
            if self.highest_bidder:
                self.highest_bidder.notify_outbid(self.name, self.current_price)

            if not self.is_expired() and self.time_remaining() < timedelta(minutes=30):
                if self.time_increases >= 5:
                    minimum_bid = self.current_price + 5
                else:
                    minimum_bid = self.current_price + min(self.time_increases + 1, 4)

                if bid_amount < minimum_bid:
                    bidder.notify_invalid_bid(self.name, bid_amount, minimum_bid)
                    return

                if self.time_increases >= 5:
                    self.end_time += timedelta(seconds=15)
                elif self.time_increases >= 2:
                    self.end_time += timedelta(seconds=30)
                else:
                    self.end_time += timedelta(minutes=1)

                self.time_increases += 1

            self.current_price = bid_amount
            self.highest_bidder = bidder
            bidder.notify_winning_bid(self.name, bid_amount)
            save_items_to_file(items)  # Save the items after each bid
        else:
            bidder.notify_invalid_bid(self.name, bid_amount, self.current_price)






    def is_expired(self):
        return datetime.now() >= self.end_time


class Bidder:
    def __init__(self, name):
        self.name = name
        self.notifications = []
        self.notifications_accepted = False
        self.notifications_invalid = False

    def notify_outbid(self, item_name, current_price):
        self.notifications.append(f"{item_name}: You have been outbid. The current price is {current_price}.")

    def notify_winning_bid(self, item_name, bid_amount):
        self.notifications.append(f"{item_name}: Congratulations! You placed a bid of {bid_amount}.")
        self.notifications_accepted = True

    def notify_invalid_bid(self, item_name, bid_amount):
        self.notifications.append(f"{item_name}: Your bid of {bid_amount} is too low. Please place a higher bid.")
        self.notifications_invalid = True

    def notify_invalid_bid(self, item_name, bid_amount, minimum_bid):
        self.notifications.append(f"{item_name}: Your bid of {bid_amount} is too low. The minimum bid is {minimum_bid}. Please place a higher bid.")
        self.notifications_invalid = True



def load_items_from_file():
    try:
        with open('items.json', 'r') as file:
            data = json.load(file)
            items = []
            for item_data in data:
                item = AuctionItem(
                    item_data['name'],
                    item_data['starting_price'],
                    datetime.fromisoformat(item_data['end_time']),
                    item_data['image_filename'],
                    item_data['description'],
                )
                item.current_price = item_data['current_price']
                item.time_increases = item_data.get('time_increases', 0)
                items.append(item)
            return items
    except FileNotFoundError:
        return []



def save_items_to_file(items):
    data = []
    for item in items:
        item_data = {
            'name': item.name,
            'starting_price': item.starting_price,
            'current_price': item.current_price,
            'highest_bidder': item.highest_bidder.name if item.highest_bidder else None,
            'end_time': item.end_time.isoformat(),
            'image_filename': item.image_url.split('/')[-1],
            'description': item.description,
            'time_increases': item.time_increases,
        }
        data.append(item_data)
    with open('items.json', 'w') as file:
        json.dump(data, file, indent=4)



items = load_items_from_file()


@app.after_request
def save_items(response):
    save_items_to_file(items)
    return response





@app.route('/', methods=['GET', 'POST'])
def auction():
    if not items:
        return redirect(url_for('empty_auction'))

    if request.method == 'POST':
        item_index = int(request.form['item_index'])
        bid_amount = int(request.form['bid_amount'])
        bidder_name = request.form['bidder_name']

        if item_index < len(items):
            item = items[item_index]

            if bidder_name:
                bidder = Bidder(bidder_name)
                if not item.is_expired():
                    item.place_bid(bidder, bid_amount)
            else:
                error_message = 'Bidder name is required.'
                return render_template('auction.html', items=items, error_message=error_message)

        else:
            return redirect(url_for('auction'))  # Redirect to the auction page if the index is invalid

    else:
        item_index = 0
        item = items[item_index]
        bidder = None

    return render_template('auction.html', items=items, item=item, bidder=bidder, item_index=item_index)


@app.route('/empty')
def empty_auction():
    return render_template('empty.html')
    
@app.route('/admin', methods=['GET', 'POST'])
def admin():
    global admin_authenticated
    if not admin_authenticated:
        return redirect(url_for('login'))

    if request.method == 'POST':
        name = request.form['name']
        starting_price = int(request.form['starting_price'])
        end_time = datetime.strptime(request.form['end_time'], '%Y-%m-%dT%H:%M')
        description = request.form['description']


        image_file = request.files['image_file']
        if image_file and allowed_file(image_file.filename):
            # Generate a unique filename
            filename = secure_filename(image_file.filename)
            image_file.save(os.path.join(app.config['UPLOAD_FOLDER'], secure_filename(image_file.filename)))
            image_filename = filename
        else:
            image_filename = ''  # Set a default value if no file is uploaded or the file type is not allowed

        item = AuctionItem(name, starting_price, end_time, image_filename, description)
        items.append(item)
        return redirect(url_for('admin'))

    return render_template('admin.html', items=items, enumerate=enumerate)


@app.route('/login', methods=['GET', 'POST'])
def login():
    global admin_authenticated

    if request.method == 'POST':
        password = request.form.get('password')
        if password == ADMIN_PASSWORD:
            admin_authenticated = True
            return redirect(url_for('admin'))

        # Password is incorrect, display an error message
        error_message = 'Invalid password'
        return render_template('login.html', error_message=error_message)

    # GET request, display the login form
    return render_template('login.html')


@app.route('/delete', methods=['POST'])
def delete():
    item_index = int(request.form['item_index'])
    if item_index < len(items):
        del items[item_index]
    return redirect(url_for('admin'))
    

if __name__ == "__main__":
    app.run(debug=True, port=80, host='0.0.0.0')
