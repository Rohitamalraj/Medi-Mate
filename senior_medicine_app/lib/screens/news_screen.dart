import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/news_service.dart';
import '../services/tts_service.dart';

class NewsScreen extends StatefulWidget {
  final String language;

  const NewsScreen({super.key, required this.language});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isLoading = false;
  bool _isPlaying = false;
  List<String> _newsItems = [];
  int _currentNewsIndex = 0;

  // Backend URL - Update this with your actual backend URL
  static const String backendUrl = 'http://localhost:8000';

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _speakInstructions();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage(widget.language);
    await _flutterTts.setSpeechRate(0.8);
    await _flutterTts.setVolume(1.0);
    
    _flutterTts.setCompletionHandler(() {
      if (_isPlaying && _currentNewsIndex < _newsItems.length - 1) {
        _currentNewsIndex++;
        _speakCurrentNews();
      } else {
        setState(() {
          _isPlaying = false;
          _currentNewsIndex = 0;
        });
      }
    });
  }

  Future<void> _speakInstructions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _flutterTts.speak(
      "Press the button to listen to today's news. I will read simplified news in your language."
    );
  }

  Future<void> _fetchAndReadNews() async {
    setState(() {
      _isLoading = true;
      _newsItems.clear();
    });

    try {
      await TTSService().speak("Getting today's news for you...", language: widget.language);
      
      // Fetch and simplify news using the news service
      final languageCode = _getLanguageCode();
      final simplifiedNews = await NewsService().getSimplifiedNews(language: languageCode);
      
      if (simplifiedNews.isEmpty) {
        await TTSService().speak("Sorry, I couldn't get the news right now. Please try again later.", language: widget.language);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _newsItems = simplifiedNews;
        _isLoading = false;
        _isPlaying = true;
        _currentNewsIndex = 0;
      });

      await TTSService().speak("Here are today's top news stories:", language: widget.language);
      await Future.delayed(const Duration(seconds: 1));
      _speakCurrentNews();

    } catch (e) {
      print('Error fetching news: $e');
      setState(() {
        _isLoading = false;
      });
      await TTSService().speak("Sorry, there was an error getting the news. Please try again later.", language: widget.language);
    }
  }

  Future<List<String>> _fetchNewsHeadlines() async {
    try {
      // Using a free news API (you can replace with RSS feed or other source)
      // For demo purposes, using mock data
      return [
        "Local weather update: Sunny skies expected today with temperatures reaching 28 degrees.",
        "Health reminder: Doctors recommend drinking plenty of water during hot weather.",
        "Community news: New park opens in the city center with walking paths for seniors.",
        "Traffic update: Main road construction completed, normal traffic flow restored.",
        "Festival announcement: Traditional music festival scheduled for next weekend."
      ];
    } catch (e) {
      print('Error fetching headlines: $e');
      return [];
    }
  }

  Future<List<String>> _simplifyNews(List<String> newsItems) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/summarize'),
        body: {
          'articles': json.encode(newsItems),
          'language': _getLanguageCode(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['simplified_news']);
      } else {
        throw Exception('Failed to simplify news');
      }
    } catch (e) {
      print('Summarization error: $e');
      // Fallback: return original news items
      return newsItems;
    }
  }

  String _getLanguageCode() {
    switch (widget.language) {
      case 'ta-IN':
        return 'ta';
      case 'hi-IN':
        return 'hi';
      default:
        return 'en';
    }
  }

  Future<void> _speakCurrentNews() async {
    if (_currentNewsIndex < _newsItems.length) {
      final newsText = "News ${_currentNewsIndex + 1}: ${_newsItems[_currentNewsIndex]}";
      await TTSService().speakNews(newsText, language: widget.language);
    }
  }

  void _stopReading() {
    setState(() {
      _isPlaying = false;
    });
    TTSService().stop();
  }

  void _previousNews() {
    if (_currentNewsIndex > 0) {
      setState(() {
        _currentNewsIndex--;
      });
      TTSService().stop();
      _speakCurrentNews();
    }
  }

  void _nextNews() {
    if (_currentNewsIndex < _newsItems.length - 1) {
      setState(() {
        _currentNewsIndex++;
      });
      TTSService().stop();
      _speakCurrentNews();
    }
  }

  void _repeatCurrentNews() {
    TTSService().stop();
    _speakCurrentNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('News Reader', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.orange[100],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange[200]!, width: 2),
              ),
              child: Column(
                children: [
                  const Icon(Icons.newspaper, color: Colors.orange, size: 32),
                  const SizedBox(height: 10),
                  Text(
                    'Listen to Today\'s News',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'I will read simplified news stories in your language',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Main content area
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _newsItems.isEmpty
                      ? _buildInitialState()
                      : _buildNewsPlayer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 6),
          SizedBox(height: 20),
          Text(
            'Getting news for you...',
            style: TextStyle(fontSize: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_filled,
            size: 120,
            color: Colors.orange[400],
          ),
          const SizedBox(height: 30),
          Text(
            'Ready to Read News',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _fetchAndReadNews,
              icon: const Icon(Icons.play_arrow, size: 32),
              label: const Text('START READING NEWS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[400],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 80),
                textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsPlayer() {
    return Column(
      children: [
        // Current news display
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: Column(
              children: [
                // Progress indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'News ${_currentNewsIndex + 1} of ${_newsItems.length}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // News content
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        _newsItems[_currentNewsIndex],
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                
                // Status indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isPlaying ? Icons.volume_up : Icons.volume_off,
                      color: _isPlaying ? Colors.green : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isPlaying ? 'Playing...' : 'Paused',
                      style: TextStyle(
                        fontSize: 18,
                        color: _isPlaying ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Previous button
            ElevatedButton.icon(
              onPressed: _currentNewsIndex > 0 ? _previousNews : null,
              icon: const Icon(Icons.skip_previous, size: 24),
              label: const Text('PREVIOUS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[400],
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 60),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            // Play/Stop button
            ElevatedButton.icon(
              onPressed: _isPlaying ? _stopReading : _repeatCurrentNews,
              icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow, size: 32),
              label: Text(_isPlaying ? 'STOP' : 'PLAY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPlaying ? Colors.red[400] : Colors.green[400],
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 60),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // Next button
            ElevatedButton.icon(
              onPressed: _currentNewsIndex < _newsItems.length - 1 ? _nextNews : null,
              icon: const Icon(Icons.skip_next, size: 24),
              label: const Text('NEXT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[400],
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 60),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // Repeat button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _repeatCurrentNews,
            icon: const Icon(Icons.repeat, size: 24),
            label: const Text('REPEAT THIS NEWS'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[400],
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
