import 'package:flutter/material.dart';
import 'package:image_text_reader/constants/colors.dart';
import 'package:image_text_reader/screens/home_page.dart';
import 'package:image_text_reader/screens/user_history.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
   
  int _selectedIndex = 0;

  //Method to hadle the tapping on botton navigation item
  void _onTapItem(int index){
    setState(() {
      _selectedIndex = index; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.transform),
            label: "Conversion",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
        ],
        onTap: _onTapItem,
        currentIndex: _selectedIndex,
        unselectedItemColor: const Color.fromARGB(255, 1, 23, 42),
        selectedItemColor: const Color.fromARGB(255, 252, 254, 255),
        backgroundColor: mainColor,
        
      ),
      body: _selectedIndex == 0 ? HomePage() : UserHistory(),
    );
  }
}
