#!/bin/bash
# Claude Code ステータスライン表示スクリプト
# settings.json の statusLine.command に指定して使う
# stdin から JSON を受け取り、1〜2行のテキストを stdout に出力する

input=$(cat)

# --- モデル情報 ---
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')

# --- コスト ---
COST_USD=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')           # セッション累計コスト（USD）
COST_JPY=$(echo "$COST_USD * 160" | bc -l | xargs printf '%.1f')        # JPY換算（固定レート 160円/ドル）

# --- 時間 ---
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')     # セッション経過時間（ms）
API_DURATION_MS=$(echo "$input" | jq -r '.cost.total_api_duration_ms // 0') # うちAPIの待ち時間（ms）
MINS=$((DURATION_MS / 60000))
SECS=$(((DURATION_MS % 60000) / 1000))
API_MINS=$((API_DURATION_MS / 60000))
API_SECS=$(((API_DURATION_MS % 60000) / 1000))

# --- コンテキストウィンドウ ---
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')   # 入力トークン累計
OUTPUT_TOKENS=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0') # 出力トークン累計
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1) # 使用率（%）

# --- コード変更行数 ---
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')     # セッションで追加した行数
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0') # セッションで削除した行数

# --- Gitブランチ（git管理外ディレクトリでは非表示） ---
BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && BRANCH=" | 🌿 $(git branch --show-current 2>/dev/null)"

# --- 出力（2行） ---
echo "[$MODEL]$BRANCH"
echo "💰 ¥${COST_JPY} | ⏱️ ${MINS}m ${SECS}s (API: ${API_MINS}m ${API_SECS}s) | ctx: ${PCT}% (in: ${INPUT_TOKENS}, out: ${OUTPUT_TOKENS}) | +${LINES_ADDED} -${LINES_REMOVED}"
