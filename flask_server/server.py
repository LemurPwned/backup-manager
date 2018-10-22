from flask import Flask
from flask import request
from backupIO import *

app = Flask(__name__)
io = BackupIO()


@app.route('/')
def hello_world():
    return 'Backup manager'


@app.route('/getDirectoryListing')
def getListing():
    req = request.args.get('root_dir')
    print(req)
    listing = io.localDirectoryContents(str(req))
    print(listing)
    return listing


@app.route('/addBackupFolder', methods=['POST'])
def parse_request():
    data = request.data  # data is empty
    # need posted data here
    print(str(data))
    io.saveBackupServer(data)
    return '200'


@app.route('/getBackupFolders')
def get_backup_folder():
    # need posted data here
    folders = io.loadBackupServer()
    return folders


if __name__ == "__main__":
    app.run(host='0.0.0.0')
    app.run(debug=True)
