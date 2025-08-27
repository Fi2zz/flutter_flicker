import 'package:flutter/material.dart';

/// 颜色混合器
/// 
/// 提供基于亮度模式的颜色调整功能，支持浅色和深色主题的颜色变化
class ColorMixer {
  /// 基准颜色
  final Color baseColor;
  
  /// 当前亮度模式
  final Brightness brightness;
  
  /// 浅色模式下的混合因子 (0.0 - 1.0)
  final double lightMixFactor;
  
  /// 深色模式下的混合因子 (0.0 - 1.0)
  final double darkMixFactor;
  
  /// 创建颜色混合器
  /// 
  /// [baseColor] - 基准颜色
  /// [brightness] - 亮度模式
  /// [lightMixFactor] - 浅色模式混合因子，默认0.1
  /// [darkMixFactor] - 深色模式混合因子，默认0.3
  const ColorMixer({
    required this.baseColor,
    required this.brightness,
    this.lightMixFactor = 0.1,
    this.darkMixFactor = 0.3,
  });
  
  /// 获取调整后的颜色
  /// 
  /// 根据当前亮度模式返回相应的调整颜色
  Color get adjustedColor {
    switch (brightness) {
      case Brightness.light:
        return _lighten(baseColor, lightMixFactor);
      case Brightness.dark:
        return _darken(baseColor, darkMixFactor);
    }
  }
  
  /// 获取对比色
  /// 
  /// 返回与当前亮度模式相反的颜色调整
  Color get contrastColor {
    switch (brightness) {
      case Brightness.light:
        return _darken(baseColor, darkMixFactor);
      case Brightness.dark:
        return _lighten(baseColor, lightMixFactor);
    }
  }
  
  /// 获取禁用状态颜色
  /// 
  /// 返回降低透明度的颜色
  Color get disabledColor {
    return adjustedColor.withValues(alpha: 0.38);
  }
  
  /// 获取高亮颜色
  /// 
  /// 返回稍微调整的高亮颜色
  Color get highlightColor {
    switch (brightness) {
      case Brightness.light:
        return _lighten(baseColor, lightMixFactor * 0.5);
      case Brightness.dark:
        return _lighten(baseColor, darkMixFactor * 0.5);
    }
  }
  
  /// 变亮颜色
  /// 
  /// [color] - 原始颜色
  /// [factor] - 变亮因子 (0.0 - 1.0)
  Color _lighten(Color color, double factor) {
    assert(factor >= 0.0 && factor <= 1.0, 'Factor must be between 0.0 and 1.0');
    
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + factor).clamp(0.0, 1.0);
    
    return hsl.withLightness(lightness).toColor();
  }
  
  /// 变暗颜色
  /// 
  /// [color] - 原始颜色
  /// [factor] - 变暗因子 (0.0 - 1.0)
  Color _darken(Color color, double factor) {
    assert(factor >= 0.0 && factor <= 1.0, 'Factor must be between 0.0 and 1.0');
    
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - factor).clamp(0.0, 1.0);
    
    return hsl.withLightness(lightness).toColor();
  }
  
  /// 创建新的混合器实例，使用不同的亮度模式
  /// 
  /// [newBrightness] - 新的亮度模式
  ColorMixer withBrightness(Brightness newBrightness) {
    return ColorMixer(
      baseColor: baseColor,
      brightness: newBrightness,
      lightMixFactor: lightMixFactor,
      darkMixFactor: darkMixFactor,
    );
  }
  
  /// 创建新的混合器实例，使用不同的基准颜色
  /// 
  /// [newBaseColor] - 新的基准颜色
  ColorMixer withBaseColor(Color newBaseColor) {
    return ColorMixer(
      baseColor: newBaseColor,
      brightness: brightness,
      lightMixFactor: lightMixFactor,
      darkMixFactor: darkMixFactor,
    );
  }
  
  /// 创建新的混合器实例，使用不同的混合因子
  /// 
  /// [newLightMixFactor] - 新的浅色模式混合因子
  /// [newDarkMixFactor] - 新的深色模式混合因子
  ColorMixer withMixFactors({
    double? newLightMixFactor,
    double? newDarkMixFactor,
  }) {
    return ColorMixer(
      baseColor: baseColor,
      brightness: brightness,
      lightMixFactor: newLightMixFactor ?? lightMixFactor,
      darkMixFactor: newDarkMixFactor ?? darkMixFactor,
    );
  }
}

/// 颜色混合器工厂类
/// 
/// 提供常用颜色的预设混合器
class ColorMixerFactory {
  /// 创建主色调混合器
  static ColorMixer primary(Brightness brightness) {
    return ColorMixer(
      baseColor: Colors.blue,
      brightness: brightness,
      lightMixFactor: 0.1,
      darkMixFactor: 0.2,
    );
  }
  
  /// 创建次要色调混合器
  static ColorMixer secondary(Brightness brightness) {
    return ColorMixer(
      baseColor: Colors.grey,
      brightness: brightness,
      lightMixFactor: 0.05,
      darkMixFactor: 0.15,
    );
  }
  
  /// 创建成功色调混合器
  static ColorMixer success(Brightness brightness) {
    return ColorMixer(
      baseColor: Colors.green,
      brightness: brightness,
      lightMixFactor: 0.1,
      darkMixFactor: 0.25,
    );
  }
  
  /// 创建警告色调混合器
  static ColorMixer warning(Brightness brightness) {
    return ColorMixer(
      baseColor: Colors.orange,
      brightness: brightness,
      lightMixFactor: 0.1,
      darkMixFactor: 0.25,
    );
  }
  
  /// 创建错误色调混合器
  static ColorMixer error(Brightness brightness) {
    return ColorMixer(
      baseColor: Colors.red,
      brightness: brightness,
      lightMixFactor: 0.1,
      darkMixFactor: 0.25,
    );
  }
  
  /// 创建表面色调混合器
  static ColorMixer surface(Brightness brightness) {
    return ColorMixer(
      baseColor: brightness == Brightness.light ? Colors.white : Colors.black,
      brightness: brightness,
      lightMixFactor: 0.05,
      darkMixFactor: 0.1,
    );
  }
}