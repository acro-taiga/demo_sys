import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:delivery_control_web/exSize.dart';
import 'package:delivery_control_web/models/base.dart';
import 'package:delivery_control_web/models/item.dart';
import 'package:flutter/material.dart';

import 'package:delivery_control_web/models/customer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid_export/pluto_grid_export.dart' as pluto_grid_export;
import 'package:file_saver/file_saver.dart';

final onSelectProvider = StateProvider<bool>((ref) => false);
// final StateProvider<List<int>> searchIndexListProvider =
// StateProvider((ref) => []);
final userIndexProvider = StateProvider<int>((ref) => 0);
final textcheckProvider = StateProvider<String>((ref) => "");
final approvalCountProvider = StateProvider<int>((ref) => 0);

DateFormat dateFormat = DateFormat('yyyy年MM月');

String isSelectedValue = 'ALL';
// final isSelectedValue = StateProvider<String>((ref) {
//   return "ALL";
// });

class Totalizer extends ConsumerStatefulWidget {
  const Totalizer({super.key});

  @override
  _Totalizer createState() => _Totalizer();
}

class _Totalizer extends ConsumerState<Totalizer> {
  bool isLoading = false;
  List<PlutoRow> rows = [];
  late PlutoGridStateManager stateManager;

  List<String> shippedDate = [];
  int getFlag = 0;
  int costSum = 0;
  Future<bool>? res;

  final List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: 'No',
      field: 'no',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.center,
      enableRowChecked: true,
      enableEditingMode: false,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 120,
    ),
    PlutoColumn(
      title: 'ユーザー',
      field: 'name',
      type: PlutoColumnType.text(),
      titleTextAlign: PlutoColumnTextAlign.center,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 150,
    ),
    PlutoColumn(
      title: 'ユーザー（子）',
      field: 'shop_name',
      type: PlutoColumnType.text(),
      titleTextAlign: PlutoColumnTextAlign.center,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 200,
    ),
    PlutoColumn(
      title: '月額',
      field: 'sales_moamount',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: '送料',
      field: 'sales_postage',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: '一般',
      field: 'sales_general',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: '大型',
      field: 'sales_large',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: '要・危',
      field: 'sales_reqdan',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: 'シール',
      field: 'sales_sticker',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: 'セット',
      field: 'sales_set',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: '商品未入力',
      field: 'sales_nonenter',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: 'SKU手数料',
      field: 'sales_commission',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: 'JAN違い',
      field: 'sales_different',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: '返送',
      field: 'sales_return',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: '破棄',
      field: 'sales_trush',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: '合計（税込）',
      field: 'sales_sum',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 150,
    ),
    PlutoColumn(
      title: '月額',
      field: 'cost_moamount',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: '送料',
      field: 'cost_postage',
      type: PlutoColumnType.text(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: '一般',
      field: 'cost_general',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: '大型',
      field: 'cost_large',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: '要・危',
      field: 'cost_reqdan',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: 'シール',
      field: 'cost_sticker',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: 'セット',
      field: 'cost_set',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: '返送',
      field: 'cost_return',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: '破棄',
      field: 'cost_trush',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: '資材費',
      field: 'cost_material',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: '外注費',
      field: 'cost_outsource',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 100,
    ),
    PlutoColumn(
      title: '合計（税込）',
      field: 'cost_sum',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 150,
    ),
    PlutoColumn(
      title: '利益',
      field: 'benefit',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      textAlign: PlutoColumnTextAlign.end,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 150,
    ),
  ];

  final List<PlutoColumnGroup> columnGroups = [
    PlutoColumnGroup(
      title: '売上',
      fields: [
        'sales_moamount',
        'sales_postage',
        'sales_general',
        'sales_large',
        'sales_reqdan',
        'sales_sticker',
        'sales_set',
        'sales_nonenter',
        'sales_commission',
        'sales_different',
        'sales_return',
        'sales_trush',
        'sales_sum',
      ],
    ),
    PlutoColumnGroup(
      title: '経費',
      fields: [
        'cost_moamount',
        'cost_postage',
        'cost_general',
        'cost_large',
        'cost_reqdan',
        'cost_sticker',
        'cost_set',
        'cost_return',
        'cost_trush',
        'cost_sum',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();

    res = createPluto(ref);
  }

  Future<bool> createPluto(WidgetRef ref) {
    final items = isSelectedValue == 'ALL'
        ? ref
            .read(itemListProvider)
            .where((item) => item.status == "発送完了")
            .toList()
        : ref
            .read(itemListProvider)
            .where((item) =>
                item.status == "発送完了" &&
                item.shippeddate != null &&
                dateFormat.format(item.shippeddate!) == isSelectedValue)
            .toList();
    final users = ref.read(customerListProvider);
    rows = [];

    for (var customerCount = 0; customerCount < users.length; customerCount++) {
      final userItems = items
          .where((item) => item.userName == users[customerCount].name)
          .toList();

      int salesMoamount = 2200;
      int salesPostage = 0;
      // 実出荷単位数をさらに掛ける
      int salesGeneral = userItems
              .where((item) => item.setNum == 1)
              .toList()
              .map((item) => item.actualShippingNum)
              .toList()
              .isNotEmpty
          ? userItems
                  .where((item) => item.setNum == 1)
                  .toList()
                  .map((item) => item.actualShippingNum)
                  .toList()
                  .reduce((a, b) => a + b) *
              40
          : 0;

      int salesLarge =
          userItems.where((element) => element.largeFlg).toList().length * 100;
      int salesReqdan = userItems
              .where((element) => element.expiryDate != null)
              .toList()
              .length *
          10;
      int salesSticker = userItems.map((e) => e.stickerNum).toList().isEmpty
          ? 0
          : userItems
                  .map((e) => e.stickerNum)
                  .toList()
                  .reduce((a, b) => a * b) *
              20;
      int salesSet = userItems.where((item) => item.setNum > 1).toList().isEmpty
          ? 0
          : userItems
                  .where((item) => item.setNum > 1)
                  .toList()
                  .map((e) => e.actualShippingNum)
                  .toList()
                  .reduce((a, b) => a + b) *
              60;

      int salesNonenter =
          userItems.where((item) => item.addAdminFlg).toList().length * 200;
      int salesCommission = userItems.length * 40;
      int salesDifferent =
          userItems.where((item) => item.editJanFlg).toList().length * 30;
      int salesReturn = userItems.isEmpty
          ? 0
          : userItems.map((e) => e.returnNum).reduce((a, b) => a + b) * 200;
      int salesTrush = userItems.isEmpty
          ? 0
          : userItems.map((e) => e.destructionNum).reduce((a, b) => a + b) * 40;
      int salesSum = salesMoamount +
          salesPostage +
          salesGeneral +
          salesLarge +
          salesReqdan +
          salesSticker +
          salesSet +
          salesNonenter +
          salesCommission +
          salesDifferent +
          salesReturn +
          salesTrush;
      salesSum =
          salesGeneral + salesLarge + salesReqdan + salesSticker + salesSet <=
                  5000
              ? salesSum + 3000
              : salesSum;

      int costMoamount = 0;
      users[customerCount].base.forEach((element) {
        final data = baseMasterData.firstWhereOrNull(
          (e) => e["委託先"] == element,
        );
        if (data != null) {
          costMoamount += data["月額"] as int;
        }
      });

      int costPostage = 0;
      // 実出荷単位数をさらに掛ける
      // int costGeneral =
      //     userItems.where((item) => item.setNum == 1).toList().length * 40;
      int costGeneral = userItems
              .where((item) => item.setNum == 1)
              .toList()
              .map((item) => item.actualShippingNum)
              .toList()
              .isNotEmpty
          ? userItems
                  .where((item) => item.setNum == 1)
                  .toList()
                  .map((item) => item.actualShippingNum)
                  .toList()
                  .reduce((a, b) => a + b) *
              10
          : 0;
      int costLarge =
          userItems.where((element) => element.largeFlg).toList().length * 10;
      int costReqdan = userItems
              .where((element) => element.expiryDate != null)
              .toList()
              .length *
          0;
      int costSticker = userItems.map((e) => e.stickerNum).toList().isEmpty
          ? 0
          : userItems
                  .map((e) => e.stickerNum)
                  .toList()
                  .reduce((a, b) => a * b) *
              0;

      int costSet = userItems.where((item) => item.setNum > 1).toList().isEmpty
          ? 0
          : userItems
                  .where((item) => item.setNum > 1)
                  .toList()
                  .map((e) => e.actualShippingNum)
                  .toList()
                  .reduce((a, b) => a + b) *
              20;

      int costReturn = userItems.isEmpty
          ? 0
          : userItems.map((e) => e.returnNum).reduce((a, b) => a + b) * 200;
      int costTrush = userItems.isEmpty
          ? 0
          : userItems.map((e) => e.destructionNum).reduce((a, b) => a + b) * 40;
      int costMaterial = 0;
      int costOutsource = 0;
      costSum = costMoamount +
          costPostage +
          costGeneral +
          costLarge +
          costReqdan +
          costSticker +
          costSet +
          costReturn +
          costTrush +
          costMaterial +
          costOutsource;

      int benefit = salesSum - costSum;

      rows.add(
        PlutoRow(
          cells: {
            'no': PlutoCell(value: customerCount + 1),
            'name': PlutoCell(value: '${users[customerCount].name}_親'),
            'shop_name': PlutoCell(value: ''),
            'sales_moamount': PlutoCell(value: salesMoamount),
            'sales_postage': PlutoCell(value: salesPostage),
            'sales_general': PlutoCell(value: salesGeneral),
            'sales_large': PlutoCell(value: salesLarge),
            'sales_reqdan': PlutoCell(value: salesReqdan),
            'sales_sticker': PlutoCell(value: salesSticker),
            'sales_set': PlutoCell(value: salesSet),
            'sales_nonenter': PlutoCell(value: salesNonenter),
            'sales_commission': PlutoCell(value: salesCommission),
            'sales_different': PlutoCell(value: salesDifferent),
            'sales_return': PlutoCell(value: salesReturn),
            'sales_trush': PlutoCell(value: salesTrush),
            'sales_sum': PlutoCell(value: salesSum),
            'cost_moamount': PlutoCell(value: costMoamount),
            'cost_postage': PlutoCell(value: costPostage),
            'cost_general': PlutoCell(value: costGeneral),
            'cost_large': PlutoCell(value: costLarge),
            'cost_reqdan': PlutoCell(value: costReqdan),
            'cost_sticker': PlutoCell(value: costSticker),
            'cost_set': PlutoCell(value: costSet),
            'cost_return': PlutoCell(value: costReturn),
            'cost_trush': PlutoCell(value: costTrush),
            'cost_material': PlutoCell(value: costMaterial),
            'cost_outsource': PlutoCell(value: costOutsource),
            'cost_sum': PlutoCell(value: costSum),
            'benefit': PlutoCell(value: benefit),
          },
        ),
      );

      if (getFlag == 0) {
        for (var i = 0; i < users[customerCount].base.length; i++) {
          final baseItems = userItems
              .where((item) => item.base == users[customerCount].base[i])
              .toList();
          int salesMoamount = 2200;
          int salesPostage = 0;
          // 実出荷単位数をさらに掛ける
          int salesGeneral = baseItems
                  .where((item) => item.setNum == 1)
                  .toList()
                  .map((item) => item.actualShippingNum)
                  .toList()
                  .isNotEmpty
              ? baseItems
                      .where((item) => item.setNum == 1)
                      .toList()
                      .map((item) => item.actualShippingNum)
                      .toList()
                      .reduce((a, b) => a + b) *
                  40
              : 0;

          int salesLarge =
              baseItems.where((element) => element.largeFlg).toList().length *
                  100;

          int salesReqdan = baseItems
                  .where((element) => element.expiryDate != null)
                  .toList()
                  .length *
              10;

          int salesSticker = baseItems.map((e) => e.stickerNum).toList().isEmpty
              ? 0
              : baseItems
                      .map((e) => e.stickerNum)
                      .toList()
                      .reduce((a, b) => a * b) *
                  20;

          int salesSet =
              baseItems.where((item) => item.setNum > 1).toList().isEmpty
                  ? 0
                  : baseItems
                          .where((item) => item.setNum > 1)
                          .toList()
                          .map((e) => e.actualShippingNum)
                          .toList()
                          .reduce((a, b) => a + b) *
                      40;

          int salesNonenter =
              baseItems.where((item) => item.addAdminFlg).toList().length * 200;
          int salesCommission = baseItems.length * 40;
          int salesDifferent =
              baseItems.where((item) => item.editJanFlg).toList().length * 30;
          int salesReturn = baseItems.isEmpty
              ? 0
              : baseItems.map((e) => e.returnNum).reduce((a, b) => a + b) * 200;
          int salesTrush = baseItems.isEmpty
              ? 0
              : baseItems.map((e) => e.destructionNum).reduce((a, b) => a + b) *
                  40;
          int salesSum = salesMoamount +
              salesPostage +
              salesGeneral +
              salesLarge +
              salesReqdan +
              salesSticker +
              salesSet +
              salesNonenter +
              salesCommission +
              salesDifferent +
              salesReturn +
              salesTrush;

          int costMoamount = baseMasterData.firstWhere(
              (element) => element["委託先"] == users[customerCount].base[i],
              orElse: () => baseMasterData[0])["月額"] as int;

          int costPostage = 0;
          // 実出荷単位数をさらに掛ける
          // int costGeneral =
          //     baseItems.where((item) => item.setNum == 1).toList().length * 40;
          int costGeneral = baseItems
                  .where((item) => item.setNum == 1)
                  .toList()
                  .map((item) => item.actualShippingNum)
                  .toList()
                  .isNotEmpty
              ? baseItems
                      .where((item) => item.setNum == 1)
                      .toList()
                      .map((item) => item.actualShippingNum)
                      .toList()
                      .reduce((a, b) => a + b) *
                  baseMasterData.firstWhere(
                      (element) =>
                          element["委託先"] == users[customerCount].base[i],
                      orElse: () => baseMasterData[0])["一般"] as int
              : 0;
          int costLarge = baseItems
                  .where((element) => element.largeFlg)
                  .toList()
                  .length *
              baseMasterData.firstWhere(
                  (element) => element["委託先"] == users[customerCount].base[i],
                  orElse: () => baseMasterData[0])["大型"] as int;
          ;
          int costReqdan = baseItems
                  .where((element) => element.expiryDate != null)
                  .toList()
                  .length *
              baseMasterData.firstWhere(
                  (element) => element["委託先"] == users[customerCount].base[i],
                  orElse: () => baseMasterData[0])["要・危"] as int;
          int costSticker = baseItems.map((e) => e.stickerNum).toList().isEmpty
              ? 0
              : baseItems
                      .map((e) => e.stickerNum)
                      .toList()
                      .reduce((a, b) => a * b) *
                  baseMasterData.firstWhere(
                      (element) =>
                          element["委託先"] == users[customerCount].base[i],
                      orElse: () => baseMasterData[0])["シール"] as int;

          int costSet =
              baseItems.where((item) => item.setNum > 1).toList().isEmpty
                  ? 0
                  : baseItems
                          .where((item) => item.setNum > 1)
                          .toList()
                          .map((e) => e.actualShippingNum)
                          .toList()
                          .reduce((a, b) => a + b) *
                      baseMasterData.firstWhere(
                          (element) =>
                              element["委託先"] == users[customerCount].base[i],
                          orElse: () => baseMasterData[0])["セット"] as int;

          int costReturn = baseItems.isEmpty
              ? 0
              : baseItems.map((e) => e.returnNum).reduce((a, b) => a + b) * 200;
          int costTrush = baseItems.isEmpty
              ? 0
              : baseItems.map((e) => e.destructionNum).reduce((a, b) => a + b) *
                  40;
          int costMaterial = 0;
          int costOutsource = 0;
          int costSum = costMoamount +
              costPostage +
              costGeneral +
              costLarge +
              costReqdan +
              costSticker +
              costSet +
              costReturn +
              costTrush +
              costMaterial +
              costOutsource;

          int benefit = salesSum - costSum;
          rows.add(
            PlutoRow(
              cells: {
                'no': PlutoCell(value: customerCount + 1),
                'name': PlutoCell(value: ''),
                'shop_name': PlutoCell(
                    value:
                        '${users[customerCount].name}_${users[customerCount].base[i]}_子'),
                'sales_moamount': PlutoCell(value: salesMoamount),
                'sales_postage': PlutoCell(value: salesPostage),
                'sales_general': PlutoCell(value: salesGeneral),
                'sales_large': PlutoCell(value: salesLarge),
                'sales_reqdan': PlutoCell(value: salesReqdan),
                'sales_sticker': PlutoCell(value: salesSticker),
                'sales_set': PlutoCell(value: salesSet),
                'sales_nonenter': PlutoCell(value: salesNonenter),
                'sales_commission': PlutoCell(value: salesCommission),
                'sales_different': PlutoCell(value: salesDifferent),
                'sales_return': PlutoCell(value: salesReturn),
                'sales_trush': PlutoCell(value: salesTrush),
                'sales_sum': PlutoCell(
                    value: salesGeneral +
                                salesLarge +
                                salesReqdan +
                                salesSticker +
                                salesSet <=
                            5000
                        ? salesSum + 3000
                        : salesSum),
                'cost_moamount': PlutoCell(value: costMoamount),
                'cost_postage': PlutoCell(value: costPostage),
                'cost_general': PlutoCell(value: costGeneral),
                'cost_large': PlutoCell(value: costLarge),
                'cost_reqdan': PlutoCell(value: costReqdan),
                'cost_sticker': PlutoCell(value: costSticker),
                'cost_set': PlutoCell(value: costSet),
                'cost_return': PlutoCell(value: costReturn),
                'cost_trush': PlutoCell(value: costTrush),
                'cost_material': PlutoCell(value: costMaterial),
                'cost_outsource': PlutoCell(value: costOutsource),
                'cost_sum': PlutoCell(value: costSum),
                'benefit': PlutoCell(value: benefit),
              },
            ),
          );
        }
      }
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    shippedDate = List<String>.generate(
        ref.watch(itemListProvider).length,
        (i) => ref.watch(itemListProvider)[i].shippeddate != null
            ? dateFormat.format(ref.watch(itemListProvider)[i].shippeddate!)
            : '').toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('利益計算'),
      ),
      body: FutureBuilder(
          future: res,
          builder: (context, snapshot) {
            if (!snapshot.hasData || res == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Container(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Expanded(
                    child: PlutoGrid(
                        columns: columns,
                        rows: rows,
                        columnGroups: columnGroups,
                        // mode: mode,
                        onLoaded: (PlutoGridOnLoadedEvent event) async {
                          stateManager = event.stateManager;
                          stateManager.setShowColumnFilter(true);
                          PlutoFilterTypeContains.name = 'フィルター';
                          // await createPluto(ref);
                        },
                        createHeader: (s) {
                          print(s);
                          // return
                          return _Header(
                            stateManager: s,
                            shippedDate: shippedDate,
                            columns: columns,
                          );
                        },
                        configuration: const PlutoGridConfiguration(
                            scrollbar: PlutoGridScrollbarConfig(
                              scrollbarThickness: 10,
                              scrollbarThicknessWhileDragging: 12,
                            ),
                            style: PlutoGridStyleConfig(
                                cellTextStyle: TextStyle())),
                        onChanged: (PlutoGridOnChangedEvent event) async {
                          // print(event);
                          setState(() {
                            rows[event.rowIdx]
                                .cells['sales_sum']!
                                .value = rows[event.rowIdx]
                                    .cells['sales_moamount']!
                                    .value +
                                rows[event.rowIdx]
                                    .cells['sales_postage']!
                                    .value +
                                rows[event.rowIdx]
                                    .cells['sales_general']!
                                    .value +
                                rows[event.rowIdx].cells['sales_large']!.value +
                                rows[event.rowIdx]
                                    .cells['sales_reqdan']!
                                    .value +
                                rows[event.rowIdx]
                                    .cells['sales_sticker']!
                                    .value +
                                rows[event.rowIdx].cells['sales_set']!.value +
                                rows[event.rowIdx]
                                    .cells['sales_nonenter']!
                                    .value +
                                rows[event.rowIdx]
                                    .cells['sales_commission']!
                                    .value +
                                rows[event.rowIdx]
                                    .cells['sales_different']!
                                    .value +
                                rows[event.rowIdx]
                                    .cells['sales_return']!
                                    .value +
                                rows[event.rowIdx].cells['sales_trush']!.value;

                            if (rows[event.rowIdx]
                                        .cells['sales_general']!
                                        .value +
                                    rows[event.rowIdx]
                                        .cells['sales_large']!
                                        .value +
                                    rows[event.rowIdx]
                                        .cells['sales_reqdan']!
                                        .value +
                                    rows[event.rowIdx]
                                        .cells['sales_sticker']!
                                        .value +
                                    rows[event.rowIdx]
                                        .cells['sales_set']!
                                        .value <=
                                5000) {
                              rows[event.rowIdx].cells['sales_sum']!.value =
                                  rows[event.rowIdx].cells['sales_sum']!.value +
                                      3000;
                            }
                            rows[event.rowIdx]
                                .cells['cost_sum']!
                                .value = rows[event.rowIdx]
                                    .cells['cost_moamount']!
                                    .value +
                                rows[event.rowIdx]
                                    .cells['cost_postage']!
                                    .value +
                                rows[event.rowIdx]
                                    .cells['cost_general']!
                                    .value +
                                rows[event.rowIdx].cells['cost_large']!.value +
                                rows[event.rowIdx].cells['cost_reqdan']!.value +
                                rows[event.rowIdx]
                                    .cells['cost_sticker']!
                                    .value +
                                rows[event.rowIdx].cells['cost_set']!.value +
                                rows[event.rowIdx].cells['cost_return']!.value +
                                rows[event.rowIdx].cells['cost_trush']!.value +
                                rows[event.rowIdx]
                                    .cells['cost_material']!
                                    .value +
                                rows[event.rowIdx]
                                    .cells['cost_outsource']!
                                    .value;

                            rows[event.rowIdx].cells['benefit']!.value =
                                rows[event.rowIdx].cells['sales_sum']!.value -
                                    rows[event.rowIdx].cells['cost_sum']!.value;
                          });
                        }),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class _Header extends ConsumerStatefulWidget {
  const _Header({
    required this.shippedDate,
    required this.stateManager,
    required this.columns,
    Key? key,
  }) : super(key: key);

  final PlutoGridStateManager stateManager;
  final List<String> shippedDate;
  final List<PlutoColumn> columns;

  @override
  ConsumerState<_Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<_Header> {
  // ToDo 不要な変数を確認し、削除する
  int addCount = 1;
  int addedCount = 0;

  PlutoGridSelectingMode gridSelectingMode = PlutoGridSelectingMode.row;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.stateManager.setSelectingMode(gridSelectingMode);
    });
  }

  // ToDo 下記voidを確認し、削除する

  void allGet() {
    widget.stateManager.setFilter((element) => true);
  }

  void onlySum() {
    widget.stateManager
        .setFilter((element) => element.cells['name']!.value != '');
  }

  void handleFiltering() {
    widget.stateManager
        .setShowColumnFilter(!widget.stateManager.showColumnFilter);
  }

  void filterData(WidgetRef ref) {
    print(isSelectedValue);
    final items = isSelectedValue == 'ALL'
        ? ref
            .read(itemListProvider)
            .where((item) => item.status == "発送完了")
            .toList()
        : ref
            .read(itemListProvider)
            .where((item) =>
                item.status == "発送完了" &&
                item.shippeddate != null &&
                dateFormat.format(item.shippeddate!) == isSelectedValue)
            .toList();
    final users = ref.read(customerListProvider);
    int generalInt = 40;
    int largeInt = 100;
    int reqdanInt = 10;
    int stickerInt = 20;
    int setInt = 60;

    for (var element in widget.stateManager.refRows) {
      int no = element.cells['no']!.value - 1;
      List<AmazonItem> userItems =
          items.where((item) => item.userName == users[no].name).toList();
      if (element.cells['name']!.value == "") {
        userItems = userItems
            .where((useritem) =>
                element.cells["shop_name"]!.value.contains(useritem.base))
            .toList();
        if (userItems.isNotEmpty) {
          generalInt = baseMasterData.firstWhere(
              (element) => element["委託先"] == userItems[0].base,
              orElse: () => baseMasterData[0])["一般"];
          largeInt = baseMasterData.firstWhere(
              (element) => element["委託先"] == userItems[0].base,
              orElse: () => baseMasterData[0])["大型"];
          reqdanInt = baseMasterData.firstWhere(
              (element) => element["委託先"] == userItems[0].base,
              orElse: () => baseMasterData[0])["要・危"];
          stickerInt = baseMasterData.firstWhere(
              (element) => element["委託先"] == userItems[0].base,
              orElse: () => baseMasterData[0])["シール"];
          setInt = baseMasterData.firstWhere(
              (element) => element["委託先"] == userItems[0].base,
              orElse: () => baseMasterData[0])["セット"];
        }
      }

      element.cells["sales_general"]!.value = userItems
              .where((item) => item.setNum == 1)
              .toList()
              .map((e) => e.actualShippingNum)
              .toList()
              .isEmpty
          ? 0
          : userItems
                  .where((item) => item.setNum == 1)
                  .toList()
                  .map((item) => item.actualShippingNum)
                  .toList()
                  .reduce((a, b) => a + b) *
              40;
      element.cells["sales_large"]!.value =
          userItems.where((item) => item.largeFlg).length * 100;
      element.cells["sales_reqdan"]!.value =
          userItems.where((item) => item.expiryDate != null).length * 10;
      element.cells["sales_sticker"]!.value =
          userItems.map((e) => e.stickerNum).toList().isEmpty
              ? 0
              : userItems
                      .map((e) => e.stickerNum)
                      .toList()
                      .reduce((a, b) => a * b) *
                  20;
      element.cells["sales_set"]!.value =
          userItems.where((item) => item.setNum > 1).toList().isEmpty
              ? 0
              : userItems
                      .where((item) => item.setNum > 1)
                      .toList()
                      .map((e) => e.actualShippingNum)
                      .toList()
                      .reduce((a, b) => a + b) *
                  60;
      element.cells["sales_nonenter"]!.value =
          userItems.where((item) => item.addAdminFlg).toList().length * 200;
      element.cells["sales_commission"]!.value = userItems.length * 40;
      element.cells["sales_different"]!.value =
          userItems.where((item) => item.editJanFlg).toList().length * 30;
      element.cells["sales_return"]!.value = userItems.isEmpty
          ? 0
          : userItems.map((e) => e.returnNum).reduce((a, b) => a + b) * 200;
      element.cells["sales_trush"]!.value = userItems.isEmpty
          ? 0
          : userItems.map((e) => e.destructionNum).reduce((a, b) => a + b) * 40;
      // 上記のcellを全て足した値を出す
      element.cells["sales_sum"]!.value =
          element.cells["sales_moamount"]!.value +
              element.cells["sales_postage"]!.value +
              element.cells["sales_general"]!.value +
              element.cells["sales_large"]!.value +
              element.cells["sales_reqdan"]!.value +
              element.cells["sales_sticker"]!.value +
              element.cells["sales_set"]!.value +
              element.cells["sales_nonenter"]!.value +
              element.cells["sales_commission"]!.value +
              element.cells["sales_different"]!.value +
              element.cells["sales_return"]!.value +
              element.cells["sales_trush"]!.value;
      element.cells["sales_sum"]!.value =
          element.cells["sales_general"]!.value +
                      element.cells["sales_large"]!.value +
                      element.cells["sales_reqdan"]!.value +
                      element.cells["sales_sticker"]!.value +
                      element.cells["sales_set"]!.value <=
                  5000
              ? element.cells["sales_sum"]!.value + 3000
              : element.cells["sales_sum"]!.value;
      // コスト側
      element.cells["cost_general"]!.value = userItems
              .where((item) => item.setNum == 1)
              .toList()
              .map((item) => item.actualShippingNum)
              .toList()
              .isNotEmpty
          ? userItems
                  .where((item) => item.setNum == 1)
                  .toList()
                  .map((item) => item.actualShippingNum)
                  .toList()
                  .reduce((a, b) => a + b) *
              generalInt
          : 0;
      element.cells["cost_large"]!.value =
          userItems.where((item) => item.largeFlg).length * largeInt;
      element.cells["cost_reqdan"]!.value =
          userItems.where((item) => item.expiryDate != null).length * reqdanInt;
      element.cells["cost_sticker"]!.value =
          userItems.map((e) => e.stickerNum).toList().isEmpty
              ? 0
              : userItems
                      .map((e) => e.stickerNum)
                      .toList()
                      .reduce((a, b) => a * b) *
                  stickerInt;
      element.cells["cost_set"]!.value =
          userItems.where((item) => item.setNum > 1).toList().isEmpty
              ? 0
              : userItems
                      .where((item) => item.setNum > 1)
                      .toList()
                      .map((e) => e.actualShippingNum)
                      .toList()
                      .reduce((a, b) => a + b) *
                  setInt;
      element.cells["cost_return"]!.value = userItems.isEmpty
          ? 0
          : userItems.map((e) => e.returnNum).reduce((a, b) => a + b) * 200;
      element.cells["cost_trush"]!.value = userItems.isEmpty
          ? 0
          : userItems.map((e) => e.destructionNum).reduce((a, b) => a + b) * 40;
      element.cells["cost_sum"]!.value = element.cells["cost_moamount"]!.value +
          element.cells["cost_postage"]!.value +
          element.cells["cost_general"]!.value +
          element.cells["cost_large"]!.value +
          element.cells["cost_reqdan"]!.value +
          element.cells["cost_sticker"]!.value +
          element.cells["cost_set"]!.value +
          element.cells["cost_return"]!.value +
          element.cells["cost_trush"]!.value +
          element.cells["cost_material"]!.value +
          element.cells["cost_outsource"]!.value;
      element.cells["benefit"]!.value =
          element.cells["sales_sum"]!.value - element.cells["cost_sum"]!.value;
    }
  }

  Future<void> export() async {
    // csvファイル作成
    // Planのフィールド値のcsvファイルを作成する
    String title = "利益計算表";

    var exported = const Utf8Encoder().convert(
        pluto_grid_export.PlutoGridExport.exportCSV(widget.stateManager));

    // use file_saver from pub.dev
    await FileSaver.instance
        .saveFile(name: "$title.csv", bytes: exported, mimeType: MimeType.csv);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  height: context.screenHeight * 0.001,
                  width: context.screenWidth * 0.01,
                ),
                Container(child: Text('出荷月:')),
                Container(
                  height: context.screenHeight * 0.001,
                  width: context.screenWidth * 0.01,
                ),
                Container(
                  child: DropdownButton(
                    items: <DropdownMenuItem<String>>[
                      DropdownMenuItem(
                        value: 'ALL',
                        child: Text('ALL'),
                      ),
                      ...widget.shippedDate
                          .where((date) => date != '')
                          .toList()
                          .map<DropdownMenuItem<String>>(
                              (String date) => DropdownMenuItem(
                                    value: date,
                                    child: Text(
                                      date,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                          .toList()
                    ],
                    value: isSelectedValue,
                    onChanged: (String? value) async {
                      isSelectedValue = value!;
                      setState(() {
                        filterData(ref);
                      });
                    },
                  ),
                ),
                Container(
                  height: context.screenHeight * 0.001,
                  width: context.screenWidth * 0.01,
                ),
                Container(
                  height: context.screenHeight * 0.05,
                  width: context.screenWidth * 0.1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.8),
                    ),
                    onPressed: () {
                      allGet();
                    },
                    child: const Text('全表示'),
                  ),
                ),
                Container(
                  height: context.screenHeight * 0.001,
                  width: context.screenWidth * 0.01,
                ),
                Container(
                  height: context.screenHeight * 0.05,
                  width: context.screenWidth * 0.1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.8),
                    ),
                    onPressed: onlySum,
                    // () {
                    // setState(
                    //   () {},
                    //   );
                    // },
                    child: const Text('合計のみ表示'),
                  ),
                ),
                Container(
                  height: context.screenHeight * 0.001,
                  width: context.screenWidth * 0.01,
                ),
                Container(
                  height: context.screenHeight * 0.05,
                  width: context.screenWidth * 0.1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.8),
                    ),
                    onPressed: handleFiltering,
                    child: const Text('Toggle filtering'),
                  ),
                ),
                Container(
                  height: context.screenHeight * 0.001,
                  width: context.screenWidth * 0.01,
                ),
                Container(
                  height: context.screenHeight * 0.05,
                  width: context.screenWidth * 0.1,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.8),
                    ),
                    onPressed: export,
                    child: const Text('CSV出力'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
