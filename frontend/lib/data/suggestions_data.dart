// AI Mood Suggestions
const Map<String, List<String>> moodSuggestions = {
  'amazing': [
    'Keep this momentum going! 🚀',
    'You\'re doing great! Keep it up! 💪',
    'Spread this happiness with others! 🌟',
    'This is your peak moment, cherish it! 🎉',
    'You\'re unstoppable today! 💫',
  ],
  'good': [
    'You\'re on the right track! 👍',
    'Keep smiling! 😊',
    'Today is a good day, make it count! ✨',
    'Ride this wave of positivity! 🌊',
    'You\'ve got this! Keep going! 🎯',
  ],
  'okay': [
    'Take a deep breath, you\'re doing fine. 🧘',
    'This feeling is temporary, be patient. ⏳',
    'Consider doing something you enjoy. 🎨',
    'Reach out to someone you care about. 💬',
    'A small walk might help! 🚶',
  ],
  'sad': [
    'It\'s okay to feel sad. Let it out. 💙',
    'Call a friend or family member. 📞',
    'Practice self-care today. 🛀',
    'Remember, this feeling will pass. 🌈',
    'Try listening to your favorite music. 🎵',
  ],
  'terrible': [
    'You\'re not alone in this. 🤝',
    'Please reach out to someone you trust. 💚',
    'Consider talking to a counselor. 👥',
    'Take time for self-care. 🌸',
    'Crisis? Call your local helpline. ☎️',
  ],
  'positive': [
    'Great mindset! Keep thinking positive! 🌟',
    'Your positive energy is contagious! ✨',
    'Channel this positivity into action! ⚡',
    'Keep believing in yourself! 🙌',
    'You\'re capable of amazing things! 🚀',
  ],
  'negative': [
    'It\'s okay to have negative feelings. 💙',
    'Challenge one negative thought today. 🧠',
    'Do something kind for yourself. 🎁',
    'Reach out to someone for support. 🤝',
    'This too shall pass. 🌈',
  ],
  'neutral': [
    'Neutral is fine, stay balanced! ⚖️',
    'Try something new to shift your mood! 🎲',
    'Take a moment to reflect. 🪞',
    'Connect with nature if possible. 🌿',
    'Practice gratitude today. 🙏',
  ],
};

String getSuggestion(String mood, String sentiment) {
  final suggestions = moodSuggestions[mood] ?? moodSuggestions['neutral']!;
  return suggestions[DateTime.now().millisecond % suggestions.length];
}

// Motivational quotes
const List<String> motivationalQuotes = [
  'Your mental health is a priority, not a luxury. 💚',
  'It\'s okay to not be okay. 💙',
  'Progress, not perfection. ⭐',
  'You are stronger than you think. 💪',
  'Every day is a fresh start. 🌅',
  'Self-love is not selfish. 🫶',
  'Your feelings are valid. ✨',
  'You deserve happiness. 🌸',
  'Breathe in peace, breathe out stress. 🌬️',
  'You are doing the best you can. 🙌',
];

String getRandomQuote() {
  return motivationalQuotes[DateTime.now().millisecond % motivationalQuotes.length];
}
