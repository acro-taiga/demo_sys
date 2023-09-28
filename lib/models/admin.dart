import 'package:flutter_riverpod/flutter_riverpod.dart';

class Admin {
  String uid, name, mail;
  bool superAdmin;
  List<String>  base;

  Admin({
    required this.uid,
    required this.name,
    required this.mail,
    required this.base,
    required this.superAdmin,
  });
}

class AdminList extends StateNotifier<List<Admin>> {
  AdminList() : super([]);

  void addAdmin(Admin admin) {
    state = [...state, admin];
  }

  void clearList() {
    state = [];
  }

  
}

final adminListProvider = StateNotifierProvider<AdminList, List<Admin>>((ref) {
  return AdminList();
});
