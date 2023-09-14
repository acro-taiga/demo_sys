import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_control_web/models/item.dart';
import 'package:delivery_control_web/models/loginUser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _items;

  // Stream get allBases => _firestore.collection("admins").snapshots();

  Future<void> getallItems(WidgetRef ref) async {
    List<AmazonItem> items =
        await _firestore.collection('items').get().then((value) => value.docs
            .map(
              (doc) => AmazonItem(
                itemId: doc.id,
                userName: doc["userName"],
                uid: doc["uid"],
                amazonItemName: doc["amazonItemName"],
                asin: doc["asin"],
                itemList: List.from(doc["itemList"])
                    .map((item) => Item(
                          actualShippingNum: item["actualShippingNum"],
                          itemName: item["name"],
                          janCode: item["janCode"],
                          setNum: item["setNum"],
                          shippingNum: item["shippingNum"],
                          sumNum: item["sumNum"],
                          arriveNum: item["arriveNum"],
                          place: item["place"],
                          expiryDate: item["expiryDate"] == null
                              ? null
                              : item["expiryDate"].toDate(),
                          // ,
                        ))
                    .toList(),
                arriveDate: doc["arriveDate"] == null
                    ? null
                    : doc["arriveDate"].toDate(),
                createdAt: doc["createdAt"].toDate(),
                shippingNum: doc["shippingNum"],
                actualShippingNum: doc["actualShippingNum"],
                base: doc["base"],
                status: doc["status"],
                sku: doc["sku"],
                fnskuCode: doc["fnskuCode"],
                arriveNum: doc["arriveNum"],
                sumNum: doc["sumNum"],
                setNum: doc["setNum"],
                expiryDate: doc["expiryDate"] == null
                    ? null
                    : doc["expiryDate"].toDate(),
                notes: List.from(doc["notes"]),
                arrivedDate: doc["arrivedDate"] == null
                    ? null
                    : doc["arrivedDate"].toDate(),
                shippeddate: doc["shippeddate"] == null
                    ? null
                    : doc["shippeddate"].toDate(),
                stickerNum: doc["stickerNum"],
                destructionNum: doc["destructionNum"],
                returnNum: doc["returnNum"],
                largeFlg: doc["largeFlg"],
                editJanFlg: doc["editJanFlg"],
                addAdminFlg: doc["addAdminFlg"],
                isSelected: false,
              ),
            )
            .toList());

    if (!ref.watch(loginUserProvider).superAdimnFig) {
      List<AmazonItem> tmp = [];
      if (ref.watch(loginUserProvider).adimnFig) {
        for (String tmpBase in ref.watch(loginUserProvider).base) {
          items.where((amazonItem) => amazonItem.base == tmpBase).forEach(
            (element) {
              tmp.add(element);
            },
          );
        }
      } else {
        items
            .where((amazonItem) =>
                amazonItem.uid == ref.watch(loginUserProvider).uid)
            .forEach(
          (element) {
            tmp.add(element);
          },
        );
      }

      items = tmp;
    }

    for (var item in items) {
      ref.watch(itemListProvider.notifier).addItem(item);
    }
  }

  Future<bool> addNewItem(AmazonItem item) async {
    _items = _firestore.collection('items');
    List<Map<String, dynamic>> itemList = item.itemList.map((item) {
      return {
        'name': item.itemName,
        'janCode': item.janCode,
        'setNum': item.setNum,
        'shippingNum': item.shippingNum,
        'actualShippingNum': item.actualShippingNum,
        'sumNum': item.sumNum,
        'place': item.place,
        'expiryDate': item.expiryDate == null
            ? null
            : Timestamp.fromDate(item.expiryDate!),
        'arriveNum': item.arriveNum,
      };
    }).toList();

    try {
      await _items!.add({
        'userName': item.userName,
        'uid': item.uid,
        'amazonItemName': item.amazonItemName,
        'asin': item.asin,
        'itemList': itemList,
        'arriveNum': item.arriveNum,
        'arriveDate': item.arriveDate == null
            ? null
            : Timestamp.fromDate(item.arriveDate!),
        'createdAt': Timestamp.fromDate(item.createdAt),
        'base': item.base,
        'status': item.status,
        'sku': item.sku,
        'fnskuCode': item.fnskuCode,
        'shippingNum': item.shippingNum,
        'actualShippingNum': item.actualShippingNum,
        'sumNum': item.sumNum,
        'notes': item.notes,
        'setNum': item.setNum,
        'expiryDate': item.expiryDate == null
            ? null
            : Timestamp.fromDate(item.expiryDate!),
        'arrivedDate': item.arrivedDate == null
            ? null
            : Timestamp.fromDate(item.arrivedDate!),
        'shippeddate': null,
        'stickerNum': item.stickerNum,
        'destructionNum': item.destructionNum,
        'returnNum': item.returnNum,
        'largeFlg': item.largeFlg,
        'editJanFlg': item.editJanFlg,
        'addAdminFlg': item.addAdminFlg,
      });
      return true;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<bool> removeItem(AmazonItem item) async {
    print(item.itemId);
    try {
      await _firestore.collection('items').doc(item.itemId).delete();
      return true;
    } catch (e) {
      print(e.toString());
      return Future.error(e);
    }
  }

  Future<bool> editItem(AmazonItem item) async {
    List<Map<String, dynamic>> itemList = item.itemList.map((item) {
      return {
        'name': item.itemName,
        'janCode': item.janCode,
        'setNum': item.setNum,
        'shippingNum': item.shippingNum,
        'actualShippingNum': item.actualShippingNum,
        'sumNum': item.sumNum,
        'place': item.place,
        'expiryDate': item.expiryDate == null
            ? null
            : Timestamp.fromDate(item.expiryDate!),
        'arriveNum': item.arriveNum,
      };
    }).toList();
    try {
      await _firestore.collection('items').doc(item.itemId).update(
        {
          'userName': item.userName,
          'uid': item.uid,
          'amazonItemName': item.amazonItemName,
          'asin': item.asin,
          'itemList': itemList,
          'arriveNum': item.arriveNum,
          'arrivedDate': item.arrivedDate == null
              ? null
              : Timestamp.fromDate(item.arrivedDate!),
          'arriveDate': item.arriveDate == null
              ? null
              : Timestamp.fromDate(item.arriveDate!),
          'createdAt': Timestamp.fromDate(item.createdAt),
          'base': item.base,
          'status': item.status,
          'sku': item.sku,
          'fnskuCode': item.fnskuCode,
          'shippingNum': item.shippingNum,
          'actualShippingNum': item.actualShippingNum,
          'sumNum': item.sumNum,
          'notes': item.notes,
          'setNum': item.setNum,
          'expiryDate': item.expiryDate == null
              ? null
              : Timestamp.fromDate(item.expiryDate!),
          'shippeddate': item.shippeddate == null
              ? null
              : Timestamp.fromDate(item.shippeddate!),
          'stickerNum': item.stickerNum,
          'destructionNum': item.destructionNum,
          'returnNum': item.returnNum,
          'largeFlg': item.largeFlg,
          'editJanFlg': item.editJanFlg,
          'addAdminFlg': item.addAdminFlg,
        },
      );

      return true;
    } catch (e) {
      print(e.toString());
      return Future.error(e);
    }
  }
}
