import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_legends/configs/generic_layout.dart';
import 'package:math_legends/configs/text_stroke.dart';
import '../controllers/settings_controller.dart';
import '../configs/settings_panel.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final SettingsController controller = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    return GenericLayout(
      title: 'Settings',
      solidColor: const Color(0xFF66B2FF),
      gradientColor: const [
        Color(0xFF5FA8FF),
        Color(0xFF2F6BFF),
      ],
      strokeColor: const Color(0xFF2F6BFF),
      children: [
        const SizedBox(height: 5),
        AudioSettingsPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Audio'),
              const SizedBox(height: 12),
              Obx(() => _switchRow(
                    label: 'Mute Background Music',
                    value: controller.bgmMuted.value,
                    onChanged: controller.toggleBgmMute,
                  )),
              const SizedBox(height: 8),
              Obx(() => _slider(
                    label: 'Background Music Volume',
                    value: controller.bgmVolume.value,
                    onChanged: controller.setBgmVolume,
                  )),
              const SizedBox(height: 16),
              Obx(() => _switchRow(
                    label: 'Mute Sound Effects',
                    value: controller.sfxMuted.value,
                    onChanged: controller.toggleSfxMute,
                  )),
              const SizedBox(height: 8),
              Obx(() => _slider(
                    label: 'Sound Effects Volume',
                    value: controller.sfxVolume.value,
                    onChanged: controller.setSfxVolume,
                  )),
              const SizedBox(height: 40),
              _sectionTitle('Visual'),
              const SizedBox(height: 12),
              Obx(() => _switchRow(
                    label: 'Hide Pet',
                    value: controller.hidePetOverlay.value,
                    onChanged: controller.togglePetOverlay,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  /* =========================
     Styled Widgets
  ========================= */

  Widget _sectionTitle(String text) {
    return Center(
      child: StrokeText(
        text,
        fontSize: 26,
        fillColor: Colors.white,
        strokeColor: Colors.black,
        strokeWidth: 7,
      ),
    );
  }

  Widget _switchRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: StrokeText(
            label,
            fontSize: 18,
            fillColor: Colors.white,
            strokeColor: Colors.black,
            strokeWidth: 4,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.greenAccent,
        ),
      ],
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StrokeText(
          label,
          fontSize: 18,
          fillColor: Colors.white,
          strokeColor: Colors.black,
          strokeWidth: 4,
        ),
        Slider(
          value: value,
          min: 0,
          max: 1,
          divisions: 10,
          activeColor: Colors.lightBlueAccent,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
