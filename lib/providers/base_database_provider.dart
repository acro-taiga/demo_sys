import 'package:delivery_control_web/models/base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_control_web/models/loginUser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaseDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _bases;

  // Stream get allBases => _firestore.collection("admins").snapshots();

  Future<void> getallBases(WidgetRef ref) async {
    List<Base> baseList =
        await _firestore.collection('bases').get().then((value) => value.docs
            .map((doc) => Base(
                  name: doc["name"],
                  mail: doc["mail"],
                  postNum: doc["postNum"],
                  phoneNum: doc["phoneNum"],
                  post: doc["post"],
                  select: false,
                ))
            .toList());

    List<Base> tmpBase = baseList
        .where((element) =>
            ref.watch(loginUserProvider).base.contains(element.name))
        .toList();
    baseList = tmpBase;

    for (var base in baseList) {
      ref.read(baseListProvider.notifier).addBase(base);
    }
  }

  Future<bool> addNewBase(Base base) async {
    _bases = _firestore.collection('bases');
    try {
      await _bases!.add({
        'name': base.name,
        'mail': base.mail,
        'postNum': base.postNum,
        'phoneNum': base.phoneNum,
        'post': base.post,
      });
      return true;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<bool> removeBase(Base base) async {
    _bases = _firestore.collection('bases');
    try {
      await _bases!.where("name", isEqualTo: base.name).get().then(
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

  Future<bool> editAdmin(Base base) async {
    _bases = _firestore.collection('bases');
    try {
      await _bases!.where("name", isEqualTo: base.name).get().then((value) {
        for (var element in value.docs) {
          element.reference.update({
            'name': base.name,
            'mail': base.mail,
            'postNum': base.postNum,
            'phoneNum': base.phoneNum,
            'post': base.post,
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
