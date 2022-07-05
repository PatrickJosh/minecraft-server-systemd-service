# This repository has been migrated to codeberg.org
See [here](https://codeberg.org/PatrickJosh/minecraft-server-systemd-service).

# Minecraft Server Systemd Service Configuration

This repository contains all files needed to set up a systemd-service for running a Minecraft server on a machine 
running Fedora Linux as well as an explanation how to set it up.
During the setup, a new user will be created which is used to run the Minecraft server.
Moreover, a firewalld-configuration will be created to allow the Minecraft server to communicate through the firewall.

Probably, there is also a way to use these files to set up a systemd-service on another distribution, but certain steps 
might differ as e.g. the paths may not be the same on each Linux distribution.

## Configuration and usage

### Prerequisites
Some extra software needs to be installed (apart from the software carried out by a default Fedora Linux Server
installation):

- zsh
- mcrcon
- java-latest-openjdk-headless

All of these are available via dnf:
```shell
# dnf install zsh mcrcon java-17-openjdk-headless
```

### Setting up the systemd-service
1. Create a new group for the new minecraft user:
```shell
# groupadd -r minecraft
```

2. Create a new user called `minecraft` for the server. 
You can choose a different home directory, but then you have to edit the systemd-service file.
```shell
# useradd -r -g minecraft -d "/var/minecraft" -s "/bin/zsh" minecraft
```

3. Create the folders `/var/minecraft` and `/var/minecraft/minecraft-server`
```shell
# mkdir -p /var/minecraft/minecraft-server
```
4. Copy `start.sh` from this repository to `/var/minecraft/minecraft-server` and adjust its permissions. 
Assuming you have already copied it there:
```shell
# chown root:root /var/minecraft/minecraft-server/start.sh
# chmod 755 /var/minecraft/minecraft-server/start.sh
# semanage fcontext -a -f bin_t '/var/minecraft/minecraft-server/start.sh'
# restorecon -v /var/minecraft/minecraft-server/start.sh 
```
5. Copy `minecraft.xml` to `/etc/firewalld/services` and execute:
```shell
# firewall-cmd --reload
```
6. Copy `minecraft-server@.service` to `/etc/systemd/system`, replace `<RCON_PASSWORD>` with a chosen password and 
execute:
```shell
# systemctl daemon-reload
```

Now you have set up everything to create new minecraft servers. How you can do that is explained in the next section.

### Creating new Minecraft servers
1. Create a subfolder of `/var/minecraft/minecraft-server` with a chosen name without spaces or special characters 
(in the following referred to as `<name>`) and set its rights properly:
```shell
# chown -R minecraft:minecraft /var/minecraft/minecraft-server/<name>
```
2. Download the Minecraft server software which you would like to run and place it as `server.jar` inside of
`/var/minecraft/minecraft-server/<name>`. If you already have a server that was run elsewhere, then just copy the files
into the new location and go directly to step 4.
3. Start the new server once to let it generate the EULA file, accept the EULA as usual, and then run it another time
to let it generate all needed files such as `server.properties`. Run the server (both times) by using:
```shell
$ sudo -u minecraft /usr/lib/jvm/jre-17/bin/java -Xmx4096M -Xms1024M -jar server.jar nogui
```
4. Open the `server.properties` with your favourite editor and enter the RCON password which you set in the initial 
setup and enable RCON.
```properties
enable-rcon=true
rcon.password=<RCON_PASSWORD>
```

You are now all set to run your new server via systemd.

### Using the service

Start the server by using
```shell
# systemctl start minecraft-server@<name>.service
```
Stop the server by using
```shell
# systemctl stop minecraft-server@<name>.service
```
The service is configured to stop the server gracefully.

You should only run one server at a time as they are configured to use the same ports.

### Advanced configuration options
#### Server resource pack
If you set a server resource pack in your `server.properties`, on every start the pack will be downloaded and the hash
of the zip-file gets recalculated and put into the `server.properties` before the start of the server.
On this way, you can edit your server resource pack and the clients will automatically re-download it as the hash
changed.
Note that it can be necessary for clients to connect to the server twice to apply the new pack if it was changed.
If you do not want this behaviour, just remove the corresponding section from `start.sh`.

## Other projects
If you use the Telegram Messenger, you might be interested in
[another project of me](https://codeberg.org/PatrickJosh/minecraft-server-telegram-bot).
With it, you can start and stop your Minecraft servers via a Telegram bot.
You can also mirror your chat messages from Minecraft into Telegram and vice versa!

## Licencing
The files in this repository are licenced under the terms of the Apache License, Version 2.0.

Copyright 2022 Joshua Noeske

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
