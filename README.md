# releases

应用自动更新发布仓库 — 各项目构建产物和版本信息。

## 结构

```
releases/
├── README.md                 ← 本文件
├── scripts/                  ← 各项目本地构建脚本
│   ├── build-ai-col-lab.sh
│   └── ...
├── .github/workflows/        ← CI 自动构建
│   ├── build.yml
│   └── ...
│
├── <project-id>/             ← 每个项目独立子目录
│   └── latest.json           ← 最新版本信息（客户端查询用）
│
└── Releases                  ← GitHub Releases 页面存放安装包
```

## 已有项目

| 项目 | 目录 | 来源 |
|------|------|------|
| AI Col Lab | `ai-col-lab/` | 私有仓 `humanghosts/collaboration`，Flutter 桌面应用 |

## 新增项目

1. 在 `scripts/` 下新建构建脚本（参考 `build-ai-col-lab.sh`）
2. 在 `.github/workflows/` 下新建 CI 工作流（参考 `build.yml`）
3. 触发构建即可，脚本会自动创建对应子目录和 `latest.json`

## 客户端查询

```
GET https://raw.githubusercontent.com/humanghosts/releases/main/<project-id>/latest.json
```

返回示例：

```json
{
  "projectName": "AI Col Lab",
  "version": "0.0.1",
  "tag": "v0.0.1",
  "releasedAt": "2026-06-10T12:00:00Z",
  "releaseUrl": "https://github.com/humanghosts/releases/releases/tag/v0.0.1",
  "artifacts": {
    "windows": {
      "name": "ai-col-lab-windows-x64.zip",
      "url": "https://github.com/humanghosts/releases/releases/download/v0.0.1/ai-col-lab-windows-x64.zip",
      "size": 12345678
    }
  }
}
```
