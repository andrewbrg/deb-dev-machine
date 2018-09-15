#!/usr/bin/env bash

###############################################################
## HELPERS
###############################################################
title() {
    printf "\033[1;42m"
    printf '%*s\n'  "${COLUMNS:-$(tput cols)}" '' | tr ' ' ' '
    printf '%-*s\n' "${COLUMNS:-$(tput cols)}" "  # $1" | tr ' ' ' '
    printf '%*s'  "${COLUMNS:-$(tput cols)}" '' | tr ' ' ' '
    printf "\033[0m"
    printf "\n\n"
}

breakLine() {
    printf "\n"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    printf "\n\n"
    sleep .5
}

###############################################################
## GLOBALS
###############################################################
REPO_URL="https://gist.githubusercontent.com/andrewbrg/0974722a74d4578b97dcb161266715c0/raw/"

###############################################################
## INSTALLATION
###############################################################
title "Set your root password";
    sudo passwd root;
breakLine;

title "Installing pre-requisite packages";
    sudo chown -R $(whoami) ~/
    sudo cd ~/;
    sudo apt update;
    sudo apt install -y \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    wget \
    htop \
    mlocate \
    gnupg2 \
    cmake \
    libssh2-1-dev \
    libssl-dev \
    curl \
    nano \
    vim \
    gksu;
    
    sudo updatedb;
breakLine;

# Repositories
title "Adding repositories";
    # PHP Repo
    if [ ! -f /etc/apt/sources.list.d/php.list ]; then
        curl -sL "https://packages.sury.org/php/apt.gpg" | sudo apt-key add -;
        echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list;
    fi
    
    # Kubernetes Repo
    if [ ! -f /etc/apt/sources.list.d/kubernetes.list ]; then
        curl -sL "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | sudo apt-key add -;
        echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list;
    fi

    # Yarn Repo
    if [ ! -f /etc/apt/sources.list.d/yarn.list ]; then
        curl -sL "https://dl.yarnpkg.com/debian/pubkey.gpg" | sudo apt-key add -;
        echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list;
    fi

    # Sublime Text Repo
    if [ ! -f /etc/apt/sources.list.d/sublime-text.list ]; then
        curl -sL "https://download.sublimetext.com/sublimehq-pub.gpg" | sudo apt-key add -;
        echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list;
    fi
    
    # Wine Repo
    if [ ! -f /var/lib/dpkg/info/winehq-stable.list ]; then
        sudo dpkg --add-architecture i386;
        curl -sL "https://dl.winehq.org/wine-builds/Release.key" | sudo apt-key add -;
        sudo apt-add-repository "https://dl.winehq.org/wine-builds/debian/";
    fi
    
    # Docker Repo
    if [ ! -f /var/lib/dpkg/info/docker-ce.list ]; then
        curl -sL "https://download.docker.com/linux/debian/gpg" | sudo apt-key add -;
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable";
    fi

    sudo apt update;
breakLine;

# Git
title "Installing Git";
    sudo apt install -y git;
breakLine;

# Node 8
if [ ! -d /etc/apt/sources.list.d/nodesource.list ]; then
    title "Installing Node 8";
        curl -L "https://deb.nodesource.com/setup_8.x" | sudo -E bash -;
        sudo apt install -y nodejs;
        sudo chown -R $(whoami) /usr/lib/node_modules;
    breakLine;
fi

# React Native
title "Installing React Native";
    sudo npm install -g create-react-native-app;
breakLine;

# Apache Cordova
title "Installing Apache Cordova";
    sudo npm install -g cordova;
breakLine;

# Phone Gap
title "Installing Phone Gap";
    sudo npm install -g phonegap;
breakLine;

# Yarn
title "Installing Yarn";
    sudo apt install -y yarn;
breakLine;

# Docker
title "Installing Docker CE";
    sudo apt install -y docker-ce;
breakLine;

# Docker Compose
title "Installing Docker Compose";
    sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose;
    sudo chmod +x /usr/local/bin/docker-compose
breakLine;

# Kubernetes
title "Installing Kubernetes";
    sudo apt install -y kubectl;
breakLine;

# Memcached
title "Installing Memcached";
    sudo apt install -y memcached;
    sudo systemctl start memcached;
    sudo systemctl enable memcached;
breakLine;

# Redis
title "Installing Redis";
    sudo apt install -y redis-server;
    sudo systemctl start redis;
    sudo systemctl enable redis;
breakLine;

# PHP 7.2
title "Installing PHP 7.2";
    sudo apt install -y php7.2 php7.2-{bcmath,cli,common,curl,dev,gd,mbstring,mysql,sqlite,xml,zip} php-pear php-memcached php-redis;
    sudo apt install -y libphp-predis;
breakLine;

# Composer
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

# DBeaver
title "Installing DBeaver SQL Client";
    curl -L "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb" -o dbeaver.deb;
    sudo apt install -y \
    ca-certificates-java* \
    java-common* \
    libpcsclite1* \
    libutempter0* \
    openjdk-8-jre-headless* \
    xbitmaps*;
    
    sudo dpkg -i dbeaver.deb;
    sudo rm dbeaver.deb;
breakLine;

# Ruby
title "Installing Ruby & DAPP";
    sudo apt install -y ruby-dev gcc pkg-config;
    sudo gem install dapp;
breakLine;

# Python
title "Installing Python & PIP";
    sudo apt install -y python-pip;
    curl "https://bootstrap.pypa.io/get-pip.py" | sudo python;
    sudo pip install --upgrade setuptools;
breakLine;

# Firefox
title "Installing Firefox";
    sudo apt install -y firefox-esr-l10n-en-gb;
breakLine;

# Wine
title "Installing Wine";
    sudo apt install -y --install-recommends winehq-stable;
breakLine;

# Postman
if [ ! -d /opt/postman/ ]; then
    title "Installing Postman";
        sudo curl -L "https://dl.pstmn.io/download/latest/linux64" -o postman.tar.gz;
        sudo tar xfz postman.tar.gz;
        sudo dpkg -i postman.tar.gz;
        sudo mkdir /opt/postman/;
        sudo mv Postman*/* /opt/postman/;
        sudo rm -rf Postman*;
        sudo rm -rf postman.tar.gz;
        sudo ln -s /opt/postman/Postman /usr/bin/postman;
        sudo curl -L ${REPO_URL}"dbd4b3ea4d1dd2ec7bc08fc64bc90454e81a5c76/postman.desktop" \
        -o ~/.local/share/applications/postman.desktop;
    breakLine;
fi

# Sublime Text
if [ ! -d /opt/sublime_text/ ]; then
    title "Installing Sublime Text";
        sudo apt install -y sublime-text;
        sudo pip install -U CodeIntel;
        
        curl -L ${REPO_URL}"282e80d531c774ea47b64f79396fa055b619598b/Package%2520Control.sublime-settings" \
        -o "/home/$(whoami)/.config/sublime-text-3/Packages/User/Package Control.sublime-settings";
        
        curl -L ${REPO_URL}"3f96d7ce378dc67470ecdcd2ec8a6211888f2eb0/Preferences.sublime-settings" \
        -o "/home/$(whoami)/.config/sublime-text-3/Packages/User/Preferences.sublime-settings";
        
        curl -L "https://github.com/emmetio/pyv8-binaries/raw/master/pyv8-linux64-p3.zip" -o bin.zip
        sudo unzip bin.zip -d "/home/$(whoami)/.config/sublime-text-3/Installed Packages/PyV8";
        sudo rm bin.zip;
    breakLine;
fi

# PHP Storm
if [ ! -d /opt/phpstorm/ ]; then
    title "Installing PhpStorm IDE";
        curl -L "https://download.jetbrains.com/webide/PhpStorm-2018.2.2.tar.gz" -o phpstorm.tar.gz;
        sudo tar xfz phpstorm.tar.gz;
        sudo mkdir /opt/phpstorm/;
        sudo mv PhpStorm-*/* /opt/phpstorm/;
        sudo rm -rf phpstorm.tar.gz;
        sudo rm -rf PhpStorm-*;
        
        sudo curl -L ${REPO_URL}"5ca1dc77e75513a0733e888fe7123f1801e7ef7d/jetbrains-phpstorm.desktop" \
        -o "~/.local/share/applications/jetbrains-phpstorm.desktop";
    breakLine;
fi

# Clean
title "Finalising & cleaning up...";
    sudo apt --fix-broken install -y;
    sudo apt dist-upgrade -y;
    sudo apt autoremove -y --purge;
breakLine;

echo "Installation complete.";
