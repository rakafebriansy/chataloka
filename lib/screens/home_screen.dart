// import 'dart:ui_web';

// import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:chataloka/screens/chat_list_screen.dart';
import 'package:chataloka/screens/groups.dart';
import 'package:chataloka/screens/people_screen.dart';
import 'package:chataloka/utilities/assets_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController homeController = PageController(initialPage: 0);
  int currentIndex = 0;

  final List<Widget> pages = const [
    ChatListScreen(),
    GroupsScreen(),
    PeopleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chataloka'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(AssetsManager.userImage),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: homeController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2_fill),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.globe),
            label: 'People',
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          homeController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
