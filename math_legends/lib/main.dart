import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_legends/firebase_options.dart';
import 'package:math_legends/screens/connection_check_page.dart';
import 'package:math_legends/services/sound_service.dart';

import 'controllers/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SoundService.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Math Legends',
      theme: ThemeData(fontFamily: 'Ubuntu'),
      home: Builder(
        builder: (context) {
          SoundService.playBgm('sounds/background_music.mp3');
          Get.lazyPut(() => SettingsController(), fenix: true);
                    
          return const ConnectionCheckPage(); 
        },
      ),
    );
  }
}