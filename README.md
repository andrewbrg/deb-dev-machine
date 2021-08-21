# Debian 10 Developer Machine
Quickly install common Developer tools, IDEs &amp; services on Debian 10. In order to use the installer run the following:

<p align="center">
  <img src="https://i.ibb.co/FmTqMVN/Screenshot-2021-06-17-21-12-09.png" />
</p>

__Note__: Please do NOT run the script with sudo, run it as your own user!

```
cd ~/
sudo apt install -y wget && bash <(wget -qO- https://raw.githubusercontent.com/andrewbrg/deb-dev-machine/master/setup.sh);
```

This script can be run via the terminal and will get a fresh Debian 10 (Buster) installation up and running with most (if not all) of the dev tools you would require.

Tested on Debian 10 installations as well as the ChromeOS Crostini Debian 10 containers. **Total installation size including the OS itself is ~6.5GB**

You can expect the following to be automatically installed and readily accessible:

**Utilities**
- ca-certificates
- apt-transport-https
- software-properties-common
- gnupg
- gnupg2
- wget
- curl
- nano
- vim
- htop

**Languages**
- PHP
- GoLang
- Node & NPM

**Dev Tools**
- Git
- Nginx
- Apache2
- Composer
- Werf
- Yarn
- Docker
- Docker Compose
- Kubectl
- Helm
- Sops
- Apache Cordova
- React Native
- Laravel Installer
- Symfony Installer

**Databases**
- Redis
- MySQL Community Server
- MongoDb
- SQLite Browser
- Redis Desktop Manager
- DBeaver

**Software**
- Jetbrains Toolbox App -> Installs to /opt/
- Atom IDE
- VS Code IDE
- Wine
- Snap
- Postman
- Remmina Remote Desktop
- Locust
- Stacer
- Tor Browser
- Google Cloud SDK
