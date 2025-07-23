import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text('Frequently Asked Questions', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          ExpansionTile(
            title: const Text('How do I reset my password?'),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Go to Account Details > Edit Profile. You will see an option to reset your password (coming soon).'),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('How do I contact support?'),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('You can use the button below to email our support team.'),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('How do I update my profile information?'),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Go to Account Details and tap Edit Profile (coming soon).'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                // In a real app, use url_launcher to open email
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Launching email to support@example.com')),
                );
              },
              icon: const Icon(Icons.email),
              label: const Text('Contact Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
