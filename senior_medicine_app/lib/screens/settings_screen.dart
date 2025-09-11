import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'en-US';
  double _speechRate = 0.8;
  double _volume = 1.0;
  bool _useCloudTTS = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // In a real app, load from SharedPreferences
    setState(() {
      _selectedLanguage = 'en-US';
      _speechRate = 0.8;
      _volume = 1.0;
      _useCloudTTS = true;
      _vibrationEnabled = true;
    });
  }

  Future<void> _saveSettings() async {
    // In a real app, save to SharedPreferences
    await TTSService().initialize(language: _selectedLanguage);
    await TTSService().setSpeechRate(_speechRate);
    await TTSService().setVolume(_volume);
    
    await TTSService().speak("Settings saved successfully", language: _selectedLanguage);
  }

  Future<void> _testVoice() async {
    final testText = _getTestText(_selectedLanguage);
    if (_useCloudTTS) {
      await TTSService().speakWithCloudTTS(testText, language: _selectedLanguage);
    } else {
      await TTSService().speak(testText, language: _selectedLanguage);
    }
  }

  String _getTestText(String language) {
    switch (language) {
      case 'ta-IN':
        return 'இது குரல் சோதனை. நீங்கள் இதை கேட்க முடிகிறதா?';
      case 'hi-IN':
        return 'यह आवाज़ का परीक्षण है। क्या आप इसे सुन सकते हैं?';
      default:
        return 'This is a voice test. Can you hear this clearly?';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.purple[100],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language Settings
            _buildSectionTitle('Language Settings'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.language, size: 32, color: Colors.blue),
                      title: const Text('Voice Language', style: TextStyle(fontSize: 20)),
                      subtitle: Text(_getLanguageDisplayName(_selectedLanguage)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showLanguageDialog(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Voice Settings
            _buildSectionTitle('Voice Settings'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Speech Rate
                    ListTile(
                      leading: const Icon(Icons.speed, size: 32, color: Colors.green),
                      title: const Text('Speech Speed', style: TextStyle(fontSize: 20)),
                      subtitle: Text('${(_speechRate * 100).round()}%'),
                    ),
                    Slider(
                      value: _speechRate,
                      min: 0.5,
                      max: 1.5,
                      divisions: 10,
                      onChanged: (value) {
                        setState(() {
                          _speechRate = value;
                        });
                        TTSService().setSpeechRate(value);
                      },
                    ),

                    const Divider(),

                    // Volume
                    ListTile(
                      leading: const Icon(Icons.volume_up, size: 32, color: Colors.orange),
                      title: const Text('Volume', style: TextStyle(fontSize: 20)),
                      subtitle: Text('${(_volume * 100).round()}%'),
                    ),
                    Slider(
                      value: _volume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      onChanged: (value) {
                        setState(() {
                          _volume = value;
                        });
                        TTSService().setVolume(value);
                      },
                    ),

                    const Divider(),

                    // Cloud TTS Toggle
                    SwitchListTile(
                      secondary: const Icon(Icons.cloud, size: 32, color: Colors.purple),
                      title: const Text('High Quality Voice', style: TextStyle(fontSize: 20)),
                      subtitle: const Text('Use cloud-based text-to-speech for better quality'),
                      value: _useCloudTTS,
                      onChanged: (value) {
                        setState(() {
                          _useCloudTTS = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Notification Settings
            _buildSectionTitle('Notification Settings'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.vibration, size: 32, color: Colors.red),
                      title: const Text('Vibration', style: TextStyle(fontSize: 20)),
                      subtitle: const Text('Vibrate when reminder notifications appear'),
                      value: _vibrationEnabled,
                      onChanged: (value) {
                        setState(() {
                          _vibrationEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testVoice,
                    icon: const Icon(Icons.play_arrow, size: 24),
                    label: const Text('TEST VOICE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveSettings,
                    icon: const Icon(Icons.save, size: 24),
                    label: const Text('SAVE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[400],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Help Section
            Card(
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.help_outline, color: Colors.grey[600], size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Help',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Adjust speech speed if the voice is too fast or slow\n'
                      '• Use high quality voice for clearer pronunciation\n'
                      '• Test voice settings before saving\n'
                      '• Enable vibration for better notification alerts',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language', style: TextStyle(fontSize: 22)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppConstants.languageCodes.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.key, style: const TextStyle(fontSize: 18)),
                value: entry.value,
                groupValue: _selectedLanguage,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedLanguage = value;
                    });
                    Navigator.of(context).pop();
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _getLanguageDisplayName(String languageCode) {
    return AppConstants.languageCodes.entries
        .firstWhere((entry) => entry.value == languageCode)
        .key;
  }
}
