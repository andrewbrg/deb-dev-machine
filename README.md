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

This script can be run via the terminal and will get a fresh Debian (Stretch or Buster) installation up and running with most (if not all) of the dev tools you would require.

Tested on Debian installations as well as the ChromeOS Crostini Debian containers. **Total installation size including the OS itself is ~6.5GB**

You can expect the following to be automatically installed and readily accessible:

**Utilities**
- ca-certificates
- apt-transport-https
- software-properties-common
- wget
- htop
- gnupg2
- curl
- nano
- vim
- wine
- snap

**Services**
- Git
- PHP
- MySQL Community Server
- Composer
- GoLang
- Werf
- Redis
- Node & NPM
- Yarn
- Docker
- Docker Compose
- Kubectl
- Helm
- Sops

**Libraries**
- Apache Cordova
- React Native
- Laravel Installer
- Symfony Installer
- Google Cloud SDK

**Software**
- Postman
- DBeaver
- SQLite Browser
- Redis Desktop Manager
- Jetbrains Toolbox App
- Atom IDE
- VS Code IDE
- Remmina Remote Desktop
- Locust
- Stacer
