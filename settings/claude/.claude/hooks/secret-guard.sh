#!/usr/bin/env bash
#
# secret-guard.sh — commit直前に staged 差分を走査し、秘密情報・業務固有情報の
# 混入を検出したら commit をブロックする。二刀流で動く:
#
#   (1) Claude Code の PreToolUse フック（stdinにJSONが渡る）
#       → 検出時は permissionDecision:"deny" を返して Claude の commit を止める
#   (2) 素の git pre-commit フック（stdin無し）
#       → 検出時は exit 1 で commit を止める（Fork/ターミナル/IDE 全部に効く）
#
# 検出パターン:
#   - 汎用の秘密パターン: secret-patterns.txt（このスクリプトと同ディレクトリ）
#   - あなた固有の業務語: secret-denylist.local（gitignore対象・任意）
#
# 高速化: commit時のみ発火し、staged差分の「追加行」だけを grep 一発で走査する。
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERNS_FILE="${SECRET_GUARD_PATTERNS:-$SCRIPT_DIR/secret-patterns.txt}"
DENYLIST_FILE="${SECRET_GUARD_DENYLIST:-$SCRIPT_DIR/secret-denylist.local}"

# --- staged追加行を走査し、マッチ行を stdout に出す。マッチ有り=0 / 無し=1 ---
scan_staged() {
  local rules
  rules="$(cat "$PATTERNS_FILE" "$DENYLIST_FILE" 2>/dev/null \
    | grep -Ev '^[[:space:]]*#' | grep -Ev '^[[:space:]]*$')"
  [ -z "$rules" ] && return 1

  # 追加行を走査。ただし `secret-guard:allow` を含む行は誤検出回避の除外対象
  # （テストの偽フィクスチャ等。gitleaksの gitleaks:allow 相当）。
  git diff --cached --unified=0 --no-color -- . 2>/dev/null \
    | grep -E '^\+' | grep -Ev '^\+\+\+' \
    | grep -Ev 'secret-guard:allow' \
    | grep -E -i -f <(printf '%s\n' "$rules")
}

REASON_HEADER="機密情報/業務固有情報の混入を検出したため commit をブロックしました。"

# --- 入力（stdin）読み取り: あれば Claude フックモード、無ければ git フックモード ---
input=""
if [ ! -t 0 ]; then
  input="$(cat)"
fi

if printf '%s' "$input" | grep -q '"tool_input"'; then
  # ===== Claude Code PreToolUse モード =====
  JQ="$(command -v jq || true)"
  cmd=""; cwd=""
  if [ -n "$JQ" ]; then
    cmd="$(printf '%s' "$input" | "$JQ" -r '.tool_input.command // empty')"
    cwd="$(printf '%s' "$input" | "$JQ" -r '.cwd // empty')"
  fi

  # git commit 以外は素通り（if フィルタの保険）。
  # 「git」直後の commit サブコマンドのみに限定（"git add ... commit可能" 等の誤認を防ぐ）。
  if ! printf '%s' "$cmd" | grep -qE 'git[[:space:]]+commit([[:space:]]|$)'; then
    exit 0
  fi

  [ -n "$cwd" ] && cd "$cwd" 2>/dev/null

  hits="$(scan_staged)"
  if [ -n "$hits" ]; then
    reason="$REASON_HEADER 該当行: $(printf '%s' "$hits" | head -5 | tr '\n' '｜')"
    # JSON文字列エスケープ（jqがあれば安全に）
    if [ -n "$JQ" ]; then
      "$JQ" -cn --arg r "$reason" \
        '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
    else
      printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' \
        "$REASON_HEADER"
    fi
  fi
  # マッチ無し: 何も出力せず exit 0（通常フローに委ねる）
  exit 0
fi

# ===== git pre-commit モード =====
hits="$(scan_staged)"
if [ -n "$hits" ]; then
  {
    echo "🚫 $REASON_HEADER"
    echo "--- 該当行（先頭5件） ---"
    printf '%s\n' "$hits" | head -5
    echo "------------------------"
    echo "誤検出なら: git commit --no-verify で回避可（乱用は禁物）。"
  } >&2
  exit 1
fi
exit 0
