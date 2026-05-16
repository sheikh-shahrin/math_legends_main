import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

class SoundService {
  static final AudioPlayer _bgmPlayer = AudioPlayer();
  static final List<AudioPlayer> _sfxPlayers = [];

  static bool _bgmStarted = false;
  static String? _currentBgm;

  // 🔊 GLOBAL SETTINGS
  static bool bgmMuted = false;
  static bool sfxMuted = false;

  static double bgmVolume = 1.0;
  static double sfxVolume = 1.0;

  static void init() {
    WidgetsBinding.instance.addObserver(_LifecycleHandler());
  }

  static Future<void> playBgm(String assetPath) async {
    if (bgmMuted) return;
    if (_bgmStarted && _currentBgm == assetPath) return;

    _bgmStarted = true;
    _currentBgm = assetPath;

    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(bgmVolume);
    await _bgmPlayer.play(AssetSource(assetPath));
  }

  static Future<void> pauseBgm() async {
    if (_bgmStarted) {
      await _bgmPlayer.pause();
    }
  }

  static Future<void> resumeBgm() async {
    if (_bgmStarted && !bgmMuted) {
      await _bgmPlayer.resume();
    }
  }

  static Future<void> stopBgm() async {
    _bgmStarted = false;
    _currentBgm = null;
    await _bgmPlayer.stop();
  }

  static Future<void> setBgmVolume(double volume) async {
    bgmVolume = volume;
    if (!bgmMuted) {
      await _bgmPlayer.setVolume(volume);
    }
  }

  static Future<void> playSfx(String assetPath) async {
    if (sfxMuted) return;

    final player = AudioPlayer();
    _sfxPlayers.add(player);

    await player.setVolume(sfxVolume);
    await player.play(AssetSource(assetPath));

    player.onPlayerComplete.listen((_) {
      player.dispose();
      _sfxPlayers.remove(player);
    });
  }

  static void dispose() {
    _bgmPlayer.dispose();
    for (final p in _sfxPlayers) {
      p.dispose();
    }
    _sfxPlayers.clear();
  }
}

class _LifecycleHandler with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      SoundService.pauseBgm();
    } else if (state == AppLifecycleState.resumed) {
      SoundService.resumeBgm();
    }
  }
}
