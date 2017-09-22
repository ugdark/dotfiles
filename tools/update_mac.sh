#!/bin/sh

brew upgrade

for c in `brew cask list`; do ! brew cask info $c | grep -qF "Not installed" || brew cask install $c; done

# rbenv を更新 (よくわすれる)
cd ~/.anyenv/envs/rbenv/plugins/ruby-build && git pull && cd -