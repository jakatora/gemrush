import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Cienki wrapper na audioplayers. Ścieżki względne do `assets/audio/`.
class AudioService {
  final AudioPlayer _musicPlayer = AudioPlayer();
  bool soundEnabled = true;
  bool musicEnabled = true;
  String? _currentMusic;

  Future<void> init() async {
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playSfx(String filename) async {
    if (!soundEnabled) return;
    try {
      final player = AudioPlayer();
      await player.play(AssetSource('audio/sfx/$filename'));
      player.onPlayerComplete.first.then((_) => player.dispose());
    } catch (e) {
      if (kDebugMode) debugPrint('[audio] sfx error: $e');
    }
  }

  Future<void> playMusic(String filename) async {
    if (!musicEnabled) return;
    if (_currentMusic == filename) return;
    try {
      await _musicPlayer.stop();
      await _musicPlayer.play(AssetSource('audio/music/$filename'));
      _currentMusic = filename;
    } catch (e) {
      if (kDebugMode) debugPrint('[audio] music error: $e');
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
    _currentMusic = null;
  }

  Future<void> dispose() async {
    await _musicPlayer.dispose();
  }
}
