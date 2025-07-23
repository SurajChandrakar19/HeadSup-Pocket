import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../utils/app_colors.dart';
import 'dashboard_shell_screen.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showAdminForm = false;
  final TextEditingController _adminEmailController = TextEditingController();
  final TextEditingController _adminPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

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
              const SizedBox(height: 40),
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
              if (!_showAdminForm) ...[
                // Welcome message
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
                      TextSpan(
                        text:
                            'Welcome to Headsup,\nwhere Your Workforce\nBecome ',
                      ),
                      TextSpan(
                        text: 'Empower',
                        style: TextStyle(color: empowerBlue),
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
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
                      TextSpan(
                        text: 'Impactfull',
                        style: TextStyle(color: empowerBlue),
                      ),
                      TextSpan(text: ' Platform.'),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                // Google Sign In button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement Google Sign-In
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardShellScreen(),
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
                    icon: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/google_logo.png',
                          width: 16,
                          height: 16,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                              'G',
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    label: const Text('Sign In With Google'),
                  ),
                ),
                const SizedBox(height: 16),
                // Admin Login button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showAdminForm = true;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryBlue, width: 2),
                      foregroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const Icon(
                      Icons.admin_panel_settings,
                      color: primaryBlue,
                    ),
                    label: const Text('Admin Login'),
                  ),
                ),
              ] else ...[
                // Admin login form
                Text(
                  'Admin Access',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Secure administrative login',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                // Email field
                TextField(
                  controller: _adminEmailController,
                  decoration: InputDecoration(
                    labelText: 'Admin Email',
                    prefixIcon: const Icon(Icons.email, color: primaryBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                // Password field
                TextField(
                  controller: _adminPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Admin Password',
                    prefixIcon: const Icon(Icons.lock, color: primaryBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                // Admin login button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    // onPressed: () {
                    //   // Simple admin login logic
                    //   if (_adminEmailController.text == 'admin@headsup.com' &&
                    //       _adminPasswordController.text == 'admin123') {
                    //     Navigator.pushReplacement(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => const DashboardShellScreen(isAdmin: true),
                    //       ),
                    //     );
                    //   } else {
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       SnackBar(
                    //         content: Row(
                    //           children: const [
                    //             Icon(Icons.error, color: whiteColor),
                    //             SizedBox(width: 8),
                    //             Text('Invalid admin credentials'),
                    //           ],
                    //         ),
                    //         backgroundColor: primaryBlue,
                    //       ),
                    //     );
                    //   }
                    // },
                    onPressed: () async {
                      final email = _adminEmailController.text.trim();
                      final password = _adminPasswordController.text.trim();

                      final authService = AuthService();
                      final data = await authService.login(email, password);

                      if (data != null) {
                        // set data in provider
                        final userProvider = Provider.of<UserProvider>(
                          context,
                          listen: false,
                        );
                        userProvider.setUser(
                          id: data['id'],
                          email: data['email'],
                          name: data['name'],
                        );

                        // Navigate to dashboard
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DashboardShellScreen(isAdmin: true),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: const [
                                Icon(Icons.error, color: whiteColor),
                                SizedBox(width: 8),
                                Text('Login failed: Invalid credentials'),
                              ],
                            ),
                            backgroundColor: primaryBlue,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: whiteColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const Icon(
                      Icons.admin_panel_settings,
                      color: whiteColor,
                    ),
                    label: const Text('Admin Login'),
                  ),
                ),
                const SizedBox(height: 16),
                // Cancel/back button
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showAdminForm = false;
                    });
                  },
                  child: const Text('Back to User Login'),
                ),
              ],
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
