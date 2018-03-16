## 参考: https://qiita.com/RIT80/items/1cc77faadfa5ac61e976


# 引数に渡した文字列をPATHに追加する
function append_path() { remove_path $1; export PATH=$PATH:$1; }
function remove_path() { export PATH=`echo -n $PATH | awk -v RS=: -v ORS=: '$0 !="'$1'"' | sed 's/:$//'`; }

# ディレクトリ変更時に削除するPATH
PREVIOUS_NODE_PATH="";

#  カレントディレクトリにnode_modules/.binが存在する場合、PATHに追加する。
#  前回追加したnode_modules/.binをPATHから削除する。
function update_node_path(){
  # 変数の初期化
  current_node_path=""

  # カレントディレクトリにnode_modules/.binディレクトリが存在する場合、PATHに追加する。
  if [ -d ./node_modules/.bin ]; then
    current_node_path=`pwd`"/node_modules/.bin"
    path+=($current_node_path)
  fi

  # 以前のnode_modules/.binが存在する場合、PATHから削除する。
  remove_path $PREVIOUS_NODE_PATH

  # ディレクトリ変更時にPATHから削除するために追加したぱPATHを記憶する
  PREVIOUS_NODE_PATH=$current_node_path
}

# ディレクリ変更時にupdate_node_pathを実行する
autoload -Uz add-zsh-hook
add-zsh-hook chpwd update_node_path