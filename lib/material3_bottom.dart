import 'package:flutter/material.dart';
import 'package:mywallet/pages/History.dart';
import 'package:mywallet/pages/Profile.dart';

import 'pages/Dashboard.dart';
import 'pages/HomePage.dart';

class Material3BottomNav extends StatefulWidget {
  const Material3BottomNav({Key? key}) : super(key: key);

  @override
  State<Material3BottomNav> createState() => _Material3BottomNavState();
}

class _Material3BottomNavState extends State<Material3BottomNav> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // This getter for navigation bar items needs to be inside the state class
  List<NavigationDestination> get _navBarItems {
    return [
      NavigationDestination(
        icon: AnimatedNavigationBarIcon(
          isSelected: _selectedIndex == 0,
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
        ),
        label: 'Home',
      ),
      NavigationDestination(
        icon: AnimatedNavigationBarIcon(
          isSelected: _selectedIndex == 1,
          icon: Icons.bookmark_border_outlined,
          selectedIcon: Icons.bookmark,
        ),
        label: 'Dashboard',
      ),
      NavigationDestination(
        icon: AnimatedNavigationBarIcon(
          isSelected: _selectedIndex == 2,
          icon: Icons.shopping_bag_outlined,
          selectedIcon: Icons.shopping_bag,
        ),
        label: 'History',
      ),
      NavigationDestination(
        icon: AnimatedNavigationBarIcon(
          isSelected: _selectedIndex == 3,
          icon: Icons.person_outline_rounded,
          selectedIcon: Icons.person,
        ),
        label: 'Profile',
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet')),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(), // Disable swipe to change tabs
        children: <Widget>[
          HomeScreen(),
          DashboardScreen(),
          HistoryScreen(),
          ProfileScreen(),
        ],
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
      bottomNavigationBar: NavigationBar(
        animationDuration: const Duration(milliseconds: 400),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
        destinations: _navBarItems,
      ),
    );
  }
}

// Define your separate page widgets here
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HomePage(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Dashboard(),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: History(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Profile(),
    );
  }
}

// animation for clicking bottom bar kub
class AnimatedNavigationBarIcon extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final IconData selectedIcon;

  const AnimatedNavigationBarIcon({
    Key? key,
    required this.isSelected,
    required this.icon,
    required this.selectedIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: isSelected
          ? Icon(
              selectedIcon,
              key: UniqueKey(),
              size: 35, // Size when selected
            )
          : Icon(
              icon,
              key: UniqueKey(),
              size: 24, // Size when not selected
            ),
    );
  }
}
