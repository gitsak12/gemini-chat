import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geminilink/pages/chat/controller/chat_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../hive/boxes.dart';
import '../../hive/chat_history.dart';
import '../home/controller/home_controller.dart';

class ChatHistory1 extends ConsumerWidget {
  final PageController controller;

  const ChatHistory1({super.key, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      maintainBottomViewPadding: false,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          forceMaterialTransparency: true,
          //bottomOpacity: 1,

          //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text(
            'Chat History',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        body: ValueListenableBuilder<Box<ChatHistory>>(
          valueListenable: Boxes.getChatHistory().listenable(),
          builder:
              (BuildContext context, Box<ChatHistory> value, Widget? child) {
            final chatHistory = value.values.toList().cast<ChatHistory>();
            return chatHistory.isEmpty
                ? Center(
                    child: Text('No Chats, Do some some chat with gemini'),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(
                        left: size.width * 0.0001, right: size.width * 0.0001),
                    itemCount: chatHistory.length,
                    itemBuilder: (context, i) {
                      final chat = chatHistory[i];
                      return Card(
                        //color: Colors.red,
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.chat),
                            radius: 22,
                          ),
                          title: Text(
                            chat.prompt,
                            maxLines: 1,
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          subtitle: Text(
                            chat.response,
                            maxLines: 2,
                          ),
                          onTap: () async {
                            //navigate to chat Screen
                            await ref
                                .read(chatMessageControllerProvider.notifier)
                                .prepareChatRoom(
                                    isNewChat: false, chatId: chat.chatId);
                            ref
                                .read(homeControllerProvider.notifier)
                                .changeIndex(1);
                            controller.animateToPage(1,
                                duration: Duration(milliseconds: 1000),
                                curve: Curves.fastLinearToSlowEaseIn);
                          },
                          onLongPress: () {
                            //show dialog to delete
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Text(
                                        'Do you really want to delete the chat?'),
                                    title: Text(
                                      'Delete',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Cancel')),
                                      TextButton(
                                          onPressed: () async {
                                            await ref
                                                .read(
                                                    chatMessageControllerProvider
                                                        .notifier)
                                                .deleteChatMessages(
                                                    chatId: chat.chatId);
                                            chat.delete();
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Delete')),
                                    ],
                                  );
                                });
                          },
                        ),
                      );
                    });
          },
        ),
      ),
    );
  }
}
