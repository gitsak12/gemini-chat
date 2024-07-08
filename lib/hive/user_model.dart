import 'package:hive_flutter/hive_flutter.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel1 extends HiveObject {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String name;
  @HiveField(2)
  final String image;

  //contructor
  UserModel1({
    required this.uid,
    required this.name,
    required this.image,
  });
}
