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
brew install docker

# linux互換
brew install coreutils
brew install findutils

brew tap caskroom/cask
# cask-versionsで複数versionの管理をできるようにする
brew tap caskroom/versions

# ゴミ箱に移動させるため
brew install trash

echo "test"
# mysql5.6でinstall
brew install mysql@5.6

# Mac Application installs
brew cask install google-chrome
brew cask install google-drive
brew cask install google-japanese-ime
brew cask install intellij-idea
brew cask install jetbrains-toolbox  #  intellijを更新するのに便利
brew cask install slack
brew cask install dropbox
brew cask install sequel-pro
brew cask install sourcetree
brew cask install gyazo
brew cask install skype
brew cask install 1password
brew cask install libreoffice

# ChefはGemより 「Chef Development Kit」で推奨 (もう使いたくない。ansible推奨:レガシーの為)
# knife-soloもついでに入れるなら。
brew cask install chefdk
chef gem install knife-solo

# editer 今はVSC ただ悩み中
#brew cask install atom
brew cask install visual-studio-code

# amazon-workspaces使ってるから
brew cask install amazon-workspaces

# 画像編集ソフト
brew cask install gimp

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


anyenv install ndenv
anyenv install jenv
anyenv install scalaenv
anyenv install sbtenv
anyenv install rbenv

ndenv install v6.7.0
scalaenv install scala-2.11.8
sbtenv install sbt-0.13.8
rbenv install 2.4.0

# これでjava8 現時点で
brew cask install java

ndenv global v6.7.0
scalaenv global scala-2.11.8
sbtenv global sbt-0.13.9
rbenv global 2.4.0

