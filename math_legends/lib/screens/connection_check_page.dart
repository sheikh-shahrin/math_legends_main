import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:math_legends/configs/buttons.dart';
import 'package:math_legends/configs/retrieve_user_data.dart';
import 'package:math_legends/screens/home_page.dart';
import 'package:math_legends/screens/login_page.dart';

import '../controllers/network_controller.dart';

class ConnectionCheckPage extends StatefulWidget {
  const ConnectionCheckPage({super.key});

  @override
  State<ConnectionCheckPage> createState() => _ConnectionCheckPageState();
}

class _ConnectionCheckPageState extends State<ConnectionCheckPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkInternetAndProceed();
  }

  Future<void> _checkInternetAndProceed() async {
    setState(() {
      _isLoading = true;
    });

    // Check if the user has active internet connection
    bool hasConnection = await InternetConnectionChecker().hasConnection;

    if (hasConnection) {
      // Internet is available! Proceed to load the app data
      String? uid = await RetrieveUserdata().retrieveUid();

      Get.put(NetworkController(), permanent: true); 
      
      if (uid != null) {
        // Logged in user -> go to home
        Get.offAll(() => HomePage(uid: uid, newUser: false));
      } else {
        // New user -> go to login
        Get.offAll(() => const LoginPage());
      }
    } else {
      // No internet connection
      setState(() {
        _isLoading = false;
      });
      _showNoInternetDialog();
    }
  }

  void _showNoInternetDialog() {
    Get.defaultDialog(
      title: "Connection Error",
      titleStyle: const TextStyle(
        fontWeight: FontWeight.bold, 
        fontSize: 22, 
        color: Colors.redAccent
      ),
      middleText: "No internet connection detected.\nPlease check your network and try again.",
      middleTextStyle: const TextStyle(fontSize: 16),
      barrierDismissible: false, // Prevents closing the dialog by tapping outside
      contentPadding: const EdgeInsets.all(20),
      actions: [
        CustomButton(
          text: "Reconnect",
          gradientColors: [Colors.blue, Colors.blue[900]!],
          textStrokeColor: Colors.black,
          borderColor: Colors.blue[200]!,
          fontSize: 18,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          onPressed: () {
            Get.back(); // Close the dialog
            _checkInternetAndProceed(); // Re-trigger the internet check
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Keeps the game aesthetic while loading/verifying
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/math_legends_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: _isLoading 
              ? const CircularProgressIndicator(
                  color: Colors.yellow, 
                  strokeWidth: 6,
                ) 
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}