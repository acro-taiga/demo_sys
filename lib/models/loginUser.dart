import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginUserModel {
  String uid;
  String name;
  List<String> base;
  bool adimnFig;
  bool superAdimnFig;

  LoginUserModel({
    required this.uid,
    required this.name,
    required this.base,
    required this.adimnFig,
    required this.superAdimnFig,
  });
}

class LoginUserNotifier extends StateNotifier<LoginUserModel> {
  LoginUserNotifier()
      : super(LoginUserModel(
            adimnFig: false,
            base: [],
            name: '',
            superAdimnFig: false,
            uid: ''));

  Future<void> create(LoginUserModel model) async {
    state = model;
  }
}

final loginUserProvider =
    StateNotifierProvider<LoginUserNotifier, LoginUserModel>((ref) {
  return LoginUserNotifier();
});
