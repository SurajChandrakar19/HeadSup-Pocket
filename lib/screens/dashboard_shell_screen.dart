import 'package:flutter/material.dart';
import 'home_tab_screen.dart';
import 'candidates_tab_screen.dart';
import 'applications_tab_screen.dart';
import 'jobs_tab_screen.dart';
import 'data_vault_page.dart';

class DashboardShellScreen extends StatefulWidget {
  final bool isAdmin;
  const DashboardShellScreen({super.key, this.isAdmin = false});

  @override
  State<DashboardShellScreen> createState() => _DashboardShellScreenState();
}

class _DashboardShellScreenState extends State<DashboardShellScreen> {
  // Access widget.isAdmin for admin features
  int _selectedIndex = 0; // Default to Home tab

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = [
      HomeTabScreen(),
      CandidatesTabScreen(
        onBackToHome: () => setState(() => _selectedIndex = 0),
        isAdmin: widget.isAdmin,
      ),
      JobsTabScreen(
        onBackToHome: () => setState(() => _selectedIndex = 0),
        isAdmin: widget.isAdmin,
      ),
      ApplicationsTabScreen(
        onBackToHome: () => setState(() => _selectedIndex = 0),
        isAdmin: widget.isAdmin,
      ),
      DataVaultPage(),
    ];
    return Scaffold(
      body: widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Candidates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage_outlined),
            activeIcon: Icon(Icons.storage),
            label: 'Data Vault',
          ),
        ],
        currentIndex: _selectedIndex,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        elevation: 8.0,
      ),
    );
  }
}
