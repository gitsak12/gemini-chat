import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geminilink/hive/chat_history.dart';
import 'package:geminilink/hive/settings.dart';
import 'package:geminilink/hive/user_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path;

import 'commons/Api/hive_constants/constants.dart';

class Global {
  static Future init() async {
    print('initilizing');
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env');
    //directory where we are storing all data
    final dir = await path.getApplicationDocumentsDirectory();
    print(dir.path);
    Hive.init(dir.path);
    await Hive.initFlutter(Constants.geminiDB);

    //register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChatHistoryAdapter());
      //open the box
      await Hive.openBox<ChatHistory>(Constants.chatHistoryBox);
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserModel1Adapter());
      //open the box
      await Hive.openBox<UserModel1>(Constants.userBox);
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsAdapter());
      //open the box
      await Hive.openBox<Settings>(Constants.settingsBox);
    }
  }
}
