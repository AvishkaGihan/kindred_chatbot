import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/subscription_service.dart';
import '../utils/theme/app_colors.dart';
import '../utils/theme/app_dimensions.dart';
import '../utils/theme/app_animations.dart';
import '../widgets/snackbar/custom_snackbar.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with SingleTickerProviderStateMixin {
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadProducts();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.durationSlow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppAnimations.curveSmooth,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: AppAnimations.curveSmooth,
          ),
        );

    _animationController.forward();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeroSection(isDark),
                      _buildFeaturesSection(isDark),
                      _buildComparisonSection(isDark),
                      _buildPricingSection(isDark),
                      _buildFAQSection(isDark),
                      _buildFooter(isDark),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFC107),
            const Color(0xFFFF6F00),
            AppColors.primaryBlue,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingLg),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              const Text(
                'Kindred Premium',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                'Unlock unlimited conversations and exclusive features',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(bool isDark) {
    final features = [
      {
        'icon': Icons.chat_bubble_rounded,
        'title': 'Unlimited Messages',
        'description': 'Chat without daily limits',
        'color': AppColors.primaryBlue,
      },
      {
        'icon': Icons.flash_on_rounded,
        'title': 'Priority AI Responses',
        'description': 'Get faster, prioritized responses',
        'color': AppColors.secondaryTeal,
      },
      {
        'icon': Icons.mic_rounded,
        'title': 'Advanced Voice Features',
        'description': 'Multiple voice options and accents',
        'color': AppColors.success,
      },
      {
        'icon': Icons.download_rounded,
        'title': 'Export Conversations',
        'description': 'Download your chat history anytime',
        'color': AppColors.warning,
      },
      {
        'icon': Icons.block_rounded,
        'title': 'Ad-Free Experience',
        'description': 'Enjoy without interruptions',
        'color': AppColors.error,
      },
      {
        'icon': Icons.support_agent_rounded,
        'title': 'Priority Support',
        'description': '24/7 premium customer support',
        'color': const Color(0xFF9C27B0),
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Features',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.spacingMd,
              mainAxisSpacing: AppDimensions.spacingMd,
              childAspectRatio: 1.0,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return Container(
                padding: const EdgeInsets.all(AppDimensions.paddingMd),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariantLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  border: Border.all(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (feature['color'] as Color).withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingSm),
                      decoration: BoxDecoration(
                        color: (feature['color'] as Color).withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMd,
                        ),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        color: feature['color'] as Color,
                        size: AppDimensions.iconLg,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Text(
                      feature['title'] as String,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spacing2xs),
                    Text(
                      feature['description'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Free vs Premium',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              children: [
                _buildComparisonRow(
                  'Daily message limit',
                  '20 messages',
                  'Unlimited',
                  isDark,
                ),
                _buildDivider(isDark),
                _buildComparisonRow(
                  'Response priority',
                  'Standard',
                  'Priority',
                  isDark,
                ),
                _buildDivider(isDark),
                _buildComparisonRow(
                  'Voice features',
                  'Basic',
                  'Advanced',
                  isDark,
                ),
                _buildDivider(isDark),
                _buildComparisonRow(
                  'Chat history',
                  '7 days',
                  'Forever',
                  isDark,
                ),
                _buildDivider(isDark),
                _buildComparisonRow('Export chats', '✗', '✓', isDark),
                _buildDivider(isDark),
                _buildComparisonRow(
                  'Customer support',
                  'Standard',
                  'Priority 24/7',
                  isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String feature,
    String freeValue,
    String premiumValue,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              freeValue,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingXs,
                vertical: AppDimensions.spacing2xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Text(
                premiumValue,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your Plan',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          if (_products.isEmpty)
            _buildDefaultPricingCards(isDark)
          else
            ..._products.asMap().entries.map((entry) {
              return _buildPricingCard(entry.value, entry.key, isDark);
            }),
        ],
      ),
    );
  }

  Widget _buildDefaultPricingCards(bool isDark) {
    return Column(
      children: [
        _buildMockPricingCard(
          'Monthly',
          '\$9.99',
          'per month',
          'Perfect for trying premium',
          false,
          isDark,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        _buildMockPricingCard(
          'Annual',
          '\$79.99',
          'per year',
          'Save 33% - Best Value!',
          true,
          isDark,
        ),
      ],
    );
  }

  Widget _buildMockPricingCard(
    String title,
    String price,
    String period,
    String description,
    bool isPopular,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        gradient: isPopular
            ? const LinearGradient(
                colors: [Color(0xFFFFC107), Color(0xFFFF6F00)],
              )
            : null,
        color: isPopular
            ? null
            : (isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isPopular
              ? Colors.transparent
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 2,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSm,
                vertical: AppDimensions.spacing2xs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: const Text(
                '🔥 MOST POPULAR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          if (isPopular) const SizedBox(height: AppDimensions.spacingSm),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isPopular ? Colors.white : null,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: isPopular ? Colors.white : AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          Text(
            period,
            style: TextStyle(
              fontSize: 16,
              color: isPopular
                  ? Colors.white.withValues(alpha: 0.9)
                  : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: isPopular
                  ? Colors.white.withValues(alpha: 0.95)
                  : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeightMd,
            child: ElevatedButton(
              onPressed: () {
                CustomSnackbar.showInfo(
                  context,
                  message: 'Premium subscription coming soon!',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular
                    ? Colors.white
                    : AppColors.primaryBlue,
                foregroundColor: isPopular
                    ? const Color(0xFFFF6F00)
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              child: const Text(
                'Subscribe Now',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(ProductDetails product, int index, bool isDark) {
    final isPopular = index == 1; // Make second plan popular

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        gradient: isPopular
            ? const LinearGradient(
                colors: [Color(0xFFFFC107), Color(0xFFFF6F00)],
              )
            : null,
        color: isPopular
            ? null
            : (isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isPopular
              ? Colors.transparent
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 2,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingSm,
                vertical: AppDimensions.spacing2xs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: const Text(
                '🔥 MOST POPULAR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          if (isPopular) const SizedBox(height: AppDimensions.spacingSm),
          Text(
            product.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isPopular ? Colors.white : null,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            product.price,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: isPopular ? Colors.white : AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            product.description,
            style: TextStyle(
              fontSize: 14,
              color: isPopular
                  ? Colors.white.withValues(alpha: 0.95)
                  : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeightMd,
            child: ElevatedButton(
              onPressed: () async {
                await _subscriptionService.buyProduct(product);
                if (mounted) {
                  CustomSnackbar.showSuccess(
                    context,
                    message: 'Processing your subscription...',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPopular
                    ? Colors.white
                    : AppColors.primaryBlue,
                foregroundColor: isPopular
                    ? const Color(0xFFFF6F00)
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              child: const Text(
                'Subscribe Now',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection(bool isDark) {
    final faqs = [
      {
        'question': 'Can I cancel anytime?',
        'answer':
            'Yes! You can cancel your subscription at any time. You\'ll continue to have access until the end of your billing period.',
      },
      {
        'question': 'What payment methods do you accept?',
        'answer':
            'We accept all major credit cards, debit cards, and payment methods supported by your app store.',
      },
      {
        'question': 'Is there a free trial?',
        'answer':
            'New users get a 7-day free trial to experience all premium features before committing.',
      },
      {
        'question': 'Can I switch plans?',
        'answer':
            'Yes, you can upgrade or downgrade your plan at any time. Changes take effect in the next billing cycle.',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          ...faqs.map(
            (faq) => _buildFAQItem(faq['question']!, faq['answer']!, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline_rounded,
                size: AppDimensions.iconSm,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: AppDimensions.spacingXs),
              Expanded(
                child: Text(
                  question,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            answer,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceVariantLight,
      child: Column(
        children: [
          TextButton.icon(
            onPressed: () async {
              await _subscriptionService.restorePurchases();
              if (mounted) {
                CustomSnackbar.showInfo(
                  context,
                  message: 'Restoring purchases...',
                );
              }
            },
            icon: const Icon(Icons.restore_rounded),
            label: const Text('Restore Purchases'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primaryBlue),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Premium subscription auto-renews unless cancelled',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textHintDark : AppColors.textHintLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacing2xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                  'Terms',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textHintDark
                        : AppColors.textHintLight,
                  ),
                ),
              ),
              Text(
                '•',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textHintDark
                      : AppColors.textHintLight,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Privacy',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textHintDark
                        : AppColors.textHintLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _subscriptionService.dispose();
    super.dispose();
  }
}
