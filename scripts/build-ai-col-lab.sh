#!/bin/bash
# ============================================================
# AI Col Lab - 本地构建脚本
# ============================================================
# 用途: 从 ohoda monorepo 构建 Windows 安装包，发布到 releases
# 使用: bash build-ai-col-lab.sh v0.0.1
#
# 前置条件:
#   - Flutter SDK 3.24+ (https://flutter.dev)
#   - Git (已登录 github.com)
#   - gh CLI (https://cli.github.com) 并已认证
#   - zip / unzip
# ============================================================
set -euo pipefail
SOURCE_REPO="humanghosts/ohoda"
PUBLIC_REPO="humanghosts/releases"
FLUTTER_DIR="ai_col_lab"
PROJECT_ID="ai-col-lab"
PROJECT_NAME="AI Col Lab"
TAG="${1:-}"
if [ -z "$TAG" ]; then
  echo "用法: bash build-ai-col-lab.sh <版本号>"
  echo "示例: bash build-ai-col-lab.sh v0.0.2"
  exit 1
fi
VERSION="${TAG#v}"
WORKDIR="$(mktemp -d)"
echo "[1/7] 工作目录: $WORKDIR"

# 1. Clone ohoda monorepo
echo "[2/7] Clone ohoda monorepo..."
cd "$WORKDIR"
git clone "git@github.com:$SOURCE_REPO.git" --branch master ohoda 2>/dev/null || \
gh repo clone "$SOURCE_REPO" ohoda
cd ohoda

# 2. Init submodule (collaboration skills)
echo "[3/7] Init collaboration submodule..."
git submodule update --init --remote --recursive

# 3. Resolve workspace + install deps
echo "[4/7] Flutter 构建..."
dart pub get
cd "$FLUTTER_DIR"
flutter pub get
flutter build windows --release

# 4. 打包技能
echo "[5/7] 打包技能文件..."
cp -r "$WORKDIR/ohoda/collaboration/standard" "build/windows/x64/runner/Release/data/flutter_assets/standard"

# 5. 打包安装包
echo "[6/7] 打包 tar.gz..."
ARCHIVE="${PROJECT_ID}-windows-x64.tar.gz"
cd build/windows/x64/runner/Release
tar -czf "$WORKDIR/$ARCHIVE" .
cd "$WORKDIR"
SIZE=$(stat -c%s "$ARCHIVE" 2>/dev/null || stat -f%z "$ARCHIVE")
echo "产物: $ARCHIVE ($(( SIZE / 1024 / 1024 ))MB)"

# 6. 上传 Release
echo "[7/7] 发布..."
gh release create "$TAG" "$ARCHIVE" \
  -R "$PUBLIC_REPO" \
  --title "$PROJECT_NAME $VERSION" \
  --notes "手动构建 - $TAG" \
  --prerelease

# 7. 更新 latest.json
DOWNLOAD_BASE="https://github.com/$PUBLIC_REPO/releases/download/$TAG"
RELEASED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
jq -n \
  --arg projectName "$PROJECT_NAME" \
  --arg version "$VERSION" \
  --arg tag "$TAG" \
  --arg releasedAt "$RELEASED_AT" \
  --arg releaseUrl "https://github.com/$PUBLIC_REPO/releases/tag/$TAG" \
  --arg winName "$ARCHIVE" \
  --arg winUrl "${DOWNLOAD_BASE}/${ARCHIVE}" \
  --argjson winSize "$SIZE" '{
    projectName: $projectName,
    version: $version,
    tag: $tag,
    releasedAt: $releasedAt,
    releaseUrl: $releaseUrl,
    artifacts: {
      windows: { name: $winName, url: $winUrl, size: $winSize }
    }
  }' > latest.json

CONTENT_B64=$(base64 -w0 latest.json 2>/dev/null || base64 latest.json | tr -d '\n')
SHA=$(gh api "repos/$PUBLIC_REPO/contents/$PROJECT_ID/latest.json" --jq '.sha' 2>/dev/null || echo "")
if [ -n "$SHA" ]; then
  gh api "repos/$PUBLIC_REPO/contents/$PROJECT_ID/latest.json" -X PUT \
    -f message="Update $PROJECT_ID/latest.json: $VERSION" \
    -f content="$CONTENT_B64" \
    -f sha="$SHA"
else
  gh api "repos/$PUBLIC_REPO/contents/$PROJECT_ID/latest.json" -X PUT \
    -f message="Create $PROJECT_ID/latest.json: $VERSION" \
    -f content="$CONTENT_B64"
fi

echo ""
echo "========================================"
echo "  构建完成!"
echo "  查看: https://github.com/$PUBLIC_REPO/releases/tag/$TAG"
echo "========================================"
