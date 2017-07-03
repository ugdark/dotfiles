#!/bin/sh

# mac 隠しファイル表示
defaults write com.apple.finder AppleShowAllFiles -boolean true
killall Finder

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
brew install vim
brew install zsh
brew install git
brew install curl
brew install peco

# 構成管理ツール
brew install awscli
brew install terraform
brew install ansible


brew install coreutils
brew install findutils



# Mac Application installs
brew tap caskroom/cask
brew cask install google-chrome
brew cask install google-drive
brew cask install google-japanese-ime
brew cask install intellij-idea
brew cask install slack
brew cask install dropbox
brew cask install sequel-pro
brew cask install sourcetree
brew cask install gyazo
brew cask install skype
brew cask install vagrant
brew cask install virtualbox
brew cask install 1password
brew cask install docker
brew cask install libreoffice
# ChefはGemより 「Chef Development Kit」で推奨
brew cask install chefdk
# knife-soloもついでに入れるなら。
chef gem install knife-solo

# editer 今はVSC
#brew cask install atom
brew cask install visual-studio-code

# amazon-workspaces使ってるから
brew cask install amazon-workspaces

for f in .??*
do
    [[ "$f" == ".git" ]] && continue
    [[ "$f" == ".DS_Store" ]] && continue
    [[ "$f" == ".idea" ]] && continue
    [[ "$f" == ".gitmodules" ]] && continue
    [[ "$f" == ".gitconfig" ]] && continue #手動で書き換え
    [[ "$f" == ".gitignore" ]] && continue #ここのignoreをglobalに適応

#    echo "${HOME}/.dotfiles/$f" "${HOME}/$f"
    ln -sfn "${HOME}/.dotfiles/$f" $HOME/"$f"
done

## ここのを全体に
ln -sfn "${HOME}/.dotfiles/.gitignore" "$HOME/.gitignore_global"

# sdkman anyenvとどっち使うか迷う。
#curl -s "https://get.sdkman.io" | bash

anyenv install ndenv
anyenv install jenv
anyenv install scalaenv
anyenv install sbtenv
anyenv install rbenv

ndenv install v6.7.0
scalaenv install scala-2.11.8
sbtenv install sbt-0.13.8
rbenv install 2.4.0

# cask-versionsで複数versionの管理をできるようにする
brew tap caskroom/versions
# これでjava8 現時点で
brew cask install java

# java
# jenv add /Library/Java/JavaVirtualMachines/jdk1.7.0_51.jdk/Contents/Home
# java -version



ndenv global v6.7.0
scalaenv global scala-2.11.8
sbtenv global sbt-0.13.9
rbenv global 2.4.0

# chefとknife-solo を入れるなら (globalインストールになる)
#gem install chef
#gem install knife-solo
