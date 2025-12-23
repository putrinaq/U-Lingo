import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  /// Play audio from bytes
  static Future<void> playAudio(Uint8List audioBytes) async {
    try {
      if (_isPlaying) {
        await _player.stop();
      }

      _isPlaying = true;
      await _player.play(BytesSource(audioBytes));

      // Listen for completion
      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      print('Error playing audio: $e');
      _isPlaying = false;
    }
  }

  /// Stop current playback
  static Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  /// Check if audio is currently playing
  static bool get isPlaying => _isPlaying;

  /// Dispose the player
  static Future<void> dispose() async {
    await _player.dispose();
  }
}