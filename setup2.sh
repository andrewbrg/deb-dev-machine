#!/usr/bin/env bash

## SET YOUR VERSIONS
###############################################################

VERSION_PHP="8.0";
VERSION_NODE="14";
VERSION_HELM="3";
VERSION_SOPS="3.1.1";
VERSION_WERF="1.1.21+fix22";
VERSION_DOCKERCOMPOSE="1.29.2";

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

installPhp() {
  title "Installing PHP v${VERSION_PHP}";
  sudo apt install -y php${VERSION_PHP}-{bcmath,cli,curl,common,gd,ds,igbinary,dom,fpm,gettext,intl,mbstring,mysql,zip};
  
  sudo update-alternatives --set php "/usr/bin/php${VERSION_PHP}";
  sudo update-alternatives --set phar "/usr/bin/phar${VERSION_PHP}";
  sudo update-alternatives --set phar.phar "/usr/bin/phar.phar${VERSION_PHP}";
  sudo update-alternatives --set phpize "/usr/bin/phpize${VERSION_PHP}";
  sudo update-alternatives --set php-config "/usr/bin/php-config${VERSION_PHP}";
}

installComposer() {
  title "Installing Composer";
  local DL_PATH="composer-setup.php";
  
  curlToFile "https://getcomposer.org/installer" ${DL_PATH};
  sudo php ${DL_PATH} --install-dir=/usr/local/bin --filename=composer;
  rm -f ${DL_PATH};
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
  
  sudo curlToFile "https://github.com/docker/compose/releases/download/${VERSION_DOCKERCOMPOSE}/docker-compose-$(uname -s)-$(uname -m)" ${DL_FILE};
  sudo chmod +x ${DL_FILE};
}

installKubectl() {
  title "Installing Kubectl";
  sudo apt install -y kubectl;
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

installSymfony() {
  title "Installing Symfony Installer";
  curl -L "https://get.symfony.com/cli/installer" | sudo -E bash -;
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

installGoogleSdk() {
  title "Installing Google Cloud SDK";
  sudo apt install -y google-cloud-sdk;
}

installLocust() {
  title "Installing Locust";
  sudo pip3 install locust;
}

installBleachBit() {
  title "Installing Bleachbit";
  local DL_FILE="bleachbit.deb";
  
  curlToFile "https://download.bleachbit.org/bleachbit_4.4.0-0_all_debian10.deb" ${DL_FILE};
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

## CHECKS
###############################################################
if [[ "$EUID" -eq 0 ]]; then 
  notify "Please do not run this script as root!";
  exit;
fi

if [[ ${which lsb_release} == '' ]]; then
  sudo apt install -y lsb-release;
fi

if [[ ${lsb_release -c -s} != "buster" ]]; then 
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
  --checklist "Select installable packages:" 32 50 50);

options=(
    01 "Git" on
    02 "Node v${VERSION_NODE} with NPM" on
    03 "PHP v${VERSION_PHP}" on
    04 "Composer" on
    05 "Sops v${VERSION_SOPS}" on
    06 "Werf v${VERSION_WERF}" on
    07 "Helm v${VERSION_HELM}" on
    
    08 "Webpack" off
    09 "Yarn" off
    
    10 "React Native" off
    11 "Apache Cordova" off
    
    12 "Snap" on
    
    13 "Redis Server" off
    14 "MySql Community Server" off    
    15 "Redis Desktop Manager" off
    16 "DBeaver" off
    
    17 "Docker CE" on
    18 "Docker Compose v${VERSION_DOCKERCOMPOSE}" on
    19 "Kubectl" on

    20 "Laravel Installer" off
    21 "Symfony Installer" on

    22 "Google Cloud SDK" on
    23 "Locust (Load Tester)" off
    
    24 "BleachBit" on
    25 "JetBrains Toolbox App" on
);

choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty);
sleep .5;
clear;

## MAIN PROGRAM
###############################################################
title "Running Dist Upgrade";
  sudo apt update;
  sudo apt dist-upgrade -y;
breakLine;

title "Installing PreRequisites"
  installPreRequisites;
breakLine;

title "Adding Repositories";
  while [ ${CROSS_CHECKED} -eq 0 ]
  do
    CROSS_CHECKED=1;
    for choice in ${choices}
    do
      case ${choice} in
        04) 
          if [[ $(arrContains choices "03") -eq 0 ]]; then
            choices+=("03"); CROSS_CHECKED=0;
          fi
        ;;
        08) 
          if [[ $(arrContains choices "02") -eq 0 ]]; then
            choices+=("02"); CROSS_CHECKED=0;
          fi
        ;;
        10)
          if [[ $(arrContains choices "02") -eq 0 ]]; then
            choices+=("02"); CROSS_CHECKED=0;
          fi
        ;;
        11) 
          if [[ $(arrContains choices "02") -eq 0 ]]; then
            choices+=("02"); CROSS_CHECKED=0;
          fi
        ;;
        20)
          if [[ $(arrContains choices "04") -eq 0 ]]; then
            choices+=("04"); CROSS_CHECKED=0;
          fi
        ;;
        21)
          if [[ $(arrContains choices "03") -eq 0 ]]; then
            choices+=("03"); CROSS_CHECKED=0;
          fi
        ;;
      esac
    done
  
    choices=($(echo "${choices[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '));
  done
  
  for choice in ${choices[@]}
  do
    case ${choice} in
      03) repoPhp ;;
      09) repoYarn ;;
      14) repoMySqlServer ;;
      17) repoDocker ;;
      19) repoKubectl ;;
      22) repoGoogleSdk ;;
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
    01) installGit ;;
    02) installNode ;;
    03) installPhp ;;
    04) installComposer;;
    05) installSops ;;
    06) installWerf ;;
    07) installHelm ;;
    08) installWebpack ;;
    09) installYarn ;;
    10) installReactNative;;
    11) installCordova;;
    12) installSnap ;;
    13) installRedis ;;
    14) installMySqlServer ;;
    15) installRedisDesktopManager ;;
    16) installDbeaver ;;
    17) installDocker ;;
    18) installDockerCompose ;;
    19) installKubectl;;
    20) installLaravel ;;
    21) installSymfony ;;
    22) installGoogleSdk ;;
    23) installLocust ;;
    24) installBleachBit ;;
    25) installToolboxApp ;;
  esac
  breakLine;
done

title "Cleaning Up...";
  sudo apt --fix-broken install -y;
  sudo apt autoremove -y --purge;
breakLine;

for choice in ${choices[@]}
do
  case ${choice} in
    14)  mysql-secure-install ;;
    25)  notify "JetBrains Toolbox App installed in /opt" ;;
  esac
  breakLine;
done
  
notify "Great, the installation is complete =)";
notify "To install further tools in the future you can run this script again.";
