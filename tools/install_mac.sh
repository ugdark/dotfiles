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
# 下でクライアントonlyで入れられるっぽい
# brew install mysql --client-only

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
brew cask install kitematic

# plantUML用
brew install graphviz

# ブロックチェーン関係
brew tap ethereum/ethereum
brew install ethereum
brew install solidity
brew cask install ganache

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
anyenv install goenv

ndenv install 9.6.1
rbenv install 2.4.0
pyenv install 3.6.2
goenv install 1.9.6

# gradleが9に対応してない為
#sdkman入れる javaはsdkmanで管理した方がいいのかも。。まだやってない
curl -s "https://get.sdkman.io" | bash

# java が9になったので
# java8を入れる
# javaのhomeパス確認して追加　したはshell直指定版
# export JAVA_HOME=`/System/Library/Frameworks/JavaVM.framework/Versions/A/Commands/java_home -v "1.8"`
# PATH=${JAVA_HOME}/bin:${PATH}

brew cask install java9
# jenv add /Library/Java/JavaVirtualMachines/jdk-9.0.4.jdk/Contents/Home
jenv global 9.0.4

ndenv global 9.6.1
rbenv global 2.4.0
pyenv global 3.6.2
goenv global 1.9.6

# awscli install
pip install awscli


# https://github.com/dwango/scala_text/issues/122
# brew sbtはランチャーで0.13以降は互換性を担保してるみたい。なのでenvではなくsbtを直で入れる
## scalaのsbtはgpgを求められるので先に入れる
#brew install gpg
#anyenv install sbtenv
brew install sbt
