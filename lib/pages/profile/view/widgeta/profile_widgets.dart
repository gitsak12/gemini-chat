import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../controller/profile_controller.dart';

class ProfileImage extends ConsumerStatefulWidget {
  const ProfileImage({super.key});

  @override
  ConsumerState<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends ConsumerState<ProfileImage> {
  final ImagePicker picker = ImagePicker();

  void pickImage() async {
    final pickedImage = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 800, maxWidth: 800);

    if (pickedImage != null) {
      ref
          .read(profileControllerProvider.notifier)
          .changeProfilePhoto(pickedImage.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        CircleAvatar(
          backgroundImage:
              AssetImage(ref.watch(profileControllerProvider).path),
          //radius: size.width * 0.14,
          minRadius: 60,
          maxRadius: 70,
        ),
        Positioned(
            top: size.height * 0.124,
            left: size.width * 0.25,
            child: Container(
              width: size.width * 0.1,
              height: size.height * 0.045,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                style: ButtonStyle(
                    // backgroundColor:
                    //     WidgetStateProperty.all(Colors.red),
                    ),
                icon: Icon(
                  Icons.edit,
                  color: Colors.white54,
                ),
                onPressed: pickImage,
              ),
            ))
      ],
    );
  }
}

class SettingsListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsListTile(
      {super.key,
      required this.icon,
      required this.title,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            )),
        title: Text(title),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
