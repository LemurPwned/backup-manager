import os
import json
import datetime
import subprocess


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
        self.backup_dst = 'BACKUPS'
        try:
            self.backup_data = json.load(open(self.backup_local, 'r'))
            self.preloaded = True
        except FileNotFoundError:
            self.preloaded = False
        # create the backup folder if necessary
        if not os.path.isdir(self.backup_dst):
            os.mkdir(self.backup_dst)

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
                self.snapshotDict()
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

    def snapshotDict(self):
        json.dump(self.backup_data,
                  open(self.backup_local, 'w'))

    def backupContent(self, folder, encrypted):
        if self.preloaded:
            print(
                f"Having the folder {folder}, encrypted: {encrypted} in {self.backup_dst}")
            # update the local dict
            try:
                savename = os.path.join(self.backup_dst,
                                        self.backup_data['backup_dirs'][folder]['name'])
                if encrypted is not None and encrypted != '':
                    self.save_encrypted(folder, savename, encrypted)
                else:
                    self.save_standard(folder, savename)
            except KeyError:
                print("TRIED TO ACCESS DIRECTORY NOT IN BACKUP DIRS")
            self.snapshotDict()
        else:
            print("BACKUPS NOT PRELOADED")

    def changeBackupFolder(self, folder):
        self.backup_dst = folder
        if not os.path.isdir(self.backup_dst):
            os.mkdir(self.backup_dst)

    def localDirectoryContents(self, dir):
        dir_object = FileList(dir)
        return dir_object.to_json()

    def save_standard(self, folder, savename):
        # zip secure.zip file
        # zip -r secure.zip /var/log/
        if (os.path.isdir(self.backup_data['backup_dirs'][folder]['absolutePath'])):
            subprocess.run(
                ['zip', '-r', f"{savename}.zip", self.backup_data['backup_dirs'][folder]['absolutePath']])
        else:
            subprocess.run(
                ['zip', f"{savename}.zip", self.backup_data['backup_dirs'][folder]['absolutePath']])
        self.backup_data['backup_dirs'][folder]['last_backup'] = str(datetime.datetime.now()
                                                                     )
        self.backup_data['backup_dirs'][folder]['encrypted'] = False

    def save_encrypted(self, folder, savename, password):
        # zip -P passw0rd secure.zip file
        # zip -P passw0rd -r secure.zip /var/log/
        if (os.path.isdir(self.backup_data['backup_dirs'][folder]['absolutePath'])):
            subprocess.run(['zip', '-P', password, '-r',
                            f"{savename}.zip", self.backup_data['backup_dirs'][folder]['absolutePath']])
        else:
            subprocess.run(
                ['zip',  '-P', password, f"{savename}.zip", self.backup_data['backup_dirs'][folder]['absolutePath']])
        self.backup_data['backup_dirs'][folder]['last_backup'] = str(datetime.datetime.now()
                                                                     )
        self.backup_data['backup_dirs'][folder]['encrypted'] = True
