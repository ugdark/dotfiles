#!/bin/sh

set -eu

# Initialize for iOS
if sw_vers >& /dev/null; then
  echo "It's iOS"

  # Install xcode
  xcode-select --install

  # Install homebrew
  if ! which brew >& /dev/null;then
    echo "Install homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew doctor
  fi

  # Install package in homebrew
  brew tap Homebrew/bundle
  brew bundle
fi

# Initialize for CentOS
#if cat /etc/redhat-release >& /dev/null; then
#    echo "It's CentOS"
#
#    # Install package in yum
#    rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
#    yum install -y vim
#    yum install -y tree
#    yum install -y tmux
#    yum install -y git
#    yum install -y tig
#fi
#
# Initialize for Ubuntu
#if cat /etc/lsb-release >& /dev/null; then
#    echo "It's Ubuntu"
#    echo "ERROR: Only iOS or CentOS"
#    exit 0
#fi

# Check and Change zsh
if [ -n "$ZSH_VERSION" ]; then
  echo "Change to zsh"
  zsh
else
  echo "TODO: Install zsh"
  exit 1
fi

# Install prezto
if [ ! -d ~/.zprezto ]; then
  echo "Install prezto"
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
  setopt EXTENDED_GLOB
  for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
  done
fi
