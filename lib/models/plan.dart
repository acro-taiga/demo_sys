import 'package:flutter_riverpod/flutter_riverpod.dart';

class Plan {
  String? name, status, mailStatus, uid, planId, shippingWay, note;
  DateTime? shippingDate;
  int? boxNum, boxHeight, boxWidth, boxHorizontal, boxWeight, infoNum;
  List<String> itemIds;
  bool selected;

  Plan({
    required this.name,
    required this.status,
    required this.mailStatus,
    required this.shippingDate,
    required this.boxNum,
    required this.boxHeight,
    required this.boxWidth,
    required this.boxHorizontal,
    required this.boxWeight,
    required this.itemIds,
    required this.uid,
    required this.planId,
    required this.selected,
    required this.note,
    required this.infoNum,
    required this.shippingWay,
  });
}

class PlanList extends StateNotifier<List<Plan>> {
  PlanList() : super([]);

  void addPlan(Plan plan) {
    state = [...state, plan];
  }

  void clearList() {
    state = [];
  }

  void remove(Plan plan) {
    state.remove(plan);
  }
}

final planListProvider = StateNotifierProvider<PlanList, List<Plan>>((ref) {
  return PlanList();
});
