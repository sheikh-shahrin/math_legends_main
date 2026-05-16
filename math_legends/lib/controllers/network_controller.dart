// lib/controllers/network_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:math_legends/configs/buttons.dart';

class NetworkController extends GetxController {
  late StreamSubscription<InternetConnectionStatus> _subscription;
  bool _isDialogShowing = false;

  @override
  void onInit() {
    super.onInit();
    _startMonitoring();
  }

  // REQUIREMENT 2: Constantly check connection in the background
  void _startMonitoring() {
    _subscription = InternetConnectionChecker().onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.disconnected) {
        // REQUIREMENT 1: Show popup if connection is lost
        _showNoInternetDialog();
      } else {
        // Auto-close the dialog if the system detects internet is back
        _closeDialog();
      }
    });
  }

  void _showNoInternetDialog() {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevents Android back button from closing it
        child: AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.redAccent, width: 3),
          ),
          title: const Center(
            child: Text(
              "Connection Lost",
              style: TextStyle(
                color: Colors.redAccent, 
                fontWeight: FontWeight.bold,
                fontSize: 22
              ),
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 60, color: Colors.white70),
              SizedBox(height: 20),
              Text(
                "Your gameplay has been interrupted because you lost your internet connection.\n\nPlease check your Wi-Fi or Cellular Data.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          actions: [
            Center(
              child: CustomButton(
                text: "Reconnect",
                gradientColors: [Colors.blue, Colors.blue[900]!],
                textStrokeColor: Colors.black,
                borderColor: Colors.blue[200]!,
                fontSize: 16,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                onPressed: () async {
                  
                  // REQUIREMENT 3: Manually check if user has internet when clicking button
                  bool hasConnection = await InternetConnectionChecker().hasConnection;
                  
                  if (hasConnection) {
                    _closeDialog();
                  } else {
                    Get.snackbar(
                      "Still Offline", 
                      "Please connect to the internet first.",
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.redAccent,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(15)
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
      barrierDismissible: false, // Prevents tapping outside to dismiss
    );
  }

  void _closeDialog() {
    if (_isDialogShowing) {
      _isDialogShowing = false;
      if (Get.isDialogOpen ?? false) {
        Get.back(); // Hides the dialog
      }
    }
  }

  @override
  void onClose() {
    _subscription.cancel(); // Cleans up the background listener when app closes
    super.onClose();
  }
}