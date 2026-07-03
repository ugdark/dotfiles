#!/usr/bin/env bash
# secret-guard.sh のユニットテスト。
# 使い捨ての一時gitリポジトリを作り、staged差分に対する検出/許可を検証する。
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
GUARD="$HERE/../secret-guard.sh"

pass=0
fail=0

# assert: 期待exit code と 実exit code を比較
# $1=テスト名 $2=期待exit $3=実exit
assert_exit() {
  if [ "$2" = "$3" ]; then
    pass=$((pass + 1))
    printf '  ok   %s\n' "$1"
  else
    fail=$((fail + 1))
    printf '  FAIL %s (expected exit %s, got %s)\n' "$1" "$2" "$3"
  fi
}

# 一時リポジトリを作り、渡された内容をstageして guard を「git hook モード」で実行
# $1=ファイル内容  → guardのexit codeを返す
run_guard_gitmode() {
  local content="$1"
  local repo
  repo="$(mktemp -d)"
  (
    cd "$repo" || exit 99
    git init -q
    git config user.email t@t && git config user.name t
    printf '%s\n' "$content" > file.txt
    git add file.txt
    # git hook モード（stdin無し）。denylistは環境変数で明示。
    SECRET_GUARD_PATTERNS="$HERE/../secret-patterns.txt" \
      SECRET_GUARD_DENYLIST=/dev/null bash "$GUARD" </dev/null
  )
  local code=$?
  rm -rf "$repo"
  return $code
}

echo "== secret-guard.sh tests =="

# 1) 秘密が無ければ許可（exit 0）
run_guard_gitmode "just a normal readme line"
assert_exit "clean content is allowed" 0 $?

# ↓ 各フィクスチャ行末の `secret-guard:allow` は、このテストファイル自身をcommitする際に
#   ガードが偽秘密を検出して自爆するのを防ぐマーカー（テスト内のtempファイル内容には影響しない）。

# 2) AWSアクセスキーは検出（exit 1 = block）
run_guard_gitmode "aws_key = AKIAIOSFODNN7EXAMPLE"  # secret-guard:allow
assert_exit "AWS access key is blocked" 1 $?

# 3) GitHub PAT は検出
run_guard_gitmode "token: ghp_0123456789abcdefghijklmnopqrstuvwxyz"  # secret-guard:allow
assert_exit "GitHub PAT is blocked" 1 $?

# 4) password= 代入は検出
run_guard_gitmode 'DB_PASSWORD="hunter2secret"'  # secret-guard:allow
assert_exit "password assignment is blocked" 1 $?

# 5) private key ヘッダは検出
run_guard_gitmode "-----BEGIN RSA PRIVATE KEY-----"  # secret-guard:allow
assert_exit "private key header is blocked" 1 $?

echo ""
printf 'result: %d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
