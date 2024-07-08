import 'dart:io';

import 'package:geminilink/commons/Api/hive_constants/constants.dart';
import 'package:geminilink/hive/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../hive/boxes.dart';

part 'profile_controller.g.dart';

@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  bool build() {
    return false;
  }

  void changeTheme(bool val) {
    state = val;
  }

  void getSavedSettings() {
    final settingsBox = Boxes.getSettings();

    if (settingsBox.isNotEmpty) {
      final settings = settingsBox.getAt(0);

      if (settings != null) {
        state = settings.isDarkTheme;
        ref
            .read(voiceControllerProvider.notifier)
            .isSpeak(settings.shouldSpeak);
      }
    }
  }

  void toggleDarkTheme(bool isDark, Settings? settings) {
    if (settings != null) {
      settings.isDarkTheme = isDark;
      settings.save();
    } else {
      final settingsBox = Boxes.getSettings();
      settingsBox.put(
          0,
          Settings(
              isDarkTheme: isDark,
              shouldSpeak: ref.watch(voiceControllerProvider)));
    }
    state = isDark;
  }
}

@Riverpod(keepAlive: true)
class VoiceController extends _$VoiceController {
  bool build() {
    return false;
  }

  void isSpeak(bool val) {
    state = val;
  }

  void toggleSpeak(bool value, Settings? settings) {
    if (settings != null) {
      settings.shouldSpeak = value;
      settings.save();
    } else {
      final settingsBox = Boxes.getSettings();

      settingsBox.put(
        0,
        Settings(
            isDarkTheme: ref.watch(themeControllerProvider),
            shouldSpeak: value),
      );
    }
    state = value;
  }
}

@Riverpod(keepAlive: true)
class ProfileController extends _$ProfileController {
  File build() {
    return File('assets/images/profile.png');
  }

  void changeProfilePhoto(String path) {
    File newFile = File(path);
    state = newFile;
  }
}

@Riverpod(keepAlive: true)
class ProfileName extends _$ProfileName {
  String build() {
    return 'Kane';
  }

  void changeProfileName(String name) {
    state = name;
  }
}
