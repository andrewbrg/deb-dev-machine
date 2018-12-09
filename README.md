# Debian 9 Developer Machine
Quickly install common Developer tools, IDEs &amp; services on Debian 9. In order to use the installer run the following:

![GUI Preview](https://preview.ibb.co/iU3DDe/options.jpg)

__Note__: Please do NOT run the script with sudo, run it as your own user!

```
cd ~/
sudo apt install -y wget && bash <(wget -qO- https://raw.githubusercontent.com/andrewbrg/deb9-dev-machine/master/setup.sh);
```

This script can be run via the terminal and will get a fresh debian installation up and running with most (if not all) of the dev tools you would require.

Tested on Debian 9 stretch installations as well as the ChromeOS linux Debian containers.

You can expect the following to be automatically installed and readily accessable:

**Total installation size including the OS itself is approx. 7GB**

**Utilities**
- ca-certificates
- apt-transport-https
- software-properties-common
- wget
- htop
- mlocate
- gnupg2
- cmake
- libssh2-1-dev
- libssl-dev
- curl
- nano
- vim
- gksu
- preload
- wine _(with Royale2007 Theme & Smooth fonts)_
- mono
- gnome-software
- gnome-packagekit
- snapd

**Services**
- Git
- PHP version 7.2
- Composer
- Ruby
- Python
- GoLang
- Pip
- Dapp
- Memcahed
- Redis
- Node 8
- Yarn
- Docker
- Docker Compose
- Kubernetes
- Helm
- Sops

**Libraries**
- Apache Cordova
- Phone Gap
- React Native
- Laravel Installer
- Google Cloud SDK

**Software**
- Postman
- DBeaver
- SQLite Browser
- Redis Desktop Manager
- Software center
- Package updater
- Sublime Text (with material theme and plugins)
- PHPStorm 2018.2.2
- Atom IDE
- VS Code IDE
- Remmina Remote Desktop Client

## Issues with Docker in ChromeOS

If docker gives the following error when starting (check `sudo journalctl -xe`):

```
modprobe: ERROR: ../libkmod/libkmod.c:586 kmod_search_moddep() could not open moddep file '/lib/modules/4.14.74-0777
```

The do the following:

Hash out (comment out) the ExecSartPre line from `/lib/systemd/system/containerd.service`

```
sudo vim /lib/systemd/system/containerd.service
```

Then restart the docker services

```
sudo systemctl daemon-reload
sudo systemctl restart containerd.service
sudo systemctl restart docker
```
