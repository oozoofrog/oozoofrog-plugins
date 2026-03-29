#!/bin/zsh
# apple-craft 테스트 스크립트
# Usage: test-apple-craft.sh [--no-e2e] [--e2e-only]

# --- 설정 ---
SCRIPT_DIR="${0:A:h}"
PLUGIN_ROOT="${SCRIPT_DIR:h}"
SYNC_SCRIPT="$SCRIPT_DIR/sync-docs.sh"
PREFLIGHT_SCRIPT="$SCRIPT_DIR/preflight.sh"
SKILL_MD="$PLUGIN_ROOT/skills/apple-craft/SKILL.md"
REF_DIR="$PLUGIN_ROOT/skills/apple-craft/references"

MOCK_DIR="$(mktemp -d)"
trap 'rm -rf "$MOCK_DIR"' EXIT

# --- 옵션 ---
NO_E2E=false
E2E_ONLY=false
for arg in "$@"; do
  case $arg in
    --no-e2e)  NO_E2E=true ;;
    --e2e-only) E2E_ONLY=true ;;
  esac
done

# --- 출력 헬퍼 ---
PASSED=0; FAILED=0; SKIPPED=0
PART_PASSED=0; PART_FAILED=0; PART_SKIPPED=0

pass() { echo "  ✅ $1"; (( ++PASSED )); (( ++PART_PASSED )); }
fail() { echo "  ❌ $1"; echo "     → $2"; (( ++FAILED )); (( ++PART_FAILED )); }
skip() { echo "  ⏭️  $1 (skip)"; (( ++SKIPPED )); (( ++PART_SKIPPED )); }
section() {
  PART_PASSED=0; PART_FAILED=0; PART_SKIPPED=0
  echo ""
  echo "━━━ $1 ━━━"
}
part_summary() {
  echo "  ── $PART_PASSED passed, $PART_FAILED failed, $PART_SKIPPED skipped"
}

# --- Assert 헬퍼 ---
assert_contains() {
  local output="$1" expected="$2" msg="$3"
  if echo "$output" | grep -q "$expected"; then
    pass "$msg"
  else
    fail "$msg" "expected to contain '$expected'"
  fi
}

assert_not_contains() {
  local output="$1" unexpected="$2" msg="$3"
  if echo "$output" | grep -q "$unexpected"; then
    fail "$msg" "should NOT contain '$unexpected'"
  else
    pass "$msg"
  fi
}

assert_file_exists() {
  local path="$1" msg="$2"
  if [[ -f "$path" ]]; then
    pass "$msg"
  else
    fail "$msg" "file not found: $path"
  fi
}

assert_exit_code() {
  local actual="$1" expected="$2" msg="$3"
  if [[ "$actual" == "$expected" ]]; then
    pass "$msg"
  else
    fail "$msg" "exit code $actual, expected $expected"
  fi
}

# --- Mock Xcode 생성 ---
setup_mock_xcode() {
  local mock_xcode="$MOCK_DIR/Xcode.app"
  local mock_docs="$mock_xcode/Contents/PlugIns/IDEIntelligenceChat.framework/Versions/A/Resources/AdditionalDocumentation"
  mkdir -p "$mock_docs"
  mkdir -p "$mock_xcode/Contents/Developer"

  # Info.plist 생성 (stdout도 suppress — PlistBuddy가 "File Doesn't Exist, Will Create:" 출력함)
  /usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string 99.0" "$mock_xcode/Contents/Info.plist" >/dev/null 2>&1
  /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string 99000" "$mock_xcode/Contents/Info.plist" >/dev/null 2>&1

  # 대표 3개 문서 (printf로 개행 처리)
  printf '# Liquid Glass SwiftUI\nglassEffect() modifier test content\n' > "$mock_docs/SwiftUI-Implementing-Liquid-Glass-Design.md"
  printf '# Swift Concurrency\n@concurrent attribute test content\n' > "$mock_docs/Swift-Concurrency-Updates.md"
  printf '# FoundationModels\nSystemLanguageModel test content\n' > "$mock_docs/FoundationModels-Using-on-device-LLM-in-your-app.md"

  echo "$mock_xcode"
}

# sync용 mock plugin 디렉토리 (테스트 간 상태 공유)
SYNC_MOCK_PLUGIN="$MOCK_DIR/sync-plugin"

setup_sync_mock() {
  mkdir -p "$SYNC_MOCK_PLUGIN/skills/apple-craft/references"
  mkdir -p "$SYNC_MOCK_PLUGIN/scripts"
  cp "$SYNC_SCRIPT" "$SYNC_MOCK_PLUGIN/scripts/sync-docs.sh"
}

reset_sync_mock() {
  rm -rf "$SYNC_MOCK_PLUGIN"
  setup_sync_mock
}

# sync 실행 헬퍼
run_sync() {
  local mock_xcode="$1"; shift
  # 첫 호출 시 초기화
  [[ ! -d "$SYNC_MOCK_PLUGIN/scripts" ]] && setup_sync_mock
  zsh "$SYNC_MOCK_PLUGIN/scripts/sync-docs.sh" --xcode-path "$mock_xcode" "$@" 2>&1
}

# preflight 실행 헬퍼
run_preflight() {
  local plugin_root="$1"
  CLAUDE_PLUGIN_ROOT="$plugin_root" zsh "$PREFLIGHT_SCRIPT" 2>&1
}

echo "=== apple-craft 테스트 ==="
echo "Mock: $MOCK_DIR"
echo "Plugin: $PLUGIN_ROOT"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Part 1: sync-docs.sh 단위 테스트
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if ! $E2E_ONLY; then

section "Part 1: sync-docs.sh 단위 테스트"

MOCK_XCODE="$(setup_mock_xcode)"
MOCK_DOCS="$MOCK_XCODE/Contents/PlugIns/IDEIntelligenceChat.framework/Versions/A/Resources/AdditionalDocumentation"

# Test 1: 최초 sync
output="$(run_sync "$MOCK_XCODE")"
ec=$?
assert_exit_code "$ec" "0" "1. 최초 sync exit 0"
assert_contains "$output" "추가:" "1. 파일 추가 카운터 출력"

# Test 2: 재실행 (변경 없음)
output="$(run_sync "$MOCK_XCODE")"
assert_contains "$output" "변경 없음: 3" "2. 재실행 시 변경 없음 3"

# Test 3: 소스 파일 변경
printf '\n# Modified content for test\n' >> "$MOCK_DOCS/Swift-Concurrency-Updates.md"
output="$(run_sync "$MOCK_XCODE")"
assert_contains "$output" "업데이트:" "3. 변경된 파일 업데이트 감지"

# Test 4: 매핑 없는 새 파일
printf '# Unknown\n' > "$MOCK_DOCS/Unknown-New-Feature.md"
output="$(run_sync "$MOCK_XCODE")"
assert_contains "$output" "매핑 없음" "4. 매핑 없는 파일 경고"
rm "$MOCK_DOCS/Unknown-New-Feature.md"

# Test 5: 소스에서 파일 삭제
rm "$MOCK_DOCS/FoundationModels-Using-on-device-LLM-in-your-app.md"
output="$(run_sync "$MOCK_XCODE")"
assert_contains "$output" "삭제:" "5. 소스 삭제 파일 감지"
# 복원
printf '# FoundationModels\nSystemLanguageModel test content\n' > "$MOCK_DOCS/FoundationModels-Using-on-device-LLM-in-your-app.md"

# Test 6: --diff-only
printf '\n# Another change\n' >> "$MOCK_DOCS/Swift-Concurrency-Updates.md"
output="$(run_sync "$MOCK_XCODE" --diff-only)"
assert_contains "$output" "diff-only" "6. --diff-only 모드 표시"

# Test 7: --force
run_sync "$MOCK_XCODE" > /dev/null 2>&1  # 먼저 정상 sync
output="$(run_sync "$MOCK_XCODE" --force)"
assert_contains "$output" "업데이트:" "7. --force 시 전부 업데이트"

# Test 8: --xcode-path 인자 없음
output="$(zsh "$SYNC_SCRIPT" --xcode-path 2>&1 || true)"
assert_contains "$output" "경로가 필요합니다" "8. --xcode-path 인자 누락 에러"

# Test 9: 존재하지 않는 경로
output="$(zsh "$SYNC_SCRIPT" --xcode-path "/nonexistent/path" 2>&1 || true)"
assert_contains "$output" "존재하지 않습니다" "9. 존재하지 않는 경로 에러"

# Test 10: _index.md 손상
local mock_p10="$MOCK_DIR/p10"
mkdir -p "$mock_p10/skills/apple-craft/references" "$mock_p10/scripts"
cp "$SYNC_SCRIPT" "$mock_p10/scripts/sync-docs.sh"
zsh "$mock_p10/scripts/sync-docs.sh" --xcode-path "$MOCK_XCODE" >/dev/null 2>&1
printf '| corrupted.md | Corrupted.md | 0 | not-a-valid-checksum |\n' >> "$mock_p10/skills/apple-craft/references/_index.md"
output="$(zsh "$mock_p10/scripts/sync-docs.sh" --xcode-path "$MOCK_XCODE" 2>&1)"
assert_contains "$output" "잘못된 체크섬" "10. 손상된 _index.md 체크섬 경고"

# Test 11: 빈 AdditionalDocumentation
local empty_xcode="$MOCK_DIR/EmptyXcode.app"
mkdir -p "$empty_xcode/Contents/PlugIns/IDEIntelligenceChat.framework/Versions/A/Resources/AdditionalDocumentation"
mkdir -p "$empty_xcode/Contents/Developer"
/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string 99.0" "$empty_xcode/Contents/Info.plist" >/dev/null 2>&1
/usr/libexec/PlistBuddy -c "Add :CFBundleVersion string 99000" "$empty_xcode/Contents/Info.plist" >/dev/null 2>&1
local mock_p11="$MOCK_DIR/p11"
mkdir -p "$mock_p11/skills/apple-craft/references" "$mock_p11/scripts"
cp "$SYNC_SCRIPT" "$mock_p11/scripts/sync-docs.sh"
output="$(zsh "$mock_p11/scripts/sync-docs.sh" --xcode-path "$empty_xcode" 2>&1 || true)"
assert_contains "$output" ".md 파일이 없습니다" "11. 빈 문서 디렉토리 에러"

# Test 12: 체크섬 정확성
local mock_p12="$MOCK_DIR/p12"
mkdir -p "$mock_p12/skills/apple-craft/references" "$mock_p12/scripts"
cp "$SYNC_SCRIPT" "$mock_p12/scripts/sync-docs.sh"
zsh "$mock_p12/scripts/sync-docs.sh" --xcode-path "$MOCK_XCODE" >/dev/null 2>&1
local ref_file="$mock_p12/skills/apple-craft/references/liquid-glass-swiftui.md"
if [[ -f "$ref_file" ]]; then
  local actual_checksum="$(shasum -a 256 "$ref_file" | awk '{print $1}')"
  local idx_12="$mock_p12/skills/apple-craft/references/_index.md"
  if grep -q "$actual_checksum" "$idx_12"; then
    pass "12. _index.md 체크섬 == 실제 파일 shasum"
  else
    fail "12. _index.md 체크섬 불일치" "actual: $actual_checksum"
  fi
else
  fail "12. 참조 파일 없음" "$ref_file"
fi

part_summary

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Part 2: preflight.sh 단위 테스트
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
section "Part 2: preflight.sh 단위 테스트"

# Test 1: CLAUDE_PLUGIN_ROOT 미설정
output="$(unset CLAUDE_PLUGIN_ROOT; zsh "$PREFLIGHT_SCRIPT" 2>&1 || true)"
assert_contains "$output" "환경 변수" "1. CLAUDE_PLUGIN_ROOT 미설정 에러"

# Test 2: references/ 없음
output="$(CLAUDE_PLUGIN_ROOT="/nonexistent" zsh "$PREFLIGHT_SCRIPT" 2>&1 || true)"
assert_contains "$output" "디렉토리" "2. references/ 없음 에러"

# Test 3: references/에 md 0개
local empty_plugin="$MOCK_DIR/empty-plugin"
mkdir -p "$empty_plugin/skills/apple-craft/references"
touch "$empty_plugin/skills/apple-craft/references/_index.md"
output="$(run_preflight "$empty_plugin")"
ec=$?
assert_exit_code "$ec" "1" "3. 빈 references/ exit 1"

# Test 4: 정상
output="$(run_preflight "$PLUGIN_ROOT")"
ec=$?
assert_exit_code "$ec" "0" "4. 정상 references/ exit 0"
assert_contains "$output" "참조 문서 확인됨" "4. 정상 출력 메시지"

part_summary

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Part 3: SKILL.md 라우팅 검증
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
section "Part 3: SKILL.md 라우팅 검증"

# Test 1: 라우팅 테이블의 모든 참조 파일 존재
local routing_files=($(grep -oE 'references/[a-z0-9-]+\.md' "$SKILL_MD" | sort -u))
local all_exist=true
local missing_files=""
for rf in "${routing_files[@]}"; do
  if [[ ! -f "$PLUGIN_ROOT/skills/apple-craft/$rf" ]]; then
    all_exist=false
    missing_files+="$rf "
  fi
done
if $all_exist; then
  pass "1. 라우팅 테이블 참조 파일 모두 존재 (${#routing_files[@]}개)"
else
  fail "1. 누락된 참조 파일" "$missing_files"
fi

# Test 2: 모든 참조 파일이 라우팅 테이블에 언급
local actual_refs=($(ls "$REF_DIR"/*.md 2>/dev/null | grep -v _index.md | xargs -I{} basename {}))
local all_mentioned=true
local orphan_files=""
for af in "${actual_refs[@]}"; do
  if ! grep -q "$af" "$SKILL_MD"; then
    all_mentioned=false
    orphan_files+="$af "
  fi
done
if $all_mentioned; then
  pass "2. 모든 참조 파일이 SKILL.md에 언급됨 (${#actual_refs[@]}개)"
else
  fail "2. SKILL.md에 누락된 파일" "$orphan_files"
fi

# Test 3: _index.md doc_count == 실제 파일 수
local index_count="$(grep 'doc_count:' "$REF_DIR/_index.md" | grep -oE '[0-9]+')"
local actual_count="${#actual_refs[@]}"
if [[ "$index_count" == "$actual_count" ]]; then
  pass "3. _index.md doc_count($index_count) == 실제 파일 수($actual_count)"
else
  fail "3. doc_count 불일치" "index=$index_count actual=$actual_count"
fi

# Test 4: 참조 파일 비어있지 않음
local all_nonempty=true
local empty_files=""
for af in "${actual_refs[@]}"; do
  local lc="$(wc -l < "$REF_DIR/$af" | tr -d ' ')"
  if (( lc < 10 )); then
    all_nonempty=false
    empty_files+="$af(${lc}줄) "
  fi
done
if $all_nonempty; then
  pass "4. 모든 참조 파일 10줄 이상"
else
  fail "4. 너무 짧은 파일" "$empty_files"
fi

part_summary

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Part 3b: Harness 구조 검증
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
section "Part 3b: Harness 구조 검증"

AGENTS_DIR="$PLUGIN_ROOT/agents"
HARNESS_SKILL="$PLUGIN_ROOT/skills/apple-harness/SKILL.md"

# Test 1: 에이전트 파일 존재 (3개)
local expected_agents=("harness-planner.md" "harness-builder.md" "harness-evaluator.md")
local agents_exist=true
local missing_agents=""
for ag in "${expected_agents[@]}"; do
  if [[ ! -f "$AGENTS_DIR/$ag" ]]; then
    agents_exist=false
    missing_agents+="$ag "
  fi
done
if $agents_exist; then
  pass "1. 에이전트 파일 3개 존재"
else
  fail "1. 누락된 에이전트" "$missing_agents"
fi

# Test 2: 에이전트 frontmatter 필수 필드 검증
local fm_ok=true
local fm_errors=""
for ag in "${expected_agents[@]}"; do
  local ag_path="$AGENTS_DIR/$ag"
  [[ ! -f "$ag_path" ]] && continue
  for field in "name:" "description:" "model:" "color:" "whenToUse:" "tools:"; do
    if ! grep -q "$field" "$ag_path"; then
      fm_ok=false
      fm_errors+="$ag:$field "
    fi
  done
done
if $fm_ok; then
  pass "2. 에이전트 frontmatter 필수 필드 (name,description,model,color,whenToUse,tools)"
else
  fail "2. 누락된 frontmatter 필드" "$fm_errors"
fi

# Test 3: harness 스킬 SKILL.md 존재
if [[ -f "$HARNESS_SKILL" ]]; then
  pass "3. apple-harness SKILL.md 존재"
else
  fail "3. apple-harness SKILL.md 없음" "$HARNESS_SKILL"
fi

# Test 4: harness 스킬에 Agent가 allowed-tools에 포함
if grep -q "Agent" "$HARNESS_SKILL" 2>/dev/null; then
  pass "4. harness SKILL.md에 Agent 도구 포함"
else
  fail "4. harness SKILL.md에 Agent 도구 누락" ""
fi

# Test 5: harness 스킬에 features.json 스키마 언급
if grep -q "features.json" "$HARNESS_SKILL" 2>/dev/null; then
  pass "5. harness SKILL.md에 features.json 스키마 정의"
else
  fail "5. features.json 스키마 누락" ""
fi

# Test 6: 기존 SKILL.md에 harness 크로스레퍼런스
if grep -q "apple-harness" "$SKILL_MD"; then
  pass "6. apple-craft SKILL.md에 harness 크로스레퍼런스"
else
  fail "6. harness 크로스레퍼런스 누락" ""
fi

# Test 7: 에이전트 whenToUse에 자동 호출 방지 문구
local guard_ok=true
for ag in "${expected_agents[@]}"; do
  local ag_path="$AGENTS_DIR/$ag"
  [[ ! -f "$ag_path" ]] && continue
  if ! grep -q "직접 호출하지 마세요" "$ag_path"; then
    guard_ok=false
  fi
done
if $guard_ok; then
  pass "7. 에이전트 whenToUse에 자동 호출 방지 문구"
else
  fail "7. 자동 호출 방지 문구 누락" ""
fi

part_summary

fi  # !E2E_ONLY

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Part 4: 사용 시나리오 E2E 테스트
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if ! $NO_E2E; then

section "Part 4: 사용 시나리오 E2E 테스트"

# Claude CLI 존재 확인
if ! command -v claude &>/dev/null; then
  skip "1-6. Claude CLI 미설치 — E2E 테스트 전체 스킵"
  skip ""
  skip ""
  skip ""
  skip ""
  skip ""
  part_summary
else
  E2E_TIMEOUT=120

  run_claude_test() {
    local prompt="$1" expected="$2" msg="$3"
    local output
    output="$(timeout $E2E_TIMEOUT claude -p --model sonnet "$prompt" 2>&1 || true)"
    if [[ -z "$output" ]]; then
      fail "$msg" "출력 없음 (타임아웃 또는 에러)"
      return
    fi
    # 여러 키워드 중 하나라도 매칭
    local IFS='|'
    local keywords=($expected)
    for kw in "${keywords[@]}"; do
      if echo "$output" | grep -qi "$kw"; then
        pass "$msg"
        return
      fi
    done
    fail "$msg" "출력에 '$expected' 없음 (${#output}자)"
  }

  run_claude_test \
    "Liquid Glass가 뭐야? 간단히 설명해" \
    "glassEffect|liquid-glass|Glass|유리" \
    "1. explore: Liquid Glass 설명"

  run_claude_test \
    "FoundationModels로 세션 만드는 코드 작성해줘" \
    "LanguageModelSession|SystemLanguageModel|FoundationModels" \
    "2. implement: FoundationModels 코드 생성"

  run_claude_test \
    "glassEffect 사용하면 빌드 에러가 나는데 어떻게 해결해?" \
    "GlassEffectContainer|glassEffect|liquid-glass|import SwiftUI" \
    "3. troubleshoot: Liquid Glass 에러 해결"

  run_claude_test \
    "리퀴드 글라스 적용 방법 알려줘" \
    "glassEffect|liquid-glass|Glass" \
    "4. 한국어 키워드: 리퀴드 글라스"

  run_claude_test \
    "위젯에 Liquid Glass 적용하는 방법" \
    "liquid-glass-widgetkit|widgetRenderingMode|WidgetKit|widget" \
    "5. 복합 주제: 위젯 + Liquid Glass"

  run_claude_test \
    "Swift 6.2의 @concurrent 속성 설명해줘" \
    "@concurrent|swift-concurrency|background|nonisolated" \
    "6. Xcode MCP 미연결: Swift 6.2 설명"

  part_summary
fi

fi  # !NO_E2E

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 최종 요약
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "=== apple-craft 테스트 결과 ==="
echo "  Total: $PASSED passed, $FAILED failed, $SKIPPED skipped"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if (( FAILED > 0 )); then
  exit 1
fi
