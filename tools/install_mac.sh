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
brew install jq
brew install wget
brew install xclip

# linux互換
brew install coreutils
brew install findutils

brew tap caskroom/cask
# cask-versionsで複数versionの管理をできるようにする
brew tap caskroom/versions

# ゴミ箱に移動させるため
brew install trash

# スクレイピング用
brew install chromedriver

# mysql5.7でinstall
# brew install mysql
# 下でクライアントonlyで入れられるっぽい
# brew install mysql-client
brew cask install mysqlworkbench
brew cask install sequel-pro

# Mac Application installs
brew cask install google-chrome
brew cask install google-backup-and-sync
brew cask install google-japanese-ime
# toolboxでインストールに変更した。 brew cask install intellij-idea
brew cask install jetbrains-toolbox  #  intellijを更新するのに便利
brew cask install slack
brew cask install dropbox

# CI
brew install circleci

brew cask install mysqlworkbench
brew cask install sourcetree
brew cask install gyazo
brew cask install bitwarden

# officeの代わり
brew cask install libreoffice

brew cask install visual-studio-code

# 画像編集ソフト
brew cask install gimp

# 構成管理ツール
brew install tfenv
brew install awscli
brew cask install google-cloud-sdk
#brew install terraform
brew install ansible
# caskに移動してるのが新しい
brew cask install docker
brew cask install kitematic

#
brew cask install clipy

brew install plantuml
brew install graphviz



# FTP/SFTP,S3　クライアント
brew cask install cyberduck

# ansibleで必要になるsshpassを追加
brew install http://git.io/sshpass.rb

# pythonインストールでコケたら
# CFLAGS="-I$(brew --prefix openssl)/include" \
# LDFLAGS="-L$(brew --prefix openssl)/lib" \
# pyenv install -v 3.4.3

# リンクする。
for file in $(cd .. && ls -d .??*); do
    [[ "$file" == ".git" ]] && continue
    [[ "$file" == ".DS_Store" ]] && continue
    [[ "$file" == ".idea" ]] && continue
    [[ "$file" == ".gitmodules" ]] && continue
    [[ "$file" == ".gitconfig" ]] && continue #全体のは手動で書き換え
    [[ "$file" == ".gitignore" ]] && continue #.dotfile用なので
    echo ${file}
    rm -f $HOME/"$file"
    ln -sfn "${HOME}/.dotfiles/$file" $HOME/"$file"
done

brew install sbt

anyenv install ndenv
anyenv install jenv
anyenv install rbenv
anyenv install pyenv
anyenv install goenv

ndenv install 11.13.0
rbenv install 2.6.2
pyenv install 3.7.3
goenv install 1.12.1

# javaのhomeパス確認して追加　したはshell直指定版
# export JAVA_HOME=`/System/Library/Frameworks/JavaVM.framework/Versions/A/Commands/java_home -v "1.8"`
# PATH=${JAVA_HOME}/bin:${PATH}
brew cask install java11
brew cask install java8

jenv global 11.0.2

ndenv global 9.6.1
rbenv global 2.4.0
pyenv global 3.6.2
goenv global 1.9.6

