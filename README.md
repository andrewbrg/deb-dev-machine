# Debian 9 Developer Machine
Quickly install common Developer tools, IDEs &amp; services on Debian 9. In order to use the installer run the following:

<p align="center">
  <img src="https://i.ibb.co/FsznYFn/Screenshot-2018-12-09-at-11-44-06.png" />
</p>

__Note__: Please do NOT run the script with sudo, run it as your own user!

```
cd ~/
sudo apt install -y wget && bash <(wget -qO- https://raw.githubusercontent.com/andrewbrg/deb9-dev-machine/master/setup.sh);
```

This script can be run via the terminal and will get a fresh debian installation up and running with most (if not all) of the dev tools you would require.

Tested on Debian 9 stretch installations as well as the ChromeOS linux Debian containers. **Total installation size including the OS itself is ~7GB**

You can expect the following to be automatically installed and readily accessable:

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
- snapd _(may not work on chromebook devices)_
- Zsh
- Oh my Zsh

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

**Then do the following:**

1. Hash out _(comment out)_ the `ExecSartPre` line from: `/lib/systemd/system/containerd.service`

```
sudo vim /lib/systemd/system/containerd.service;
```

2. Install separate runc environment

```
sudo apt install libseccomp-dev -y;
go get -v github.com/opencontainers/runc;

cd $GOPATH/src/github.com/opencontainers/runc;
make BUILDTAGS='seccomp apparmor';

sudo ln -s $(realpath ./runc) /usr/local/bin/runc-master;
```

3. Point docker runc to the new environment

```
sudo mkdir /etc/docker;
sudo touch /etc/docker/daemon.json;
sudo vim /etc/docker/daemon.json;
```

```json
{
  "runtimes": {
    "runc-master": {
      "path": "/usr/local/bin/runc-master"
    }
  },
  "default-runtime": "runc-master"
}
```

4. Restart the docker services

```
sudo systemctl daemon-reload;
sudo systemctl restart containerd.service;
sudo systemctl restart docker;
```

5. Test the installation

```
docker run hello-world;
```
