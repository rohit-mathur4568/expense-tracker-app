import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'home_screen.dart';
import '../widgets/add_expense.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 🔴 Update: Ab 4 screens hain taaki UI perfectly balance rahe
  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('Stats Screen', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Profile Screen', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Settings Screen', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      extendBody: true, // Background gaddhe ke pichhe jaye

      body: _screens[_currentIndex],

      // 🛠️ PERFECTLY BALANCED NAV BAR
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        color: AppColors.cardColor, // White ya dark mode color
        elevation: 10,
        child: SizedBox(
          height: 65, // Thodi height badhayi taaki premium feel aaye
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Beech mein apne aap space banayega
            children: [

              // LEFT SIDE (Home & Stats)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(Icons.home_filled, 'Home', 0),
                  _buildNavItem(Icons.bar_chart_rounded, 'Stats', 1),
                ],
              ),

              // RIGHT SIDE (Profile & Settings)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(Icons.person, 'Profile', 2),
                  _buildNavItem(Icons.settings, 'Settings', 3), // Ab ye visible hai!
                ],
              ),

            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => const AddExpense(),
          );
        },
        backgroundColor: AppColors.primaryColor,
        shape: const CircleBorder(),
        elevation: 5,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // 📝 Nav Item Builder (Slightly adjusted for perfect width)
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return MaterialButton(
      minWidth: 70, // Har icon ko barabar space milegi
      onPressed: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}