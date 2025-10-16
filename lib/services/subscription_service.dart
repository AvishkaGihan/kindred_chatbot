import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';
import 'package:logging/logging.dart';

class SubscriptionService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final Logger _logger = Logger('SubscriptionService');

  // Product IDs
  static const String premiumMonthly = 'kindred_premium_monthly';
  static const String premiumYearly = 'kindred_premium_yearly';

  bool _isPremium = false;
  bool get isPremium => _isPremium;

  Future<void> initialize() async {
    final bool available = await _iap.isAvailable();
    if (!available) return;

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => _logger.severe('Purchase error: $error'),
    );

    // Check existing purchases
    await restorePurchases();
  }

  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      _logger.severe('Restore purchases error: $e');
    }
  }

  Future<List<ProductDetails>> getProducts() async {
    const Set<String> ids = {premiumMonthly, premiumYearly};
    final ProductDetailsResponse response = await _iap.queryProductDetails(ids);

    if (response.notFoundIDs.isNotEmpty) {
      _logger.warning('Products not found: ${response.notFoundIDs}');
    }

    return response.productDetails;
  }

  Future<void> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        _isPremium = true;
        _completePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        _logger.severe('Purchase error: ${purchase.error}');
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _completePurchase(PurchaseDetails purchase) async {
    // Verify purchase with your backend
    // Update user's premium status in Firestore
    await _iap.completePurchase(purchase);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
