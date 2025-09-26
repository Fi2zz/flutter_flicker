# Flicker 📅

[![pub package](https://img.shields.io/pub/v/flutter_flicker.svg)](https://pub.dev/packages/flutter_flicker)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-blue.svg)](https://flutter.dev/)

**中文** | [English](README.md)

一个现代化、高度可定制且性能优异的 Flutter 日期选择器组件，支持多种选择模式、自定义样式和灵活布局。

## ✨ 特性

### 🎯 多种选择模式
- **单选模式**: 一次选择一个日期
- **范围模式**: 选择连续的日期范围
- **多选模式**: 选择多个独立日期

### 🎨 丰富的自定义功能
- 自定义日期单元格构建器，完全控制 UI
- 全面的主题系统，支持明暗模式
- 禁用日期支持，带验证回调
- 灵活的布局选项（水平/垂直滚动）
- 多月显示（同时显示 1 或 2 个月）

### 🌍 国际化支持
- 本地化感知的日期格式
- 可配置的一周首日
- 支持多种语言（英文、中文）

### ⚡ 高性能
- 高效的网格管理和懒加载
- 优化的渲染，确保流畅滚动
- 内存友好的日期生成
- 使用信号模式的响应式更新

## 📱 截图

*截图即将添加*

## 🚀 快速开始

### 安装

在您的 `pubspec.yaml` 文件中添加：

```yaml
dependencies:
  flutter_flicker: ^1.0.0
```

然后运行：

```bash
flutter pub get
```

### 基本用法

```dart
import 'package:flutter_flicker/flutter_flicker.dart';

// 简单的单日期选择
Flicker(
  onValueChange: (dates) {
    print('选择的日期: $dates');
  },
)

// 带约束的日期范围选择
Flicker(
  mode: SelectionMode.range,
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 365)),
  onValueChange: (dates) {
    if (dates.length == 2) {
      print('范围: ${dates.first} 到 ${dates.last}');
    }
  },
)

// 带自定义主题的多日期选择
Flicker(
  mode: SelectionMode.multiple,
  theme: FlickerTheme.dark(),
  selectionCount: 5, // 限制最多选择 5 个日期
  onValueChange: (dates) {
    print('已选择 ${dates.length} 个日期');
  },
)
```

## 📖 文档

### 选择模式

| 模式 | 描述 | 使用场景 |
|------|------|----------|
| `SelectionMode.single` | 选择单个日期 | 预约预订、生日选择 |
| `SelectionMode.range` | 选择日期范围 | 酒店预订、假期规划 |
| `SelectionMode.multiple` | 选择多个日期 | 活动策划、可用性标记 |

### 主要属性

| 属性 | 类型 | 默认值 | 描述 |
|------|------|--------|------|
| `mode` | `SelectionMode` | `single` | 选择行为 |
| `value` | `List<DateTime>` | `[]` | 当前选中的日期 |
| `startDate` | `DateTime?` | `null` | 最小可选日期 |
| `endDate` | `DateTime?` | `null` | 最大可选日期 |
| `disabledDate` | `bool Function(DateTime)?` | `null` | 自定义日期验证 |
| `onValueChange` | `ValueChanged<List<DateTime>>` | 必需 | 选择回调 |
| `theme` | `FlickerTheme?` | `null` | 自定义主题 |
| `viewCount` | `int` | `1` | 月份数量（1 或 2） |
| `scrollDirection` | `Axis` | `horizontal` | 滚动方向 |
| `firstDayOfWeek` | `FirstDayOfWeek` | `monday` | 一周开始日 |

### 主题设置

```dart
// 浅色主题
Flicker(
  theme: FlickerTheme.light(),
  // ... 其他属性
)

// 深色主题
Flicker(
  theme: FlickerTheme.dark(),
  // ... 其他属性
)

// 自定义主题
Flicker(
  theme: FlickerTheme(
    useDarkMode: false,
    // 自定义主题属性
  ),
  // ... 其他属性
)
```

### 自定义日期构建器

```dart
Flicker(
  dayBuilder: (context, date, isSelected, isDisabled) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.transparent,
        shape: BoxShape.circle,
        border: isDisabled ? Border.all(color: Colors.grey) : null,
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: isDisabled ? Colors.grey : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  },
  // ... 其他属性
)
```

## 🌐 国际化

Flicker 支持多种语言环境并提供内置本地化：

```dart
MaterialApp(
  localizationsDelegates: FlickerL10n.localizationsDelegates,
  supportedLocales: FlickerL10n.supportedLocales,
  home: MyApp(),
)
```

支持的语言环境：
- 英语 (en-US)
- 中文 (zh-CN)

## 🎯 示例

查看 [example](example/) 目录获取展示所有功能的完整演示应用。

运行示例：

```bash
cd example
flutter run
```

## 🤝 贡献

欢迎贡献！请随时提交 Pull Request。

1. Fork 这个仓库
2. 创建您的功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交您的更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 打开一个 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- Flutter 团队提供的出色框架
- 贡献者和社区反馈
- 各种日期选择器实现的灵感

---

由 Flutter 社区用 ❤️ 制作