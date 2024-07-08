import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geminilink/commons/Api/api_service.dart';
import 'package:geminilink/commons/Api/global_loader/global_loader.dart';
import 'package:geminilink/commons/Api/hive_constants/constants.dart';
import 'package:geminilink/commons/Api/models/message.dart';
import 'package:geminilink/hive/boxes.dart';
import 'package:geminilink/hive/chat_history.dart';
import 'package:geminilink/pages/chat/controller/images_list.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

part 'chat_controller.g.dart';

@Riverpod(keepAlive: true)
class ChatMessageController extends _$ChatMessageController {
  List<Message> build() {
    return [];
  }

  //set in chat messages
  Future<void> setChatMessages({required String chatId}) async {
    //get messages from hive db
    final messages = await loadChatMessagesFromDb(chatId: chatId);
    for (var message in messages) {
      if (state.contains(message)) {
        print('containes');
        continue;
      }
      state.add(message);
    }
  }

  void addMessage(Message userMessage) {
    print(8);
    state = [...state, userMessage];
    ref.notifyListeners();
    print('state length is ${state.length}');
  }

  //load messages from hive db
  Future<List<Message>> loadChatMessagesFromDb({required String chatId}) async {
    //open box
    await Hive.openBox('${Constants.chatMessagesBox}$chatId');
    final messageBox = Hive.box(('${Constants.chatMessagesBox}$chatId'));

    final newMessages = messageBox.keys.map((e) {
      final message = messageBox.get(e);
      final messageData = Message.fromJson(Map<String, dynamic>.from(message));
      return messageData;
    }).toList();

    return newMessages;
  }

  Future<List<Content>> getHistory({required String chatId}) async {
    print(6);
    List<Content> history = [];
    if (chatId.isNotEmpty) {
      await setChatMessages(chatId: chatId);
      for (var message in state) {
        if (message.role == Role.user) {
          history.add(Content.text(message.message.toString()));
        } else {
          history.add(Content.model([TextPart(message.message.toString())]));
        }
      }
    }
    return history;
  }

  Future<void> prepareChatRoom(
      {required bool isNewChat, required String chatId}) async {
    if (!isNewChat) {
      print('old chat');
      List<Message> chatHistory = await loadChatMessagesFromDb(chatId: chatId);

      //clear the ongoing chat messages
      state = [];
      print(state.length);
      //now add chathistory messages
      for (var message in chatHistory) {
        state = [...state, message];
        //ref.notifyListeners();
      }
      print(state.length);

      //set current chat id
      ref.read(chatIdProvider.notifier).setChatId(chatId);
    } else {
      state = [];
      ref.read(chatIdProvider.notifier).setChatId(chatId);
    }
  }

  Future<void> deleteChatMessages({
    required String chatId,
  }) async {
    //check if the box is open
    if (!Hive.isBoxOpen('${Constants.chatMessagesBox}$chatId')) {
      await Hive.openBox('${Constants.chatMessagesBox}$chatId');

      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();

      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    } else {
      await Hive.box('${Constants.chatMessagesBox}$chatId').clear();

      await Hive.box('${Constants.chatMessagesBox}$chatId').close();
    }

    //means you are on the chat screen
    final currentChatId = ref.watch(chatIdProvider);
    if (currentChatId.isNotEmpty && currentChatId == chatId) {
      ref.read(chatIdProvider.notifier).setChatId('');
      state = [];
    }
  }

//send response to gemini and get the streamed response
}

@Riverpod(keepAlive: true)
class GeminiModel extends _$GeminiModel {
  GenerativeModel build() {
    return GenerativeModel(model: 'gemini-pro', apiKey: getApiKey());
  }

  Future<void> setModel({required bool isTextOnly}) async {
    print(3);
    if (isTextOnly) {
      state = GenerativeModel(
        model: 'gemini-pro',
        apiKey: getApiKey(),
        generationConfig: GenerationConfig(
          temperature: 0.4,
          topK: 32,
          topP: 1,
          maxOutputTokens: 4096,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        ],
      );
    } else {
      state = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: getApiKey(),
        generationConfig: GenerationConfig(
          temperature: 0.4,
          topK: 32,
          topP: 1,
          maxOutputTokens: 4096,
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        ],
      );
    }
  }

  String getApiKey() {
    return dotenv.env['GEMINI_API_KEY']!;
  }

  Future<void> sendMessage(
      {required String message, required bool isTextOnly}) async {
    print(2);
    await setModel(isTextOnly: isTextOnly);
    ref.read(globalLoaderProvider.notifier).setLoader(true);
    String chatId = ref.watch(chatIdProvider.notifier).getChatId();

    //list of history messages
    List<Content> history = [];
    history = await ref
        .read(chatMessageControllerProvider.notifier)
        .getHistory(chatId: chatId);

    List<String> images = [];
    images = ref
        .read(imagesListProvider.notifier)
        .getImageList(isTextOnly: isTextOnly);

    final messageBox =
        await Hive.openBox('${Constants.chatMessagesBox}$chatId');
    final userMessageId = messageBox.keys.length;
    final assistantMessageId = messageBox.keys.length + 1;
    final userMessage = Message(
      messageId: userMessageId.toString(),
      chatId: chatId,
      role: Role.user,
      message: StringBuffer(message),
      imagesUrls: images,
      timeSent: DateTime.now(),
    );

    ref.read(chatMessageControllerProvider.notifier).addMessage(userMessage);

    final currentId = ref.watch(chatIdProvider);
    if (currentId.isEmpty) {
      ref.read(chatIdProvider.notifier).setChatId(chatId);
    }
    await sendMessageAndWaitForResponse(
      message: message,
      chatId: chatId,
      isTextOnly: isTextOnly,
      history: history,
      userMessage: userMessage,
      modelMessageId: assistantMessageId.toString(),
      messageBox: messageBox,
    );
  }

  Future<void> sendMessageAndWaitForResponse({
    required String message,
    required String chatId,
    required bool isTextOnly,
    required List<Content> history,
    required Message userMessage,
    required String modelMessageId,
    required Box messageBox,
  }) async {
    print(12);
    //start the chat session : only send history if it is textonly
    final chatSession = state.startChat(
        history: history.isEmpty || !isTextOnly ? null : history);

    //get content
    final content = await getContent(
      message: message,
      isTextOnly: isTextOnly,
    );

    ref.read(messageLoaderProvider.notifier).changebool(true);
    //assistant message
    final assistantMessage = userMessage.copyWith(
      messageId: modelMessageId,
      role: Role.assistant,
      message: StringBuffer(''),
      timeSent: DateTime.now(),
    );

    ref
        .read(chatMessageControllerProvider.notifier)
        .addMessage(assistantMessage);
    await chatSession.sendMessageStream(content).asyncMap((event) {
      return event;
    }).listen((event) {
      ref
          .read(chatMessageControllerProvider)
          .firstWhere((e) =>
              e.messageId == assistantMessage.messageId &&
              e.role.name == Role.assistant.name)
          .message
          .write(event.text);
      ref.read(messageLoaderProvider.notifier).changebool(false);
    }, onDone: () async {
      ref.notifyListeners();
      print(24);
      ref.read(globalLoaderProvider.notifier).setLoader(false);
      //save mssg to hive db
      await saveMessagesToDb(
          chatId: chatId,
          userMessage: userMessage,
          assistantMessage: assistantMessage,
          messageBox: messageBox);
    }, onError: (error, stackTrace) {
      print(11);
      print(stackTrace);
      print(error);
      ref
          .read(chatMessageControllerProvider)
          .firstWhere((e) =>
              e.messageId == assistantMessage.messageId &&
              e.role.name == Role.assistant.name)
          .message
          .write(error);
      ref.read(globalLoaderProvider.notifier).setLoader(false);
    });
    print(10);
  }

  Future<void> saveMessagesToDb(
      {required String chatId,
      required Message userMessage,
      required Message assistantMessage,
      required Box messageBox}) async {
    //open the messages box
    print('saving chat id $chatId');
    //save the user message
    await messageBox.add(userMessage.toJson());
    //save the asssitant message
    await messageBox.add(assistantMessage.toJson());

    //save chat history with same chatId
    //if its there then update it
    //otherwise create one
    final chatHistoryBox = Boxes.getChatHistory();

    final chatHistoryMessage = ChatHistory(
      chatId: chatId,
      prompt: userMessage.message.toString(),
      response: assistantMessage.message.toString(),
      images: userMessage.imagesUrls,
      timestamp: DateTime.now(),
    );
    await chatHistoryBox.put(chatId, chatHistoryMessage);

    await messageBox.close();
  }

  Future<Content> getContent(
      {required String message, required bool isTextOnly}) async {
    if (isTextOnly) {
      return Content.text(message);
    } else {
      final images = ref.read(imagesListProvider);
      final imagesFuture =
          images.map((imageFile) => imageFile.readAsBytes()).toList();

      final imageBytes = await Future.wait(imagesFuture);
      final prompt = TextPart(message);
      final imageParts = imageBytes
          .map((bytes) => DataPart('image/jpg', Uint8List.fromList(bytes)))
          .toList();

      return Content.multi([prompt, ...imageParts]);
    }
  }
}

@Riverpod(keepAlive: true)
class ChatId extends _$ChatId {
  String build() => '';

  void setChatId(String id) {
    print(9);
    state = id;
  }

  String getChatId() {
    print(5);
    if (state.isEmpty) {
      return Uuid().v4();
    } else {
      return state;
    }
  }
}

@Riverpod(keepAlive: true)
class MessageLoader extends _$MessageLoader {
  bool build() => true;

  void changebool(bool val) {
    state = val;
  }
}
