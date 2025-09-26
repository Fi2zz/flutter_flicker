# Flicker 日期选择器使用文档

Flicker 是一个高度可定制且性能优异的 Flutter 日期选择器组件，支持多种选择模式、自定义样式和灵活布局。

## 目录

- [核心特性](#核心特性)
- [快速开始](#快速开始)
- [API 参考](#api-参考)
- [选择模式](#选择模式)
- [主题配置](#主题配置)
- [高级用法](#高级用法)
- [示例代码](#示例代码)
- [最佳实践](#最佳实践)

## 核心特性

### 🎯 选择模式

- **单选模式 (Single)**: 一次选择一个日期
- **范围模式 (Range)**: 选择连续的日期范围
- **多选模式 (Multiple)**: 选择多个独立日期

### 🎨 自定义功能

- 自定义日期单元格构建器，完全控制 UI
- 全面的主题系统，支持明暗模式
- 禁用日期支持，带验证回调
- 灵活的布局选项（水平/垂直滚动）
- 多月显示（同时显示 1 或 2 个月）

### 🌍 国际化

- 本地化感知的日期格式
- 可配置的一周首日

## 快速开始

### 基本安装

```dart
import 'package:flutter_flicker/flutter_flicker.dart';
```

### 最简单的使用

```dart
Flicker(
  onValueChange: (dates) {
    print('选择的日期: $dates');
  },
)
```

## API 参考

### 构造函数参数

| 参数              | 类型                        | 默认值                  | 描述                   |
| ----------------- | --------------------------- | ----------------------- | ---------------------- |
| `mode`            | `SelectionMode?`            | `SelectionMode.single`  | 选择模式               |
| `value`           | `List<DateTime>`            | `[]`                    | 当前选中的日期列表     |
| `startDate`       | `DateTime?`                 | `null`                  | 最小可选日期（包含）   |
| `endDate`         | `DateTime?`                 | `null`                  | 最大可选日期（包含）   |
| `disabledDate`    | `bool Function(DateTime)?`  | `null`                  | 禁用日期判断函数       |
| `onValueChange`   | `Function(List<DateTime>)?` | `null`                  | 选择变化回调           |
| `dayBuilder`      | `DayBuilder?`               | `null`                  | 自定义日期单元格构建器 |
| `firstDayOfWeek`  | `FirstDayOfWeek?`           | `FirstDayOfWeek.monday` | 一周的第一天           |
| `theme`           | `FlickerTheme?`             | `null`                  | 自定义主题配置         |
| `viewCount`       | `int?`                      | `1`                     | 同时显示的月份数量     |
| `scrollDirection` | `Axis?`                     | `Axis.horizontal`       | 滚动方向               |
| `selectionCount`  | `int?`                      | `null`                  | 选择数量限制           |

## 选择模式

### SelectionMode.single - 单选模式

一次只能选择一个日期，选择新日期会自动取消之前的选择。

```dart
Flicker(
  mode: SelectionMode.single,
  value: [DateTime.now()],
  onValueChange: (dates) {
    if (dates.isNotEmpty) {
      print('选择的日期: ${dates.first}');
    }
  },
)
```

**适用场景:**

- 生日选择
- 预约安排
- 简单的日期输入表单

### SelectionMode.range - 范围模式

选择连续的日期范围，通过选择开始和结束日期来定义范围。

```dart
Flicker(
  mode: SelectionMode.range,
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 365)),
  disabledDate: (date) => date.weekday == DateTime.sunday,
  onValueChange: (dates) {
    if (dates.length == 2) {
      print('日期范围: ${dates.first} 到 ${dates.last}');
    }
  },
)
```

**适用场景:**

- 酒店预订日期范围
- 假期规划
- 报告日期范围
- 事件持续时间选择

### SelectionMode.many - 多选模式

可以选择多个独立的日期，每个日期可以独立选择或取消选择。

```dart
Flicker(
  mode: SelectionMode.many,
  selectionCount: 5, // 限制最多选择5个日期
  onValueChange: (dates) {
    print('选择的日期: $dates');
  },
)
```

**适用场景:**

- 会议可用性
- 多个事件日期
- 灵活的日程安排
- 自定义日期集合

## 主题配置

### FirstDayOfWeek - 一周首日配置

```dart
enum FirstDayOfWeek {
  sunday,    // 周日开始（美国、日本、韩国等）
  monday,    // 周一开始（欧洲、中国等，ISO 8601 标准）
  saturday,  // 周六开始（部分中东国家）
  locale,    // 根据系统区域设置自动确定
}
```

### FlickerTheme - 主题管理

```dart
// 自动跟随系统主题
final autoTheme = FlickerTheme();

// 强制使用明亮主题
final lightTheme = FlickerTheme(useDarkMode: false);

// 强制使用暗黑主题
final darkTheme = FlickerTheme(useDarkMode: true);

// 自定义主题数据
final customTheme = FlickerTheme(
  themeData: FlickThemeData(
    dayTextStyle: TextStyle(color: Colors.purple),
    daySelectedDecoration: BoxDecoration(
      color: Colors.purple,
      shape: BoxShape.circle,
    ),
  ),
);
```

## 高级用法

### 自定义日期单元格

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
)
```

### 禁用特定日期

```dart
Flicker(
  disabledDate: (date) {
    // 禁用周末
    if (date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday) {
      return true;
    }

    // 禁用过去的日期
    if (date.isBefore(DateTime.now())) {
      return true;
    }

    // 禁用特定日期
    final disabledDates = [
      DateTime(2024, 12, 25), // 圣诞节
      DateTime(2024, 1, 1),   // 新年
    ];

    return disabledDates.any((disabled) =>
      date.year == disabled.year &&
      date.month == disabled.month &&
      date.day == disabled.day
    );
  },
)
```

### 多月视图配置

```dart
// 水平双月视图
Flicker(
  viewCount: 2,
  scrollDirection: Axis.horizontal,
)

// 垂直双月视图
Flicker(
  viewCount: 2,
  scrollDirection: Axis.vertical,
)
```

## 示例代码

### 完整的酒店预订示例

```dart
class HotelBookingCalendar extends StatefulWidget {
  @override
  _HotelBookingCalendarState createState() => _HotelBookingCalendarState();
}

class _HotelBookingCalendarState extends State<HotelBookingCalendar> {
  List<DateTime> selectedDates = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('选择入住和退房日期')),
      body: Column(
        children: [
          // 显示选择的日期范围
          if (selectedDates.length == 2)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '入住: ${_formatDate(selectedDates.first)}\n'
                '退房: ${_formatDate(selectedDates.last)}',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),

          // 日期选择器
          Expanded(
            child: Flicker(
              mode: SelectionMode.range,
              value: selectedDates,
              startDate: DateTime.now(),
              endDate: DateTime.now().add(Duration(days: 365)),
              firstDayOfWeek: FirstDayOfWeek.monday,
              theme: FlickerTheme(useDarkMode: false),
              viewCount: 2,
              scrollDirection: Axis.vertical,
              disabledDate: (date) {
                // 禁用过去的日期
                return date.isBefore(DateTime.now().subtract(Duration(days: 1)));
              },
              onValueChange: (dates) {
                setState(() {
                  selectedDates = dates;
                });
              },
            ),
          ),

          // 确认按钮
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: selectedDates.length == 2 ? _confirmBooking : null,
              child: Text('确认预订'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  void _confirmBooking() {
    // 处理预订逻辑
    print('预订确认: ${selectedDates.first} 到 ${selectedDates.last}');
  }
}
```

### 会议可用性选择示例

```dart
class MeetingAvailabilityPicker extends StatefulWidget {
  @override
  _MeetingAvailabilityPickerState createState() => _MeetingAvailabilityPickerState();
}

class _MeetingAvailabilityPickerState extends State<MeetingAvailabilityPicker> {
  List<DateTime> availableDates = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '选择您可参会的日期 (最多选择5天)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),

        Flicker(
          mode: SelectionMode.many,
          value: availableDates,
          selectionCount: 5,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: 60)),
          firstDayOfWeek: FirstDayOfWeek.monday,
          disabledDate: (date) {
            // 禁用周末
            return date.weekday == DateTime.saturday ||
                   date.weekday == DateTime.sunday;
          },
          onValueChange: (dates) {
            setState(() {
              availableDates = dates;
            });
          },
          dayBuilder: (context, date, isSelected, isDisabled) {
            return Container(
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.green
                    : isDisabled
                        ? Colors.grey.shade300
                        : Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.green : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isDisabled
                            ? Colors.grey
                            : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(height: 16),
        Text(
          '已选择 ${availableDates.length}/5 天',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
```

---

这份文档涵盖了 Flicker 日期选择器的主要功能和使用方法。如需更多详细信息，请参考源代码中的注释和示例。
