#!/usr/bin/env bash

## SET YOUR VERSIONS
###############################################################

VERSION_PHP="8.0";
VERSION_NODE="14";
VERSION_HELM="3";
VERSION_SOPS="3.1.1";
VERSION_WERF="1.1.21+fix22";
VERSION_DOCKERCOMPOSE="1.29.2";
VERSION_STACER="1.1.0";

###############################################################

## NO EDIT BELOW

REPO_URL="https://raw.githubusercontent.com/andrewbrg/deb-dev-machine/master/";
CROSS_CHECKED=0;
REPOS_ADDED=0;

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

## REPOSITORIES
###############################################################
repoPhp() {
  local REPO="/etc/apt/sources.list.d/php.list";
  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding PHP Repository";
    curl -fsSL "https://packages.sury.org/php/apt.gpg" | sudo apt-key add -;
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee ${REPO};
    REPOS_ADDED=1;
  fi
}

repoDocker() {
  local REPO="/etc/apt/sources.list.d/docker.list";
  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding Docker Repository";
    curl -fsSL "https://download.docker.com/linux/debian/gpg" | sudo gpg --dearmor -o "/usr/share/keyrings/docker-archive-keyring.gpg";
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee ${REPO};
    REPOS_ADDED=1;
  fi
}

repoKubectl() {
  local REPO="/etc/apt/sources.list.d/kubernetes.list";
  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding Kubernetes Repository";
    sudo curl -fsSLo "/usr/share/keyrings/kubernetes-archive-keyring.gpg" "https://packages.cloud.google.com/apt/doc/apt-key.gpg";
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee ${REPO};
    REPOS_ADDED=1;
  fi
}

repoYarn() {
  local REPO="/etc/apt/sources.list.d/yarn.list";
  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding Yarn Repository";
    curl -fsSL "https://dl.yarnpkg.com/debian/pubkey.gpg" | sudo apt-key add -;
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee ${REPO};
    REPOS_ADDED=1;
  fi
}

repoWine() {
  local REPO="/etc/apt/sources.list.d/wine.list";
  
  sudo dpkg --add-architecture i386;
  sudo apt install -y gnupg2;
    
  if [[ ! -f ${REPO} ]]; then
    notify "Adding Wine HQ Repository";
    curl -fsSL "https://dl.winehq.org/wine-builds/winehq.key" | sudo apt-key add -;
    echo "deb https://dl.winehq.org/wine-builds/debian/ buster main" | sudo tee ${REPO};
    REPOS_ADDED=1;
  fi
  
  REPO="/etc/apt/sources.list.d//wine-obs.list";
  if [[ ! -f ${REPO} ]]; then
    notify "Adding Wine Repository";
    curl -fsSL "https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key" | sudo apt-key add -;   
    echo "deb http://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./" | sudo tee ${REPO};
    REPOS_ADDED=1;
  fi
}

repoMySqlServer() {
  local REPO="/var/lib/dpkg/info/mysql-apt-config.list";
  local DL_FILE="mysql.deb";
  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding MySQL Apt Repository";
    curlToFile "https://dev.mysql.com/get/mysql-apt-config_0.8.11-1_all.deb" ${DL_FILE};
    sudo apt install -y -f ./${DL_FILE};
    rm -f ${DL_FILE};
    REPOS_ADDED=1;
  fi
}

repoGoogleSdk() {
  local REPO="/etc/apt/sources.list.d/google-cloud-sdk.list";
  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding Google Cloud Repository";
    curl -fsSL "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | sudo apt-key add -;
    echo "deb http://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -c -s) main" | sudo tee ${REPO};
    
    local ENTRY="export CLOUDSDK_PYTHON=python2";
    
    if [[ -f "${HOME}/.bashrc" ]]; then
      if ! grep -q ${ENTRY} "${HOME}/.bashrc"; then
        echo ${ENTRY} | tee -a "${HOME}/.bashrc";
      fi
    fi

    if [[ -f "${HOME}/.zshrc" ]]; then
      if ! grep -q ${ENTRY} "${HOME}/.zshrc"; then
        echo ${ENTRY} | tee -a "${HOME}/.zshrc";
      fi
    fi
    
    REPOS_ADDED=1;
  fi
}

repoAtom() {
  local REPO="/etc/apt/sources.list.d/atom.list";
  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding Atom IDE Repository";
    curl -fsSL "https://packagecloud.io/AtomEditor/atom/gpgkey" | sudo apt-key add -;
    echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" | sudo tee ${REPO};
    REPOS_ADDED=1;
  fi
}

repoVsCode() {
  local REPO="/etc/apt/sources.list.d/vscode.list";
  
  if [[ ! -f ${REPO} ]]; then
    notify "Adding VSCode Repository";
    curl -fsSL "https://packages.microsoft.com/keys/microsoft.asc" | sudo apt-key add -;
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee ${REPO};
    REPOS_ADDED=1;
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

installNode() {
  title "Installing Node v${VERSION_NODE} & npm";
  curl -L "https://deb.nodesource.com/setup_${VERSION_NODE}.x" | sudo -E bash -;
  
  sudo apt install -y nodejs;
  sudo apt install -y npm;

  local DIR_PATH="/usr/share/npm/node_modules";
  
  if [[ -f ${DIR_PATH} ]]; then
    sudo chown -R "$(whoami)" ${DIR_PATH};
    sudo chmod -R 777 ${DIR_PATH};
  fi

  sudo npm install -g n;
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
  sudo apt install golang;
  
  if [[ -f "${HOME}/.bashrc" ]]; then
    echo 'export GOPATH=~/go' >> "${HOME}/.bashrc";
    source "${HOME}/.bashrc";
  fi
  
  if [[ -f "${HOME}/.zshrc" ]]; then
    echo 'export GOPATH=~/go' >> "${HOME}/.zshrc";
    source "${HOME}/.zshrc";
  fi

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
  local DL_FILE="sops_${VERSION_SOPS}_amd64.deb";
  
  curlToFile "https://github.com/mozilla/sops/releases/download/${VERSION_SOPS}/sops_${VERSION_SOPS}_amd64.deb" ${DL_FILE};
  sudo apt install -y -f ./${DL_FILE};
  rm -f ${DL_FILE};
}

installWerf() {
  title "Installing Werf v${VERSION_WERF}";
  local DL_FILE="werf_${VERSION_WERF}.gz";
  
  curlToFile "${REPO_URL}werf/${VERSION_WERF}.gz" ${DL_FILE};
  tar -xvf ${DL_FILE};
  rm -f ${DL_FILE};
  
  chmod +x ${VERSION_WERF};
  sudo mv ${VERSION_WERF} "/usr/local/bin/werf";
}

installHelm() {
  title "Installing Helm v${VERSION_HELM}";
  curl -fsSL "https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-${VERSION_HELM}" | sudo -E bash -;
}

installYarn() {
  title "Installing Yarn";
  sudo apt install -y yarn;
}

installWebpack() {
  title "Installing Webpack";
  sudo npm install -g webpack;
}

installReactNative() {
  title "Installing React Native";
  sudo npm install -g create-react-native-app;
}

installCordova() {
  title "Installing Apache Cordova";
  sudo npm install -g cordova;
}

installSnap() {
  title "Installing Snap";
  sudo apt install -y \
    libsquashfuse0 \
    squashfuse fuse;
    
  sudo apt install -y snapd;
  sudo snap install core;
  sudo snap install snapd;
}

installWine() {
  title "Installing Wine";
  sudo apt install -y --install-recommends winehq-stable;
}

installRedis() {
  title "Installing Redis Server";
  sudo apt install -y redis-server;
  sudo systemctl start redis;
  sudo systemctl enable redis;
}

installMySqlServer() {
  title "Installing MySQL Community Server";
  sudo apt install -y mysql-server;
  sudo systemctl enable mysql;
  sudo systemctl start mysql;
}

installRedisDesktopManager() {
  title "Installing Redis Desktop Manager";
  sudo snap install redis-desktop-manager;
}

installDbeaver() {
  title "Installing DBeaver";
  local DL_FILE="dbeaver-ce_latest_amd64.deb";
  
  curlToFile "https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb" ${DL_FILE};
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
  
  curlToFile "https://github.com/docker/compose/releases/download/${VERSION_DOCKERCOMPOSE}/docker-compose-$(uname -s)-$(uname -m)" ${DL_FILE};
  sudo chmod +x ${DL_FILE};
}

installKubectl() {
  title "Installing Kubectl";
  sudo apt install -y kubectl;
}

installLaravel() {
  title "Installing Laravel Installer";
  composer global require "laravel/installer";

  if [[ -f "${HOME}/.bashrc" ]]; then
    sed -i '/export PATH/d' "${HOME}/.bashrc";
    echo "export PATH=\"$PATH:$HOME/.config/composer/vendor/bin\"" | tee -a "${HOME}/.bashrc";
  fi
  
  if [[ -f "${HOME}/.zshrc" ]]; then
    sed -i '/export PATH/d' "${HOME}/.zshrc";
    echo "export PATH=\"$PATH:$HOME/.config/composer/vendor/bin\"" | tee -a "${HOME}/.zshrc";
  fi
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
  sudo pip3 install locust;
}

installPostman() {
  title "Installing Postman";
  snap install postman;
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
  sudo apt install -y -t "buster-backports" remmina remmina-plugin-rdp remmina-plugin-secret;
}

installStacer() {
  title "Installing Stacer v${VERSION_STACER}";
  local DL_FILE="stacer_${VERSION_STACER}_amd64.deb";
  
  curlToFile "https://github.com/oguzhaninan/Stacer/releases/download/v${VERSION_STACER}/stacer_${VERSION_STACER}_amd64.deb" ${DL_FILE};
  sudo apt install -y -f ./${DL_FILE};
  rm -f ${DL_FILE};
}

installToolboxApp() {
  title "Installing JetBrains Toolbox App";
  local DL_FILE="toolbox.gz";
  local DL_VERSION="jetbrains-toolbox-1.21.9712";
  
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

## CHECKS
###############################################################
if [[ "$EUID" -eq 0 ]]; then 
  notify "Please do not run this script as root!";
  exit;
fi

if [[ $(which lsb_release) == '' ]]; then
  sudo apt install -y lsb-release;
fi

if [[ $(lsb_release -c -s) != "buster" ]]; then 
  notify "Unfortunately your OS is not supported."
  exit;
fi

## SELECTOR
###############################################################
sudo apt install -y dialog;

cmd=(dialog --backtitle "Debian dev installer - USAGE: <space> un/select options & <enter> start installation." \
  --ascii-lines \
  --clear \
  --nocancel \
  --separate-output \
  --checklist "Select installable packages:" 34 80 34)

options=(
    git "Git" on    
 
    node "Node v${VERSION_NODE} with NPM" on
    php "PHP v${VERSION_PHP}" on
    golang "GoLang" off
    
    composer "Composer" on
    sops "Sops v${VERSION_SOPS}" on
    werf "Werf v${VERSION_WERF}" on
    helm "Helm v${VERSION_HELM}" on
    
    webpack "Webpack" off
    yarn "Yarn" off
    react "React Native" off
    cordova "Apache Cordova" off

    snap "Snap" on
    wine "Wine HQ" off
    
    redis "Redis Server" off
    mysql "MySql Community Server" off    
    rdm "Redis Desktop Manager" on
    dbeaver "DBeaver" on
    sqliteb "SQLite Browser" off
    
    docker "Docker CE" on
    dcompose "Docker Compose v${VERSION_DOCKERCOMPOSE}" on
    k8 "Kubectl" on

    laravel "Laravel Installer" off
    symfony "Symfony Installer" on

    gce "Google Cloud SDK" on
    locust "Locust (Load Tester)" off
    postman "Postman" off
    
    bleach "BleachBit" on
    remmina "Remmina Remote Desktop" off
    stacer "Stacer" off
    
    jb "JetBrains Toolbox App" on
    atom "Atom IDE" on
    vscode "Visual Studio Code" off
);

choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty);
sleep .5;
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
  while [ ${CROSS_CHECKED} -eq 0 ]
  do
    CROSS_CHECKED=1;
    for choice in ${choices}
    do
      case ${choice} in
        composer) 
          if [[ $(arrContains choices "php") -eq 0 ]]; then
            choices=("php" "${choices[@]}");
            CROSS_CHECKED=0;
          fi
        ;;
        symfony)
          if [[ $(arrContains choices "php") -eq 0 ]]; then
            choices=("php" "${choices[@]}");
            CROSS_CHECKED=0;
          fi
        ;;
        webpack) 
          if [[ $(arrContains choices "node") -eq 0 ]]; then
            choices=("node" "${choices[@]}");
            CROSS_CHECKED=0;
          fi
        ;;
        react)
          if [[ $(arrContains choices "node") -eq 0 ]]; then
            choices=("node" "${choices[@]}");
            CROSS_CHECKED=0;
          fi
        ;;
        cordova) 
          if [[ $(arrContains choices "node") -eq 0 ]]; then
            choices=("node" "${choices[@]}");
            CROSS_CHECKED=0;
          fi
        ;;
        rdm) 
          if [[ $(arrContains choices "snap") -eq 0 ]]; then
            choices=("snap" "${choices[@]}");
            CROSS_CHECKED=0;
          fi
        ;;
        postman) 
          if [[ $(arrContains choices "snap") -eq 0 ]]; then
            choices=("snap" "${choices[@]}");
            CROSS_CHECKED=0;
          fi
        ;;
        laravel)
          if [[ $(arrContains choices "composer") -eq 0 ]]; then
            choices=("composer" "${choices[@]}");
            CROSS_CHECKED=0;
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
      docker) repoDocker ;;
      k8) repoKubectl ;;
      gce) repoGoogleSdk ;;
      atom) repoAtom ;;
      vscode) repoVsCode ;;
    esac
  done
  
  if [[ ${REPOS_ADDED} -eq 1 ]]; then
    breakLine;
    sudo apt update;
  fi
  
  notify "Required repositories have been added...";
breakLine;

for choice in ${choices[@]}
do
  case ${choice} in
    git) installGit ;;
    
    node) installNode ;;
    php) installPhp ;;
    golang) installGoLang ;;
    
    composer) installComposer;;
    sops) installSops ;;
    werf) installWerf ;;
    helm) installHelm ;;
    
    webpack) installWebpack ;;
    yarn) installYarn ;;
    react) installReactNative;;
    cordova) installCordova;;
    
    snap) installSnap ;;
    wine) installWine ;;
    
    redis) installRedis ;;
    mysql) installMySqlServer ;;
    rdm) installRedisDesktopManager ;;
    dbeaver) installDbeaver ;;
    sqliteb) installSqLiteBrowser ;;
    
    docker) installDocker ;;
    dcompose) installDockerCompose ;;
    k8) installKubectl ;;
    
    laravel) installLaravel ;;
    symfony) installSymfony ;;
    
    gce) installGoogleSdk ;;
    locust) installLocust ;;
    postman) installPostman ;;
    
    bleach) installBleachBit ;;
    remmina) installRemmina ;;
    stacer) installStacer ;;
    
    jb) installToolboxApp ;;
    atom) installAtom ;;
    vscode) installVsCode ;;
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
    mysql) mysql-secure-install ;;
    jb) notify "JetBrains Toolbox App installed in /opt" ;;
  esac
done
  
breakLine;
notify "Great, the installation is complete =)";
notify "To install further tools in the future you can run this script again.";
