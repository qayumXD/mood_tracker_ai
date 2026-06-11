import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _noteController = TextEditingController();

  List<Mood> _moods = [];
  int _currentLevel = 3;
  bool _isLoading = true;
  bool _isAnalyzing = false;

  static const List<String> _moodLabels = [
    'Terrible',
    'Sad',
    'Okay',
    'Good',
    'Amazing',
  ];

  static const List<Color> _moodColors = [
    Color(0xFF1565C0),
    Color(0xFF42A5F5),
    Color(0xFF78909C),
    Color(0xFF66BB6A),
    Color(0xFFFFA726),
  ];

  @override
  void initState() {
    super.initState();
    _fetchMoods();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _fetchMoods() async {
    try {
      final moods = await _apiService.fetchMoods();
      if (mounted) {
        setState(() {
          _moods = moods;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnack(
          'Could not connect to server. Is the backend running?',
          isError: true,
        );
      }
    }
  }

  Future<void> _logMood() async {
    final note = _noteController.text.trim();
    setState(() => _isAnalyzing = true);
    try {
      await _apiService.logMood(_currentLevel, note);
      if (mounted) {
        setState(() {
          _noteController.clear();
          _currentLevel = 3;
        });
        await _fetchMoods();
        _showSnack('Mood logged successfully!');
      }
    } catch (e) {
      if (mounted) _showSnack('Failed to log mood: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _deleteMood(Mood mood) async {
    try {
      await _apiService.deleteMood(mood.id);
      if (mounted) {
        setState(() => _moods.removeWhere((m) => m.id == mood.id));
        _showSnack('Mood deleted.');
      }
    } catch (e) {
      if (mounted) _showSnack('Failed to delete mood.', isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  Icon _getMoodIcon(int level, {double size = 32}) {
    switch (level) {
      case 5:
        return Icon(Icons.star_rounded, color: _moodColors[4], size: size);
      case 4:
        return Icon(
          Icons.sentiment_very_satisfied_rounded,
          color: _moodColors[3],
          size: size,
        );
      case 3:
        return Icon(
          Icons.sentiment_neutral_rounded,
          color: _moodColors[2],
          size: size,
        );
      case 2:
        return Icon(
          Icons.sentiment_dissatisfied_rounded,
          color: _moodColors[1],
          size: size,
        );
      case 1:
        return Icon(
          Icons.sentiment_very_dissatisfied_rounded,
          color: _moodColors[0],
          size: size,
        );
      default:
        return Icon(Icons.sentiment_neutral_rounded, size: size);
    }
  }

  Widget _buildMoodSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive icon size: scales down on narrow screens
        final iconSize = (constraints.maxWidth / 7).clamp(28.0, 44.0);
        final selectedSize = (iconSize * 1.25).clamp(32.0, 52.0);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final level = index + 1;
                  final isSelected = _currentLevel == level;
                  return GestureDetector(
                    onTap: () => setState(() => _currentLevel = level),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _moodColors[index].withValues(alpha: 0.18)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: _getMoodIcon(
                        level,
                        size: isSelected ? selectedSize : iconSize,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _moodLabels[_currentLevel - 1],
                  key: ValueKey(_currentLevel),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: _moodColors[_currentLevel - 1],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem(Mood mood) {
    final formattedDate = DateFormat('MMM d, h:mm a').format(mood.createdAt);
    final color = _moodColors[mood.level - 1];
    final label = _moodLabels[mood.level - 1];

    return Dismissible(
      key: Key('mood_${mood.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        if (!mounted) return false;
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text('Delete mood?'),
                content: const Text('This entry will be permanently removed.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => _deleteMood(mood),
      child: Card(
        margin: const EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _getMoodIcon(mood.level, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        if (mood.note != null && mood.note!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            mood.note!,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (mood.aiSuggestion != null &&
                  mood.aiSuggestion!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.tips_and_updates_rounded,
                        color: Colors.blue,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI INSIGHT',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mood.aiSuggestion!,
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          children: [
            Icon(Icons.edit_note_rounded, size: 72, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              'No moods logged yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
            const SizedBox(height: 4),
            Text(
              'Log your first mood above!',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Mood Companion',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchMoods,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'How are you feeling?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Log your mood to get personalized AI insights',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _buildMoodSelector(),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "What's on your mind? (optional)",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: _isAnalyzing ? null : _logMood,
                        icon: _isAnalyzing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.bolt_rounded),
                        label: Text(
                          _isAnalyzing
                              ? 'Analyzing...'
                              : 'Log Mood & Get AI Insight',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (_moods.isNotEmpty) ...[
                        Row(
                          children: [
                            const Text(
                              'History',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_moods.length} entries',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Swipe left to delete',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _moods.length,
                          itemBuilder: (context, index) =>
                              _buildHistoryItem(_moods[index]),
                        ),
                      ] else
                        _buildEmptyState(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
