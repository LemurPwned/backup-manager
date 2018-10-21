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
        pass

    def localDirectoryContents(self, dir):
        print(f"LISITNG REQUESTED: {dir}")
        dir_object = FileList(dir)
        return dir_object.to_json()
