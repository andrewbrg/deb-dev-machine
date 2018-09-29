#!/usr/bin/env bash

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
    printf "\033[1;46m$1 \033[0m \n";
}

curlToFile() {
    notify "Downloading: $1 ----> $2";
    sudo curl -fSL "$1" -o "$2";
}

askUser() {
    while true; do
        read -p " - $1 (y/n): " yn
        case ${yn} in
            [Yy]* ) echo 1; return 1;;
            [Nn]* ) echo 0; return 0;;
        esac
    done
}

###############################################################
## GLOBALS
###############################################################
REPO_URL="https://raw.githubusercontent.com/andrewbrg/deb9-dev-machine/master/";

###############################################################
## INSTALLATION
###############################################################

# Disallow running with sudo or su
##########################################################
if [ "$EUID" -eq 0 ]
  then printf "\033[1;101mNein, nein, nein... Please do NOT run this script as root! \033[0m \n";
  exit;
fi

# Secure the root user
##########################################################
title "Set your root password";
    sudo passwd root;
breakLine;

# Preperation
##########################################################
title "Installing pre-requisite packages";
    sudo chown -R $(whoami) ~/
    cd ~/;
    
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
    cabextract \
    preload \
    gksu \
    gnome-software \
    gnome-packagekit;
    
    sudo updatedb;
breakLine;

# Repositories
##########################################################
title "Adding repositories";
    # PHP Repo
    if [ ! -f /etc/apt/sources.list.d/php.list ]; then
        notify "Adding PHP sury repository";
        curl -fsSL "https://packages.sury.org/php/apt.gpg" | sudo apt-key add -;
        echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list;
    fi
    
    # Kubernetes Repo
    if [ ! -f /etc/apt/sources.list.d/kubernetes.list ]; then
        notify "Adding Kubernetes repository";
        curl -fsSL "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | sudo apt-key add -;
        echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list;
    fi

    # Yarn Repo
    if [ ! -f /etc/apt/sources.list.d/yarn.list ]; then
        notify "Adding Yarn repository";
        curl -fsSL "https://dl.yarnpkg.com/debian/pubkey.gpg" | sudo apt-key add -;
        echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list;
    fi

    # Sublime Text Repo
    if [ ! -f /etc/apt/sources.list.d/sublime-text.list ]; then
        notify "Adding Sublime text repository";
        curl -fsSL "https://download.sublimetext.com/sublimehq-pub.gpg" | sudo apt-key add -;
        echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list;
    fi
    
    # Wine Repo
    if [ ! -f /var/lib/dpkg/info/wine.list ]; then
        notify "Adding Wine repository";
        sudo dpkg --add-architecture i386;
        curl -fsSL "https://dl.winehq.org/wine-builds/Release.key" | sudo apt-key add -;
        sudo apt-add-repository "https://dl.winehq.org/wine-builds/debian/";
    fi
    
    # Docker Repo
    if [ ! -f /var/lib/dpkg/info/docker-ce.list ]; then
        notify "Adding Docker repository";
        curl -fsSL "https://download.docker.com/linux/debian/gpg" | sudo apt-key add -;
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable";
    fi
    
    # Atom IDE
    if [ ! -f /etc/apt/sources.list.d/atom.list ]; then
        notify "Adding Atom IDE repository";
        curl -fsSL https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -;
        echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" | sudo tee /etc/apt/sources.list.d/atom.list;
    fi
    
    # VS Code
    if [ ! -f /etc/apt/sources.list.d/vscode.list ]; then
        notify "Adding VS Code repository";
        curl "https://packages.microsoft.com/keys/microsoft.asc" | gpg --dearmor > microsoft.gpg;
        sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/;
        echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list;
    fi
        
    notify "Updating apt...";
    sudo apt update;
breakLine;

# Git
##########################################################
title "Installing Git";
    sudo apt install -y git;
breakLine;

# Node 8
##########################################################
if [ ! -d /etc/apt/sources.list.d/nodesource.list ]; then
    title "Installing Node 8";
        curl -L "https://deb.nodesource.com/setup_8.x" | sudo -E bash -;
        sudo apt install -y nodejs;
        sudo chown -R $(whoami) /usr/lib/node_modules;
    breakLine;
fi

# React Native
##########################################################
title "Installing React Native";
    npm install -g create-react-native-app;
breakLine;

# Apache Cordova
##########################################################
title "Installing Apache Cordova";
    npm install -g cordova;
breakLine;

# Phone Gap
##########################################################
title "Installing Phone Gap";
    npm install -g phonegap;
breakLine;

# Webpack
##########################################################
title "Installing Webpack";
   npm install -g webpack;
breakLine;

# Yarn
##########################################################
title "Installing Yarn";
    sudo apt install -y yarn;
breakLine;

# Memcached
##########################################################
title "Installing Memcached";
    sudo apt install -y memcached;
    sudo systemctl start memcached;
    sudo systemctl enable memcached;
breakLine;

# Redis
##########################################################
title "Installing Redis";
    sudo apt install -y redis-server;
    sudo systemctl start redis;
    sudo systemctl enable redis;
breakLine;

# PHP 7.2
##########################################################
title "Installing PHP 7.2";
    sudo apt install -y php7.2 php7.2-{bcmath,cli,common,curl,dev,gd,mbstring,mysql,sqlite,xml,zip} php-pear php-memcached php-redis;
    sudo apt install -y libphp-predis;
    php --version;
breakLine;

# Composer
##########################################################
title "Installing Composer";
    php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');";
    sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer;
    sudo rm /tmp/composer-setup.php;
breakLine;

# Laravel Installer
title "Installing Laravel Installer";
    composer global require "laravel/installer";
    echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' | tee -a ~/.bashrc;
breakLine;

# SQLite Browser
##########################################################
title "Installing SQLite Browser";
    sudo apt install -y sqlitebrowser;
breakLine;    



# DBeaver
##########################################################
title "Installing DBeaver SQL Client";
if [ "$(askUser "Do you want to install DBeaver?")" -eq 1 ]; then
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
fi
breakLine;

# Docker
##########################################################
title "Installing Docker with Kubernetes";
if [ "$(askUser "Do you want to install Docker, Docker Compose & Kubernetes?")" -eq 1 ]; then
    sudo apt install -y docker-ce;
    
    curlToFile "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" "/usr/local/bin/docker-compose";
    sudo chmod +x /usr/local/bin/docker-compose;
    
    sudo apt install -y kubectl;
fi
breakLine;

# Ruby
##########################################################
title "Installing Ruby & DAPP";
if [ "$(askUser "Do you want to install Ruby & DAPP?")" -eq 1 ]; then
    sudo apt install -y ruby-dev gcc pkg-config;
    sudo gem install dapp;
fi
breakLine;

# Python
##########################################################
title "Installing Python & PIP";
if [ "$(askUser "Do you want to install Python & PIP?")" -eq 1 ]; then
    sudo apt install -y python-pip;
    curl "https://bootstrap.pypa.io/get-pip.py" | sudo python;
    sudo pip install --upgrade setuptools;
fi
breakLine;

# Wine
##########################################################
title "Installing Wine & Mono";
if [ "$(askUser "Do you want to install WineHQ and Mono?")" -eq 1 ]; then
    sudo apt install -y --install-recommends winehq-stable;
    sudo apt install -y mono-vbnc;

    notify "Installing windows fonts for wine apps";
    curlToFile "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks" "winetricks";
    sudo chmod +x ~/winetricks;
    ./winetricks allfonts;
    echo "y" | rm ~/winetricks;
    
    notify "Applying font smoothing to wine apps";
    curlToFile ${REPO_URL}"wine_fontsmoothing.sh" "wine_fontsmoothing";
    sudo chmod +x ~/wine_fontsmoothing;
    sudo ./wine_fontsmoothing;
    echo "y" | rm ~/wine_fontsmoothing;
    clear;
    
    notify "Installing Royale 2007 theme for windows apps";
    curlToFile "http://www.gratos.be/wincustomize/compressed/Royale_2007_for_XP_by_Baal_wa_astarte.zip" "Royale_2007.zip";
    
    sudo chown -R $(whoami) ~/;
    mkdir -p ~/.wine/drive_c/Resources/Themes/;
    unzip ~/Royale_2007.zip -d ~/.wine/drive_c/Resources/Themes/;
    echo "y" | rm ~/Royale_2007.zip;
fi
breakLine;

# Postman
##########################################################
if [ ! -d /opt/postman/ ]; then
    title "Installing Postman";
    if [ "$(askUser "Do you want to install Postman?")" -eq 1 ]; then
        curlToFile "https://dl.pstmn.io/download/latest/linux64" "postman.tar.gz";
        sudo tar xfz ~/postman.tar.gz;
        
        sudo rm -rf /opt/postman/;
        sudo mkdir /opt/postman/;
        sudo mv ~/Postman*/* /opt/postman/;
        sudo rm -rf ~/Postman*;
        sudo rm -rf ~/postman.tar.gz;
        sudo ln -s /opt/postman/Postman /usr/bin/postman;
        
        notify "Adding desktop file for Postman";
        curlToFile ${REPO_URL}"postman.desktop" "/usr/share/applications/postman.desktop";
    fi
    breakLine;
fi

# Atom IDE
##########################################################
title "Installing Atom IDE";
if [ "$(askUser "Do you want to install Atom?")" -eq 1 ]; then
    sudo apt install -y atom;
fi
breakLine;

# VS Code
##########################################################
title "Installing VS Code IDE";
if [ "$(askUser "Do you want to install VS Code?")" -eq 1 ]; then
    sudo apt install -y code;
fi
breakLine;

# Sublime Text
##########################################################
if [ ! -d /opt/sublime_text/ ]; then
    title "Installing Sublime Text";
    if [ "$(askUser "Do you want to install Sublime Text?")" -eq 1 ]; then
        sudo apt install -y sublime-text;
        sudo pip install -U CodeIntel;
        
        sudo chown -R $(whoami) ~/;
        
        mkdir -p ~/.config/sublime-text-3/Packages/User/;
        
        notify "Adding pre-installed packages for sublime";
        curlToFile "${REPO_URL}PackageControl.sublime-settings" ".config/sublime-text-3/Packages/User/Package Control.sublime-settings";
        
        notify "Applying default preferences to sublime";
        curlToFile "${REPO_URL}Preferences.sublime-settings" ".config/sublime-text-3/Packages/User/Preferences.sublime-settings";
        
        notify "Installing additional binaries for sublime auto-complete";
        curlToFile "https://github.com/emmetio/pyv8-binaries/raw/master/pyv8-linux64-p3.zip" "bin.zip";
        
        sudo mkdir -p ".config/sublime-text-3/Installed Packages/PyV8/";
        sudo unzip ~/bin.zip -d ".config/sublime-text-3/Installed Packages/PyV8/";
        sudo rm ~/bin.zip;
    fi
    breakLine;
fi

# PHP Storm
##########################################################
if [ ! -d /opt/phpstorm/ ]; then
    title "Installing PhpStorm IDE";
    if [ "$(askUser "Do you want to install PhpStorm?")" -eq 1 ]; then
        curlToFile "https://download.jetbrains.com/webide/PhpStorm-2018.2.2.tar.gz" "phpstorm.tar.gz";
        sudo tar xfz ~/phpstorm.tar.gz;
        
        sudo rm -rf /opt/phpstorm/;
        sudo mkdir /opt/phpstorm/;
        sudo mv ~/PhpStorm-*/* /opt/phpstorm/;
        sudo rm -rf ~/phpstorm.tar.gz;
        sudo rm -rf ~/PhpStorm-*;
        
        notify "Adding desktop file for PhpStorm";
        curlToFile ${REPO_URL}"jetbrains-phpstorm.desktop" "/usr/share/applications/jetbrains-phpstorm.desktop";
    fi
    breakLine;
fi

# Clean
##########################################################
title "Finalising & cleaning up...";
    sudo apt --fix-broken install -y;
    sudo apt dist-upgrade -y;
    sudo apt autoremove -y --purge;
breakLine;

notify "Installation complete...";
