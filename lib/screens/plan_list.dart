import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import 'package:delivery_control_web/exSize.dart';
import 'package:delivery_control_web/models/base.dart';
import 'package:delivery_control_web/models/customer.dart';
import 'package:delivery_control_web/models/item.dart';
import 'package:delivery_control_web/models/loginUser.dart';
import 'package:delivery_control_web/models/plan.dart';

import 'package:delivery_control_web/providers/plan_database_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pluto_grid_export/pluto_grid_export.dart' as pluto_grid_export;
import 'package:file_saver/file_saver.dart';

DateFormat outputFormat = DateFormat('yyyy/MM/dd');

final onSelectProvider = StateProvider<bool>((ref) => false);
final userIndexProvider = StateProvider<int>((ref) => 0);
final approvalCountProvider = StateProvider<int>((ref) => 0);

class PlanListScreen extends ConsumerStatefulWidget {
  const PlanListScreen({super.key});

  @override
  _PlanList createState() => _PlanList();
}

class _PlanList extends ConsumerState<PlanListScreen> {
  bool isLoading = false;
  late Future<int> result;
  int index = 0;
  late List<PlutoRow> rows;
  late PlutoGridStateManager stateManager;
  PlutoGridMode mode = PlutoGridMode.normal;

  PlanDatabase planDatabase = PlanDatabase();

  List<Customer>? dataList;
  String? filterKind;
  bool? selectbool;
  bool delFlg = false;

  List<PlutoColumn> columns = [];

  // void handleOnRowChecked(PlutoGridOnRowCheckedEvent event) {
  //   setState(
  //     () {
  //       ref.watch(approvalCountProvider.notifier).state =
  //           stateManager.checkedRows.length;
  //     },
  //   );
  //   // inspect(event);
  // }

  Future<void> export() async {
    // csvファイル作成
    // Planのフィールド値のcsvファイルを作成する
    String title = "plan";

    var exported = const Utf8Encoder()
        .convert(pluto_grid_export.PlutoGridExport.exportCSV(stateManager));

    // use file_saver from pub.dev
    await FileSaver.instance
        .saveFile(name: "$title.csv", bytes: exported, mimeType: MimeType.csv);
  }

  Future<void> update() async {
    ref.read(planListProvider.notifier).clearList();
    await planDatabase.getallPlans(ref);
  }

  @override
  void initState() {
    columns = <PlutoColumn>[
      PlutoColumn(
        title: '配送日',
        field: 'deliveryDate',
        type: PlutoColumnType.date(format: "yyyy/MM/dd"),
        titleTextAlign: PlutoColumnTextAlign.center,
        enableRowChecked: true,
        enableColumnDrag: false,
        enableContextMenu: false,
        textAlign: PlutoColumnTextAlign.center,
        width: 150,
      ),
      PlutoColumn(
        title: '配送方法',
        field: 'shippingWay',
        type: PlutoColumnType.select(["西濃運輸", "佐川急便", "ヤマト運輸", "その他"]),
        titleTextAlign: PlutoColumnTextAlign.center,
        enableColumnDrag: false,
        enableContextMenu: false,
        textAlign: PlutoColumnTextAlign.center,
        width: 100,
      ),
      PlutoColumn(
        title: 'メール送信',
        field: 'mailStatus',
        type: PlutoColumnType.select(['未送信', '送信済み']),
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.center,
        enableColumnDrag: false,
        enableContextMenu: false,
        width: 100,
      ),
      PlutoColumn(
        title: '集荷依頼',
        field: 'request',
        type: PlutoColumnType.select(["未依頼", "依頼済", "集荷完了"]),
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.center,
        enableColumnDrag: false,
        enableContextMenu: false,
        width: 100,
      ),
      PlutoColumn(
        title: '箱数',
        field: 'boxNum',
        type: PlutoColumnType.number(),
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.center,
        enableColumnDrag: false,
        enableContextMenu: false,
        width: 80,
      ),
      PlutoColumn(
        title: '縦(cm)',
        field: 'boxHeight',
        type: PlutoColumnType.number(),
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.center,
        enableColumnDrag: false,
        enableContextMenu: false,
        width: 80,
      ),
      PlutoColumn(
        title: '横(cm)',
        field: 'boxWidth',
        type: PlutoColumnType.number(),
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.center,
        enableColumnDrag: false,
        enableContextMenu: false,
        width: 80,
      ),
      PlutoColumn(
        title: '高さ(cm)',
        field: 'boxHorizontal',
        type: PlutoColumnType.number(),
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.center,
        enableColumnDrag: false,
        enableContextMenu: false,
        width: 80,
      ),
      PlutoColumn(
        title: '重量(kg)',
        field: 'boxWeight',
        type: PlutoColumnType.number(),
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.center,
        enableColumnDrag: false,
        enableContextMenu: false,
        width: 80,
      ),
      PlutoColumn(
        title: 'プラン名',
        field: 'planName',
        type: PlutoColumnType.text(),
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.center,
        enableColumnDrag: false,
        enableContextMenu: false,
        width: 100,
      ),
      PlutoColumn(
        title: 'ユーザ名',
        field: 'planWhoIs',
        type: PlutoColumnType.select(ref
            .read(customerListProvider)
            .map((customer) => customer.name)
            .toList()),
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.center,
        enableColumnDrag: false,
        enableContextMenu: false,
        width: 100,
      ),
      PlutoColumn(
        title: '拠点',
        field: 'planWhereIs',
        type: PlutoColumnType.select(
            ref.read(baseListProvider).map((base) => base.name).toList()),
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.center,
        enableColumnDrag: false,
        enableContextMenu: false,
        width: 100,
      ),
      PlutoColumn(
        title: '問い合わせ番号',
        field: 'questionNumber',
        type: PlutoColumnType.number(),
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.center,
        enableColumnDrag: false,
        enableContextMenu: false,
        width: 100,
      ),
      PlutoColumn(
        title: '備考',
        field: 'remarks',
        type: PlutoColumnType.text(),
        titleTextAlign: PlutoColumnTextAlign.center,
        textAlign: PlutoColumnTextAlign.center,
        enableColumnDrag: false,
        enableContextMenu: false,
        width: 100,
      ),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    rows = List<PlutoRow>.generate(
      ref.watch(planListProvider).length,
      (i) => PlutoRow(cells: {
        'deliveryDate':
            PlutoCell(value: ref.watch(planListProvider)[i].shippingDate ?? ""),
        'shippingWay':
            PlutoCell(value: ref.watch(planListProvider)[i].shippingWay ?? ""),
        'mailStatus':
            PlutoCell(value: ref.watch(planListProvider)[i].mailStatus),
        'request': PlutoCell(value: ref.watch(planListProvider)[i].status),
        'boxNum': PlutoCell(value: ref.watch(planListProvider)[i].boxNum),
        'boxHeight': PlutoCell(value: ref.watch(planListProvider)[i].boxHeight),
        'boxWidth': PlutoCell(value: ref.watch(planListProvider)[i].boxWidth),
        'boxHorizontal':
            PlutoCell(value: ref.watch(planListProvider)[i].boxHorizontal),
        'boxWeight': PlutoCell(value: ref.watch(planListProvider)[i].boxWeight),
        'planName': PlutoCell(value: ref.watch(planListProvider)[i].name),
        'planWhoIs': PlutoCell(
            value: ref.watch(planListProvider)[i].itemIds[0] == ""
                ? ref.read(loginUserProvider).name
                : ref.watch(customerListProvider).firstWhereOrNull(
                            (Customer customer) =>
                                customer.name ==
                                ref
                                    .watch(itemListProvider)
                                    .firstWhere((AmazonItem item) =>
                                        item.itemId ==
                                        ref
                                            .watch(planListProvider)[i]
                                            .itemIds[0])
                                    .userName) ==
                        null
                    ? ref.read(loginUserProvider).name
                    : ref
                        .watch(customerListProvider)
                        .firstWhereOrNull((Customer customer) =>
                            customer.name ==
                            ref
                                .watch(itemListProvider)
                                .firstWhere((AmazonItem item) =>
                                    item.itemId ==
                                    ref.watch(planListProvider)[i].itemIds[0])
                                .userName)!
                        .name),
        'planWhereIs': PlutoCell(
            value: ref.watch(planListProvider)[i].itemIds[0] == ""
                ? ref.read(loginUserProvider).base[0]
                : ref.watch(itemListProvider).firstWhereOrNull(
                            (AmazonItem item) =>
                                item.itemId ==
                                ref.watch(planListProvider)[i].itemIds[0]) ==
                        null
                    ? ref.read(loginUserProvider).base[0]
                    : ref
                        .read(itemListProvider)
                        .firstWhereOrNull((AmazonItem item) =>
                            item.itemId ==
                            ref.watch(planListProvider)[i].itemIds[0])!
                        .base),
        'questionNumber':
            PlutoCell(value: ref.watch(planListProvider)[i].infoNum),
        'remarks': PlutoCell(value: ref.watch(planListProvider)[i].note),
      }),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('プラン一覧'),
      ),
      body: ref.watch(planListProvider).isEmpty
          ? const Center(child: Text("データがありません"))
          : Container(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  Expanded(
                    child: PlutoGrid(
                      columns: columns,
                      rows: rows,
                      mode: mode,
                      onLoaded: (PlutoGridOnLoadedEvent event) {
                        stateManager = event.stateManager;
                        stateManager.setShowColumnFilter(true);
                      },
                      onChanged: (PlutoGridOnChangedEvent event) async {
                        Plan plan = ref.read(planListProvider)[event.rowIdx];
                        plan.shippingDate =
                            event.row.cells['deliveryDate']!.value == ""
                                ? null
                                : DateFormat('yyyy/MM/dd').parse(
                                    event.row.cells['deliveryDate']!.value);

                        plan.shippingWay =
                            event.row.cells['shippingWay']!.value;
                        plan.mailStatus = event.row.cells['mailStatus']!.value;
                        plan.status = event.row.cells['request']!.value;
                        plan.boxNum = event.row.cells['boxNum']!.value;
                        plan.boxHeight = event.row.cells['boxHeight']!.value;
                        plan.boxWidth = event.row.cells['boxWidth']!.value;
                        plan.boxHorizontal =
                            event.row.cells['boxHorizontal']!.value;
                        plan.boxWeight = event.row.cells['boxWeight']!.value;
                        plan.name = event.row.cells['planName']!.value;
                        plan.infoNum = event.row.cells['questionNumber']!.value;
                        plan.note = event.row.cells['remarks']!.value;

                        if (plan.shippingWay == "西濃運輸") {
                          plan.boxWeight = (plan.boxHeight! *
                                  plan.boxWidth! *
                                  plan.boxHorizontal! *
                                  0.00028)
                              .round();
                        }

                        event.row.cells['boxWeight']!.value = plan.boxWeight;

                        planDatabase.editPlan(plan);
                      },
                      onRowChecked: (PlutoGridOnRowCheckedEvent event) {
                        ref.read(planListProvider)[event.rowIdx!].selected =
                            event.isChecked!;
                        print(event.rowIdx);
                      },
                      configuration: const PlutoGridConfiguration(
                        scrollbar: PlutoGridScrollbarConfig(
                          scrollbarThickness: 10,
                          scrollbarThicknessWhileDragging: 12,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: context.screenHeight * 0.08,
                    child: Row(
                      children: [
                        SizedBox(
                          width: context.screenWidth * 0.05,
                        ),
                        SizedBox(
                          height: context.screenHeight * 0.05,
                          width: context.screenWidth * 0.2,
                          child: ElevatedButton(
                            child: const Text("西濃運輸ページへ"),
                            onPressed: () async {
                              final Uri url =
                                  Uri.parse('https://net.seino.co.jp/myseino/');
                              if (!await launchUrl(url)) {
                                throw Exception('Could not launch $url');
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: context.screenWidth * 0.05,
                        ),
                        SizedBox(
                            height: context.screenHeight * 0.05,
                            width: context.screenWidth * 0.2,
                            child: ElevatedButton(
                                onPressed: () async {
                                  List<Plan> selectedPlan = ref
                                      .watch(planListProvider)
                                      .where(
                                          (element) => element.selected == true)
                                      .toList();
                                  for (var plan in selectedPlan) {
                                    Customer? toUser = ref
                                        .watch(customerListProvider)
                                        .firstWhereOrNull((Customer customer) =>
                                            customer.name ==
                                            ref
                                                .watch(itemListProvider)
                                                .firstWhere((AmazonItem item) =>
                                                    item.itemId ==
                                                    plan.itemIds[0])
                                                .userName);
                                    if (toUser == null) {
                                      print("ユーザーなし");
                                      return;
                                    }
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('email')
                                          .add({
                                        // 'to': toUser.mail,
                                        'to': "skrnmik12@gmail.com",
                                        'message': {
                                          'subject':
                                              '【納品代行ラクロジ】${toUser.name}様 商品発送のお知らせ',
                                          'text': '''
                  ${toUser.name}様
                              
                    いつもご利用いただき誠にありがとうございます。
                    納品代行ラクロジです。
                          
                    商品を発送いたしました。
                    配送情報を下記させていただきます。
                          
                    【お荷物情報】
                    [プラン名] ${plan.name}
                    [配送日] ${outputFormat.format(plan.shippingDate!)}
                    [配送方法] ${plan.shippingWay}
                    [箱数] ${plan.boxNum ?? 0}箱
                    [問合せ番号] ${plan.infoNum}
                    
                    https://fir-sys-47c75.web.app/
                          
                    ご不明点などございましたら、LINEグループにてお気軽にご連絡ください。
                    よろしくお願いします。
                          
                                      ''',
                                        }
                                      });

                                      plan.mailStatus = "送信済み";
                                      plan.status = "集荷完了";

                                      for (var row
                                          in stateManager.checkedRows) {
                                        row.cells['request']!.value = "集荷完了";
                                        row.cells['mailStatus']!.value = "送信済み";
                                      }
                                      planDatabase.editPlan(plan);
                                      for (var itemId in plan.itemIds) {
                                        AmazonItem item = ref
                                            .read(itemListProvider)
                                            .firstWhere((AmazonItem item) =>
                                                item.itemId == itemId);
                                        item.status = "発送完了";
                                      }
                                    } catch (e) {
                                      await showDialog(
                                          context: context,
                                          builder: (_) {
                                            return AlertDialog(
                                              content: SizedBox(
                                                height:
                                                    context.screenHeight * 0.15,
                                                width:
                                                    context.screenWidth * 0.25,
                                                child: const Center(
                                                  child: Text(
                                                      "メール送信でエラーが発生しました。\n空白の項目があります。"),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: const Text(
                                                    "閉じる",
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                )
                                              ],
                                            );
                                          });
                                      print(e);
                                    }

                                    setState(() {});
                                  }
                                },
                                child: const Text("メール送信"))),
                        SizedBox(
                          width: context.screenWidth * 0.05,
                        ),
                        SizedBox(
                            height: context.screenHeight * 0.05,
                            width: context.screenWidth * 0.2,
                            child: ElevatedButton(
                                onPressed: () async {
                                  // Planを削除
                                  List<Plan> selectedPlan = ref
                                      .read(planListProvider)
                                      .where((element) => element.selected)
                                      .toList();

                                  for (var plan in selectedPlan) {
                                    await planDatabase.removePlan(plan);
                                    ref
                                        .read(planListProvider.notifier)
                                        .remove(plan);
                                  }

                                  stateManager
                                      .removeRows(stateManager.checkedRows);
                                  setState(() {});
                                },
                                child: const Text("削除"))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        spacing: 3,
        direction: SpeedDialDirection.up,
        backgroundColor: Colors.blueAccent.withOpacity(0.8),
        foregroundColor: Colors.white,
        activeBackgroundColor: Colors.grey,
        activeForegroundColor: Colors.white,
        visible: true,
        closeManually: false,
        curve: Curves.bounceIn,
        renderOverlay: false,
        shape: const CircleBorder(),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            backgroundColor: Colors.blueAccent.withOpacity(0.8),
            foregroundColor: Colors.white,
            label: '追加',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () async {
              Plan newPlan = Plan(
                boxHeight: null,
                boxHorizontal: null,
                boxNum: null,
                boxWeight: null,
                boxWidth: null,
                itemIds: [""],
                name: '',
                mailStatus: '未送信',
                planId: '',
                selected: false,
                shippingDate: null,
                status: '未依頼',
                uid: ref.read(loginUserProvider).uid,
                note: "",
                infoNum: null,
                shippingWay: null,
              );
              // String res = await planDatabase.addNewPlan(newPlan);
              // newPlan.planId = res;
              ref.read(planListProvider.notifier).addPlan(newPlan);
              stateManager.insertRows(rows.length, [
                PlutoRow(cells: {
                  'deliveryDate': PlutoCell(value: ""),
                  'shippingWay': PlutoCell(value: ""),
                  'mailStatus': PlutoCell(value: newPlan.mailStatus),
                  'request': PlutoCell(value: newPlan.status),
                  'boxNum': PlutoCell(value: newPlan.boxNum),
                  'boxHeight': PlutoCell(value: newPlan.boxHeight),
                  'boxWidth': PlutoCell(value: newPlan.boxWidth),
                  'boxHorizontal': PlutoCell(value: newPlan.boxHorizontal),
                  'boxWeight': PlutoCell(value: newPlan.boxWeight),
                  'planName': PlutoCell(value: newPlan.name),
                  'planWhoIs': PlutoCell(
                    value: ref.read(loginUserProvider).name,
                  ),
                  'planWhereIs':
                      PlutoCell(value: ref.read(loginUserProvider).base[0]),
                  'questionNumber': PlutoCell(value: newPlan.infoNum),
                  'remarks': PlutoCell(value: newPlan.note),
                }),
              ]);
              setState(() {});
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.download),
            backgroundColor: Colors.blueAccent.withOpacity(0.8),
            foregroundColor: Colors.white,
            label: 'CSV出力',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () async {
              await export();
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.sync),
            backgroundColor: Colors.blueAccent.withOpacity(0.8),
            foregroundColor: Colors.white,
            label: '更新',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () async {
              await update();
            },
          ),
          if (!delFlg)
            SpeedDialChild(
              child: const Icon(Icons.delete),
              backgroundColor: Colors.blueAccent.withOpacity(0.8),
              foregroundColor: Colors.white,
              label: '削除モード',
              labelStyle: const TextStyle(fontSize: 18.0),
              onTap: () async {
                setState(() {
                  delFlg = !delFlg;
                });
              },
            ),
          if (delFlg)
            SpeedDialChild(
              child: const Icon(Icons.mail),
              backgroundColor: Colors.blueAccent.withOpacity(0.8),
              foregroundColor: Colors.white,
              label: '通常モード',
              labelStyle: const TextStyle(fontSize: 18.0),
              onTap: () async {
                setState(() {
                  delFlg = !delFlg;
                });
              },
            ),
        ],
      ),
    );
  }
}
