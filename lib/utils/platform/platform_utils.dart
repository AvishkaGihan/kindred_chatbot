import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Platform detection and utilities
class PlatformUtils {
  /// Check if running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Check if running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Check if running on Web
  static bool get isWeb => kIsWeb;

  /// Check if running on Desktop (Windows, macOS, Linux)
  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  /// Check if running on macOS
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Check if running on Windows
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Check if running on Linux
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Get platform name as string
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Show platform-appropriate dialog
  static Future<T?> showPlatformDialog<T>({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    bool barrierDismissible = true,
  }) {
    if (isIOS) {
      return showCupertinoDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            if (cancelText != null)
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(false as T?),
                child: Text(cancelText),
              ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(true as T?),
              isDefaultAction: true,
              child: Text(confirmText ?? 'OK'),
            ),
          ],
        ),
      );
    } else {
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            if (cancelText != null)
              TextButton(
                onPressed: () => Navigator.of(context).pop(false as T?),
                child: Text(cancelText),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true as T?),
              child: Text(confirmText ?? 'OK'),
            ),
          ],
        ),
      );
    }
  }

  /// Show platform-appropriate action sheet
  static Future<T?> showPlatformActionSheet<T>({
    required BuildContext context,
    required String title,
    String? message,
    required List<PlatformActionSheetAction> actions,
    PlatformActionSheetAction? cancelAction,
  }) {
    if (isIOS) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: Text(title),
          message: message != null ? Text(message) : null,
          actions: actions.map((action) {
            return CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop(action.value as T?);
                action.onPressed?.call();
              },
              isDestructiveAction: action.isDestructive,
              child: Text(action.label),
            );
          }).toList(),
          cancelButton: cancelAction != null
              ? CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop(cancelAction.value as T?);
                    cancelAction.onPressed?.call();
                  },
                  child: Text(cancelAction.label),
                )
              : null,
        ),
      );
    } else {
      return showModalBottomSheet<T>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    if (message != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              ...actions.map((action) {
                return ListTile(
                  leading: action.icon != null ? Icon(action.icon) : null,
                  title: Text(
                    action.label,
                    style: TextStyle(
                      color: action.isDestructive ? Colors.red : null,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(action.value as T?);
                    action.onPressed?.call();
                  },
                );
              }),
              if (cancelAction != null)
                ListTile(
                  title: Text(cancelAction.label),
                  onTap: () {
                    Navigator.of(context).pop(cancelAction.value as T?);
                    cancelAction.onPressed?.call();
                  },
                ),
            ],
          ),
        ),
      );
    }
  }

  /// Show platform-appropriate loading indicator
  static Widget getPlatformLoadingIndicator({Color? color}) {
    if (isIOS) {
      return CupertinoActivityIndicator(color: color);
    } else {
      return CircularProgressIndicator(color: color);
    }
  }

  /// Get platform-appropriate switch widget
  static Widget getPlatformSwitch({
    required bool value,
    required ValueChanged<bool>? onChanged,
    Color? activeColor,
  }) {
    if (isIOS) {
      return CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: activeColor,
      );
    } else {
      return Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: activeColor,
      );
    }
  }

  /// Get platform-appropriate slider widget
  static Widget getPlatformSlider({
    required double value,
    required ValueChanged<double>? onChanged,
    double min = 0.0,
    double max = 1.0,
    Color? activeColor,
  }) {
    if (isIOS) {
      return CupertinoSlider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        activeColor: activeColor,
      );
    } else {
      return Slider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        activeColor: activeColor,
      );
    }
  }

  /// Get platform-appropriate app bar
  static PreferredSizeWidget getPlatformAppBar({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
  }) {
    if (isIOS) {
      return CupertinoNavigationBar(
            middle: Text(title),
            trailing: actions != null && actions.isNotEmpty
                ? Row(mainAxisSize: MainAxisSize.min, children: actions)
                : null,
            leading: leading,
            automaticallyImplyLeading: automaticallyImplyLeading,
          )
          as PreferredSizeWidget;
    } else {
      return AppBar(
        title: Text(title),
        actions: actions,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
      );
    }
  }

  /// Create platform-adaptive page route
  static PageRoute<T> createPlatformRoute<T>({
    required WidgetBuilder builder,
    String? title,
    bool fullscreenDialog = false,
  }) {
    if (isIOS) {
      return CupertinoPageRoute<T>(
        builder: builder,
        title: title,
        fullscreenDialog: fullscreenDialog,
      );
    } else {
      return MaterialPageRoute<T>(
        builder: builder,
        fullscreenDialog: fullscreenDialog,
      );
    }
  }

  /// Get platform-appropriate back button
  static Widget getPlatformBackButton(BuildContext context) {
    if (isIOS) {
      return CupertinoNavigationBarBackButton(
        onPressed: () => Navigator.of(context).pop(),
      );
    } else {
      return BackButton();
    }
  }

  /// Check if device supports biometric authentication
  static Future<bool> supportsBiometrics() async {
    // This would require local_auth package
    // Placeholder for now
    return false;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Check if device has notch
  static bool hasNotch(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return topPadding > 24; // Typical status bar height
  }

  /// Get appropriate text selection controls
  static TextSelectionControls get platformTextSelectionControls {
    if (isIOS) {
      return cupertinoTextSelectionControls;
    } else if (isAndroid) {
      return materialTextSelectionControls;
    } else {
      return materialTextSelectionControls;
    }
  }
}

/// Action for platform action sheet
class PlatformActionSheetAction {
  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final IconData? icon;
  final dynamic value;

  const PlatformActionSheetAction({
    required this.label,
    this.onPressed,
    this.isDestructive = false,
    this.icon,
    this.value,
  });
}

/// Platform-adaptive widget builder
class PlatformWidget extends StatelessWidget {
  final WidgetBuilder? androidBuilder;
  final WidgetBuilder? iosBuilder;
  final WidgetBuilder? webBuilder;
  final WidgetBuilder? desktopBuilder;
  final WidgetBuilder fallbackBuilder;

  const PlatformWidget({
    super.key,
    this.androidBuilder,
    this.iosBuilder,
    this.webBuilder,
    this.desktopBuilder,
    required this.fallbackBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isAndroid && androidBuilder != null) {
      return androidBuilder!(context);
    } else if (PlatformUtils.isIOS && iosBuilder != null) {
      return iosBuilder!(context);
    } else if (PlatformUtils.isWeb && webBuilder != null) {
      return webBuilder!(context);
    } else if (PlatformUtils.isDesktop && desktopBuilder != null) {
      return desktopBuilder!(context);
    }
    return fallbackBuilder(context);
  }
}
