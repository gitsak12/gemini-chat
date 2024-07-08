import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  int build() {
    return 1;
  }

  void changeIndex(int index) {
    state = index;
  }
}
@riverpod
class Page extends _$Page
{
  PageController build()
  {
    return PageController(initialPage: ref.watch(homeControllerProvider));
  }

}
