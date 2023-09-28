import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

class Customer {
  String uid,
      name,
      mail,
      line_name,
      line_id,
      shop_name,
      introducer,
      driver_name,
      category;
  int monthly_charge, shipping_num;
  bool large_product, no_sticker, commitment, deposit, flg,approval,baseFlg;
  List<String> base;

  Customer({
    required this.uid,
    required this.base,
    required this.name,
    required this.mail,
    required this.line_name,
    required this.line_id,
    required this.shop_name,
    required this.introducer,
    required this.driver_name,
    required this.category,
    required this.large_product,
    required this.no_sticker,
    required this.commitment,
    required this.deposit,
    required this.flg,
    required this.monthly_charge,
    required this.shipping_num,
    required this.approval,
     required this.baseFlg,
  });
}

class CustomerList extends StateNotifier<List<Customer>> {
  CustomerList() : super([]);

  void addCustomer(Customer customer) {
    state = [...state, customer];
  }

  void clearList() {
    state = [];
  }

  String getCustomerName(String uid) {
    Customer? target =
        state.firstWhereOrNull((customer) => customer.uid == uid);
    if (target == null) {
      return "";
    } else {
      return target.name;
    }
  }
}

final customerListProvider =
    StateNotifierProvider<CustomerList, List<Customer>>((ref) {
  return CustomerList();
});


