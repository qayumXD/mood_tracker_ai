import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';
import '../core/routes/app_routes.dart';
import '../models/mood.dart';
import '../providers/mood_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/mood_chart.dart';
import '../widgets/bottom_nav_bar.dart';
import 'log_mood_screen.dart';
import 'history_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
    });
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildAddMoodTab();
      case 2:
        return _buildHistoryTab();
      case 3:
        return _buildJournalTab();
      case 4:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    final moodsState = ref.watch(moodsProvider);
    final statsState = ref.watch(statsProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.purplePinkGradient,
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Welcome, $_userName! 👋',
                        style: AppStyles.headlineSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your emotional wellness dashboard',
                        style: AppStyles.bodyMedium.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                statsState.when(
                  data: (stats) => GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      DashboardCard(
                        label: 'Total Moods',
                        value: stats.total.toString(),
                        icon: Icons.mood_rounded,
                        color: AppColors.primary,
                      ),
                      DashboardCard(
                        label: 'Avg Mood',
                        value: stats.avgLevel.toStringAsFixed(1),
                        icon: Icons.trending_up_rounded,
                        color: AppColors.moodGood,
                      ),
                      DashboardCard(
                        label: 'This Week',
                        value: stats.total > 0 ? '📊' : '—',
                        icon: Icons.calendar_today_rounded,
                        color: AppColors.secondary,
                      ),
                    ],
                  ),
                  loading: () => const SizedBox(
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => Text('Error: $err'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Mood Insights',
                  style: AppStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                moodsState.when(
                  data: (moods) => moods.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                Text(
                                  'No mood data yet',
                                  style: AppStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                CustomButton(
                                  label: 'Log Your First Mood',
                                  onPressed: () =>
                                      setState(() => _selectedIndex = 1),
                                  width: 200,
                                ),
                              ],
                            ),
                          ),
                        )
                      : MoodChart(moods: moods),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Text('Error: $err'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddMoodTab() {
    return const LogMoodScreen();
  }

  Widget _buildHistoryTab() {
    return const HistoryScreen();
  }

  Widget _buildJournalTab() {
    return const Center(child: Text('Journal Screen')); // Placeholder
  }

  Widget _buildProfileTab() {
    return const Center(child: Text('Profile Screen')); // Placeholder
  }
}
