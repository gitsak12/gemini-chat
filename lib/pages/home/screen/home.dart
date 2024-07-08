import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geminilink/pages/chat_history/chat_history.dart';
import 'package:geminilink/pages/home/controller/home_controller.dart';
import 'package:geminilink/pages/home/screen/widgets/home_widgets.dart';
import 'package:geminilink/pages/profile/view/profile.dart';

import '../../chat/view/chat.dart';

class Home extends ConsumerStatefulWidget {
  Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    PageController controller =
        PageController(initialPage: ref.watch(homeControllerProvider));
    //list of screens
    final List<Widget> screens = [
      ChatHistory1(
        controller: controller,
      ),
      Chat(),
      Profile(),
    ];
    int pageIndex = ref.watch(homeControllerProvider);
    return Scaffold(
      body: PageView(
        controller: controller,
        //physics: ScrollPhysics(parent: ScrollPhysics()),
        children: screens,

        onPageChanged: (index) => {
          ref.read(homeControllerProvider.notifier).changeIndex(index),
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: itemsList,
        enableFeedback: true,
        type: BottomNavigationBarType.shifting,
        unselectedItemColor: Colors.grey.shade400,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        currentIndex: ref.watch(homeControllerProvider),
        onTap: (i) async {
          ref.read(homeControllerProvider.notifier).changeIndex(i);
          await controller.animateToPage(i,
              duration: Duration(milliseconds: 1000),
              curve: Curves.fastLinearToSlowEaseIn);
        },
      ),
    );
  }
}
