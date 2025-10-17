import 'package:flutter/material.dart';
import '../utils/theme/app_dimensions.dart';
import '../utils/accessibility/accessibility_utils.dart';
import '../utils/platform/platform_utils.dart';

/// Frequently Asked Questions screen
class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  String _searchQuery = '';
  final List<FAQ> _faqs = [
    FAQ(
      category: 'Getting Started',
      question: 'How do I create an account?',
      answer:
          'You can create an account in three ways:\n\n'
          '1. Email: Tap "Sign up with Email" and fill in your details\n'
          '2. Google: Tap "Continue with Google" for quick registration\n'
          '3. Apple: Tap "Continue with Apple" (iOS only)\n\n'
          'All methods are secure and encrypted.',
    ),
    FAQ(
      category: 'Getting Started',
      question: 'Is the app free to use?',
      answer:
          'Yes! The app is free to download and use with basic features.\n\n'
          'Free features include:\n'
          '• Limited daily messages\n'
          '• Basic AI responses\n'
          '• Text chat\n\n'
          'Premium features unlock unlimited access and advanced capabilities.',
    ),
    FAQ(
      category: 'Features',
      question: 'What is Premium and what does it include?',
      answer:
          'Premium subscription includes:\n\n'
          '✓ Unlimited messages per day\n'
          '✓ Priority AI response times\n'
          '✓ Advanced AI models (GPT-4, Claude)\n'
          '✓ Voice chat capability\n'
          '✓ Custom AI personality settings\n'
          '✓ No advertisements\n'
          '✓ Early access to new features\n\n'
          'Available monthly or yearly.',
    ),
    FAQ(
      category: 'Features',
      question: 'How does voice chat work?',
      answer:
          'Voice chat is available for Premium users:\n\n'
          '1. Tap the microphone icon in chat\n'
          '2. Grant microphone permission if prompted\n'
          '3. Speak your message clearly\n'
          '4. The AI will respond with voice\n\n'
          'You can switch between text and voice anytime.',
    ),
    FAQ(
      category: 'Privacy & Security',
      question: 'Is my data secure?',
      answer:
          'Absolutely! We take security seriously:\n\n'
          '• End-to-end encryption for all messages\n'
          '• Secure cloud storage (Firebase)\n'
          '• No sharing with third parties\n'
          '• Regular security audits\n'
          '• GDPR & CCPA compliant\n\n'
          'Your conversations are private and protected.',
    ),
    FAQ(
      category: 'Privacy & Security',
      question: 'Can I delete my data?',
      answer:
          'Yes! You have full control over your data:\n\n'
          'To delete chat history:\n'
          '• Settings > Privacy > Clear Chat History\n\n'
          'To delete your account:\n'
          '• Profile > Settings > Delete Account\n\n'
          'Account deletion is permanent and removes all your data within 30 days.',
    ),
    FAQ(
      category: 'Technical',
      question: 'Why is the AI not responding?',
      answer:
          'If the AI isn\'t responding, try:\n\n'
          '1. Check your internet connection\n'
          '2. Restart the app\n'
          '3. Update to the latest version\n'
          '4. Clear app cache (Settings > Storage)\n\n'
          'If the problem persists, contact support.',
    ),
    FAQ(
      category: 'Technical',
      question: 'Which devices are supported?',
      answer:
          'Our app supports:\n\n'
          '• Android 6.0 and above\n'
          '• iOS 12.0 and above\n'
          '• Web browsers (Chrome, Safari, Firefox)\n'
          '• Windows 10/11 (desktop app)\n\n'
          'For best experience, use the latest OS version.',
    ),
    FAQ(
      category: 'Billing',
      question: 'How do I cancel my subscription?',
      answer:
          'To cancel your Premium subscription:\n\n'
          'iOS:\n'
          '• Settings > Apple ID > Subscriptions > Kindred > Cancel\n\n'
          'Android:\n'
          '• Play Store > Menu > Subscriptions > Kindred > Cancel\n\n'
          'You\'ll retain Premium access until the end of your billing period.',
    ),
    FAQ(
      category: 'Billing',
      question: 'Can I get a refund?',
      answer:
          'Refund policies:\n\n'
          '• 7-day money-back guarantee for first-time subscribers\n'
          '• Billing errors are refunded immediately\n'
          '• Unused portions are non-refundable\n\n'
          'Contact support@kindred.com for refund requests.',
    ),
  ];

  List<FAQ> get _filteredFAQs {
    if (_searchQuery.isEmpty) return _faqs;

    return _faqs.where((faq) {
      final query = _searchQuery.toLowerCase();
      return faq.question.toLowerCase().contains(query) ||
          faq.answer.toLowerCase().contains(query) ||
          faq.category.toLowerCase().contains(query);
    }).toList();
  }

  Map<String, List<FAQ>> get _groupedFAQs {
    final grouped = <String, List<FAQ>>{};
    for (final faq in _filteredFAQs) {
      grouped.putIfAbsent(faq.category, () => []).add(faq);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PlatformUtils.getPlatformAppBar(context: context, title: 'FAQ'),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingMd),
            color: theme.colorScheme.surface,
            child: AccessibilityUtils.createAccessibleTextField(
              semanticLabel: 'Search FAQs',
              semanticHint: 'Type to search frequently asked questions',
              child: TextField(
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search FAQs...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // FAQ list
          Expanded(
            child: _filteredFAQs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        Text(
                          'No FAQs found',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingSm),
                        Text(
                          'Try a different search term',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppDimensions.paddingMd),
                    children: [
                      for (final entry in _groupedFAQs.entries) ...[
                        // Category header
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppDimensions.paddingMd,
                            bottom: AppDimensions.paddingSm,
                          ),
                          child: AccessibilityUtils.createSemanticHeader(
                            label: entry.key,
                            child: Text(
                              entry.key,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),

                        // FAQs in category
                        ...entry.value.map((faq) => _FAQTile(faq: faq)),

                        const SizedBox(height: AppDimensions.spacingSm),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Expandable FAQ tile
class _FAQTile extends StatefulWidget {
  final FAQ faq;

  const _FAQTile({required this.faq});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AccessibilityUtils.createAccessibleButton(
      semanticLabel: widget.faq.question,
      semanticHint: _isExpanded
          ? 'Tap to collapse answer'
          : 'Tap to expand and read answer',
      enabled: true,
      onPressed: () {
        setState(() => _isExpanded = !_isExpanded);
        if (_isExpanded) {
          context.announce('Answer expanded: ${widget.faq.answer}');
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: InkWell(
          onTap: () {
            setState(() => _isExpanded = !_isExpanded);
            if (_isExpanded) {
              context.announce('Answer expanded');
            }
          },
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question
                Row(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.faq.question,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),

                // Answer (animated)
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(
                      top: AppDimensions.paddingMd,
                      left: 32,
                    ),
                    child: Text(
                      widget.faq.answer,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        height: 1.5,
                      ),
                    ),
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// FAQ data model
class FAQ {
  final String category;
  final String question;
  final String answer;

  FAQ({required this.category, required this.question, required this.answer});
}
