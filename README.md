# backup-manager
Backup manager in flutter for your phone app and Raspberry sync. 
The Raspberry PI has a flask server that connects to the app via local network 

# APP 
The mobile backup application interface is written in Flutter. It has rather simple interface with no special effects.

# Flask server 
This still uses the Flask instead of FastAPI but it is enough to have my backup managed in a simple way. The backup is uploaded in compressed `.zip` files.
Backup dirs should point to some mounted NFS or hard drive. 
