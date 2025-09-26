# Flicker API 文档

## 概述

Flicker 是一个高度可定制的 Flutter 日期选择器组件，提供多种选择模式和丰富的自定义选项。

## 核心组件

### Flicker

主要的日期选择器组件。

```dart
class Flicker extends StatelessWidget
```

#### 构造函数

```dart
const Flicker({
  Key? key,
  SelectionMode? mode = SelectionMode.single,
  List<DateTime> value = const [],
  DateTime? startDate,
  DateTime? endDate,
  bool Function(DateTime)? disabledDate,
  Function(List<DateTime>)? onValueChange,
  DayBuilder? dayBuilder,
  FirstDayOfWeek? firstDayOfWeek = FirstDayOfWeek.monday,
  FlickerTheme? theme,
  int? viewCount = 1,
  Axis? scrollDirection = Axis.horizontal,
  int? selectionCount,
})
```

#### 参数详解

| 参数名            | 类型                        | 默认值                  | 是否必需 | 描述                                   |
| ----------------- | --------------------------- | ----------------------- | -------- | -------------------------------------- |
| `key`             | `Key?`                      | `null`                  | 否       | Widget 的唯一标识符                    |
| `mode`            | `SelectionMode?`            | `SelectionMode.single`  | 否       | 选择模式：单选、范围选择或多选         |
| `value`           | `List<DateTime>`            | `const []`              | 否       | 当前选中的日期列表                     |
| `startDate`       | `DateTime?`                 | `null`                  | 否       | 最小可选日期（包含）                   |
| `endDate`         | `DateTime?`                 | `null`                  | 否       | 最大可选日期（包含）                   |
| `disabledDate`    | `bool Function(DateTime)?`  | `null`                  | 否       | 用于判断特定日期是否应被禁用的回调函数 |
| `onValueChange`   | `Function(List<DateTime>)?` | `null`                  | 否       | 当选择的日期发生变化时的回调函数       |
| `dayBuilder`      | `DayBuilder?`               | `null`                  | 否       | 自定义日期单元格的构建器               |
| `firstDayOfWeek`  | `FirstDayOfWeek?`           | `FirstDayOfWeek.monday` | 否       | 一周的第一天配置                       |
| `theme`           | `FlickerTheme?`             | `null`                  | 否       | 自定义主题配置                         |
| `viewCount`       | `int?`                      | `1`                     | 否       | 同时显示的月份数量（1 或 2）           |
| `scrollDirection` | `Axis?`                     | `Axis.horizontal`       | 否       | 滚动方向：水平或垂直                   |
| `selectionCount`  | `int?`                      | `null`                  | 否       | 在多选模式下限制选择的最大数量         |

## 枚举类型

### SelectionMode

定义日期选择的行为模式。

```dart
enum SelectionMode {
  /// 单选模式：一次只能选择一个日期
  single,

  /// 范围选择模式：选择连续的日期范围
  range,

  /// 多选模式：选择多个独立的日期
  many,
}
```

#### 模式说明

- **`single`**:

  - 行为：一次只能选择一个日期，选择新日期会自动取消之前的选择
  - 返回值：`List<DateTime>` 包含 0 或 1 个日期
  - 适用场景：生日选择、预约安排、简单日期输入

- **`range`**:

  - 行为：选择连续的日期范围，通过选择开始和结束日期
  - 返回值：`List<DateTime>` 包含 0、1 或 2 个日期（开始和结束）
  - 适用场景：酒店预订、假期规划、报告日期范围

- **`many`**:
  - 行为：选择多个独立日期，每个日期可独立选择或取消
  - 返回值：`List<DateTime>` 包含 0 或多个日期
  - 适用场景：会议可用性、多事件日期、灵活日程安排

### FirstDayOfWeek

配置一周的第一天显示。

```dart
enum FirstDayOfWeek {
  /// 周日作为一周的第一天（美国、日本、韩国等）
  sunday,

  /// 周一作为一周的第一天（欧洲、中国等，ISO 8601 标准）
  monday,

  /// 周六作为一周的第一天（部分中东国家）
  saturday,

  /// 根据系统区域设置自动确定
  locale,
}
```

## 回调函数类型

### DayBuilder

自定义日期单元格构建器的类型定义。

```dart
typedef DayBuilder = Widget Function(
  BuildContext context,
  DateTime date,
  bool isSelected,
  bool isDisabled,
);
```

#### 参数说明

- `context`: 构建上下文
- `date`: 当前日期
- `isSelected`: 是否被选中
- `isDisabled`: 是否被禁用

#### 使用示例

```dart
DayBuilder customDayBuilder = (context, date, isSelected, isDisabled) {
  return Container(
    decoration: BoxDecoration(
      color: isSelected ? Colors.blue : Colors.transparent,
      shape: BoxShape.circle,
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
};
```

### 禁用日期回调

```dart
typedef DisabledDateCallback = bool Function(DateTime date);
```

用于判断特定日期是否应该被禁用。

#### 使用示例

```dart
bool disabledDateCallback(DateTime date) {
  // 禁用周末
  if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
    return true;
  }

  // 禁用过去的日期
  if (date.isBefore(DateTime.now())) {
    return true;
  }

  return false;
}
```

### 值变化回调

```dart
typedef ValueChangeCallback = Function(List<DateTime> selectedDates);
```

当选择的日期发生变化时调用。

#### 使用示例

```dart
void onValueChange(List<DateTime> selectedDates) {
  print('选择的日期: $selectedDates');

  switch (mode) {
    case SelectionMode.single:
      if (selectedDates.isNotEmpty) {
        print('选中的日期: ${selectedDates.first}');
      }
      break;
    case SelectionMode.range:
      if (selectedDates.length == 2) {
        print('日期范围: ${selectedDates.first} 到 ${selectedDates.last}');
      }
      break;
    case SelectionMode.many:
      print('选中了 ${selectedDates.length} 个日期');
      break;
  }
}
```

## 主题系统

### FlickerTheme

主题管理类，用于配置日期选择器的外观。

```dart
class FlickerTheme {
  const FlickerTheme({
    this.useDarkMode,
    this.themeData,
  });

  final bool? useDarkMode;
  final FlickThemeData? themeData;
}
```

#### 参数说明

- `useDarkMode`:

  - `true`: 强制使用暗黑主题
  - `false`: 强制使用明亮主题
  - `null`: 自动跟随系统主题（默认）

- `themeData`: 自定义主题数据，覆盖默认主题

#### 使用示例

```dart
// 自动主题
FlickerTheme autoTheme = FlickerTheme();

// 明亮主题
FlickerTheme lightTheme = FlickerTheme(useDarkMode: false);

// 暗黑主题
FlickerTheme darkTheme = FlickerTheme(useDarkMode: true);

// 自定义主题
FlickerTheme customTheme = FlickerTheme(
  themeData: FlickThemeData(
    dayTextStyle: TextStyle(color: Colors.purple),
    daySelectedDecoration: BoxDecoration(
      color: Colors.purple,
      shape: BoxShape.circle,
    ),
  ),
);
```

## 使用示例

### 基本用法

```dart
Flicker(
  mode: SelectionMode.single,
  onValueChange: (dates) {
    print('选择的日期: $dates');
  },
)
```

### 范围选择

```dart
Flicker(
  mode: SelectionMode.range,
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 365)),
  onValueChange: (dates) {
    if (dates.length == 2) {
      print('选择范围: ${dates.first} 到 ${dates.last}');
    }
  },
)
```

### 多选模式

```dart
Flicker(
  mode: SelectionMode.many,
  selectionCount: 5,
  disabledDate: (date) => date.weekday == DateTime.sunday,
  onValueChange: (dates) {
    print('选择了 ${dates.length} 个日期');
  },
)
```

### 自定义主题

```dart
Flicker(
  theme: FlickerTheme(useDarkMode: true),
  firstDayOfWeek: FirstDayOfWeek.monday,
  viewCount: 2,
  scrollDirection: Axis.vertical,
)
```

### 完全自定义

```dart
Flicker(
  mode: SelectionMode.range,
  value: selectedDates,
  startDate: DateTime.now(),
  endDate: DateTime.now().add(Duration(days: 365)),
  firstDayOfWeek: FirstDayOfWeek.monday,
  viewCount: 2,
  scrollDirection: Axis.vertical,
  selectionCount: 10,
  theme: FlickerTheme(useDarkMode: false),
  disabledDate: (date) {
    return date.weekday == DateTime.saturday ||
           date.weekday == DateTime.sunday;
  },
  dayBuilder: (context, date, isSelected, isDisabled) {
    return Container(
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
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
  onValueChange: (dates) {
    setState(() {
      selectedDates = dates;
    });
  },
)
```

---

此 API 文档涵盖了 Flicker 组件的所有公共接口和使用方法。如需更多详细信息，请参考源代码注释。
