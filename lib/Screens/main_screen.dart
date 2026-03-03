import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Ye wo screens hain jo tab dabane par khulengi (Abhi dummy hain)
  final List<Widget> _screens = [
    const Center(child: Text('Home Screen', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Stats Screen', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Profile Screen', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: _screens[_currentIndex], // Jo tab select hoga, wo screen dikhegi

      // Ye raha tera bindas Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.cardColor,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),

      // Center mein ek bada '+ Add Expense' button (Floating Action Button)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aage chalkar yahan Add Expense ka bottom sheet khulega
          print("Add Expense Clicked!");
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}