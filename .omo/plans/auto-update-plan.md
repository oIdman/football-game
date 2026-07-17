# Auto-Update Workflow Plan

自主目标驱动开发工作流。AI 每轮自主评估→决策→实现→双写→发布。

## Phases

### Phase 0: 自我评估
- [ ] 读取 AGENTS.md 了解工作规则和硬约束
- [ ] `git status -sb` + `git log -5 --oneline --decorate`
- [ ] 检查 GitHub Issues（gh issue list）
- [ ] 完整读取 PROJECT_GOAL.md，关注"当前进度"表和"下一版本分析"
- [ ] 自主决策优先级：开放 Issues → 下一版本方向 → 代码自检
- Acceptance: 决策完成

### Phase 1: 实现
- [ ] 实现决策的功能/修复
- [ ] 如果是对应 Issue，在 Issue 回复"已纳入当前版本"
- Acceptance: 代码完成

### Phase 2: 验证 + 双写
- [ ] Godot 编辑器或 CLI 验证无报错
- [ ] 更新 PROJECT_GOAL.md "当前进度"表 + "版本详细记录"
- [ ] 更新 PROJECT_GOAL.md "Issue处理记录"（如有）
- [ ] 更新 README.md 发布说明
- Acceptance: 双写完成

### Phase 3: 发布
- [ ] Commit（语义化风格）
- [ ] 创建版本标签
- [ ] Push main + tags
- Acceptance: GitHub 可见
