#!/usr/bin/env bash

###############################################################
## PACKAGE VERSIONS - CHANGE AS REQUIRED
###############################################################
versionPhp="7.3";
versionGo="1.12.9";
versionHelm="2.14.1";
versionSops="3.1.1";
versionDapp="0.27.14";
versionNode="12";
versionPopcorn="0.3.10";
versionPhpStorm="2019.3.3";
versionDockerCompose="1.24.1";

# Disallow running with sudo or su
##########################################################
if [[ "$EUID" -eq 0 ]]
  then printf "\033[1;101mNein, Nein, Nein!! Please do not run this script as root (no su or sudo)! \033[0m \n";
  exit;
fi

###############################################################
## HELPERS
###############################################################
title() {
    printf "\033[1;42m";
    printf '%*s\n'  "${COLUMNS:-$(tput cols)}" '' | tr ' ' ' ';
    printf '%-*s\n' "${COLUMNS:-$(tput cols)}" "  # $1" | tr ' ' ' ';
    printf '%*s'  "${COLUMNS:-$(tput cols)}" '' | tr ' ' ' ';
    printf "\033[0m";
    printf "\n\n";
}

breakLine() {
    printf "\n";
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -;
    printf "\n\n";
    sleep .5;
}

notify() {
    printf "\n";
    printf "\033[1;46m $1 \033[0m \n";
}

curlToFile() {
    notify "Downloading: $1 ----> $2";
    sudo curl -fSL "$1" -o "$2";
}

###############################################################
## REGISTERED VARIABLES
###############################################################
installedGo=0;
installedZsh=0;
installedPhp=0;
installedNode=0;
installedSublime=0;
installedMySqlServer=0;
repoUrl="https://raw.githubusercontent.com/andrewbrg/deb9-dev-machine/master/";

###############################################################
## REPOSITORIES
###############################################################

# PHP
##########################################################
repoPhp() {
    if [[ ! -f /etc/apt/sources.list.d/php.list ]]; then
        notify "Adding PHP sury repository";
        curl -fsSL "https://packages.sury.org/php/apt.gpg" | sudo apt-key add -;
        echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list;
    fi
}

# Yarn
##########################################################
repoYarn() {
    if [[ ! -f /etc/apt/sources.list.d/yarn.list ]]; then
        notify "Adding Yarn repository";
        curl -fsSL "https://dl.yarnpkg.com/debian/pubkey.gpg" | sudo apt-key add -;
        echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list;
    fi
}

# Docker CE
##########################################################
repoDocker() {
    if [[ ! -f /var/lib/dpkg/info/docker-ce.list ]]; then
        notify "Adding Docker repository";
        curl -fsSL "https://download.docker.com/linux/debian/gpg" | sudo apt-key add -;
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable";
    fi
}

# Kubernetes
##########################################################
repoKubernetes() {
    if [[ ! -f /etc/apt/sources.list.d/kubernetes.list ]]; then
        notify "Adding Kubernetes repository";
        curl -fsSL "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | sudo apt-key add -;
        echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list;
    fi
}

# Wine
##########################################################
repoWine() {
    if [[ ! -f /var/lib/dpkg/info/wine-stable.list ]]; then
        notify "Adding Wine repository";
        sudo dpkg --add-architecture i386;
        curl -fsSL "https://dl.winehq.org/wine-builds/winehq.key" | sudo apt-key add -;
        curl -fsSL "https://dl.winehq.org/wine-builds/Release.key" | sudo apt-key add -;
        sudo apt-add-repository "https://dl.winehq.org/wine-builds/debian/";
    fi
}

# Atom
##########################################################
repoAtom() {
    if [[ ! -f /etc/apt/sources.list.d/atom.list ]]; then
        notify "Adding Atom IDE repository";
        curl -fsSL "https://packagecloud.io/AtomEditor/atom/gpgkey" | sudo apt-key add -;
        echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" | sudo tee /etc/apt/sources.list.d/atom.list;
    fi
}

# VS Code
##########################################################
repoVsCode() {
    if [[ ! -f /etc/apt/sources.list.d/vscode.list ]]; then
        notify "Adding VSCode repository";
        curl "https://packages.microsoft.com/keys/microsoft.asc" | gpg --dearmor > microsoft.gpg;
        sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/;
        echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list;
    fi
}

# Sublime
##########################################################
repoSublime() {
    if [[ ! -f /etc/apt/sources.list.d/sublime-text.list ]]; then
        notify "Adding Sublime Text repository";
        curl -fsSL "https://download.sublimetext.com/sublimehq-pub.gpg" | sudo apt-key add -;
        echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list;
    fi
}

# Remmina
##########################################################
repoRemmina() {
    if [[ ! -f /etc/apt/sources.list.d/remmina.list ]]; then
        notify "Adding Remmina repository";
        sudo touch /etc/apt/sources.list.d/remmina.list;
        echo "deb http://ftp.debian.org/debian stretch-backports main" | sudo tee --append /etc/apt/sources.list.d/stretch-backports.list >> /dev/null
    fi
}

# Google Cloud SDK
##########################################################
repoGoogleSdk() {
    if [[ ! -f /etc/apt/sources.list.d/google-cloud-sdk.list ]]; then
        notify "Adding GCE repository";
        export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)";
        echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list;
        curl -fsSL "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | sudo apt-key add -;
    fi
}

# VLC
##########################################################
repoVlc() {
    if [[ ! -f /etc/apt/sources.list.d/videolan-ubuntu-stable-daily-disco.list ]]; then
        notify "Adding VLC repository";
        sudo add-apt-repository ppa:videolan/stable-daily
    fi
}

# MySQL Community Server
##########################################################
repoMySqlServer() {
    if [[ ! -f /var/lib/dpkg/info/mysql-apt-config.list ]]; then
        notify "Adding MySQL Community Server repository";
        curlToFile "https://dev.mysql.com/get/mysql-apt-config_0.8.11-1_all.deb" "mysql.deb";
        sudo dpkg -i mysql.deb;

        /etc/apparmor.d/local
        echo 'y' | rm mysql.deb;
    fi
}


###############################################################
## INSTALLATION
###############################################################

# Debian Software Center
installSoftwareCenter() {
    sudo apt install -y gnome-software gnome-packagekit;
}

# Git
##########################################################
installGit() {
    title "Installing Git";
    sudo apt install -y git;
    breakLine;
}

# Node
##########################################################
installNode() {
    title "Installing Node ${versionNode}";
    curl -L "https://deb.nodesource.com/setup_${versionNode}.x" | sudo -E bash -;
    sudo apt install -y nodejs npm;
    sudo chown -R $(whoami) /usr/lib/node_modules;
    sudo chmod -R 777 /usr/lib/node_modules;
    installedNode=1;
    breakLine;
}

# React Native
##########################################################
installReactNative() {
    title "Installing React Native";
    sudo npm install -g create-react-native-app;
    breakLine;
}

# Cordova
##########################################################
installCordova() {
    title "Installing Apache Cordova";
    sudo npm install -g cordova;
    breakLine;
}

# Phonegap
##########################################################
installPhoneGap() {
    title "Installing Phone Gap";
    sudo npm install -g phonegap;
    breakLine;
}

# Webpack
##########################################################
installWebpack() {
    title "Installing Webpack";
    sudo npm install -g webpack;
    breakLine;
}

# PHP
##########################################################
installPhp() {
    title "Installing PHP ${versionPhp}";
    sudo apt install -y php${versionPhp} php${versionPhp}-{bcmath,cli,common,curl,dev,gd,intl,mbstring,mysql,sqlite3,xml,zip} php-pear php-memcached php-redis;
    sudo apt install -y libphp-predis php-xdebug php-ds;
    php --version;

    sudo pecl install igbinary ds;
    installedPhp=1;
    breakLine;
}

# Ruby
##########################################################
installRuby() {
    title "Installing Ruby with DAPP v${versionDapp}";
    sudo apt install -y ruby-dev gcc pkg-config;
    sudo gem install mixlib-cli -v 1.7.0;
    sudo gem install dapp -v ${versionDapp};
    breakLine;
}

# Python
##########################################################
installPython() {
    title "Installing Python & PIP";
    sudo apt install -y python-pip;
    curl "https://bootstrap.pypa.io/get-pip.py" | sudo python;
    sudo pip install --upgrade setuptools;
    breakLine;
}

# GoLang
##########################################################
installGoLang() {
    title "Installing GoLang ${versionGo}";
    curlToFile "https://dl.google.com/go/go${versionGo}.linux-amd64.tar.gz" "go.tar.gz";
    tar xvf go.tar.gz;

    if [[ -d /usr/local/go ]]; then
        sudo rm -rf /usr/local/go;
    fi

    sudo mv go /usr/local;
    echo "y" | rm go.tar.gz;

    echo 'export GOROOT="/usr/local/go"' >> ~/.bashrc;
    echo 'export GOPATH="$HOME/go"' >> ~/.bashrc;
    echo 'export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"' >> ~/.bashrc;

    source ~/.bashrc;
    mkdir ${GOPATH};
    sudo chown -R root:root ${GOPATH};

    installedGo=1;
    breakLine;
}

# Yarn
##########################################################
installYarn() {
    title "Installing Yarn";
    sudo apt install -y yarn;
    breakLine;
}

# Memcached
##########################################################
installMemcached() {
    title "Installing Memcached";
    sudo apt install -y memcached;
    sudo systemctl start memcached;
    sudo systemctl enable memcached;
    breakLine;
}

# Redis
##########################################################
installRedis() {
    title "Installing Redis";
    sudo apt install -y redis-server;
    sudo systemctl start redis;
    sudo systemctl enable redis;
    breakLine;
}

# Composer
##########################################################
installComposer() {
    title "Installing Composer";
    php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');";
    sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer;
    sudo rm /tmp/composer-setup.php;
    breakLine;
}

# Laravel Installer
##########################################################
installLaravel() {
    title "Installing Laravel Installer";
    composer global require "laravel/installer";
    echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' | tee -a ~/.bashrc;
    breakLine;
}

# SQLite Browser
##########################################################
installSqLite() {
    title "Installing SQLite Browser";
    sudo apt install -y sqlitebrowser;
    breakLine;
}

# DBeaver
##########################################################
installDbeaver() {
    title "Installing DBeaver SQL Client";
    sudo apt install -y \
    ca-certificates-java* \
    java-common* \
    libpcsclite1* \
    libutempter0* \
    openjdk-8-jre-headless* \
    xbitmaps*;

    curlToFile "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb" "dbeaver.deb";
    sudo dpkg -i ~/dbeaver.deb;
    sudo rm ~/dbeaver.deb;
    breakLine;
}

# Redis Desktop Manager
##########################################################
installRedisDesktopManager() {
    title "Installing Redis Desktop Manager";
    sudo snap install redis-desktop-manager;
    breakLine;
}

# Docker
##########################################################
installDocker() {
    title "Installing Docker CE with Docker Compose";
    sudo apt install -y docker-ce;
    curlToFile "https://github.com/docker/compose/releases/download/${versionDockerCompose}/docker-compose-$(uname -s)-$(uname -m)" "/usr/local/bin/docker-compose";
    sudo chmod +x /usr/local/bin/docker-compose;

    sudo groupadd docker;
    sudo usermod -aG docker ${USER};

    notify "Install a separate runc environment? (recommended on chromebooks)";

    while true; do
        read -p "(Y/n)" yn
        case ${yn} in
            [Yy]* )
                if [[ ${installedGo} -ne 1 ]] && [[ "$(command -v go)" == '' ]]; then
                    breakLine;
                    installGoLang;
                fi

                sudo sed -i -e 's/ExecStartPre=\/sbin\/modprobe overlay/#ExecStartPre=\/sbin\/modprobe overlay/g' /lib/systemd/system/containerd.service;

                sudo apt install libseccomp-dev -y;
                go get -v github.com/opencontainers/runc;

                cd ${GOPATH}/src/github.com/opencontainers/runc;
                make BUILDTAGS='seccomp apparmor';

                sudo cp ${GOPATH}/src/github.com/opencontainers/runc/runc /usr/local/bin/runc-master;

                curlToFile ${repoUrl}"docker/daemon.json" /etc/docker/daemon.json;
                sudo systemctl daemon-reload;
                sudo systemctl restart containerd.service;
                sudo systemctl restart docker;
            break;;
            [Nn]* ) break;;
            * ) echo "Please answer yes or no.";;
        esac
    done

    breakLine;
}

# Kubernetes
##########################################################
installKubernetes() {
    title "Installing Kubernetes";
    sudo apt install -y kubectl;
    breakLine;
}

# Helm
##########################################################
installHelm() {
    title "Installing Helm v${versionHelm}";
    curl -fsSl "https://storage.googleapis.com/kubernetes-helm/helm-v${versionHelm}-linux-amd64.tar.gz" -o helm.tar.gz;
    tar -zxvf helm.tar.gz;
    sudo mv linux-amd64/helm /usr/local/bin/helm;
    sudo rm -rf linux-amd64 && sudo rm helm.tar.gz;
    breakLine;
}

# Sops
##########################################################
installSops() {
    title "Installing Sops v${versionSops}";
    wget -O sops_${versionSops}_amd64.deb "https://github.com/mozilla/sops/releases/download/${versionSops}/sops_${versionSops}_amd64.deb";
    sudo dpkg -i sops_${versionSops}_amd64.deb;
    sudo rm sops_${versionSops}_amd64.deb;
    breakLine;
}

# Wine
##########################################################
installWine() {
    title "Installing Wine & Mono";
    sudo apt install -y cabextract;
    sudo apt install -y --install-recommends winehq-stable;
    sudo apt install -y mono-vbnc winbind;

    notify "Installing WineTricks";
    curlToFile "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" "winetricks";
    sudo chmod +x ~/winetricks;
    sudo mv ~/winetricks /usr/local/bin;

    notify "Installing Windows Fonts";
    winetricks allfonts;

    notify "Installing Smooth Fonts for Wine";
    curlToFile ${repoUrl}"wine_fontsmoothing.sh" "wine_fontsmoothing";
    sudo chmod +x ~/wine_fontsmoothing;
    sudo ./wine_fontsmoothing;
    clear;

    notify "Installing Royale 2007 Theme";
    curlToFile "http://www.gratos.be/wincustomize/compressed/Royale_2007_for_XP_by_Baal_wa_astarte.zip" "Royale_2007.zip";

    sudo chown -R $(whoami) ~/;
    mkdir -p ~/.wine/drive_c/Resources/Themes/;
    unzip ~/Royale_2007.zip -d ~/.wine/drive_c/Resources/Themes/;

    notify "Cleaning up...";
    echo "y" | rm ~/wine_fontsmoothing;
    echo "y" | rm ~/Royale_2007.zip;
}

# Postman
##########################################################
installPostman() {
    title "Installing Postman";
    curlToFile "https://dl.pstmn.io/download/latest/linux64" "postman.tar.gz";
    sudo tar xfz ~/postman.tar.gz;

    sudo rm -rf /opt/postman/;
    sudo mkdir /opt/postman/;
    sudo mv ~/Postman*/* /opt/postman/;
    sudo rm -rf ~/Postman*;
    sudo rm -rf ~/postman.tar.gz;
    sudo ln -s /opt/postman/Postman /usr/bin/postman;

    notify "Adding desktop file for Postman";
    curlToFile ${repoUrl}"desktop/postman.desktop" "/usr/share/applications/postman.desktop";
    breakLine;
}

# Atom IDE
##########################################################
installAtom() {
    title "Installing Atom IDE";
    sudo apt install -y atom;
    breakLine;
}

# VS Code
##########################################################
installVsCode() {
    title "Installing VS Code IDE";
    sudo apt install -y code;
    breakLine;
}

# Sublime Text
##########################################################
installSublime() {
    title "Installing Sublime Text";
    sudo apt install -y sublime-text;
    sudo apt install -y python-pip;
    sudo pip install -U CodeIntel;

    sudo chown -R $(whoami) ~/;

    mkdir -p ~/.config/sublime-text-3/Packages/User/;

    notify "Adding package control for sublime";
    wget "https://packagecontrol.io/Package%20Control.sublime-package" -o ".config/sublime-text-3/Installed Packages/Package Control.sublime-package";

    notify "Adding pre-installed packages for sublime";
    curlToFile "${repoUrl}settings/PackageControl.sublime-settings" ".config/sublime-text-3/Packages/User/Package Control.sublime-settings";

    notify "Applying default preferences to sublime";
    curlToFile "${repoUrl}settings/Preferences.sublime-settings" ".config/sublime-text-3/Packages/User/Preferences.sublime-settings";

    notify "Installing additional binaries for sublime auto-complete";
    curlToFile "https://github.com/emmetio/pyv8-binaries/raw/master/pyv8-linux64-p3.zip" "bin.zip";

    sudo mkdir -p ".config/sublime-text-3/Installed Packages/PyV8/";
    sudo unzip ~/bin.zip -d ".config/sublime-text-3/Installed Packages/PyV8/";
    sudo rm ~/bin.zip;

    installedSublime=1;
    breakLine;
}

# PHP Storm
##########################################################
installPhpStorm() {
    title "Installing PhpStorm IDE ${versionPhpStorm}";
    curlToFile "https://download.jetbrains.com/webide/PhpStorm-${versionPhpStorm}.tar.gz" "phpstorm.tar.gz";
    sudo tar xfz ~/phpstorm.tar.gz;

    sudo rm -rf /opt/phpstorm/;
    sudo mkdir /opt/phpstorm/;
    sudo mv ~/PhpStorm-*/* /opt/phpstorm/;
    sudo rm -rf ~/phpstorm.tar.gz;
    sudo rm -rf ~/PhpStorm-*;

    notify "Adding desktop file for PhpStorm";
    curlToFile ${repoUrl}"desktop/jetbrains-phpstorm.desktop" "/usr/share/applications/jetbrains-phpstorm.desktop";
    breakLine;
}

# Remmina
##########################################################
installRemmina() {
    title "Installing Remmina Client";
    sudo apt install -t stretch-backports remmina remmina-plugin-rdp remmina-plugin-secret -y;
    breakLine;
}

# Google Cloud SDK
##########################################################
installGoogleSdk() {
    title "Installing Google Cloud SDK";
    sudo apt install -y google-cloud-sdk;
    breakLine;
}

# Popcorn Time
##########################################################
installPopcorn() {
    title "Installing Popcorn Time v${versionPopcorn}";
    sudo apt install -y libnss3 vlc;

    if [[ -d /opt/popcorn-time ]]; then
        sudo rm -rf /opt/popcorn-time;
    fi

    sudo mkdir /opt/popcorn-time;
    sudo wget -qO- "https://get.popcorntime.sh/build/Popcorn-Time-${versionPopcorn}-Linux-64.tar.xz" | sudo tar Jx -C /opt/popcorn-time;
    sudo ln -sf /opt/popcorn-time/Popcorn-Time /usr/bin/popcorn-time;

    notify "Adding desktop file for Popcorn Time";
    curlToFile ${repoUrl}"desktop/popcorn.desktop" "/usr/share/applications/popcorn.desktop";
    breakLine;
}

# ZSH
##########################################################
installZsh() {
    title "Installing ZSH Terminal Plugin";
    sudo apt install -y zsh fonts-powerline;
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)";

    if [[ -f ${HOME}"/.zshrc" ]]; then
        sudo mv ${HOME}"/.zshrc" ${HOME}"/.zshrc.bak";
    fi

    if [[ -f ${HOME}"/.oh-my-zsh/themes/agnoster.zsh-theme" ]]; then
        sudo mv ${HOME}"/.oh-my-zsh/themes/agnoster.zsh-theme" ${HOME}"/.oh-my-zsh/themes/agnoster.zsh-theme.bak";
    fi

    echo '/bin/zsh' >> ~/.bashrc;

    installedZsh=1;
    breakLine;
}

# MySql Community Server
##########################################################
installMySqlServer() {
    title "Installing MySql Community Server";
    sudo apt install -y mysql-server;
    sudo systemctl enable mysql;
    sudo systemctl start mysql;
    installedMySqlServer=1;
    breakLine;
}

###############################################################
## MAIN PROGRAM
###############################################################
sudo apt install -y dialog;

cmd=(dialog --backtitle "Debian 9 Developer Container - USAGE: <space> select/un-select options & <enter> start installation." \
--ascii-lines \
--clear \
--nocancel \
--separate-output \
--checklist "Select installable packages:" 42 50 50);

options=(
    01 "Git" on
    02 "Node v${versionNode}" on
    03 "PHP v${versionPhp} with PECL" on
    04 "Ruby with DAPP v${versionDapp}" on
    05 "Python" off
    06 "GoLang v${versionGo}" off
    07 "Yarn (package manager)" on
    08 "Composer (package manager)" on
    09 "React Native" on
    10 "Apache Cordova" on
    11 "Phonegap" on
    12 "Webpack" on
    13 "Memcached server" on
    14 "Redis server" on
    15 "Docker CE (with docker compose)" off
    16 "Kubernetes (Kubectl)" off
    17 "Helm v${versionHelm}" on
    18 "Sops v${versionSops}" on
    19 "Postman" on
    20 "Laravel installer" on
    21 "Wine" off
    22 "MySql Community Server" on
    23 "SQLite (database tool)" on
    24 "DBeaver (database tool)" off
    25 "Redis Desktop Manager" on
    26 "Atom IDE" off
    27 "VS Code IDE" off
    28 "Sublime Text IDE" on
    29 "PhpStorm IDE v${versionPhpStorm}" off
    30 "Software Center" on
    31 "Remmina (Remote Desktop Client)" off
    32 "Google Cloud SDK" off
    33 "Popcorn Time v${versionPopcorn}" off
    34 "ZSH Terminal Plugin" on
);

choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty);

clear;

# Preparation
##########################################################
title "Installing Pre-Requisite Packages";
    cd ~/;
    sudo chown -R $(whoami) ~/
    sudo apt update;
    sudo apt dist-upgrade -y;
    sudo apt autoremove -y --purge;

    sudo apt install -y ca-certificates \
    apt-transport-https \
    software-properties-common \
    wget \
    curl \
    htop \
    mlocate \
    gnupg2 \
    cmake \
    libssh2-1-dev \
    libssl-dev \
    nano \
    vim \
    preload \
    gksu \
    snapd;

    sudo updatedb;
    sudo rm /usr/share/applications/gksu.desktop;
breakLine;

title "Adding Repositories";
for choice in ${choices}
do
    case ${choice} in
        03) repoPhp ;;
        08) repoPhp ;;
        20) repoPhp ;;
        07) repoYarn ;;
        15) repoDocker ;;
        16) repoKubernetes ;;
        21) repoWine ;;
        22) repoMySqlServer ;;
        26) repoAtom ;;
        27) repoVsCode ;;
        28) repoSublime ;;
        31) repoRemmina ;;
        32) repoGoogleSdk ;;
        33) repoVlc ;;
    esac
done
notify "Required repositories have been added...";
breakLine;

title "Updating apt";
    sudo apt update;
    notify "The apt package manager is fully updated...";
breakLine;

for choice in ${choices}
do
    case ${choice} in
        01) installGit ;;
        02) installNode ;;
        03) installPhp ;;
        04) installRuby ;;
        05) installPython ;;
        06) installGoLang ;;
        07) installYarn ;;
        08)
            if [[ ${installedPhp} -ne 1 ]]; then
                installPhp;
            fi
            installComposer;
        ;;
        09)
            if [[ ${installedNode} -ne 1 ]]; then
                installNode;
            fi
            installReactNative;
        ;;
        10)
            if [[ ${installedNode} -ne 1 ]]; then
                installNode;
            fi
            installCordova;
        ;;
        11)
            if [[ ${installedNode} -ne 1 ]]; then
                installNode;
            fi
            installPhoneGap;
        ;;
        12)
            if [[ ${installedNode} -ne 1 ]]; then
                installNode;
            fi
            installWebpack;
        ;;
        13) installMemcached ;;
        14) installRedis ;;
        15) installDocker ;;
        16) installKubernetes ;;
        17) installHelm ;;
        18)
            if [[ ${installedGo} -ne 1 ]]; then
                installGoLang;
            fi
            installSops;
        ;;
        19) installPostman ;;
        20)
            if [[ ${installedPhp} -ne 1 ]]; then
                installPhp;
            fi
            installLaravel;
        ;;
        21) installWine ;;
        22) installMySqlServer ;;
        23) installSqLite ;;
        24) installDbeaver ;;
        25) installRedisDesktopManager ;;
        26) installAtom ;;
        27) installVsCode ;;
        28) installSublime ;;
        29) installPhpStorm ;;
        30) installSoftwareCenter ;;
        31) installRemmina ;;
        32) installGoogleSdk ;;
        33) installPopcorn ;;
        34) installZsh ;;
    esac
done

# Clean
##########################################################
title "Finalising & Cleaning Up...";
    sudo chown -R $(whoami) ~/;
    sudo apt --fix-broken install -y;
    sudo apt dist-upgrade -y;
    sudo apt autoremove -y --purge;
breakLine;

notify "Great, the installation is complete =)";
echo "If you want to install further tool in the future you can run this script again.";

###############################################################
## POST INSTALLATION ACTIONS
###############################################################
if [[ ${installedZsh} -eq 1 ]]; then
    breakLine;
    notify "ZSH Plugin Detected..."

    cd ~/;
    curlToFile ${repoUrl}"zsh/.zshrc" ".zshrc";
    curlToFile ${repoUrl}"zsh/agnoster.zsh-theme" ".oh-my-zsh/themes/agnoster.zsh-theme";
    source ~/.zshrc;

    echo "";
    echo "If you are on a Chromebook, to complete the zsh setup you must manually change your terminal settings 'Ctrl+Shift+P':";
    echo "";
    echo "   1) Set user-css path to: $(tput bold)https://cdnjs.cloudflare.com/ajax/libs/hack-font/3.003/web/hack.css$(tput sgr0)";
    echo "   2) Add $(tput bold)'Hack'$(tput sgr0) as a font-family entry.";
    echo "";
    echo "Alternatively:";
    echo "";
    echo "   1) Import this file directly: $(tput bold)${repoUrl}zsh/crosh.json$(tput sgr0)";
    echo "";
    echo "If the zsh plugin does not take effect you can manually activate it by adding /bin/zsh to you .bashrc file. ";
    echo "Further information & documentation on the ZSH plugin: https://github.com/robbyrussell/oh-my-zsh";
fi

if [[ ${installedSublime} -eq 1 ]]; then
    breakLine;
    notify "Sublime Text Detected..."
    echo "";
    echo "To complete the Sublime Text installation make sure to install the 'Package Control' plugin when first running Sublime."
    echo "";
fi

if [[ ${installedMySqlServer} -eq 1 ]]; then
    breakLine;
    notify "MySql Community Server Detected..."
    echo "";
    echo "If you want to harden your MySql installation run: mysql-secure-install"
    echo "";
fi

echo "";
