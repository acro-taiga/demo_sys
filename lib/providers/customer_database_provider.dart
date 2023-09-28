import 'package:delivery_control_web/models/customer.dart';
import 'package:delivery_control_web/models/loginUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _customers;
  // Stream get allCustomers => _firestore.collection("users").snapshots();
  Future<void> getallCustomers(ref) async {
    List<Customer> customerList =
        await _firestore.collection('users').get().then((value) => value.docs
            .map(
              (doc) => Customer(
                  uid: doc["uid"],
                  base: List.from(doc["base"]),
                  name: doc["name"],
                  mail: doc["mail"],
                  line_name: doc["line_name"],
                  line_id: doc["line_id"],
                  shop_name: doc["shop_name"],
                  introducer: doc["introducer"],
                  driver_name: doc["driver_name"],
                  category: doc["category"],
                  large_product: doc["large_product"],
                  no_sticker: doc["no_sticker"],
                  commitment: doc["commitment"],
                  deposit: doc["deposit"],
                  flg: doc["flg"],
                  monthly_charge: doc["monthly_charge"],
                  shipping_num: doc["shipping_average_num"],
                  approval: doc["approval"],
                  baseFlg: doc["baseFlg"]),
            )
            .toList());

    if (!ref.watch(loginUserProvider).superAdimnFig) {
      List<Customer> tmp = [];
      if (ref.watch(loginUserProvider).adimnFig) {
        for (String tmpBase in ref.watch(loginUserProvider).base) {
          customerList
              .where((customer) => customer.base.contains(tmpBase))
              .forEach(
            (element) {
              tmp.add(element);
            },
          );
        }
        customerList = tmp;
      } else {
        Customer customer = customerList.firstWhere((tmpCustomer) =>
            tmpCustomer.uid == ref.watch(loginUserProvider).uid);
        ref.read(customerListProvider.notifier).addCustomer(customer);
        return;
      }
    }

    for (Customer customer in customerList) {
      ref.read(customerListProvider.notifier).addCustomer(customer);
    }
  }

  Future<UserCredential> tempRegistration(String mail, String password) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    UserCredential result = await auth.createUserWithEmailAndPassword(
      email: mail,
      password: password,
    );

    return Future.value(result);
  }

  Future<bool> addNewCustomer(Customer customer) async {
    _customers = _firestore.collection('users');

    try {
      await _customers!.add({
        'uid': customer.uid,
        'base': customer.base,
        'name': customer.name,
        'mail': customer.mail,
        'line_name': customer.line_name,
        'line_id': customer.line_id,
        'shop_name': customer.shop_name,
        'introducer': customer.introducer,
        'driver_name': customer.driver_name,
        'category': customer.category,
        'large_product': customer.large_product,
        'no_sticker': customer.no_sticker,
        'commitment': customer.commitment,
        'deposit': customer.deposit,
        'flg': customer.flg,
        'monthly_charge': customer.monthly_charge,
        'shipping_average_num': customer.shipping_num,
        'approval': customer.approval,
        'baseFlg': customer.baseFlg,
      });

      return true;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<bool> removeCustomers(String uid) async {
    _customers = _firestore.collection('users');
    try {
      await _customers!.where("uid", isEqualTo: uid).get().then(
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

  Future<bool> editCustomer(Customer customer) async {
    _customers = _firestore.collection('users');
    try {
      await _customers!
          .where("uid", isEqualTo: customer.uid)
          .get()
          .then((value) {
        for (var element in value.docs) {
          element.reference.update({
            'uid': customer.uid,
            'base': customer.base,
            'name': customer.name,
            'mail': customer.mail,
            'line_name': customer.line_name,
            'line_id': customer.line_id,
            'shop_name': customer.shop_name,
            'introducer': customer.introducer,
            'driver_name': customer.driver_name,
            'category': customer.category,
            'large_product': customer.large_product,
            'no_sticker': customer.no_sticker,
            'commitment': customer.commitment,
            'deposit': customer.deposit,
            'flg': customer.flg,
            'monthly_charge': customer.monthly_charge,
            'shipping_average_num': customer.shipping_num,
            'approval': customer.approval,
            'baseFlg': customer.baseFlg,
          });
        }
      });
      return true;
    } catch (e) {
      return Future.error(e);
    }
  }
}

final customerDatabaseProvider = Provider((ref) => CustomerDatabase());
// 現在のユーザーの種類(利用者ならuser,管理者ならadmin)

