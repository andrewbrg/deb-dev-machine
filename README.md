# Debian Developer Machine
Quickly install common Developer tools, IDEs &amp; services on Debian. In order to use the installer run the following:

<p align="center">
  <img src="https://i.ibb.co/FmTqMVN/Screenshot-2021-06-17-21-12-09.png" />
</p>

__Note__: Please do NOT run the script with sudo, run it as your own user!

```
cd ~/
sudo apt install -y wget && bash <(wget -qO- https://raw.githubusercontent.com/andrewbrg/deb-dev-machine/master/setup.sh);
```

This script can be run via the terminal and will get a fresh Debian installation up and running with most (if not all) of the dev tools you would require.

Tested on Debian installations as well as the ChromeOS linux Debian containers. **Total installation size including the OS itself is ~7GB**

You can expect the following to be automatically installed and readily accessible:

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
- wine _(with Royale2007 theme & Smooth fonts)_
- mono
- gnome-software
- gnome-packagekit
- snapd _(may not work on chromebook devices)_
- Zsh
- Oh my Zsh

**Services**
- Git
- PHP
- MySQL Community Server
- Composer
- Ruby
- Python
- GoLang
- Pip
- Werf
- Memcached
- Redis
- Node & NPM
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
- Sublime Text IDE _(with material theme and dev plugins)_
- PHPStorm IDE
- Atom IDE
- VS Code IDE
- Remmina Remote Desktop Client
- Locust

## Issues with Docker in ChromeOS?

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
