# Debian 10 Developer Machine
Quickly install common Developer tools, IDEs &amp; services on Debian 10. In order to use the installer run the following:

__Note__: Please do NOT run the script with sudo, run it as your own user!

```
cd ~/
sudo apt install -y wget && bash <(wget -qO- https://raw.githubusercontent.com/andrewbrg/deb-dev-machine/master/setup.sh);
```

![Screenshot 2021-08-22 01 35 45](https://user-images.githubusercontent.com/5937311/130337388-1f37033b-065b-4375-96c1-b4778c5a17e4.png)

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
- NodeJS with NPM

**Dev Tools**
- Git
- Git Cola
- Nginx
- Apache2
- Composer
- Werf
- Yarn
- Docker CE
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
- Memcached
- MySQL Community Server
- MongoDb
- SQLite Browser
- Redis Desktop Manager
- DBeaver

**Software**
- Tor Browser [installs to /opt/]
- Jetbrains Toolbox [installs to /opt/]
- Atom
- Visual Studio Code
- Wine
- Snap
- Google Cloud SDK
- Locust
- Postman
- Bleachbit
- Remmina Remote Desktop
- Stacer
