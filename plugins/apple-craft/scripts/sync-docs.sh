#!/bin/zsh
set -euo pipefail

# apple-craft: Xcode AdditionalDocumentation → references/ 동기화 스크립트
# Usage: sync-docs.sh [--xcode-path PATH] [--diff-only] [--force] [--help]

# --- zsh 버전 가드 ---
if [[ -z "${ZSH_VERSION:-}" ]]; then
  echo "Error: 이 스크립트는 zsh가 필요합니다. 실행: zsh $0" >&2
  exit 1
fi

SCRIPT_DIR="${0:A:h}"
PLUGIN_ROOT="${SCRIPT_DIR:h}"
REF_DIR="$PLUGIN_ROOT/skills/apple-craft/references"

# --- 부분 동기화 경고용 trap ---
SYNC_COMPLETE=false
trap 'if ! $SYNC_COMPLETE; then echo "Warning: 동기화 중 중단됨. references/ 디렉토리가 불완전할 수 있습니다. --force 옵션으로 재실행하세요." >&2; fi' EXIT

# --- Options ---
XCODE_PATH=""
DIFF_ONLY=false
FORCE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --xcode-path)
      if [[ $# -lt 2 ]]; then
        echo "Error: --xcode-path 옵션에 경로가 필요합니다." >&2
        exit 1
      fi
      XCODE_PATH="$2"; shift 2 ;;
    --diff-only)  DIFF_ONLY=true; shift ;;
    --force)      FORCE=true; shift ;;
    --help|-h)
      echo "Usage: sync-docs.sh [options]"
      echo "  --xcode-path PATH  Xcode.app 경로 직접 지정"
      echo "  --diff-only        변경 사항만 표시 (복사하지 않음)"
      echo "  --force            체크섬 일치해도 강제 복사"
      echo "  --help             도움말"
      SYNC_COMPLETE=true
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# --- Xcode 자동 탐지 ---
detect_xcode() {
  if [[ -n "$XCODE_PATH" ]]; then
    if [[ -d "$XCODE_PATH" ]]; then
      echo "$XCODE_PATH"
      return 0
    else
      echo "Error: 지정된 경로가 존재하지 않습니다: $XCODE_PATH" >&2
      exit 1
    fi
  fi

  local dev_path
  dev_path="$(xcode-select -p 2>/dev/null || true)"
  if [[ -n "$dev_path" ]]; then
    local xcode_app="${dev_path%/Contents/Developer}"
    if [[ -d "$xcode_app/Contents/PlugIns" ]]; then
      echo "$xcode_app"
      return 0
    fi
  fi

  for path in \
    "/Applications/Xcode.app" \
    "/Applications/Xcode-beta.app" \
    /Volumes/*/Applications/Xcode.app(N) \
    /Volumes/*/Applications/Xcode-beta.app(N); do
    if [[ -d "$path/Contents/PlugIns" ]]; then
      echo "$path"
      return 0
    fi
  done

  echo "Error: Xcode.app를 찾을 수 없습니다. --xcode-path 옵션을 사용하세요." >&2
  exit 1
}

XCODE_APP="$(detect_xcode)"
DOCS_DIR="$XCODE_APP/Contents/PlugIns/IDEIntelligenceChat.framework/Versions/A/Resources/AdditionalDocumentation"

if [[ ! -d "$DOCS_DIR" ]]; then
  echo "Error: AdditionalDocumentation 디렉토리를 찾을 수 없습니다:" >&2
  echo "  $DOCS_DIR" >&2
  exit 1
fi

# --- Xcode 버전 정보 (실패 시 경고) ---
XCODE_VERSION="$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$XCODE_APP/Contents/Info.plist" 2>/dev/null || true)"
if [[ -z "$XCODE_VERSION" ]]; then
  echo "Warning: Xcode 버전을 읽을 수 없습니다: $XCODE_APP/Contents/Info.plist" >&2
  XCODE_VERSION="unknown"
fi

XCODE_BUILD="$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$XCODE_APP/Contents/Info.plist" 2>/dev/null || true)"
if [[ -z "$XCODE_BUILD" ]]; then
  echo "Warning: Xcode 빌드 번호를 읽을 수 없습니다" >&2
  XCODE_BUILD="unknown"
fi

echo "=== apple-craft doc sync ==="
echo "Xcode: $XCODE_APP (v$XCODE_VERSION, build $XCODE_BUILD)"
echo "Source: $DOCS_DIR"
echo "Target: $REF_DIR"
echo ""

# --- 파일명 매핑 (Xcode 원본 → 로컬 간결명) ---
typeset -A FILE_MAP
FILE_MAP=(
  "SwiftUI-Implementing-Liquid-Glass-Design.md"     "liquid-glass-swiftui.md"
  "UIKit-Implementing-Liquid-Glass-Design.md"        "liquid-glass-uikit.md"
  "AppKit-Implementing-Liquid-Glass-Design.md"       "liquid-glass-appkit.md"
  "WidgetKit-Implementing-Liquid-Glass-Design.md"    "liquid-glass-widgetkit.md"
  "FoundationModels-Using-on-device-LLM-in-your-app.md" "foundation-models.md"
  "Swift-Concurrency-Updates.md"                     "swift-concurrency.md"
  "Swift-InlineArray-Span.md"                        "swift-inline-array-span.md"
  "SwiftData-Class-Inheritance.md"                   "swiftdata-inheritance.md"
  "Implementing-Visual-Intelligence-in-iOS.md"       "visual-intelligence.md"
  "SwiftUI-AlarmKit-Integration.md"                  "alarmkit.md"
  "SwiftUI-WebKit-Integration.md"                    "webkit-swiftui.md"
  "StoreKit-Updates.md"                              "storekit-updates.md"
  "Swift-Charts-3D-Visualization.md"                 "charts-3d.md"
  "MapKit-GeoToolbox-PlaceDescriptors.md"            "mapkit-geotoolbox.md"
  "AppIntents-Updates.md"                            "appintents-updates.md"
  "Foundation-AttributedString-Updates.md"           "attributedstring-updates.md"
  "SwiftUI-New-Toolbar-Features.md"                  "swiftui-toolbar.md"
  "SwiftUI-Styled-Text-Editing.md"                   "styled-text.md"
  "Implementing-Assistive-Access-in-iOS.md"          "assistive-access.md"
  "Widgets-for-visionOS.md"                          "visionos-widgets.md"
)

# --- 기존 체크섬 로드 (로버스트 파싱) ---
typeset -A OLD_CHECKSUMS
INDEX_FILE="$REF_DIR/_index.md"
if [[ -f "$INDEX_FILE" ]]; then
  while IFS= read -r line; do
    # 테이블 행만 처리 (|로 시작하는 행)
    [[ "$line" != \|* ]] && continue
    # 최소 5개 | 필요 (4 데이터 컬럼)
    local pipe_count="${#line//[^|]/}"
    (( pipe_count < 5 )) && continue

    IFS='|' read -r _ local_file _ _ checksum _ <<< "$line"
    local_file="${${local_file## }%% }"
    checksum="${${checksum## }%% }"

    # 헤더 행과 구분선 스킵
    [[ "$local_file" == "Local File" || "$local_file" == -* ]] && continue
    # SHA256 형식 검증 (64자리 hex)
    if [[ ! "$checksum" =~ ^[0-9a-f]{64}$ ]]; then
      [[ -n "$checksum" ]] && echo "Warning: 잘못된 체크섬 무시: $local_file" >&2
      continue
    fi
    OLD_CHECKSUMS[$local_file]="$checksum"
  done < "$INDEX_FILE"
fi

# --- 동기화 ---
ADDED=0
UPDATED=0
UNCHANGED=0
UNMAPPED=0

INDEX_ROWS=""
typeset -A SEEN_LOCAL

mkdir -p "$REF_DIR"

# 빈 glob 안전 처리
local md_files=("$DOCS_DIR"/*.md(N))
if (( ${#md_files[@]} == 0 )); then
  echo "Error: AdditionalDocumentation 디렉토리에 .md 파일이 없습니다: $DOCS_DIR" >&2
  exit 1
fi

for src_file in "${md_files[@]}"; do
  src_name="${src_file:t}"
  local_name="${FILE_MAP[$src_name]:-}"

  if [[ -z "$local_name" ]]; then
    echo "⚠️  매핑 없음 (신규?): $src_name"
    (( ++UNMAPPED ))
    continue
  fi

  SEEN_LOCAL[$local_name]=1

  if ! new_checksum="$(shasum -a 256 "$src_file" | awk '{print $1}')"; then
    echo "Error: 체크섬 계산 실패: $src_name" >&2
    exit 1
  fi
  line_count="$(wc -l < "$src_file" | tr -d ' ')"
  old_checksum="${OLD_CHECKSUMS[$local_name]:-}"

  if [[ "$new_checksum" == "$old_checksum" && "$FORCE" == "false" ]]; then
    (( ++UNCHANGED ))
  elif [[ -f "$REF_DIR/$local_name" ]]; then
    if $DIFF_ONLY; then
      echo "📝 변경됨: $local_name ($src_name)"
      diff --unified=3 "$REF_DIR/$local_name" "$src_file" | head -30 || true
      echo ""
    else
      if ! cp "$src_file" "$REF_DIR/$local_name"; then
        echo "Error: 파일 복사 실패: $src_name → $local_name" >&2
        exit 1
      fi
      echo "📝 업데이트: $local_name"
    fi
    (( ++UPDATED ))
  else
    if $DIFF_ONLY; then
      echo "✨ 신규: $local_name ($src_name, ${line_count}줄)"
    else
      if ! cp "$src_file" "$REF_DIR/$local_name"; then
        echo "Error: 파일 복사 실패: $src_name → $local_name" >&2
        exit 1
      fi
      echo "✨ 추가: $local_name (${line_count}줄)"
    fi
    (( ++ADDED ))
  fi

  INDEX_ROWS+="| $local_name | $src_name | $line_count | $new_checksum |"$'\n'
done

# --- 삭제된 파일 감지 (SEEN_LOCAL 기반, O(n)) ---
REMOVED=0
for local_name in ${(v)FILE_MAP}; do
  if [[ -z "${SEEN_LOCAL[$local_name]:-}" && -f "$REF_DIR/$local_name" ]]; then
    if $DIFF_ONLY; then
      echo "🗑️  삭제 예정: $local_name"
    else
      if ! rm "$REF_DIR/$local_name"; then
        echo "Error: 파일 삭제 실패: $local_name" >&2
        exit 1
      fi
      echo "🗑️  삭제: $local_name"
    fi
    (( ++REMOVED ))
  fi
done

# --- _index.md 생성 ---
if ! $DIFF_ONLY; then
  TOTAL=$((ADDED + UPDATED + UNCHANGED))
  cat > "$INDEX_FILE" << EOF
---
xcode_version: "$XCODE_VERSION"
xcode_build: "$XCODE_BUILD"
xcode_path: "$XCODE_APP"
sync_date: "$(date +%Y-%m-%d)"
doc_count: $TOTAL
---

# apple-craft Reference Index

Xcode $XCODE_VERSION (build $XCODE_BUILD) AdditionalDocumentation sync 결과.

| Local File | Xcode Original | Lines | SHA256 |
|------------|---------------|-------|--------|
${INDEX_ROWS}
EOF
  echo ""
  echo "📋 _index.md 갱신 완료"
fi

# --- 결과 요약 ---
echo ""
echo "=== 동기화 결과 ==="
echo "  ✨ 추가: $ADDED"
echo "  📝 업데이트: $UPDATED"
echo "  ✅ 변경 없음: $UNCHANGED"
echo "  🗑️  삭제: $REMOVED"
if [[ $UNMAPPED -gt 0 ]]; then
  echo "  ⚠️  매핑 없음: $UNMAPPED (FILE_MAP에 추가 필요)"
fi
echo ""

if $DIFF_ONLY; then
  echo "(--diff-only 모드: 파일이 복사되지 않았습니다)"
fi

SYNC_COMPLETE=true
