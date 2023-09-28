import 'package:delivery_control_web/models/loginUser.dart';
import 'package:delivery_control_web/models/plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _plans;

  // Stream get allAdmins => _firestore.collection("admins").snapshots();

  Future<void> getallPlans(ref) async {
    List<Plan> planList =
        await _firestore.collection('plans').get().then((value) => value.docs
            .map(
              (doc) => Plan(
                name: doc["name"],
                shippingDate: doc["shippingDate"] == null
                    ? null
                    : doc["shippingDate"].toDate(),
                status: doc["status"],
                boxNum: doc["boxNum"],
                boxHeight: doc["boxHeight"],
                boxWidth: doc["boxWidth"],
                boxHorizontal: doc["boxHorizontal"],
                boxWeight: doc["boxWeight"],
                itemIds: List.from(doc["itemIds"]),
                mailStatus: doc["mailStatus"],
                uid: doc["uid"],
                planId: doc.id,
                selected: false,
                shippingWay: doc["shippingWay"],
                infoNum: doc["infoNum"],
                note: doc["note"],
              ),
            )
            .toList());
    if (!ref.watch(loginUserProvider).superAdimnFig) {
      List<Plan> tmp = [];
      planList
          .where((plan) => plan.uid == ref.watch(loginUserProvider).uid)
          .forEach(
        (element) {
          tmp.add(element);
        },
      );

      planList = tmp;
    }
    for (Plan plan in planList) {
      ref.read(planListProvider.notifier).addPlan(plan);
    }
  }

  Future<String> addNewPlan(Plan plan) async {
    _plans = _firestore.collection('plans');
    try {
      DocumentReference data = await _plans!.add({
        "name": plan.name,
        "shippingDate": plan.shippingDate == null
            ? null
            : Timestamp.fromDate(plan.shippingDate!),
        "status": plan.status,
        "boxNum": plan.boxNum,
        "boxHeight": plan.boxHeight,
        "boxWidth": plan.boxWidth,
        "boxHorizontal": plan.boxHorizontal,
        "boxWeight": plan.boxWeight,
        "itemIds": List.from(plan.itemIds),
        "mailStatus": plan.mailStatus,
        "uid": plan.uid,
        "shippingWay": plan.shippingWay,
        "infoNum": plan.infoNum,
        "note": plan.note,
      });
     
      return data.id;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<bool> removePlan(Plan plan) async {
    try {
      await _firestore.collection('plans').doc(plan.planId).delete();
      return true;
    } catch (e) {
      print(e.toString());
      return Future.error(e);
    }
  }

  Future<bool> editPlan(Plan plan) async {
    _plans = _firestore.collection('plans');
    try {
      await _firestore.collection('plans').doc(plan.planId).update({
        "name": plan.name,
        "shippingDate": plan.shippingDate == null
            ? null
            : Timestamp.fromDate(plan.shippingDate!),
        "status": plan.status,
        "boxNum": plan.boxNum,
        "boxHeight": plan.boxHeight,
        "boxWidth": plan.boxWidth,
        "boxHorizontal": plan.boxHorizontal,
        "boxWeight": plan.boxWeight,
        "itemIds": List.from(plan.itemIds),
        "mailStatus": plan.mailStatus,
        "uid": plan.uid,
        "infoNum": plan.infoNum,
        "note": plan.note,
        "shippingWay": plan.shippingWay,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return Future.error(e);
    }
  }
}

final planDatabaseProvider = Provider((ref) => PlanDatabase());
