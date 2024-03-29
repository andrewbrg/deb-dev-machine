#!/usr/bin/env bash

## SET YOUR VERSIONS
###############################################################

VERSION_PHP="8.1";
VERSION_NODE="18";
VERSION_HELM="3";
VERSION_SOPS="3.7.3";
VERSION_WERF="1.1.31";
VERSION_DOCKERCOMPOSE="2.6.1";
VERSION_STACER="1.1.0";
VERSION_TOR="11.5";
VERSION_POPCORN="0.4.8";
VERSION_JETBRAINS_TOOLBOX="1.25.12424";

###############################################################


###############################################################
## NO EDIT BELOW
IS_REPO_ADDED=0;
IS_OPTS_SANITISED=0;
ARCHITECTURE=$(dpkg --print-architecture);

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
  printf "\033[1;46m %s \033[0m" "$1";
  printf "\n";
}

curlToFile() {
  notify "Fetching: $1 --> $2";
  sudo curl -fSL "$1" -o "$2";
}

arrContains() {
  typeset _x;
  typeset -n _A="$1"
  for _x in "${_A[@]}" ; do
    [ "$_x" = "$2" ] && return 0
  done
  return 1
}

addEnvVars() {
  local -a ENVS=("bashrc" "zshrc");
  for i in "${ENVS[@]}"
  do
    : 
    if [[ -f "${HOME}/.$i" ]]; then
      if ! grep -q $1 "${HOME}/.$i"; then
        echo $1 | tee -a "${HOME}/.$i";
        source "${HOME}/.$i";
      fi
    fi
  done
}

## REPOSITORIES
###############################################################
repoPhp() {
  local REPO="/etc/apt/sources.list.d/php.list";
  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding PHP Repository";
    curl -fsSL "https://packages.sury.org/php/apt.gpg" | sudo apt-key add -;
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee ${REPO};
    IS_REPO_ADDED=1;
  fi
}

repoYarn() {
  local REPO="/etc/apt/sources.list.d/yarn.list";
  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding Yarn Repository";
    curl -fsSL "https://dl.yarnpkg.com/debian/pubkey.gpg" | sudo apt-key add -;
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee ${REPO};
    IS_REPO_ADDED=1;
  fi
}

repoWine() {
  sudo dpkg --add-architecture i386;
  sudo apt install -y gnupg2;

  local REPO="/etc/apt/sources.list.d/wine.list";  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding Wine HQ Repository";
    curl -fsSL "https://dl.winehq.org/wine-builds/winehq.key" | sudo apt-key add -;
    echo "deb https://dl.winehq.org/wine-builds/debian/ buster main" | sudo tee ${REPO};
    IS_REPO_ADDED=1;
  fi
  
  REPO="/etc/apt/sources.list.d//wine-obs.list";
  if [[ ! -f ${REPO} ]]; then
    notify "Adding Wine Repository";
    curl -fsSL "https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key" | sudo apt-key add -;   
    echo "deb http://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./" | sudo tee ${REPO};
    IS_REPO_ADDED=1;
  fi
}

repoMySqlServer() {
  local REPO="/var/lib/dpkg/info/mysql-apt-config.list";
  local DL_FILE="mysql.deb";
  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding MySQL Repository";
    curlToFile "https://dev.mysql.com/get/mysql-apt-config_0.8.13-1_all.deb" ${DL_FILE};
    sudo apt install -y -f ./${DL_FILE};
    rm -f ${DL_FILE};
    IS_REPO_ADDED=1;
  fi
}

repoMongoDb() {
  local REPO="/etc/apt/sources.list.d/mongodb-org-5.0.list";
  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding MongoDB Repository";
    curl -fsSL "https://www.mongodb.org/static/pgp/server-5.0.asc" | sudo apt-key add -;
    echo "deb http://repo.mongodb.org/apt/debian buster/mongodb-org/5.0 main" | sudo tee ${REPO}
    IS_REPO_ADDED=1;
  fi
}

repoDocker() {
  local REPO="/etc/apt/sources.list.d/docker.list";
  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding Docker Repository";
    curl -fsSL "https://download.docker.com/linux/debian/gpg" | sudo gpg --dearmor -o "/usr/share/keyrings/docker-archive-keyring.gpg";
    echo "deb [arch=${ARCHITECTURE} signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee ${REPO};
    IS_REPO_ADDED=1;
  fi
}

repoKubectl() {
  local REPO="/etc/apt/sources.list.d/kubernetes.list";
  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding Kubernetes Repository";
    sudo curl -fsSLo "/usr/share/keyrings/kubernetes-archive-keyring.gpg" "https://packages.cloud.google.com/apt/doc/apt-key.gpg";
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee ${REPO};
    IS_REPO_ADDED=1;
  fi
}

repoGoogleSdk() {
  local REPO="/etc/apt/sources.list.d/google-cloud-sdk.list";
  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding Google Cloud Repository";
    curl -fsSL "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | sudo apt-key add -;
    echo "deb http://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -c -s) main" | sudo tee ${REPO};
    
    addEnvVars "export CLOUDSDK_PYTHON=python2";    
    IS_REPO_ADDED=1;
  fi
}

repoAtom() {
  local REPO="/etc/apt/sources.list.d/atom.list";
  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding Atom IDE Repository";
    curl -fsSL "https://packagecloud.io/AtomEditor/atom/gpgkey" | sudo apt-key add -;
    echo "deb [arch=${ARCHITECTURE}] https://packagecloud.io/AtomEditor/atom/any/ any main" | sudo tee ${REPO};
    IS_REPO_ADDED=1;
  fi
}

repoVsCode() {
  local REPO="/etc/apt/sources.list.d/vscode.list";
  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding VSCode Repository";
    curl -fsSL "https://packages.microsoft.com/keys/microsoft.asc" | sudo apt-key add -;
    echo "deb [arch=${ARCHITECTURE}] https://packages.microsoft.com/repos/vscode stable main" | sudo tee ${REPO};
    IS_REPO_ADDED=1;
  fi
}

## INSTALLERS
###############################################################
installPreRequisites() {
  sudo apt install -y \
    lsb-release \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    wget \
    htop \
    nano \
    vim;
}

installGit() {
  title "Installing Git";
  sudo apt install -y git;
}

installGitCola() {
  title "Installing Git Cola";
  sudo apt install -y git-cola;
}

installNode() {
  title "Installing Node v${VERSION_NODE} with Npm";
  curl -L "https://deb.nodesource.com/setup_${VERSION_NODE}.x" | sudo -E bash -;
  
  sudo apt install -y nodejs;
  sudo apt install -y npm;

  local NODE_MODULES_PATH="/usr/share/npm/node_modules";
  
  if [[ -f ${NODE_MODULES_PATH} ]]; then
    sudo chown -R "$(whoami)" ${NODE_MODULES_PATH};
    sudo chmod -R 777 ${NODE_MODULES_PATH};
  fi

  sudo npm install --location=global n;
  sudo n ${VERSION_NODE};
}

installPhp() {
  title "Installing PHP v${VERSION_PHP}";
  sudo apt install -y php${VERSION_PHP}-{bcmath,cli,curl,common,gd,ds,igbinary,dom,fpm,gettext,intl,mbstring,mysql,zip};
  
  sudo update-alternatives --set php "/usr/bin/php${VERSION_PHP}";
  sudo update-alternatives --set phar "/usr/bin/phar${VERSION_PHP}";
  sudo update-alternatives --set phar.phar "/usr/bin/phar.phar${VERSION_PHP}";
  sudo update-alternatives --set phpize "/usr/bin/phpize${VERSION_PHP}";
  sudo update-alternatives --set php-config "/usr/bin/php-config${VERSION_PHP}";
}

installGoLang() {
  title "Installing GoLang";
  sudo apt install -y golang;
  
  addEnvVars "export GOPATH=~/go";
  mkdir $GOPATH;
}

installComposer() {
  title "Installing Composer";
  local DL_PATH="composer-setup.php";
  
  curlToFile "https://getcomposer.org/installer" ${DL_PATH};
  sudo php ${DL_PATH} --install-dir=/usr/local/bin --filename=composer;
  rm -f ${DL_PATH};
}

installSops() {
  title "Installing Sops v${VERSION_SOPS}";
  local DL_FILE="sops_${VERSION_SOPS}_${ARCHITECTURE}.deb";
  
  curlToFile "https://github.com/mozilla/sops/releases/download/v${VERSION_SOPS}/sops_${VERSION_SOPS}_${ARCHITECTURE}.deb" ${DL_FILE};
  sudo apt install -y -f ./${DL_FILE};
  rm -f ${DL_FILE};
}

installWerf() {
  title "Installing Werf v${VERSION_WERF}";
  local DL_FILE="werf";
  
  curlToFile "https://tuf.werf.io/targets/releases/${VERSION_WERF}/linux-${ARCHITECTURE}/bin/werf" ${DL_FILE};

  sudo mv ${DL_FILE} "/usr/local/bin/werf";
  sudo chmod +x "/usr/local/bin/werf";
}

installHelm() {
  title "Installing Helm v${VERSION_HELM}";
  curl -fsSL "https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-${VERSION_HELM}" | sudo -E bash -;
}

installNginx() {
  title "Installing Nginx";
  sudo apt install -y nginx;
  sudo systemctl enable nginx;
  sudo systemctl start nginx;
}

installApache() {
  title "Installing Apache";
  sudo apt install -y apache2;
  sudo systemctl enable apache2;
  sudo systemctl start apache2;
}

installWebpack() {
  title "Installing Webpack";
  sudo npm install --location=global webpack;
}

installYarn() {
  title "Installing Yarn";
  sudo apt install -y yarn;
}

installReactNative() {
  title "Installing Create React Native";
  sudo npm install --location=global create-react-native-app;
}

installReactApp() {
  title "Installing Create React App";
  sudo npm install --location=global create-react-app;
}

installGatsby() {
  title "Installing Gatsby CLI";
  sudo npm install --location=global gatsby-cli;    
}

installCordova() {
  title "Installing Apache Cordova";
  sudo npm install --location=global cordova;
}

installSnap() {
  title "Installing Snap";
  sudo apt install -y \
    libsquashfuse0 \
    squashfuse \
    fuse;
    
  sudo apt install -y snapd;
  sudo snap install core;
  sudo snap install snapd;
}

installWine() {
  title "Installing Wine HQ";
  sudo apt install -y --install-recommends winehq-stable;
}

installRedis() {
  title "Installing Redis Server";
  sudo apt install -y redis-server;
  sudo systemctl start redis;
  sudo systemctl enable redis;
}

installMemcached() {
  title "Installing Memcached Server";
  sudo apt install -y memcached libmemcached-tools;
  sudo systemctl start memcached;
  sudo systemctl enable memcached;
}

installMySqlServer() {
  title "Installing MySQL Community Server";
  sudo apt install -y mysql-server;
  sudo systemctl enable mysql;
  sudo systemctl start mysql;
  clear;
}

installMongoDb() {
  title "Installing MongoDB";
  sudo apt install -y mongodb-org;
}

installRedisDesktopManager() {
  title "Installing Redis Desktop Manager";
  sudo snap install redis-desktop-manager;
}

installDbeaver() {
  title "Installing DBeaver";
  local DL_FILE="dbeaver-ce_latest_${ARCHITECTURE}.deb";
  
  curlToFile "https://dbeaver.io/files/dbeaver-ce_latest_${ARCHITECTURE}.deb" ${DL_FILE};
  sudo apt install -y -f ./${DL_FILE};
  rm -f ${DL_FILE};
}

installSqLiteBrowser() {
  title "Installing SQLite Browser";
  sudo apt install -y sqlitebrowser;
}

installDocker() {
  title "Installing Docker";
  sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io;
}

installDockerCompose() {
  title "Installing Docker Compose";
  local DL_FILE="/usr/local/bin/docker-compose";
  
  curlToFile "https://github.com/docker/compose/releases/download/v${VERSION_DOCKERCOMPOSE}/docker-compose-$(uname -s)-$(uname -m)" ${DL_FILE};
  sudo chmod +x ${DL_FILE};
}

installKubectl() {
  title "Installing Kubectl";
  sudo apt install -y kubectl;
}

installLaravel() {
  title "Installing Laravel Installer";
  composer global require "laravel/installer";
}

installSymfony() {
  title "Installing Symfony Installer";
  curl -L "https://get.symfony.com/cli/installer" | sudo -E bash -;
}

installGoogleSdk() {
  title "Installing Google Cloud SDK";
  sudo apt install -y google-cloud-sdk;
}

installLocust() {
  title "Installing Locust";
  sudo apt install -y python3-pip libffi-dev;
  sudo pip3 install locust;
}

installPostman() {
  title "Installing Postman";
  sudo snap install postman;
}

installBleachBit() {
  title "Installing Bleachbit";
  local DL_FILE="bleachbit.deb";
  
  curlToFile "https://download.bleachbit.org/bleachbit_4.4.0-0_all_debian10.deb" ${DL_FILE};
  sudo apt install -y -f ./${DL_FILE};
  rm -f ${DL_FILE};
}

installRemmina() {
  title "Installing Remmina Client";
  sudo apt install -y remmina remmina-plugin-vnc;
}

installStacer() {
  title "Installing Stacer v${VERSION_STACER}";
  local DL_FILE="stacer_${VERSION_STACER}_${ARCHITECTURE}.deb";
  
  curlToFile "https://github.com/oguzhaninan/Stacer/releases/download/v${VERSION_STACER}/stacer_${VERSION_STACER}_${ARCHITECTURE}.deb" ${DL_FILE};
  sudo apt install -y -f ./${DL_FILE};
  rm -f ${DL_FILE};
}

installTor() {
  title "Installing Tor Browser v${VERSION_TOR}";
  local DL_FILE="tor-browser_en-US.tar.xz";
  local DL_VERSION="tor-browser_en-US";
  
  curlToFile "https://www.torproject.org/dist/torbrowser/${VERSION_TOR}/tor-browser-linux64-${VERSION_TOR}_en-US.tar.xz" ${DL_FILE};
  tar -xvf ${DL_FILE};
  rm -f ${DL_FILE};
  
  sudo mv ${DL_VERSION} "/opt/";
  
  local CURR_DIR=$(pwd);
  sudo apt install -y kdialog zenity;
  
  cd "/opt/${DL_VERSION}/Browser";
  ./start-tor-browser --register-app;
  cd ${CURR_DIR};
}

installPopcornTime() {
  title "Installing Popcorn Time v${VERSION_POPCORN}";
  local DL_FILE="popcorn.deb";
  
  sudo apt install -y \
    libcanberra-gtk-module \
    libgconf-2-4 \
    libatomic1 \
    libnss3;
    
  curlToFile "https://github.com/popcorn-official/popcorn-desktop/releases/download/v${VERSION_POPCORN}/Popcorn-Time-${VERSION_POPCORN}-${ARCHITECTURE}.deb" ${DL_FILE};
  sudo apt install -y -f ./${DL_FILE};
  rm -f ${DL_FILE};
}

installToolboxApp() {
  title "Installing JetBrains Toolbox v${VERSION_JETBRAINS_TOOLBOX}";
  local DL_FILE="toolbox.gz";
  local DL_VERSION="jetbrains-toolbox-${VERSION_JETBRAINS_TOOLBOX}";
  
  curlToFile "https://download.jetbrains.com/toolbox/${DL_VERSION}.tar.gz" ${DL_FILE};
  tar -xvf ${DL_FILE};
  rm -f ${DL_FILE};
  
  sudo chmod +x ${DL_VERSION};
  sudo mv ${DL_VERSION} "/opt/";
}

installAtom() {
  title "Installing Atom IDE";
  sudo apt install -y atom;
}

installVsCode() {
  title "Installing Visual Studio Code IDE";
  sudo apt install -y code;
}

installTheme() {
  sudo apt install -y \
    gnome-tweak-tool \
    paper-icon-theme;
}

## CHECKS
###############################################################
if [[ "$EUID" -eq 0 ]]; then 
  notify "Please do not run this script as root!";
  exit;
fi

if [[ $(which lsb_release) == '' ]]; then
  sudo apt install -y lsb-release;
fi

## SELECTOR
###############################################################
sudo apt install -y dialog;

cmd=(dialog \
  --backtitle "USAGE: <space> un/select <enter> start installation." \
  --clear \
  --nocancel \
  --separate-output \
  --keep-tite \
  --no-shadow \
  --sleep 1 \
  --visit-items \
  --checklist "Debian 10 Dev Machine" 34 120 100)

options=(
    git "Git - [awesome version control tool]" on    
    gitcola "Git Cola - [a powerful graphical git client]" off
    
    node "Node v${VERSION_NODE}+NPM - [js runtime + package manager]" on
    php "PHP v${VERSION_PHP} - [programming language]" on
    golang "GoLang - [programming language]" on
    
    composer "Composer - [package manager for php]" on

    nginx "Nginx - [web server, reverse proxy, load balancer, mail proxy & http cache]" off
    apache "Apache - [web server]" off
    
    webpack "Webpack - [bundle js files for usage in a browser]" on
    yarn "Yarn - [package manager that doubles down as project manager]" off

    reactnative "Create React Native - [cli tool for bootstraping react native apps]" off
    reactapp "Create React App - [cli tool for bootstraping react apps]" on
    gatsby "Gatsby - [build and deploy headless websites]" on
    cordova "Apache Cordova - [wraps your html/js app into a mobile native container]" off
    laravel "Laravel Installer - [php framework for web artisans]" off
    symfony "Symfony Installer - [create symfony applications]" off

    snap "Snap - [manage and install containerised software packages]" on
    wine "Wine HQ - [compatibility layer capable of running Windows applications]" off
    
    redis "Redis Server - [open source in-memory data structure store]" off
    memcached "Memcached Server - [in-memory key-value store for small chunks of arbitrary data]" off
    mysql "MySql Community Server - [world's most popular open source database]" off   
    mongo "MongoDB - [noSQL database solution]" off
    rdm "Redis Desktop Manager - [redis database interface]" on
    sqlitebrowser "SqLite Browser - [mySQL Lite database interface]" off
    dbeaver "DBeaver - [multi platform database tool interface]" on
    
    docker "Docker CE - [open source containerization platform]" on
    dockercompose "Docker Compose v${VERSION_DOCKERCOMPOSE} - [defining and run multi-container Docker apps]" on
    kubectl "Kubectl - [the kubernetes cli tool]" on
    werf "Werf v${VERSION_WERF} - [cli tool for full deployment cycle implementation]" on
    helm "Helm v${VERSION_HELM} - [manage kubernetes applications]" on
    sops "Sops v${VERSION_SOPS} - [tool for managing secrets]" off

    gce "Google Cloud SDK - [cli client for google cloud hosting]" off
    locust "Locust - [load testing tool]" off
    postman "Postman - [api/rest testing platform]" off
    
    bleachbit "BleachBit - [system maintenance and cleanup utility]" on
    remmina "Remmina Remote Desktop - [full featured remote desktop client]" off
    stacer "Stacer - [performance tweaker utility]" off
    tor "Tor Browser v${VERSION_TOR} - [all in one browser for the tor network]" off
    popcorn "Popcorn Time v${VERSION_POPCORN} - [stream free movies & tv series]" off
    
    jbtoolbox "JetBrains Toolbox v${VERSION_JETBRAINS_TOOLBOX} - [installs and manages all jetbrains software]" on
    atom "Atom - [a hackable text editor]" off
    vscode "VS Code - [editor for building web and cloud applications]" on
    
    theme "Debian 10 Theme - [gnome tweak tool & paper icons]" on
);

choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty);
clear;

## MAIN PROGRAM
###############################################################
title "Upgrading your OS Installation";
  sudo apt update;
  sudo apt dist-upgrade -y;
breakLine;

title "Installing Pre-Requisites"
  installPreRequisites;
breakLine;

title "Adding Repositories";
  while [ ${IS_OPTS_SANITISED} -eq 0 ]
  do
    IS_OPTS_SANITISED=1;
    for choice in ${choices}
    do
      case ${choice} in
        gitcola) 
          if [[ $(arrContains choices "git") -eq 0 ]]; then
            choices=("git" "${choices[@]}"); IS_OPTS_SANITISED=0;
          fi
        ;;
        composer) 
          if [[ $(arrContains choices "php") -eq 0 ]]; then
            choices=("php" "${choices[@]}"); IS_OPTS_SANITISED=0;
          fi
        ;;
        symfony)
          if [[ $(arrContains choices "php") -eq 0 ]]; then
            choices=("php" "${choices[@]}"); IS_OPTS_SANITISED=0;
          fi
        ;;
        webpack) 
          if [[ $(arrContains choices "node") -eq 0 ]]; then
            choices=("node" "${choices[@]}"); IS_OPTS_SANITISED=0;
          fi
        ;;
        reactnative)
          if [[ $(arrContains choices "node") -eq 0 ]]; then
            choices=("node" "${choices[@]}"); IS_OPTS_SANITISED=0;
          fi
        ;;
        reactapp)
          if [[ $(arrContains choices "node") -eq 0 ]]; then
            choices=("node" "${choices[@]}"); IS_OPTS_SANITISED=0;
          fi
        ;;
        gatsby)
          if [[ $(arrContains choices "node") -eq 0 ]]; then
            choices=("node" "${choices[@]}"); IS_OPTS_SANITISED=0;
          fi
        ;;
        cordova) 
          if [[ $(arrContains choices "node") -eq 0 ]]; then
            choices=("node" "${choices[@]}"); IS_OPTS_SANITISED=0;
          fi
        ;;
        rdm) 
          if [[ $(arrContains choices "snap") -eq 0 ]]; then
            choices=("snap" "${choices[@]}"); IS_OPTS_SANITISED=0;
          fi
        ;;
        postman) 
          if [[ $(arrContains choices "snap") -eq 0 ]]; then
            choices=("snap" "${choices[@]}"); IS_OPTS_SANITISED=0;
          fi
        ;;
        laravel)
          if [[ $(arrContains choices "composer") -eq 0 ]]; then
            choices=("composer" "${choices[@]}");
            IS_OPTS_SANITISED=0;
          fi
        ;;
        dockercompose)
          if [[ $(arrContains choices "docker") -eq 0 ]]; then
            choices=("docker" "${choices[@]}"); IS_OPTS_SANITISED=0;
          fi
        ;;
      esac
    done

    choices=($(echo "${choices[@]}" | tr ' ' '\n' | awk '!a[$0]++' | tr '\n' ' '));
  done
  
  for choice in ${choices[@]}
  do
    case ${choice} in
      php) repoPhp ;;
      yarn) repoYarn ;;
      wine) repoWine ;;
      mysql) repoMySqlServer ;;
      mongo) repoMongoDb ;;
      docker) repoDocker ;;
      kubectl) repoKubectl ;;
      gce) repoGoogleSdk ;;
      atom) repoAtom ;;
      vscode) repoVsCode ;;
    esac
  done
  
  if [[ ${IS_REPO_ADDED} -eq 1 ]]; then
    breakLine;
    sudo apt update;
  fi
  
  notify "Required repositories have been added...";
breakLine;

for choice in ${choices[@]}
do
  case ${choice} in
    git) installGit ;;
    gitcola) installGitCola ;;
    
    node) installNode ;;
    php) installPhp ;;
    golang) installGoLang ;;
    
    composer) installComposer;;
    
    nginx) installNginx ;;
    apache) installApache ;;
    
    webpack) installWebpack ;;
    yarn) installYarn ;;

    reactnative) installReactNative;;
    reactapp) installReactApp;;
    gatsby) installGatsby;;
    cordova) installCordova;;
    laravel) installLaravel ;;
    symfony) installSymfony ;;
    
    snap) installSnap ;;
    wine) installWine ;;
    
    redis) installRedis ;;
    memcached) installMemcached ;;
    mysql) installMySqlServer ;;
    mongo) installMongoDb ;;
    rdm) installRedisDesktopManager ;;
    dbeaver) installDbeaver ;;
    sqlitebrowser) installSqLiteBrowser ;;
    
    docker) installDocker ;;
    dockercompose) installDockerCompose ;;
    kubectl) installKubectl ;;
    werf) installWerf ;;
    helm) installHelm ;;
    sops) installSops ;;
    
    gce) installGoogleSdk ;;
    locust) installLocust ;;
    postman) installPostman ;;
    
    bleachbit) installBleachBit ;;
    remmina) installRemmina ;;
    stacer) installStacer ;;
    tor) installTor ;;
    popcorn) installPopcornTime ;;
    
    jbtoolbox) installToolboxApp ;;
    atom) installAtom ;;
    vscode) installVsCode ;;
    
    theme) installTheme ;;
  esac
  
  breakLine;
done

title "Cleaning Up";
  sudo apt --fix-broken install -y;
  sudo apt autoremove -y --purge;
breakLine;

for choice in ${choices[@]}
do
  case ${choice} in
    nginx) notify "Nginx set to auto-start on startup" ;;
    apache) notify "Apache set to auto-start on startup" ;;
    redis) notify "Redis set to auto-start on startup" ;;
    memcached) notify "Memcached set to auto-start on startup" ;;
    mysql) notify "MySQL Server set to auto-start on startup" ;;
    jbtoolbox) notify "JetBrains Toolbox installed in /opt" ;;
    tor) notify "Tor Browser installed in /opt" ;;
  esac
done
  
notify "Great, your installation is now complete =)";
notify "To install further tools in the future you can run this script again.";
