import 'package:flutter/foundation.dart';
import '../services/subscription_service.dart';

class SubscriptionProvider with ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();
  bool _isLoading = true;

  bool get isPremium => _subscriptionService.isPremium;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    try {
      await _subscriptionService.initialize();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> restorePurchases() async {
    await _subscriptionService.restorePurchases();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscriptionService.dispose();
    super.dispose();
  }
}
