# 测试框架配置

本项目使用 [GUT](https://github.com/bitwes/Gut) 作为单元测试框架。

## 安装 GUT

1. 打开 Godot Asset Library 或手动下载 GUT 插件
2. 将 GUT 插件解压到 `addons/gut/` 目录
3. 在 Godot 项目设置中启用 GUT 插件

## 运行测试

```bash
godot --headless --script addons/gut/gut_cmdln.gd -gdir=res://tests/
```

## 测试结构

```
tests/
├── unit/
│   ├── test_player_stats.gd
│   └── test_element_system.gd
└── README.md
```

## 已包含的测试

- `test_player_stats.gd` - PlayerStats 资源测试
- `test_element_system.gd` - 元素系统克制关系测试

## 编写新测试

在 `tests/unit/` 目录下创建新的测试文件，继承 `GutTest`：

```gdscript
extends GutTest

func test_my_feature():
    assert_eq(expected, actual)
```
