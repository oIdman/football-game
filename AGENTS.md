# Penalty Shootout — 开发说明

在修改本仓库前，必须完整阅读 PROJECT_GOAL.md。该文件是产品目标、版本进度、
Issue 状态和持续开发规则的唯一长期来源。不要把目标缩减为当前已完成的功能。

## 工作规则

- 保持 Godot 4.7 + GDScript 技术栈。
- 每次只完成一个可独立使用的最小版本。
- 每次修改必须用 Godot 编辑器或 CLI 打开项目验证无报错。
- 每次完成后更新 PROJECT_GOAL.md 的"当前进度"表和 README.md。
- 每轮开始时检查 GitHub Issues：可执行的回复并纳入版本，需澄清的回复问题并保持开放；
  发布后在 Issue 回复版本号、提交和结果并关闭。
- 提交信息使用语义化风格（feat/fix/chore）。
- 创建对应版本标签并推送 main 与标签。不改写已推送的历史，不丢弃已有功能。

## 项目结构

```
football-game/
├── AGENTS.md            # 工作规则（本文件）
├── README.md            # 发布说明
├── PROJECT_GOAL.md      # 产品上下文（必须先读）
├── scenes/              # Godot 场景文件
├── scripts/             # GDScript 脚本
├── assets/              # 资源文件（图片、音频）
├── ui/                  # UI 场景
└── .omo/                # 自动化脚本
```
