# dotfiles
先にMacを前提としての構築

# mac インストール
```
 sh ./tools/install.sh
```

## ごにょごにょリンク
```bash
ln -sfn ~/Google\ ドライブ/office/00.infra/aws ~/.aws

```

## Macのアプリケーションインストール一部自動化

### brew cask upgrade
```
for c in `brew cask list`; do ! brew cask info $c | grep -qF "Not installed" || brew cask install $c; done
```
### brew cask upgrade
```
brew cask search {パッケージ名}
brew cask install {パッケージ名}
brew cask uninstall {パッケージ名}
```


## anyenv 使い方
nodeやscala,Javaのversionを複数管理する

### Nodeインストール
```
$ ndenv install v0.11.13　←バージョンは適宜好きなものを！
$ ndenv rehash　　　　　   ←再構築（インストール後のおまじない）
$ ndenv global v0.11.13　 ←デフォルトのバージョンに設定
$ node -v
$ ndenv versions ←version確認
  v0.11.14
```

## awscli
credentialsの切り替え

### 見る
```
cat ~/.aws/credentials 
```

### コマンドで指定する場合
```
aws s3 ls --profile test-user
```

### 環境変数で切り替える場合
```
export AWS_DEFAULT_PROFILE=test-user
aws s3 list
```

