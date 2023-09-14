import 'package:delivery_control_web/models/admin.dart';
import 'package:delivery_control_web/models/loginUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _admins;

  // Stream get allAdmins => _firestore.collection("admins").snapshots();

  Future<void> getallAdmins(ref) async {
    List<Admin> adminList =
        await _firestore.collection('admins').get().then((value) => value.docs
            .map(
              (doc) => Admin(
                uid: doc["uid"],
                name: doc["name"],
                mail: doc["mail"],
                base: List.from(doc["base"]),
                superAdmin: doc["super_flg"],
              ),
            )
            .toList());
    if (!ref.watch(loginUserProvider).superAdimnFig) {
      List<Admin> tmp = [];
      for (String tmpBase in ref.watch(loginUserProvider).base) {
        adminList.where((admin) => admin.base.contains(tmpBase)).forEach(
          (element) {
            tmp.add(element);
          },
        );
      }
      adminList = tmp;
    }
    for (Admin admin in adminList) {
      ref.read(adminListProvider.notifier).addAdmin(admin);
    }
  }

  Future<bool> addNewAdmin(Admin admin, password) async {
    _admins = _firestore.collection('admins');
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;

      UserCredential result = await auth.createUserWithEmailAndPassword(
        email: admin.mail,
        password: password,
      );
      await _admins!.add({
        'uid': result.user!.uid,
        'name': admin.name,
        'mail': admin.mail,
        'base': admin.base,
        'super_flg': admin.superAdmin,
      });
      return true;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<bool> removeAdmin(String uid) async {
    _admins = _firestore.collection('admins');
    try {
      await _admins!.where("uid", isEqualTo: uid).get().then(
        (value) {
          for (var element in value.docs) {
            element.reference.delete();
          }
        },
      );
      return true;
    } catch (e) {
      print(e.toString());
      return Future.error(e);
    }
  }

  Future<bool> editAdmin(Admin admin) async {
    _admins = _firestore.collection('admins');
    try {
      await _admins!.where("uid", isEqualTo: admin.uid).get().then((value) {
        for (var element in value.docs) {
          element.reference.update({
            'uid': admin.uid,
            'name': admin.name,
            'mail': admin.mail,
            'base': admin.base,
            'super_flg': admin.superAdmin,
          });
        }
      });
      return true;
    } catch (e) {
      print(e.toString());
      return Future.error(e);
    }
  }
}

final adminDatabaseProvider = Provider((ref) => AdminDatabase());
