import 'package:flutter/material.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/theme/app_dimensions.dart';

/// Offline indicator banner
/// Note: To use full connectivity monitoring, add connectivity_plus to pubspec.yaml
/// For now, this provides a simple banner that can be shown manually
class OfflineIndicator extends StatelessWidget {
  final Widget child;
  final String offlineMessage;
  final Color? backgroundColor;
  final bool isOffline;

  const OfflineIndicator({
    super.key,
    required this.child,
    this.offlineMessage = 'No internet connection',
    this.backgroundColor,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isOffline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 4,
              color: backgroundColor ?? AppColors.warning,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMd,
                    vertical: AppDimensions.paddingSm,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: AppDimensions.spacingSm),
                      Expanded(
                        child: Text(
                          offlineMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Simple connection status widget
class ConnectionStatus extends StatelessWidget {
  final bool isOnline;

  const ConnectionStatus({super.key, this.isOnline = true});

  @override
  Widget build(BuildContext context) {
    final icon = isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded;
    final color = isOnline ? AppColors.success : AppColors.error;
    final label = isOnline ? 'Online' : 'Offline';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Network-aware widget builder
/// Shows different widgets based on connection status
class NetworkAwareWidget extends StatelessWidget {
  final Widget Function(BuildContext context, bool isOnline) builder;
  final bool isOnline;

  const NetworkAwareWidget({
    super.key,
    required this.builder,
    this.isOnline = true,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, isOnline);
  }
}

/*
/// Enhanced version with automatic connectivity detection
/// Uncomment and add connectivity_plus to pubspec.yaml to use this version

import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class OfflineIndicator extends StatefulWidget {
  final Widget child;
  final String offlineMessage;
  final Color? backgroundColor;

  const OfflineIndicator({
    super.key,
    required this.child,
    this.offlineMessage = 'No internet connection',
    this.backgroundColor,
  });

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator>
    with SingleTickerProviderStateMixin {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOnline = true;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _checkConnectivity();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final isOnline = !result.contains(ConnectivityResult.none) &&
                     !result.contains(ConnectivityResult.bluetooth);

    if (isOnline != _isOnline) {
      setState(() => _isOnline = isOnline);

      if (!isOnline) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_isOnline)
          SlideTransition(
            position: _slideAnimation,
            child: Material(
              elevation: 4,
              color: widget.backgroundColor ?? AppColors.warning,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMd,
                    vertical: AppDimensions.paddingSm,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: AppDimensions.spacingSm),
                      Expanded(
                        child: Text(
                          widget.offlineMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ConnectionStatus extends StatefulWidget {
  const ConnectionStatus({super.key});

  @override
  State<ConnectionStatus> createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final isOnline = !result.contains(ConnectivityResult.none) &&
                     !result.contains(ConnectivityResult.bluetooth);

    if (isOnline != _isOnline) {
      setState(() => _isOnline = isOnline);
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded;
    final color = _isOnline ? AppColors.success : AppColors.error;
    final label = _isOnline ? 'Online' : 'Offline';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class NetworkAwareWidget extends StatefulWidget {
  final Widget Function(BuildContext context, bool isOnline) builder;

  const NetworkAwareWidget({
    super.key,
    required this.builder,
  });

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final isOnline = !result.contains(ConnectivityResult.none) &&
                     !result.contains(ConnectivityResult.bluetooth);

    if (isOnline != _isOnline) {
      setState(() => _isOnline = isOnline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _isOnline);
  }
}
*/
