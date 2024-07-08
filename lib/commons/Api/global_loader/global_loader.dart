import 'package:geminilink/pages/chat/view/chat.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'global_loader.g.dart';

@riverpod
class GlobalLoader extends _$GlobalLoader {
  bool build() => true;

  void setLoader(bool val) {
    print(4);
    state = val;

  }
}
