import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/routes/app_routes.dart';
import '../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'emoji': '📝',
      'title': 'Track Your Mood',
      'description': 'Log your daily emotions with ease. Simple, quick, and effective.',
    },
    {
      'emoji': '📊',
      'title': 'Visualize Patterns',
      'description': 'See your mood trends with beautiful charts and analytics.',
    },
    {
      'emoji': '✍️',
      'title': 'Write Journals',
      'description': 'Reflect on your day with detailed journal entries.',
    },
    {
      'emoji': '🤖',
      'title': 'AI Insights',
      'description': 'Get personalized suggestions powered by intelligent AI.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                final data = _onboardingData[index];
                return _OnboardingPage(
                  emoji: data['emoji']!,
                  title: data['title']!,
                  description: data['description']!,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => Container(
                      width: _currentIndex == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentIndex == index
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (_currentIndex > 0)
                      Expanded(
                        child: CustomButton(
                          label: 'Back',
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          isOutlined: true,
                        ),
                      ),
                    if (_currentIndex > 0) const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        label: _currentIndex == _onboardingData.length - 1
                            ? 'Get Started'
                            : 'Next',
                        onPressed: () {
                          if (_currentIndex == _onboardingData.length - 1) {
                            _markOnboardingComplete();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 120),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(
                title,
                style: AppStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: AppStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
