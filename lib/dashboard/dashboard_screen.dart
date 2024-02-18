import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_pm2/fragments/explore_screen.dart';
import 'package:uas_pm2/fragments/home_screen.dart';
import 'package:uas_pm2/fragments/profile_screen.dart';

void main() {
  runApp(DashboardScreen());
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bottom Navigation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider(
        create: (context) => TabProvider(),
        child: BottomNavigationBarExample(),
      ),
    );
  }
}

class BottomNavigationBarExample extends StatelessWidget {
  final List<Widget> _pages = [HomeScreen(), ExploreScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    final tabProvider = Provider.of<TabProvider>(context);
    return Scaffold(
      body: _pages[tabProvider.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabProvider.currentIndex,
        onTap: (index) {
          tabProvider.currentIndex = index;
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Color.fromARGB(255, 202, 62, 226),
        unselectedItemColor: const Color.fromARGB(255, 214, 113, 232),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 50, 49, 49),
        elevation: 8.0,
      ),
    );
  }
}

class TabProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
