import 'package:get/get.dart';
import '../services/sound_service.dart';

class SettingsController extends GetxController {
  final bgmMuted = false.obs;
  final sfxMuted = false.obs;

  final bgmVolume = 1.0.obs;
  final sfxVolume = 1.0.obs;

  final hidePetOverlay = false.obs;

  @override
  void onInit() {
    bgmMuted.value = SoundService.bgmMuted;
    sfxMuted.value = SoundService.sfxMuted;
    bgmVolume.value = SoundService.bgmVolume;
    sfxVolume.value = SoundService.sfxVolume;
    super.onInit();
  }

  void toggleBgmMute(bool value) {
    bgmMuted.value = value;
    SoundService.bgmMuted = value;

    if (value) {
      SoundService.pauseBgm();
    } else {
      SoundService.resumeBgm();
    }
  }

  void toggleSfxMute(bool value) {
    sfxMuted.value = value;
    SoundService.sfxMuted = value;
  }

  void setBgmVolume(double value) {
    bgmVolume.value = value;
    SoundService.setBgmVolume(value);
  }

  void setSfxVolume(double value) {
    sfxVolume.value = value;
    SoundService.sfxVolume = value;
  }

  void togglePetOverlay(bool v) {
    hidePetOverlay.value = v;
  }

  void resetSettings() {
    bgmMuted.value = false;
    sfxMuted.value = false;
    bgmVolume.value = 1.0;
    sfxVolume.value = 1.0;
    hidePetOverlay.value = false;

    SoundService.bgmMuted = false;
    SoundService.sfxMuted = false;
    SoundService.setBgmVolume(1.0);
    SoundService.sfxVolume = 1.0;
    
    SoundService.resumeBgm();
  }
}

