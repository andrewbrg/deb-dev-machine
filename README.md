# Debian 10 Developer Machine

Quickly install common developer tools, runtimes, bootstrappers, IDEs & other related goodies on Debian 10. If you work in PHP, NodeJS or GoLang you should be pretty much catered for.

In order to use the installer run the following:

```shell
cd ~/
sudo apt install -y wget && bash <(wget -qO- https://raw.githubusercontent.com/andrewbrg/deb-dev-machine/master/setup.sh);
```

Select the tools you want to install via the menu, hit enter and go grab a coffee.

__Please Note__: Do NOT run this script with sudo as it will install things under the root user, run it as your own user...

![Screenshot 2021-08-22 01 35 45](https://user-images.githubusercontent.com/5937311/130337388-1f37033b-065b-4375-96c1-b4778c5a17e4.png)

If needed, the versions of certain installations can be set via the configuration at the top of the bash file prior to executing the installer.

This script should also work on other Linux flavors (at least most packages) which use `apt` as their main package manager (for example Ubuntu). Doing so is however untested at this point.

Tested on Linux Debian 10 as well as ChromeOS Crouton/Crostini Debian 10 containers.

__Total installation size (including the OS) is ~6.5GB__

__Base OS Packages__

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

__Code Versioning__

- Git
- Git Cola

__Languages__

- PHP
- GoLang
- NodeJS with NPM

__Package Managers__

- Composer

__Webservers__

- Nginx
- Apache2

__Code Packaging__

- Webpack
- Yarn

__CLI Bootsrappers__

- Create React Native
- Create React App
- Gatsby CLI
- Apache Cordova
- Laravel Installer
- Symfony Installer

__Software Managers__

- Wine
- Snap

__Databases & Database Tools__

- Redis
- Memcached
- MySQL Community Server
- MongoDb
- Redis Desktop Manager
- DBeaver
- SQLite Browser

__Containerisation, Deployment, CI & Security__

- Docker CE
- Docker Compose
- Kubectl
- Helm
- Werf
- Sops

__Helper Utilities__

- Google Cloud SDK
- Locust
- Postman

__OS Maintenance__

- Bleachbit
- Remmina Remote Desktop
- Stacer

__Browsers & Entertainment__

- Tor Browser [installs to /opt/]
- Popcorn Time

__IDEs__

- Jetbrains Toolbox [installs to /opt/]
- Atom
- Visual Studio Code
