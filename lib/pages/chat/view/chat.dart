import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geminilink/pages/chat/controller/chat_controller.dart';
import 'package:geminilink/pages/chat/view/widgets/chat_widgets.dart';

import '../../../commons/Api/models/message.dart';

class Chat extends ConsumerStatefulWidget {
  const Chat({super.key});

  @override
  ConsumerState<Chat> createState() => _ChatState();
}

class _ChatState extends ConsumerState<Chat> {
  late TextEditingController controller;
  late FocusNode textFieldFocus;
  late ScrollController _scrollController;

  @override
  void initState() {
    controller = TextEditingController();
    textFieldFocus = FocusNode();
    _scrollController = ScrollController();
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    controller.dispose();
    textFieldFocus.dispose();
    _scrollController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  void scrollBottom() {
    print('scrolling function');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0.0) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List chats = ref.watch(chatMessageControllerProvider);
    print('building');
    Size size = MediaQuery.of(context).size;
    if (chats.isNotEmpty) scrollBottom();

    return SafeArea(
      top: true,
      child: Scaffold(
        //extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          forceMaterialTransparency: true,
          //bottomOpacity: 1,
          actions: [
            if (ref.watch(chatMessageControllerProvider).isNotEmpty)
              CircleAvatar(
                child: IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(
                                'Are you sure you want to start a new chat?'),
                            title: Text(
                              'Start New Chat',
                              style: TextStyle(fontWeight: FontWeight.bold),
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
                                      .read(chatMessageControllerProvider
                                          .notifier)
                                      .prepareChatRoom(
                                          isNewChat: true, chatId: '');
                                  Navigator.of(context).pop();
                                },
                                child: Text('Yes'),
                              ),
                            ],
                          );
                        });
                  },
                  icon: Icon(Icons.delete),
                ),
              ),
          ],

          //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text(
            'Chat with Gemini',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.02),
          height: size.height * 0.86,
          //color: Colors.blue,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  child: chats.isEmpty
                      ? Center(
                          child: Text(
                            'No Messages yet.. Start your conversation',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.only(top: size.height * 0.01),
                          // height: size.height,
                          // width: size.width,
                          // color: Colors.red,
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount:
                                ref.watch(chatMessageControllerProvider).length,
                            itemBuilder: (context, i) {
                              //compare date on basis of timesent
                              final message =
                                  ref.watch(chatMessageControllerProvider)[i];

                              return message.role == Role.user
                                  ? MyMessage(message: message)
                                  : AssistantMessage(
                                      message: ref
                                          .watch(
                                              chatMessageControllerProvider)[i]
                                          .message
                                          .toString(),
                                      index: i,
                                    );
                            },
                          ),
                        ),
                ),
              ),
              PromptField(
                controller: controller,
                textFieldFocus: textFieldFocus,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
