import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geminilink/commons/Api/global_loader/global_loader.dart';
import 'package:geminilink/commons/Api/models/message.dart';
import 'package:geminilink/pages/chat/controller/chat_controller.dart';
import 'package:geminilink/pages/chat/controller/images_list.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class ChatList extends StatelessWidget {
  final List<Message> chats;

  const ChatList({super.key, required this.chats});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    //final provider = ref.read(chatMessageControllerProvider);
    print('chatting');
    return Container(
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
              color: Colors.red,
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, i) {
                  final message = chats[i];
                  return message.role == Role.user
                      ? MyMessage(message: message)
                      : AssistantMessage(message: message.message.toString());
                },
              ),
            ),
    );
  }
}

class PromptField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final FocusNode textFieldFocus;

  const PromptField(
      {super.key, required this.controller, required this.textFieldFocus});

  @override
  ConsumerState<PromptField> createState() => _PromptFieldState();
}

class _PromptFieldState extends ConsumerState<PromptField> {
  final ImagePicker picker = ImagePicker();

  Future<void> sendChatMessage({
    required String message,
    required bool isTextOnly,
  }) async {
    try {
      print(1);
      await ref
          .read(geminiModelProvider.notifier)
          .sendMessage(message: message, isTextOnly: isTextOnly);
    } catch (e) {
      print(1.1);
      print('error: $e');
    } finally {
      print(1.2);
      widget.controller.clear();
      ref.read(imagesListProvider.notifier).pickedImagesSelect([]);
      widget.textFieldFocus.unfocus();
    }
  }

  void pickImage() async {
    final pickedImages = await picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 95,
    );
    ref.read(imagesListProvider.notifier).pickedImagesSelect(pickedImages);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool hasImages = ref.watch(imagesListProvider) != null &&
        ref.watch(imagesListProvider).isNotEmpty;
    return Container(
      margin: EdgeInsets.symmetric(vertical: size.height * 0.004),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border:
            Border.all(color: Theme.of(context).textTheme.titleLarge!.color!),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          if (hasImages) PreviewImageWidget(),
          Row(
            children: [
              IconButton(
                icon: Icon(hasImages ? Icons.delete_forever : Icons.image),
                onPressed: () {
                  if (hasImages) {

                  } else {
                    pickImage();
                  }
                },
              ),
              Expanded(
                child: TextField(
                  focusNode: widget.textFieldFocus,
                  controller: widget.controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (val) {
                    if (val.isNotEmpty) {
                      sendChatMessage(
                          message: widget.controller.text,
                          isTextOnly: hasImages ? false : true);
                    }
                  },
                  decoration: InputDecoration.collapsed(
                    hintText: 'Enter Your Prompt..',
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  //send prompt to model
                  if (widget.controller.text.isNotEmpty) {
                    sendChatMessage(
                        message: widget.controller.text,
                        isTextOnly: hasImages ? false : true);
                  }
                },
                child: Container(
                  margin: EdgeInsets.all(size.width * 0.005),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: IconButton(
                    iconSize: 25,
                    //color: Colors.white,
                    disabledColor: Colors.white,
                    icon: Icon(
                      Icons.arrow_upward_outlined,
                      color: Colors.white,
                    ),
                    onPressed: null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MyMessage extends StatefulWidget {
  final Message message;

  const MyMessage({super.key, required this.message});

  @override
  State<MyMessage> createState() => _MyMessageState();
}

class _MyMessageState extends State<MyMessage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.message.imagesUrls.isNotEmpty)
              PreviewImageWidget(
                message: widget.message,
              ),
            MarkdownBody(
              data: widget.message.message.toString(),
              selectable: true,
            ),
          ],
        ),
      ),
    );
  }
}

class AssistantMessage extends ConsumerWidget {
  final String message;
  final int index;

  const AssistantMessage({super.key, required this.message, this.index = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(chatMessageControllerProvider)[index];
    final size = MediaQuery.of(context).size;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.only(bottom: 8),
        child:
            ref.watch(chatMessageControllerProvider)[index].message.isEmpty &&
                    ref.watch(globalLoaderProvider)
                ? SizedBox(
                    width: size.width * 0.1,
                    child: SpinKitThreeBounce(
                      color: Colors.blueGrey,
                      size: 20.0,
                    ),
                  )
                : MarkdownBody(
                    data: message.message.toString(),
                    selectable: true,
                  ),
      ),
    );
  }
}

class PreviewImageWidget extends ConsumerWidget {
  final Message? message;

  const PreviewImageWidget({super.key, this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messageToShow =
        message != null ? message?.imagesUrls : ref.watch(imagesListProvider);
    return Padding(
      padding: message != null
          ? EdgeInsets.all(0)
          : EdgeInsets.only(left: 8, right: 8),
      child: SizedBox(
        height: 80,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: messageToShow?.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: EdgeInsets.fromLTRB(4, 8, 4, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    File(message != null
                        ? message!.imagesUrls[i]
                        : ref.watch(imagesListProvider)[i].path),
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }),
      ),
    );
  }
}
