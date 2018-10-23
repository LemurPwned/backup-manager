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
        try:
            self.backup_data = json.load(open(self.backup_local, 'r'))
            self.preloaded = True
        except FileNotFoundError:
            self.preloaded = False

    def contentLoad(self, dir):
        if self.preloaded:
            pass
        else:
            # create new
            pass

    def addContent(self, new_content):
        if self.preloaded:
            # do preloaded
            pass
        else:
            # create new
            pass

    def deleteContent(self, to_delete):
        if self.preloaded:
            # do preloaded
            pass
        else:
            # create new
            pass

    def localDirectoryContents(self, dir):
        print(f"LISITNG REQUESTED: {dir}")
        dir_object = FileList(dir)
        return dir_object.to_json()

    def loadBackupServer(self):
        try:
            conts = json.load(open(self.backup_local))
        except (json.decoder.JSONDecodeError, FileNotFoundError):
            return None
        return json.dumps(conts['backup_dirs'])

    def saveBackupServer(self, new_conts):
        new_conts = json.loads(new_conts)
        try:
            old_conts = json.load(open(self.backup_local))
            try:
                if (new_conts['name'] not in old_conts['backup_dirs'].keys()):
                    old_conts['backup_dirs'][new_conts['name']] = new_conts
                    json.dump(old_conts, open(self.backup_local, 'w'))
            except KeyError:
                # no such key in the list
                pass
        except FileNotFoundError:
            json.dump({'backup_dirs': {new_conts['name']: new_conts}},
                      open(self.backup_local, 'w'))

    def deleteBackupFoldr(self, folder):
        try:
            old_conts = json.load(open(self.backup_local))
            deleted = old_conts['backup_dirs'].pop(folder, None)
            print(f"Deleted {deleted} of {folder}")
            json.dump(old_conts, open(self.backup_local, 'w'))
        except FileNotFoundError:
            pass
