import 'package:cinemind/module/home_screen.dart';
import 'package:cinemind/module/impulse_screen.dart';
import 'package:cinemind/module/profile/profile_screen.dart';
import 'package:cinemind/module/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late List<AnimationController> _animationControllers;

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: Duration(milliseconds: 500),
        vsync: this,
      ),
    );
    _animationControllers[_currentIndex].forward();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget buildNavItem(IconData icon, String label, int index, bool isBolt) {
    bool isSelected = _currentIndex == index;
    Color itemColor = index == 2
        ? (isSelected ? Colors.yellow : Colors.grey)
        : (isSelected ? Colors.red : Colors.grey);

    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? itemColor.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isBolt
                ? LottieBuilder.asset(
                    'asset/lottie/bolt.json',
                  )
                : Icon(icon, color: itemColor, size: isSelected ? 28 : 24),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: isSelected ? 80 : 0,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: itemColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(),
      SearchScreen(),
      ImpulseScreen(),
      ProfileScreen()
    ];
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildNavItem(Icons.home, "Home", 0, false),
              buildNavItem(Icons.search, "Search", 1, false),
              buildNavItem(Icons.bolt, "Impulse", 2, true),
              buildNavItem(Icons.person, "Profile", 3, false),
            ],
          ),
        ),
      ),
    );
  }
}
