import os
import json


class FileList:
    def __init__(self, root_dir):
        self.root_dir = root_dir

    def __str__(self):
        fileString = ""
        for fillename in os.listdir(self.root_dir):
            fileString = fileString + fillename + "\n"
        return fileString

    def to_json(self):
        listing_array = []
        for filename in os.listdir(self.root_dir):
            listing_array.append({
                'name': filename,
                'type': 'directory' if os.path.isdir(os.path.join(self.root_dir, filename)) else 'file'
            })
        return json.dumps(listing_array)


class BackupIO:
    def __init__(self):
        self.backup_local = 'backup_log.json'

    def localDirectoryContents(self, dir):
        print(f"LISITNG REQUESTED: {dir}")
        dir_object = FileList(dir)
        return dir_object.to_json()

    def loadBackupServer(self):
        try:
            conts = json.load(open(self.backup_local))
        except json.decoder.JSONDecodeError:
            print("INVALID FILE")
            conts = '{"folder": "None"}'
        return conts

    def saveBackupServer(self, new_conts):
        new_conts = json.loads(new_conts)
        try:
            conts = self.loadBackupServer()
            new_conts = {**conts, **new_conts}
        except FileNotFoundError:
            pass

        json.dump(new_conts, open(self.backup_local, 'w'))
