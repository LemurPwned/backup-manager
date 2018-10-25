from flask import Flask
from flask import request, Response
from backupIO import *

app = Flask(__name__)
io = BackupIO()


@app.route('/')
def backup_greeting():
    return 'Backup manager'


@app.route('/getDirectoryListing')
def getListing():
    req = request.args.get('root_dir')
    listing = io.localDirectoryContents(str(req))
    return listing


@app.route('/addBackupFolder', methods=['POST'])
def parse_request():
    data = request.data  # data is empty
    # need posted data here
    print(str(data))
    io.updateContent(data)
    return '200'


@app.route('/getBackupFolders')
def get_backup_folder():
    # need posted data here
    folders = io.contentLoad()
    if folders is None:
        return Response("null", status='404', mimetype='application/json')
    return folders


@app.route('/manageBackupFolder')
def manage_backup():
    # need posted data here
    folder_to_change = request.args.get('change')
    to_delete = request.args.get('to_delete')
    folder = request.args.get('folder')
    encrypt = request.args.get('encrypted')
    if folder_to_change is not None and folder_to_change != '':
        io.changeBackupFolder(str(folder_to_change))
        return '200'
    if to_delete is not None and to_delete != '':
        io.deleteContent(str(to_delete))
        return '200'
    if folder is not None and folder != '':
        print(str(folder))
        io.backupContent(str(folder), encrypt)
        return '200'
    else:
        return '404'


if __name__ == "__main__":
    app.run(host='0.0.0.0')
    app.run(debug=True)
