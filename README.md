# Penalty Shootout

一款最小 2D 点球游戏，使用 Godot 4.7 开发。

模拟球门后方视角，守门员需在球门框内移动接球，每次成功扑救 +1 分，球进门则游戏结束。

## v0.1.0 已实现

- 2D 点球核心玩法（球门视角、守门员移动、球随机发射）
- 轨迹拖尾效果（Line2D）
- 计分系统 + 失败结算
- 开始 / 重新开始界面
- 运行时纹理生成（无需外部资源）
- 数据版本 1

## 启动

用 Godot 4.7 打开本项目，运行 Main.tscn。

操控方式：
- 方向键 / WASD 移动守门员
- 鼠标在球门框内直接定位守门员

## 项目结构

```
football-game/
├── AGENTS.md            # 工作规则
├── README.md            # 发布说明
├── PROJECT_GOAL.md      # 产品上下文
├── scenes/              # Godot 场景
│   ├── Main.tscn        # 主场景
│   ├── Ball.tscn        # 足球场景
│   └── Goalkeeper.tscn  # 守门员场景
├── scripts/             # GDScript 脚本
│   ├── main.gd          # 主场景控制 + 渲染
│   ├── ball.gd          # 足球逻辑
│   ├── goalkeeper.gd    # 守门员逻辑
│   ├── game_manager.gd  # 游戏状态管理 (autoload)
│   └── getgoal.gd       # UI 逻辑
├── assets/
│   ├── sprites/         # 精灵资源
│   └── audio/           # 音频资源
├── ui/
│   └── Getgoal.tscn     # UI 场景
└── .omo/                # 自动化脚本
```

## 跨环境继续开发

完整产品上下文、已完成版本和持续开发规则保存在 PROJECT_GOAL.md，
AGENTS.md 会要求新环境在修改前读取该文件。换电脑后克隆仓库即可恢复开发上下文。

每轮开发检查仓库开放 Issues：可执行的回复并纳入版本，完成发布后再回复提交、标签和上线状态并关闭。

## 小版本路线

- v0.1.0：项目初始化，最小 2D 点球游戏
