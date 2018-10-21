from flask import Flask
from flask import request
from backupIO import *

app = Flask(__name__)
io = BackupIO()


@app.route('/')
def hello_world():
    return 'Backup manager'


@app.route('/data')
def data():
    # here we want to get the value of user (i.e. ?user=some-value)
    user = request.args.get('user')
    return user


@app.route('/getBackupStatus')
def backupStatus():
    # here we want to get the value of user (i.e. ?user=some-value)
    backupStatus = request.args.get('user')
    req = request.query_string
    return backupStatus


@app.route('/getDirectoryListing')
def getListing():
    req = request.args.get('root_dir')
    print(req)
    listing = io.localDirectoryContents(str(req))
    print(listing)
    return listing


if __name__ == "__main__":
    app.run(host='0.0.0.0')
    app.run(debug=True)
