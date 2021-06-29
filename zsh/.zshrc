# Path to your oh-my-zsh installation.
export ZSH=$HOME"/.oh-my-zsh"
export ZSH_THEME="robbyrussell"
export CLOUDSDK_PYTHON=python2

# Plugins
plugins=(
  git
  laravel5  
  docker
  composer 
  debian
  helm 
  kubectl
)

source $ZSH/oh-my-zsh.sh
