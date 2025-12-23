import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class ElevenLabsService {
  static const String _apiKey = 'sk_12f4a776ab66a9f31055de1408f6c41f6d494f81a8250fa6';
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';

  // Voice ID for multilingual support (Chinese + English)
  static const String _voiceId = 'pNInz6obpgDQGcFmaJgB'; // Adam (multilingual)

  /// Convert text to speech and return audio bytes
  static Future<Uint8List?> textToSpeech(String text, {String? voiceId}) async {
    try {
      final url = Uri.parse('$_baseUrl/text-to-speech/${voiceId ?? _voiceId}');

      final response = await http.post(
        url,
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': _apiKey,
        },
        body: jsonEncode({
          'text': text,
          'model_id': 'eleven_multilingual_v2',
          'voice_settings': {
            'stability': 0.5,
            'similarity_boost': 0.75,
            'style': 0.0,
            'use_speaker_boost': true,
          },
        }),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('ElevenLabs API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calling ElevenLabs API: $e');
      return null;
    }
  }

  /// Get list of available voices
  static Future<List<Map<String, dynamic>>> getVoices() async {
    try {
      final url = Uri.parse('$_baseUrl/voices');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'xi-api-key': _apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['voices'] ?? []);
      } else {
        print('Error fetching voices: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching voices: $e');
      return [];
    }
  }
}