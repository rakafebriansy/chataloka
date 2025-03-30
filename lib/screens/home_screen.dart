import 'package:chataloka/constants/route.dart';
import 'package:chataloka/providers/authentication_provider.dart';
import 'package:chataloka/screens/home/page_view/chat_list_screen.dart';
import 'package:chataloka/screens/home/page_view/groups_screen.dart';
import 'package:chataloka/screens/home/page_view/people_screen.dart';
import 'package:chataloka/widgets/user_image_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.read<AuthenticationProvider>();
    if (authProvider.userModel == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(RouteConstant.loginScreen, (route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chataloka'),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: UserImageButton(
              imageUrl: authProvider.userModel?.image,
              radius: 20,
              onTap: () {
                if (authProvider.userModel != null) {
                  Navigator.of(context).pushNamed(
                    RouteConstant.profileScreen,
                    arguments: authProvider.userModel!.uid,
                  );
                }
              },
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
