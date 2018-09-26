# Debian 9 Developer Machine
Quickly install common Developer tools, IDEs &amp; services on Debian 9. In order to use the installer run the following:

__Note__: Please do NOT run the script with sudo, run it as your own user!

```
cd ~/
sudo apt install -y wget
wget https://raw.githubusercontent.com/andrewbrg/deb9-dev-machine/master/setup.sh -O setup.sh;
bash setup.sh;
rm setup.sh;
```

This script can be run via the terminal and will get a fresh debian installation up and running with most (if not all) of the dev tools you would require.

Tested on Debian 9 stretch installations as well as the ChromeOS linux Debian containers.

You can expect the following to be automatically insalled and readily accessable:

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
- wine
- gnome-software
- gnome-packagekit

**Services**
- Git
- PHP version 7.2
- Composer
- Ruby
- Python
- Memcahed
- Redis
- Node 8
- Yarn
- Docker
- Docker Compose
- Kubernetes
- MySQL community server v8.0.10+

**Libraries**
- Apache Cordova
- Phone Gap
- React Native
- Laravel Installer

**Software**
- Postman
- Firefox
- DBeaver
- SQLite Browser
- Sublime Text (with material theme and plugins)
- PHPStorm 2018.2.2

