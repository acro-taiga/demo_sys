import 'package:flutter_riverpod/flutter_riverpod.dart';

class AmazonItem {
  String itemId;
  String uid;
  String userName;
  String amazonItemName;
  String asin;
  List<Item> itemList;
  DateTime? arriveDate;
  DateTime createdAt;
  int shippingNum;
  int actualShippingNum;
  String base;
  String status;
  String sku;
  String fnskuCode;
  int arriveNum;
  int? sumNum;
  List<String> notes;
  int setNum;
  DateTime? expiryDate;
  DateTime? arrivedDate;
  bool isSelected;
  DateTime? shippeddate;
  int stickerNum;
  int destructionNum;
  int returnNum;
  bool largeFlg;
  bool editJanFlg;
  bool addAdminFlg;


  

  AmazonItem(
      {required this.itemId,
      required this.userName,
      required this.uid,
      required this.amazonItemName,
      required this.asin,
      required this.itemList,
      required this.arriveDate,
      required this.createdAt,
      required this.shippingNum,
      required this.actualShippingNum,
      required this.base,
      required this.status,
      required this.sku,
      required this.fnskuCode,
      required this.arriveNum,
      required this.sumNum,
      required this.notes,
      required this.setNum,
      required this.expiryDate,
      required this.isSelected,
      required this.arrivedDate,
      required this.shippeddate,
      required this.stickerNum,
      required this.destructionNum,
      required this.returnNum,
      required this.largeFlg,
      required this.editJanFlg,
      required this.addAdminFlg,
      });
}

class Item {
  String itemName;
  int janCode;
  int setNum;
  int shippingNum;
  int actualShippingNum;
  int? sumNum;
  int arriveNum;
  String place;
  DateTime? expiryDate;

  Item({
    required this.itemName,
    required this.janCode,
    required this.setNum,
    required this.shippingNum,
    required this.actualShippingNum,
    required this.sumNum,
    required this.arriveNum,
    required this.place,
    required this.expiryDate,
  });
}

class ItemList extends StateNotifier<List<AmazonItem>> {
  ItemList() : super([]);

  void addItem(AmazonItem item) {
    state = [...state, item];
  }

  void clearList() {
    state = [];
  }
}

final itemListProvider =
    StateNotifierProvider<ItemList, List<AmazonItem>>((ref) {
  return ItemList();
});
