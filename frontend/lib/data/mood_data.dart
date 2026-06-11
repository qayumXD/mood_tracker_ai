// AI Sentiment Analysis Data
const Map<String, int> positiveKeywords = {
  'happy': 5,
  'good': 4,
  'great': 5,
  'excited': 5,
  'relaxed': 4,
  'calm': 4,
  'amazing': 5,
  'love': 5,
  'enjoy': 4,
  'wonderful': 5,
  'excellent': 5,
  'fantastic': 5,
  'brilliant': 5,
  'beautiful': 4,
  'grateful': 4,
  'blessed': 4,
  'confident': 4,
  'energetic': 4,
  'hopeful': 4,
  'peaceful': 4,
  'proud': 4,
  'accomplished': 5,
  'thrilled': 5,
  'delighted': 5,
  'cheerful': 4,
  'content': 4,
  'satisfied': 4,
  'joyful': 5,
  'motivated': 4,
};

const Map<String, int> negativeKeywords = {
  'sad': 1,
  'bad': 2,
  'angry': 1,
  'stress': 1,
  'stressed': 1,
  'tired': 2,
  'upset': 1,
  'depressed': 1,
  'worried': 2,
  'lonely': 1,
  'anxiety': 1,
  'anxious': 2,
  'frustrated': 1,
  'upset': 1,
  'miserable': 1,
  'terrible': 1,
  'horrible': 1,
  'awful': 1,
  'sick': 2,
  'hurt': 1,
  'confused': 2,
  'scared': 1,
  'afraid': 1,
  'disappointed': 2,
  'overwhelmed': 1,
  'exhausted': 2,
  'desperate': 1,
  'failed': 2,
  'guilty': 2,
  'ashamed': 2,
};

// Get sentiment from text
String analyzeSentiment(String text) {
  if (text.isEmpty) return 'neutral';

  final lowerText = text.toLowerCase();
  int positiveScore = 0;
  int negativeScore = 0;

  positiveKeywords.forEach((word, score) {
    if (lowerText.contains(word)) {
      positiveScore += score;
    }
  });

  negativeKeywords.forEach((word, score) {
    if (lowerText.contains(word)) {
      negativeScore += score;
    }
  });

  if (positiveScore > negativeScore) {
    return 'positive';
  } else if (negativeScore > positiveScore) {
    return 'negative';
  } else {
    return 'neutral';
  }
}

// Get mood level from sentiment
int getMoodLevelFromSentiment(String sentiment) {
  switch (sentiment) {
    case 'positive':
      return 4;
    case 'negative':
      return 2;
    default:
      return 3;
  }
}
