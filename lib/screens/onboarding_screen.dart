import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../utils/app_colors.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Title with Pocket CTS
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(text: 'Pocket '),
                    TextSpan(
                      text: 'CTS',
                      style: TextStyle(color: pocketBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
              // Lottie Animation
              Expanded(
                flex: 3,
                child: SizedBox(
                  width: double.infinity,
                  child: Lottie.asset(
                    'assets/images/Animation.json',
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: true,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.business_center,
                          size: 120,
                          color: pocketBlue,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Main description text
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(text: 'The whole company in\nyour '),
                    TextSpan(
                      text: 'Pocket',
                      style: TextStyle(color: pocketBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle description
              const Text(
                'Get all your HR related tasks in one place. Easy,\nreliable and quick.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textSecondary,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 60),
              // Get Started button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: buttonTextWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Get Started'),
                ),
              ),
              const SizedBox(height: 16),
              // Powered by text
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(text: 'Powered by '),
                    TextSpan(
                      text: 'Headsup HR',
                      style: TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
