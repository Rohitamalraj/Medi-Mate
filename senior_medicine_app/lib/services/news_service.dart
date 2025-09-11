import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class NewsService {
  static final NewsService _instance = NewsService._internal();
  factory NewsService() => _instance;
  NewsService._internal();

  // Free news sources (no API key required)
  static const String rssUrl = 'https://feeds.bbci.co.uk/news/rss.xml';
  static const String newsApiUrl = 'https://newsapi.org/v2/top-headlines';
  
  Future<List<String>> fetchNews({String language = 'en'}) async {
    try {
      // Try multiple sources for news
      List<String> articles = [];
      
      // First try: Mock news for reliable testing
      articles = await _getMockNews(language);
      
      // Second try: RSS feed (if available)
      if (articles.isEmpty) {
        articles = await _fetchFromRSS();
      }
      
      // Third try: News API (if API key available)
      if (articles.isEmpty) {
        articles = await _fetchFromNewsAPI();
      }
      
      return articles.take(5).toList(); // Limit to 5 articles
    } catch (e) {
      print('Error fetching news: $e');
      return await _getMockNews(language);
    }
  }

  Future<List<String>> _getMockNews(String language) async {
    // Mock news articles for different languages
    switch (language) {
      case 'ta':
        return [
          'வானிலை அறிக்கை: இன்று வெயில் காலம். வெப்பநிலை 28 டிகிரி வரை இருக்கும்.',
          'சுகாதார அறிவுரை: வெயில் காலத்தில் அதிக தண்ணீர் குடிக்க மருத்துவர்கள் அறிவுறுத்துகின்றனர்.',
          'சமூக செய்தி: நகரின் மையத்தில் முதியவர்களுக்கான புதிய பூங்கா திறக்கப்பட்டது.',
          'போக்குவரத்து செய்தி: பிரதான சாலை பணிகள் முடிந்தது. இயல்பான போக்குவரத்து மீட்டமைக்கப்பட்டது.',
          'திருவிழா அறிவிப்பு: அடுத்த வாரம் பாரம்பரிய இசை திருவிழா நடைபெறும்.'
        ];
      case 'hi':
        return [
          'मौसम अपडेट: आज धूप रहेगी। तापमान 28 डिग्री तक पहुंच सकता है।',
          'स्वास्थ्य सलाह: गर्मी में डॉक्टर अधिक पानी पीने की सलाह देते हैं।',
          'समुदायिक समाचार: शहर के केंद्र में बुजुर्गों के लिए नया पार्क खुला।',
          'ट्रैफिक अपडेट: मुख्य सड़क का निर्माण पूरा। सामान्य यातायात बहाल।',
          'त्योहार घोषणा: अगले सप्ताह पारंपरिक संगीत उत्सव होगा।'
        ];
      default:
        return [
          'Weather update: Sunny skies expected today with temperatures reaching 28 degrees.',
          'Health advisory: Doctors recommend drinking plenty of water during hot weather.',
          'Community news: New park opens in city center with walking paths for seniors.',
          'Traffic update: Main road construction completed, normal traffic flow restored.',
          'Festival announcement: Traditional music festival scheduled for next weekend.'
        ];
    }
  }

  Future<List<String>> _fetchFromRSS() async {
    try {
      // Simple RSS parsing would go here
      // For now, return empty to fall back to mock
      return [];
    } catch (e) {
      print('RSS fetch error: $e');
      return [];
    }
  }

  Future<List<String>> _fetchFromNewsAPI() async {
    try {
      // News API integration would go here
      // For now, return empty to fall back to mock
      return [];
    } catch (e) {
      print('News API fetch error: $e');
      return [];
    }
  }

  Future<List<String>> simplifyNews(List<String> articles, String language) async {
    try {
      return await ApiService().summarizeNews(articles, language);
    } catch (e) {
      print('News simplification error: $e');
      // Return original articles if simplification fails
      return articles;
    }
  }

  Future<List<String>> getSimplifiedNews({String language = 'en'}) async {
    final articles = await fetchNews(language: language);
    return await simplifyNews(articles, language);
  }
}
