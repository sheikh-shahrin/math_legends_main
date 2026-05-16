// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:math_legends/configs/generic_layout.dart';
import 'package:math_legends/configs/text_stroke.dart';
import 'package:math_legends/services/firestore_user_service.dart';
import 'package:math_legends/services/firebase_storage_service.dart';
import '../configs/buttons.dart';
import '../controllers/user_controller.dart';
import '../utils/player_progress.dart';

class ProfilePage extends StatefulWidget {
  final dynamic userModel;

  const ProfilePage(this.userModel, {super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double xp = widget.userModel.xp ?? 0;
    final double rp = widget.userModel.rp ?? 0;

    final level = PlayerProgress.getLevel(xp);
    final levelProgress = PlayerProgress.getLevelProgress(xp);

    final rankData = PlayerProgress.getRank(rp);
    final rankProgress = PlayerProgress.getRankProgress(rp);

    return GenericLayout(
      title: 'Profile',
      solidColor: const Color(0xFF7B61FF),
      gradientColor: const [Color(0xFF6A11CB), Color(0xFF2575FC)],
      strokeColor: const Color(0xFF6A11CB),
      children: [
        Center(
          child: Container(
            height: size.height * 0.7,
            width: size.width * 0.9,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.75),
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// PROFILE PICTURE (EDITABLE)
                    GestureDetector(
                      onTap: () => _editProfilePic(context),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundImage: NetworkImage(
                              widget.userModel.profilePic ??
                                  'https://i.imgur.com/BoN9kdC.png',
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// NAME (EDITABLE)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StrokeText(
                          widget.userModel.name ?? 'User',
                          fontSize: 22,
                          fillColor: Colors.white,
                          strokeColor: Colors.black,
                          strokeWidth: 4,
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _editName(context),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.draw_rounded, // ✏️ draw icon
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    /// EMAIL
                    Text(
                      widget.userModel.email ?? 'No email',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _infoRow('Coins', '${widget.userModel.coins ?? 0}'),

                    const SizedBox(height: 14),

                    /// LEVEL
                    StrokeText(
                      'Level $level',
                      fontSize: 16,
                      fillColor: Colors.white,
                      strokeColor: Colors.black,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 6),
                    _progressBar(
                      progress: levelProgress,
                      fillColor: Colors.lightGreenAccent,
                    ),

                    const SizedBox(height: 18),

                    /// RANK
                    StrokeText(
                      '${rankData['rank']} ${rankData['tier']}',
                      fontSize: 16,
                      fillColor: Colors.white,
                      strokeColor: Colors.black,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 6),
                    _progressBar(
                      progress: rankProgress,
                      fillColor: Colors.orangeAccent,
                    ),
                    const SizedBox(height: 20),

                    const SizedBox(height: 22),

                    CustomButton(
                      btnWidth: 200,
                      fontSize: 15,
                      onPressed: () => _resetPassword(context),
                      gradientColors: const [
                        Color(0xFF8B0000), // Dark red
                        Color(0xFFB71C1C), // Red accent
                      ],
                      borderColor: const Color(0xFF5F0000),
                      text: 'Reset Password',
                      textStrokeColor: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /* =========================
     EDIT NAME
  ========================= */
  void _editName(BuildContext context) {
    final controller = TextEditingController(text: widget.userModel.name);
    final service = FirestoreUserService();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter new name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;

              await service.updateUserName(
                uid: widget.userModel.uid!,
                name: newName,
              );

              widget.userModel.name = newName;

              final userCtrl = Get.find<UserController>();
              await userCtrl.loadUser(widget.userModel.uid!);

              setState(() {});

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /* =========================
     EDIT PROFILE PIC
  ========================= */
  Future<void> _editProfilePic(BuildContext context) async {
    final picker = ImagePicker();
    final firestoreService = FirestoreUserService();
    final storageService = FirebaseStorageService();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final imageUrl = await storageService.uploadProfilePic(
        uid: widget.userModel.uid!,
        imageFile: imageFile,
      );

      await firestoreService.updateUserProfilePic(
        uid: widget.userModel.uid!,
        profilePic: imageUrl,
      );

      widget.userModel.profilePic = imageUrl;

      final userCtrl = Get.find<UserController>();
      await userCtrl.loadUser(widget.userModel.uid!);

      setState(() {});
    } finally {
      Navigator.pop(context);
    }
  }

  /* =========================
     UI HELPERS
  ========================= */
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StrokeText(
            label,
            fontSize: 16,
            fillColor: Colors.white,
            strokeColor: Colors.black,
            strokeWidth: 3,
          ),
          StrokeText(
            value,
            fontSize: 16,
            fillColor: Colors.yellowAccent,
            strokeColor: Colors.black,
            strokeWidth: 3,
          ),
        ],
      ),
    );
  }

  Widget _progressBar({
    required double progress,
    required Color fillColor,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;

        final double displayProgress = progress.clamp(0.02, 1.0);

        return Container(
          height: 14,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: barWidth * displayProgress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      fillColor.withOpacity(0.6),
                      fillColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /* =========================
   RESET PASSWORD
========================= */
  Future<void> _resetPassword(BuildContext context) async {
    final email = widget.userModel.email;

    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email linked to this account')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send reset email: $e'),
        ),
      );
    }
  }
}
