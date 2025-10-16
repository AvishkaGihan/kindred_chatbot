import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/subscription_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<ProductDetails> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    await _subscriptionService.initialize();
    final products = await _subscriptionService.getProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kindred Premium')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    size: 80,
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Upgrade to Premium',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _buildFeatureTile(
                    'Unlimited Messages',
                    'No daily message limits',
                    Icons.chat_bubble_outline,
                  ),
                  _buildFeatureTile(
                    'Priority AI Responses',
                    'Faster response times',
                    Icons.flash_on,
                  ),
                  _buildFeatureTile(
                    'Advanced Voice Features',
                    'Multiple voice options',
                    Icons.mic,
                  ),
                  _buildFeatureTile(
                    'Export Conversations',
                    'Download your chat history',
                    Icons.download,
                  ),
                  _buildFeatureTile(
                    'Ad-Free Experience',
                    'No advertisements',
                    Icons.block,
                  ),
                  const SizedBox(height: 40),
                  ..._products.map((product) => _buildProductCard(product)),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      _subscriptionService.restorePurchases();
                    },
                    child: const Text('Restore Purchases'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureTile(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildProductCard(ProductDetails product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              product.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(product.description, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(
              product.price,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _subscriptionService.buyProduct(product);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: const Text('Subscribe'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subscriptionService.dispose();
    super.dispose();
  }
}
