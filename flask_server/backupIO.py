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

    def contentLoad(self):
        if self.preloaded:
            return json.dumps(self.backup_data['backup_dirs'])
        else:
            return None

    def updateContent(self, new_content):
        if self.preloaded:
            new_content = json.loads(new_content)
            nkey = new_content['name']
            if (nkey not in self.backup_data['backup_dirs'].keys()):
                self.backup_data['backup_dirs'][nkey] = new_content
        else:
            self.addContent(new_content)

    def addContent(self, new_content):
        new_content = json.loads(new_content)
        print(new_content)
        self.backup_data = {'backup_dirs': {
            new_content['name']: new_content}}
        json.dump(self.backup_data,
                  open(self.backup_local, 'w'))
        self.preloaded = True

    def deleteContent(self, to_delete):
        if self.preloaded:
            # do preloaded
            deleted = self.backup_data['backup_dirs'].pop(to_delete, None)
            print(f"Deleted {deleted} of {to_delete}")
        else:
            print("CANNOT DELETE EMPTY")

    def localDirectoryContents(self, dir):
        dir_object = FileList(dir)
        return dir_object.to_json()
