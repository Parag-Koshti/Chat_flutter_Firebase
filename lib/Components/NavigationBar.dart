import 'package:chat/Pages/AddPage.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:chat/Pages/HomePage.dart';
import 'package:chat/Pages/searchPage.dart';
import 'package:chat/Pages/AddPage.dart';
import 'package:chat/Pages/ContactPage.dart';
import 'package:chat/Pages/ProfilePage.dart';

class NavigationMenu extends StatefulWidget {
  NavigationMenu({super.key});

  @override
  _NavigationMenuState createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Homepage(),
    SearchPage(),
    newUser(),
    ContactPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: BottomNavigationBar(
              showUnselectedLabels: false,
              elevation: 20,
              showSelectedLabels: false,
              unselectedItemColor: Colors.black,
              selectedItemColor: Colors.white,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: _selectedIndex == 0
                        ? const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.black)
                        : null,
                    child: const Icon(AntDesign.message_outline),
                  ),
                  label: "Home",
                  backgroundColor: Colors.grey.shade300,
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: _selectedIndex == 1
                        ? const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.black)
                        : null,
                    child: const Icon(AntDesign.search_outline),
                  ),
                  label: "Wallet",
                  backgroundColor: Colors.grey.shade300,
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: _selectedIndex == 2
                        ? const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.black)
                        : null,
                    child: const Icon(AntDesign.plus_outline),
                  ),
                  label: "Stock",
                  backgroundColor: Colors.grey.shade300,
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: _selectedIndex == 3
                        ? const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.black)
                        : null,
                    child: const Icon(AntDesign.phone_outline),
                  ),
                  label: "Group",
                  backgroundColor: Colors.grey.shade300,
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: _selectedIndex == 4
                        ? const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.black)
                        : null,
                    child: const Icon(AntDesign.profile_twotone),
                  ),
                  label: "Block",
                  backgroundColor: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ),
      ),
      // body: Center(
      //   child:,
      // ),
      endDrawer: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}

// Placeholder Widgets for each page
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Home Page'),
      ),
    );
  }
}

class WalletPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Wallet Page'),
      ),
    );
  }
}

class UpArrowPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Up Arrow Page'),
      ),
    );
  }
}

class StockPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Stock Page'),
      ),
    );
  }
}

class BlockPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Block Page'),
      ),
    );
  }
}
