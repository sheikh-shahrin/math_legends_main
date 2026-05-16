import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:math_legends/configs/generic_layout.dart';
import 'package:math_legends/configs/text_stroke.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GenericLayout(
      title: 'About',
      solidColor: const Color(0xFF2EE6A6),
      gradientColor: const [Color(0xFF43CEA2), Color(0xFF185A9D)],
      strokeColor: const Color(0xFF185A9D),
      children: [
        Expanded(
          child: Container(
            height: size.height * 0.8,
            width: size.width,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Application'),
                    _bodyText(
                      'Math Legends is an interactive educational game designed '
                      'to help students improve their mathematics skills through '
                      'fun challenges, mini-games, and engaging visuals.',
                    ),
                    const SizedBox(height: 30),
                    _sectionTitle('Company'),
                    _bodyText(
                      'This application is developed and maintained by Saturn Studios, '
                      'with the goal of making learning mathematics enjoyable, accessible, '
                      'and effective for students of all levels.',
                    ),
                    const SizedBox(height: 30),
                    _sectionTitle('Developer'),
                    _bodyText(
                      'Developed by an Infocomm & Media Engineering student specialising '
                      'in software application development, focusing on user-friendly '
                      'design and interactive learning experiences.',
                    ),
                    const SizedBox(height: 30),
                    _sectionTitle('Contact Us'),
                    const SizedBox(height: 15),
                    _contactButton(
                      icon: Icons.call,
                      label: 'Call Company',
                      onTap: () => _launchUri('tel:+6588308565'),
                    ),
                    const SizedBox(height: 10),
                    _contactButton(
                      icon: Icons.email,
                      label: 'Email Feedback',
                      onTap: () =>
                          _launchUri('mailto:shahrinquerty51@gmail.com'),
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
     UI Helpers
  ========================= */

  Widget _sectionTitle(String text) {
    return StrokeText(
      text,
      fontSize: 24,
      fillColor: Colors.white,
      strokeColor: Colors.black,
      strokeWidth: 5,
    );
  }

  Widget _bodyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _contactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            StrokeText(
              label,
              fontSize: 16,
              fillColor: Colors.white,
              strokeColor: Colors.black,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }

  /* =========================
     Launcher
  ========================= */

  Future<void> _launchUri(String uri) async {
    final url = Uri.parse(uri);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
