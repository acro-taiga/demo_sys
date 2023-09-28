import 'package:delivery_control_web/models/base.dart';
import 'package:delivery_control_web/models/item.dart';
import 'package:delivery_control_web/models/loginUser.dart';
import 'package:delivery_control_web/providers/item_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:delivery_control_web/models/customer.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:delivery_control_web/providers/customer_database_provider.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../exSize.dart';
import 'package:delivery_control_web/common/popup.dart';

final onSelectProvider = StateProvider<bool>((ref) => false);
final userIndexProvider = StateProvider<int>((ref) => 0);
final approvalCountProvider = StateProvider<int>((ref) => 0);

class UserListInfo extends ConsumerStatefulWidget {
  const UserListInfo({super.key});

  @override
  _UserInfo createState() => _UserInfo();
}

class _UserInfo extends ConsumerState<UserListInfo> {
  bool isLoading = false;
  late Future<int> result;
  int index = 0;
  late List<PlutoRow> rows;
  late PlutoGridStateManager stateManager;
  PlutoGridMode mode = PlutoGridMode.normal;

  List<Customer>? dataList;
  SelectBase selectBase = SelectBase();

  String? filterKind;
  bool? selectbool;
  CustomerDatabase customerDatabase = CustomerDatabase();

  final List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: 'No',
      field: 'no',
      type: PlutoColumnType.number(),
      titleTextAlign: PlutoColumnTextAlign.center,
      enableRowChecked: true,
      enableEditingMode: false,
      enableColumnDrag: false,
      enableContextMenu: false,
      textAlign: PlutoColumnTextAlign.center,
      width: 120,
    ),
    PlutoColumn(
      title: '承認',
      field: 'approval',
      type: PlutoColumnType.text(),
      titleTextAlign: PlutoColumnTextAlign.center,
      enableEditingMode: false,
      enableColumnDrag: false,
      enableContextMenu: false,
      textAlign: PlutoColumnTextAlign.center,
      width: 100,
    ),
    PlutoColumn(
      title: 'ユーザー',
      field: 'name',
      type: PlutoColumnType.text(),
      titleTextAlign: PlutoColumnTextAlign.center,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 200,
    ),
    PlutoColumn(
      title: 'メールアドレス',
      field: 'mailadress',
      type: PlutoColumnType.text(),
      titleTextAlign: PlutoColumnTextAlign.center,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 200,
    ),
    PlutoColumn(
      title: '拠点',
      field: 'base',
      type: PlutoColumnType.text(),
      titleTextAlign: PlutoColumnTextAlign.center,
      enableEditingMode: false,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 200,
    ),
    PlutoColumn(
      title: 'ショップ名',
      field: 'shopname',
      type: PlutoColumnType.text(),
      titleTextAlign: PlutoColumnTextAlign.center,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 200,
    ),
    PlutoColumn(
      title: '配送名',
      field: 'deliveryname',
      type: PlutoColumnType.text(),
      titleTextAlign: PlutoColumnTextAlign.center,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 200,
    ),
    PlutoColumn(
      title: 'メモ',
      field: 'memo',
      type: PlutoColumnType.text(),
      titleTextAlign: PlutoColumnTextAlign.center,
      enableColumnDrag: false,
      enableContextMenu: false,
      width: 150,
    ),
  ];

  late String headerText;

  void handleOnRowChecked(PlutoGridOnRowCheckedEvent event) {
    setState(
      () {
        ref.watch(approvalCountProvider.notifier).state =
            stateManager.checkedRows.length;
      },
    );
    // inspect(event);
  }

  Future<void> openDetail(PlutoRow? row, Customer customer) async {
    String? value = await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return Dialog(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: const EdgeInsets.all(15),
                width: context.screenWidth * 0.3,
                height: context.screenHeight * 0.9,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: context.screenHeight * 0.05,
                      child: const Text(
                        '所属拠点を選択',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: context.screenHeight * 0.02,
                    ),
                    LayoutBuilder(
                      builder: (ctx, size) {
                        return selectBase.selectBasePull(customer.base, () {
                          Navigator.pop(ctx);
                        }, ref);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });

    if (value == null || value.isEmpty) {
      return;
    }

    stateManager.changeCellValue(
      stateManager.currentRow!.cells['base']!,
      value,
      force: true,
    );
  }

  Future<void> update() async {
    ref.read(customerListProvider.notifier).clearList();
    await customerDatabase.getallCustomers(ref);
  }

  @override
  void initState() {
    super.initState();
    headerText = mode.isNormal ? '編集' : '読取専用';
  }

  @override
  Widget build(BuildContext context) {
    rows = List<PlutoRow>.generate(
      ref.watch(customerListProvider).length,
      (i) => PlutoRow(cells: {
        'no': PlutoCell(value: i + 1),
        'approval': PlutoCell(
            value: ref.watch(customerListProvider)[i].approval == true
                ? '○'
                : '-'),
        'name': PlutoCell(value: ref.watch(customerListProvider)[i].name),
        'mailadress': PlutoCell(value: ref.watch(customerListProvider)[i].mail),
        'base': PlutoCell(
            value: ref
                .watch(customerListProvider)[i]
                .base
                .map<String>((value) => value)
                .join(',')),
        'shopname':
            PlutoCell(value: ref.watch(customerListProvider)[i].shop_name),
        'deliveryname':
            PlutoCell(value: ref.watch(customerListProvider)[i].driver_name),
        'memo': PlutoCell(value: ref.watch(customerListProvider)[i].introducer),
      }),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('ユーザーリスト'),
      ),
      body: ref.watch(customerListProvider).isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.all(5),
              child: Column(
                children: [
                  SizedBox(
                    width: context.screenWidth,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      width: context.screenWidth * 0.1,
                      child: TextButton(
                        onPressed: () {
                          ref.read(loginUserProvider).superAdimnFig
                              ? setState(() {
                                  mode = mode.isNormal
                                      ? PlutoGridMode.readOnly
                                      : PlutoGridMode.normal;
                                  headerText = mode.isNormal ? '編集' : '読取専用';
                                })
                              : null;
                        },
                        child: Text(
                          headerText,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // if (mode.isReadOnly == true)
                  // createHeader:

                  Expanded(
                    child: PlutoGrid(
                      onRowDoubleTap: (event) async {
                        if (event.cell.column.title == '拠点' &&
                            mode == PlutoGridMode.normal) {
                          Customer currentUser =
                              ref.watch(customerListProvider)[event.rowIdx];
                          if (currentUser.base.isNotEmpty) {
                            for (var baseName in currentUser.base) {
                              for (var base in ref.read(baseListProvider)) {
                                if (base.name == baseName) {
                                  base.select = true;
                                }
                              }
                            }
                          }
                          await openDetail(event.row, currentUser);

                          ref.watch(customerListProvider)[event.rowIdx].base =
                              List.generate(
                                  ref
                                      .read(baseListProvider)
                                      .where((element) => element.select)
                                      .toList()
                                      .length,
                                  (index) => ref
                                      .read(baseListProvider)
                                      .where((element) => element.select)
                                      .toList()[index]
                                      .name);
                          event.cell.value = ref
                              .watch(customerListProvider)[event.rowIdx]
                              .base
                              .map<String>((value) => value)
                              .join(',');

                          await customerDatabase.editCustomer(currentUser);

                          setState(() {});
                        }
                      },
                      columns: columns,
                      rows: rows,
                      mode: mode,
                      onLoaded: (PlutoGridOnLoadedEvent event) {
                        stateManager = event.stateManager;
                        stateManager.setShowColumnFilter(true);
                        PlutoFilterTypeContains.name = 'フィルター';
                      },
                      onChanged: (PlutoGridOnChangedEvent event) async {
                        // stateManager = event.stateManager;
                        switch (event.columnIdx) {
                          case 0:
                            break;
                          case 1:
                            break;
                          case 2:
                            ItemDatabase itemDatabase = ItemDatabase();

                            List<AmazonItem> items = ref
                                .watch(itemListProvider)
                                .where((element) =>
                                    element.userName ==
                                    ref
                                        .watch(
                                            customerListProvider)[event.rowIdx]
                                        .name)
                                .toList();
                            for (AmazonItem item in items) {
                              item.userName = event.value;
                              await itemDatabase.editItem(item);
                            }
                            ref.watch(customerListProvider)[event.rowIdx].name =
                                event.value;
                            await customerDatabase.editCustomer(
                                ref.watch(customerListProvider)[event.rowIdx]);
                            setState(() {});
                            break;
                          case 3:
                            ref.watch(customerListProvider)[event.rowIdx].mail =
                                event.value;
                            await customerDatabase.editCustomer(
                                ref.watch(customerListProvider)[event.rowIdx]);
                            setState(() {});
                            break;
                          case 4:
                            break;
                          case 5:
                            ref
                                .watch(customerListProvider)[event.rowIdx]
                                .shop_name = event.value;
                            await customerDatabase.editCustomer(
                                ref.watch(customerListProvider)[event.rowIdx]);
                            setState(() {});
                            break;
                          case 6:
                            ref
                                .watch(customerListProvider)[event.rowIdx]
                                .driver_name = event.value;
                            await customerDatabase.editCustomer(
                                ref.watch(customerListProvider)[event.rowIdx]);
                            setState(() {});
                            break;
                          case 7:
                            ref
                                .watch(customerListProvider)[event.rowIdx]
                                .introducer = event.value;
                            await customerDatabase.editCustomer(
                                ref.watch(customerListProvider)[event.rowIdx]);
                            setState(() {});
                            break;
                        }
                      },
                      onRowChecked: handleOnRowChecked,
                      configuration: const PlutoGridConfiguration(
                        scrollbar: PlutoGridScrollbarConfig(
                          scrollbarThickness: 10,
                          scrollbarThicknessWhileDragging: 12,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible:
                        ref.watch(approvalCountProvider.notifier).state > 0,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 0,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.white,
                      ),
                      width: double.infinity,
                      child: Column(
                        children: [
                          SizedBox(
                            height: context.screenHeight * 0.07,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '全${ref.watch(approvalCountProvider.notifier).state}件選択されています',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: context.screenHeight * 0.07,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: context.screenWidth * 0.12,
                                  height: context.screenHeight * 0.05,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.blueAccent.withOpacity(0.8),
                                    ),
                                    onPressed: () async {
                                      List<String> nonBase = [];
                                      for (var element
                                          in stateManager.checkedRows) {
                                        if (ref
                                                .read(customerListProvider)[
                                                    element.sortIdx]
                                                .base
                                                .length ==
                                            0) {
                                          nonBase.add(ref
                                              .read(customerListProvider)[
                                                  element.sortIdx]
                                              .name);
                                        } else {
                                          ref
                                              .read(customerListProvider)[
                                                  element.sortIdx]
                                              .approval = true;
                                          await customerDatabase.editCustomer(
                                              ref.read(customerListProvider)[
                                                  element.sortIdx]);
                                        }
                                      }
                                      stateManager.checkedRows.forEach(
                                        (element) {
                                          element.setChecked(false);
                                        },
                                      );
                                      if (nonBase.isNotEmpty) {
                                        String noBase = nonBase
                                            .map<String>((value) => value)
                                            .join(',');
                                        PopupAlert.alert(context,
                                            '${noBase}\n は拠点が空白のため承認をスキップしました。',
                                            (context) {
                                          Navigator.of(context).pop();
                                        });
                                      }
                                      setState(() {
                                        ref
                                            .read(
                                                approvalCountProvider.notifier)
                                            .state = 0;
                                      });
                                      ref
                                          .watch(customerListProvider.notifier)
                                          .clearList();
                                      await customerDatabase
                                          .getallCustomers(ref);
                                    },
                                    child: const Text('承認する'),
                                  ),
                                ),
                                SizedBox(
                                  width: context.screenHeight * 0.05,
                                ),
                                Container(
                                  width: context.screenWidth * 0.12,
                                  height: context.screenHeight * 0.05,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.grey.withOpacity(0.8),
                                    ),
                                    onPressed: () {
                                      stateManager.checkedRows.forEach(
                                        (element) {
                                          element.setChecked(false);
                                        },
                                      );
                                      setState(() {
                                        ref
                                            .watch(
                                                approvalCountProvider.notifier)
                                            .state = 0;
                                      });
                                    },
                                    child: const Text('キャンセル'),
                                  ),
                                ),
                                SizedBox(
                                  width: context.screenHeight * 0.1,
                                ),
                                Container(
                                  width: context.screenWidth * 0.12,
                                  height: context.screenHeight * 0.05,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.pink.withOpacity(0.8),
                                    ),
                                    onPressed: () async {
                                      for (var element
                                          in stateManager.checkedRows) {
                                        customerDatabase.removeCustomers(ref
                                            .read(customerListProvider)[
                                                element.sortIdx]
                                            .uid);
                                      }
                                      stateManager
                                          .removeRows(stateManager.checkedRows);
                                      stateManager.checkedRows.forEach(
                                        (element) {
                                          element.setChecked(false);
                                        },
                                      );
                                      setState(() {
                                        ref
                                            .watch(
                                                approvalCountProvider.notifier)
                                            .state = 0;
                                      });
                                    },
                                    child: const Text('ユーザー削除'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: context.screenHeight * 0.01,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
            child: const Icon(Icons.sync),
            backgroundColor: Colors.blueAccent.withOpacity(0.8),
            foregroundColor: Colors.white,
            label: '更新',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () async {
              ref.read(customerListProvider.notifier).clearList();
              await customerDatabase.getallCustomers(ref);
            },
          ),
          if (ref.watch(loginUserProvider).superAdimnFig)
            if (mode.isNormal == true)
              SpeedDialChild(
                child: const Icon(Icons.edit),
                backgroundColor: const Color.fromARGB(255, 165, 11, 231),
                foregroundColor: Colors.white,
                label: '読取モード',
                labelStyle: const TextStyle(fontSize: 18.0),
                onTap: () {
                  setState(() {
                    mode = PlutoGridMode.readOnly;

                    headerText = "読取専用";
                  });
                },
              ),
          if (mode.isReadOnly == true)
            SpeedDialChild(
              child: const Icon(Icons.edit),
              backgroundColor: const Color.fromARGB(255, 165, 11, 231),
              foregroundColor: Colors.white,
              label: '編集モード',
              labelStyle: const TextStyle(fontSize: 18.0),
              onTap: () {
                setState(() {
                  mode = PlutoGridMode.normal;
                  headerText = "編集";
                });
              },
            ),
        ],
      ),
    );
  }
}
