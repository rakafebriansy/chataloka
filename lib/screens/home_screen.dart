import 'package:chataloka/constants/route_constants.dart';
import 'package:chataloka/providers/user_provider.dart';
import 'package:chataloka/screens/home/chat_list_screen.dart';
import 'package:chataloka/screens/home/groups_screen.dart';
import 'package:chataloka/screens/home/friends_screen.dart';
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
    FriendsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final int? arguments = ModalRoute.of(context)?.settings.arguments as int?;
      if (arguments != null) {
        setState(() {
          currentIndex = arguments;
          homeController.jumpToPage(arguments);
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = context.read<UserProvider>();
    if (userProvider.userModel == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(RouteConstant.loginScreen, (route) => false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chataloka'),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamed(RouteConstant.friendRequestsScreen);
                  },
                  icon: Icon(Icons.notification_add),
                ),
                UserImageButton(
                  imageUrl: userProvider.userModel?.image,
                  side: 40,
                  onTap: () {
                    if (userProvider.userModel != null) {
                      Navigator.of(context).pushNamed(
                        RouteConstant.profileScreen,
                        arguments: userProvider.userModel!.uid,
                      );
                    }
                  },
                ),
              ],
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
            label: 'Friends',
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
