import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geminilink/hive/settings.dart';
import 'package:geminilink/pages/profile/controller/profile_controller.dart';
import 'package:geminilink/pages/profile/view/widgeta/profile_widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../hive/boxes.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({super.key});

  @override
  ConsumerState<Profile> createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  void getUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userBox = Boxes.getUser();

      if (userBox.isNotEmpty) {
        final user = userBox.getAt(0);
        ref
            .read(profileControllerProvider.notifier)
            .changeProfilePhoto(user!.image);
        ref.read(profileNameProvider.notifier).changeProfileName(user.name);
      }
    });
  }

  @override
  void initState() {
    getUserData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            forceMaterialTransparency: true,
            //bottomOpacity: 1,

            //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text(
              'Profile',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
            child: SingleChildScrollView(
              child: Container(
                width: size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfileImage(),
                    SizedBox(
                      height: size.height * 0.02,
                    ),
                    Text(
                      ref.watch(profileNameProvider),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    ValueListenableBuilder<Box<Settings>>(
                        valueListenable: Boxes.getSettings().listenable(),
                        builder: (context, box, child) {
                          if (box.isEmpty) {
                            return Column(
                              children: [
                                SettingsListTile(
                                  icon: Icons.mic,
                                  title: 'Enable AI Voice',
                                  value: false,
                                  onChanged: (value) {
                                    ref
                                        .read(voiceControllerProvider.notifier)
                                        .toggleSpeak(value, null);
                                  },
                                ),
                                SettingsListTile(
                                  icon: ref.watch(themeControllerProvider)
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  title: ref.watch(themeControllerProvider)
                                      ? 'Enable Dark Mode'
                                      : 'Enable Light Mode',
                                  value: false,
                                  onChanged: (value) {
                                    ref
                                        .read(themeControllerProvider.notifier)
                                        .toggleDarkTheme(value, null);
                                  },
                                ),
                              ],
                            );
                          } else {
                            final settings = box.getAt(0);
                            return Column(
                              children: [
                                SettingsListTile(
                                  icon: Icons.mic,
                                  title: 'Enable AI Voice',
                                  value: settings!.shouldSpeak,
                                  onChanged: (value) {
                                    ref
                                        .read(voiceControllerProvider.notifier)
                                        .toggleSpeak(value, settings);
                                  },
                                ),
                                SettingsListTile(
                                  icon: settings.isDarkTheme
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  title: settings.isDarkTheme
                                      ? 'Disable Dark Mode'
                                      : 'Enable Dark Mode',
                                  value: settings.isDarkTheme,
                                  onChanged: (value) {
                                    ref
                                        .read(themeControllerProvider.notifier)
                                        .toggleDarkTheme(value, settings);
                                  },
                                ),
                              ],
                            );
                          }
                        }),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
