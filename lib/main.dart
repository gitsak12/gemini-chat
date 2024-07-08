import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geminilink/commons/Api/themes/my_theme.dart';
import 'package:geminilink/pages/profile/controller/profile_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'global.dart';
import 'pages/home/screen/home.dart';

Future<void> main() async {
  await Global.init();

  runApp(ProviderScope(
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // This widget is the root of your application.

  @override
  void initState() {
    print('ty');
    Future(() {
      ref.read(themeControllerProvider.notifier).getSavedSettings();
    });

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ref.watch(themeControllerProvider) ? darkTheme : lightTheme,
      home: Home(),
    );
  }
}
