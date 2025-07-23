import 'package:flutter/material.dart';
import '../utils/app_colors.dart'; // For specific colors if not themed
import 'login_screen.dart'; // For logout navigation
import 'privacy_policy_screen.dart';
import 'help_support_screen.dart';
import 'account_details_screen.dart';

class SettingsTabScreen extends StatefulWidget {
  const SettingsTabScreen({super.key});

  @override
  State<SettingsTabScreen> createState() => _SettingsTabScreenState();
}

class _SettingsTabScreenState extends State<SettingsTabScreen> {
  bool _isDarkMode = false; // State variable to track dark mode

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      // backgroundColor: lightGreyBackground, // From theme
      body: Builder(
        builder: (context) => ListView(
          children: <Widget>[
            const SizedBox(height: 20),
            // User Profile Summary Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: accentLighterBlue,
                  child: Icon(Icons.person, size: 30, color: whiteColor), // Placeholder
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Name', // TODO: Replace with actual user data
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'user.email@example.com', // TODO: Replace
                      style: TextStyle(fontSize: 14, color: subtleTextColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 40),

          // Settings Options
          _buildSettingsItem(
            context,
            icon: Icons.account_circle_outlined,
            title: 'Account Details',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountDetailsScreen()),
              );
            },
          ),
          // Notification Preferences removed
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined, color: primaryDarkBlue),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: _isDarkMode, // Now uses the state variable
              onChanged: (bool value) {
                setState(() {
                  _isDarkMode = value; // Update the state
                });
                // TODO: Implement actual dark mode theme switching logic
                print('Dark Mode toggled: $value');
                
                // Show a snackbar to indicate the toggle worked
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isDarkMode ? 'Dark mode enabled' : 'Dark mode disabled'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              activeColor: accentLighterBlue,
            ),
            onTap: () {
              // Toggle the switch when the whole row is tapped
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
              print('Dark Mode toggled via row tap: $_isDarkMode');
              
              // Show a snackbar to indicate the toggle worked
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isDarkMode ? 'Dark mode enabled' : 'Dark mode disabled'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()),
              );
            },
          ),
          _buildSettingsItem(
            context,
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpSupportScreen()),
              );
            },
          ),
          const Divider(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400], // Destructive action color
              ),
              onPressed: () {
                // TODO: Implement logout logic (clear session, etc.)
                print('Logout tapped');
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false, // Remove all previous routes
                );
              },
              child: const Text('Logout', style: TextStyle(color: whiteColor)),
            ),
          ),
        ],
        ),
        ),
        );
        }

  Widget _buildSettingsItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: primaryDarkBlue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: subtleTextColor),
      onTap: onTap,
    );
  }
}
