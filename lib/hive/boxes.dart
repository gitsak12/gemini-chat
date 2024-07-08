import 'package:geminilink/commons/Api/hive_constants/constants.dart';
import 'package:geminilink/hive/chat_history.dart';
import 'package:geminilink/hive/settings.dart';
import 'package:geminilink/hive/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

class Boxes {
//get the chat history box
  static Box<ChatHistory> getChatHistory() =>
      Hive.box<ChatHistory>(Constants.chatHistoryBox);

//get the user model box
  static Box<UserModel1> getUser() => Hive.box<UserModel1>(Constants.userBox);

  //get the chat box
  static Box<Settings> getSettings() =>
      Hive.box<Settings>(Constants.settingsBox);
}
