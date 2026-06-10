# 构建脚本目录

每个子目录或脚本对应一个应用的构建流程。

## 已有项目

| 项目 | 脚本 | 说明 |
|------|------|------|
| AI Col Lab | `build-ai-col-lab.sh` | Flutter Windows 应用，源码在私有仓 `humanghosts/collaboration` |

## 新增项目

1. 复制一份脚本，修改 `PRIVATE_REPO`、`PROJECT_ID`、`PROJECT_NAME` 等变量
2. 新建对应的 CI workflow 文件 `.github/workflows/build-xxx.yml`
3. 触发构建: `gh workflow run build-xxx.yml -R humanghosts/releases -f tag=v1.0.0`

## CI vs 本地构建

| 方式 | 触发 | 使用场景 |
|------|------|----------|
| 本地脚本 | `bash scripts/build-ai-col-lab.sh v0.0.2` | 本地有 Flutter SDK 时直接构建发布 |
| GitHub Actions | `gh workflow run` | 没有本地环境或需要 CI 自动化时 |
