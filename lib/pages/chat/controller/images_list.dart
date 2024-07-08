import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'images_list.g.dart';

@Riverpod(keepAlive: true)
class ImagesList extends _$ImagesList {
  List<XFile> build() => [];

  void pickedImagesSelect(List<XFile> images) {
    state = [...images];
  }

  List<String> getImageList({required bool isTextOnly}) {
    print(7);
    print('list of image Length');
    List<String> images = [];
    if (state != null && !isTextOnly) {
      for (var image in state) {
        images.add(image.path);
      }
    }
    return images;
  }
}
