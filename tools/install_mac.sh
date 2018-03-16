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
brew install mysql

# Mac Application installs
brew cask install google-chrome
brew cask install google-backup-and-sync
brew cask install google-japanese-ime
# toolboxでインストールに変更した。 brew cask install intellij-idea
brew cask install jetbrains-toolbox  #  intellijを更新するのに便利
brew cask install slack
brew cask install dropbox
brew cask install sequel-pro
brew cask install sourcetree
brew cask install gyazo
brew cask install skype
# 買い取り版なので一度買い取り版をインストール後にはこちらでもいいのかも
# brew cask install 1password
# officeの代わり
brew cask install libreoffice

# editer 今はVSC ただ悩み中
#brew cask install atom
brew cask install visual-studio-code

# 画像編集ソフト
brew cask install gimp

# 構成管理ツール
brew install awscli
brew install terraform
brew install ansible
# caskに移動してるのが新しい
brew cask install docker

# ブロックチェーン関係
brew tap ethereum/ethereum
brew install ethereum
brew install solidity

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
anyenv install rbenv
anyenv install pyenv

ndenv install v9.6.1
rbenv install 2.4.0
pyenv install 3.6.2

# java が9になったので
# java8を入れる
#brew cask install java8
# javaのhomeパス確認して追加　したはshell直指定版
# export JAVA_HOME=`/System/Library/Frameworks/JavaVM.framework/Versions/A/Commands/java_home -v "1.8"`
# PATH=${JAVA_HOME}/bin:${PATH}
#jenv add /Library/Java/JavaVirtualMachines/jdk1.8.0_152.jdk/Contents/Home

jenv global jdk1.8.0_152
ndenv global v9.6.1
rbenv global 2.4.0
pyenv global 3.6.2

# awscli install
pip install awscli



