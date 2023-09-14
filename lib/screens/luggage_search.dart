import 'package:async/async.dart';
import 'package:delivery_control_web/common/popup.dart';
import 'package:delivery_control_web/exSize.dart';
import 'package:delivery_control_web/models/customer.dart';
import 'package:delivery_control_web/models/item.dart';
import 'package:delivery_control_web/models/plan.dart';
import 'package:delivery_control_web/models/status.dart';
import 'package:delivery_control_web/models/loginUser.dart';
import 'package:delivery_control_web/providers/item_database_provider.dart';
import 'package:delivery_control_web/providers/page_set_provider.dart';
import 'package:delivery_control_web/providers/plan_database_provider.dart';
import 'package:delivery_control_web/screens/luggage_import.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:barcode/barcode.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:excel/excel.dart' as xlsio;

DateFormat outputFormat = DateFormat('yyyy/MM/dd');
DateFormat excelDateFormat = DateFormat('MM/dd/yyyy');

class SearchLuggages extends ConsumerStatefulWidget {
  final bool arrivalFlg;

  const SearchLuggages(this.arrivalFlg, {super.key});

  @override
  ConsumerState<SearchLuggages> createState() => _SearchLuggages();
}

class _SearchLuggages extends ConsumerState<SearchLuggages> {
  late Future<int> result;
  ItemDatabase itemDatabase = ItemDatabase();
  final AsyncMemoizer memoizer = AsyncMemoizer();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _usercontroller = TextEditingController();
  String? selectedUser;
  String? selectStatus;
  bool selectedFilter = false;
  bool onsort = false;
  List<String> filterKinds = ["JAN", "ASIN", "商品名", "FNSKU", "JAN違い"];
  String filterKind = "JAN";
  bool isLoading = false;
  final GlobalKey _one = GlobalKey();
  xlsio.Excel? excel;
  late List<AmazonItem>? dataList;

  bool _isAscending = true;
  PlanDatabase planDatabase = PlanDatabase();
  String filePath = "assets/";

  final fileName = "ManifestFileUpload_Template_IncludeExpirationDate_MPL";
  final fileExtension = ".xlsx";
  int currentSortColumn = 0;
  late String fullFilePath;

  bool openRow = false;
  int minTable = 0;
  int maxTable = 20;
  late int maxDataTable;
  List<String> notDeteleStatus = ["未入力", "要確認", "入荷待ち"];

  Future<List<AmazonItem>> filter() {
    dataList = ref.read(itemListProvider);
    if (ref.read(pageChangeProvider)) {
      minTable = 0;
      maxTable = 20;

      selectedUser = null;
      _controller.text = "";
      selectStatus = null;
      selectedFilter = false;
    }
    if (ref.read(itemFlgProvider) != 10) {
      switch (ref.read(itemFlgProvider.notifier).state) {
        case 0:
          dataList = ref.read(itemListProvider);
          break;
        case 1:
          dataList = ref
              .read(itemListProvider)
              .where((element) => element.status == "入荷待ち")
              .toList();

          selectStatus = "入荷待ち";
          break;
        case 2:
          dataList = ref
              .read(itemListProvider)
              .where((element) => element.status == "未入力")
              .toList();
          break;
        case 3:
          dataList = ref
              .read(itemListProvider)
              .where((element) =>
                  element.status == "入荷待ち" || element.status == "未入力")
              .toList();
          break;
        case 4:
          dataList = ref
              .read(itemListProvider)
              .where((element) =>
                  element.status == "入荷済み" ||
                  element.status == "プラン作成中" ||
                  element.status == "発送準備中")
              .toList();
          break;
        case 5:
          dataList = ref
              .read(itemListProvider)
              .where((element) => element.status == "発送完了")
              .toList();
          break;
        case 6:
          dataList = ref
              .read(itemListProvider)
              .where((element) => element.status == "要確認")
              .toList();
          break;
        case 7:
          dataList = ref
              .read(itemListProvider)
              .where((element) =>
                  element.status == "入荷待ち" || element.status == "未入力")
              .toList();
          dataList = dataList!
              .where((element) => element.createdAt
                  .add(const Duration(days: 21))
                  .isBefore(DateTime.now()))
              .toList();
          break;
        case 8:
          dataList = ref
              .read(itemListProvider)
              .where((element) =>
                  element.status == "入荷済み" ||
                  element.status == "プラン作成中" ||
                  element.status == "発送準備中")
              .toList();
          dataList = dataList!
              .where((element) =>
                  element.arrivedDate != null &&
                  element.arrivedDate!
                      .add(const Duration(days: 5))
                      .isBefore(DateTime.now()))
              .toList();
          break;

        case 9:
          dataList = ref
              .read(itemListProvider)
              .where((element) => element.status == "入荷済み")
              .toList();
        default:
          dataList = ref.read(itemListProvider);
          break;
      }

      // dataList = ref.watch(itemListProvider);
    } else {
      dataList = ref.read(filterItemListProvider);
    }

    if (selectStatus != null && dataList!.isNotEmpty) {
      dataList =
          dataList!.where((element) => element.status == selectStatus).toList();
    }

    if (selectedUser != null) {
      dataList = dataList!
          .where((element) => element.userName.contains(selectedUser!))
          .toList();
    }

    if (filterKind == "ASIN" &&
        _controller.text != "" &&
        dataList!.isNotEmpty) {
      dataList = dataList!
          .where((element) => element.asin.contains(_controller.text))
          .toList();
    }

    if (filterKind == "JAN" && _controller.text != "" && dataList!.isNotEmpty) {
      List<AmazonItem> tmp = [];
      for (AmazonItem amazonItem in dataList!) {
        for (var item in amazonItem.itemList) {
          if (item.janCode.toString().contains(_controller.text)) {
            if (!tmp.contains(amazonItem)) {
              tmp.add(amazonItem);
            }
          }
        }
      }
      dataList = tmp;
    }

    if (filterKind == "商品名" && _controller.text != "" && dataList!.isNotEmpty) {
      dataList = dataList!
          .where((element) => element.amazonItemName.contains(_controller.text))
          .toList();
    }
    if (filterKind == "FNSKU" &&
        _controller.text != "" &&
        dataList!.isNotEmpty) {
      dataList = dataList!
          .where((element) => element.fnskuCode.contains(_controller.text))
          .toList();
    }

    if (filterKind == "JAN違い" && dataList!.isNotEmpty) {
      dataList = dataList!.where((element) => element.editJanFlg).toList();
    }

    if (selectedFilter) {
      dataList = dataList!.where((element) => element.isSelected).toList();
    }
    maxDataTable = dataList!.length;
    if (maxTable < 20) {
      maxTable = 20;
    }
    if (maxTable > dataList!.length - 1) {
      maxTable = dataList!.length;
    }

    if (_isAscending && onsort) {
      dataList!.sort(((a, b) {
        return a.itemList[0].janCode.compareTo(b.itemList[0].janCode);
      }));
      onsort = false;
    } else if (!_isAscending && onsort) {
      dataList!.sort(((a, b) {
        return b.itemList[0].janCode.compareTo(a.itemList[0].janCode);
      }));
      onsort = false;
    }

    dataList = dataList!.getRange(minTable, maxTable).toList();
    return Future.value(dataList);
  }

  Future<void> update() async {
    setState(() {
      isLoading = true;
    });
    ref.read(itemListProvider.notifier).clearList();
    await itemDatabase.getallItems(ref);
    filterReset();
    // await filter();
    setState(() {
      isLoading = false;
    });
  }

  Widget filterUserPull() {
    return Center(
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'ユーザーから絞り込む',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).hintColor,
            ),
          ),
          items: ref.watch(loginUserProvider).adimnFig
              ? <DropdownMenuItem<String>>[
                  const DropdownMenuItem(
                    value: "開発者",
                    child: Text(
                      "開発者",
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ...ref
                      .watch(customerListProvider)
                      .map<DropdownMenuItem<String>>(
                          (Customer customer) => DropdownMenuItem(
                                value: customer.name,
                                child: Text(
                                  customer.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ))
                      .toList()
                ]
              : ref
                  .watch(customerListProvider)
                  .map<DropdownMenuItem<String>>(
                      (Customer customer) => DropdownMenuItem(
                            value: customer.name,
                            child: Text(
                              customer.name,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ))
                  .toList(),
          value: selectedUser,
          onChanged: (value) {
            setState(() {
              minTable = 0;
              maxTable = 20;
              selectedUser = value as String;
            });
          },
          buttonStyleData: const ButtonStyleData(
            height: 40,
            width: 200,
          ),
          dropdownStyleData: const DropdownStyleData(
            maxHeight: 200,
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
          ),
          dropdownSearchData: DropdownSearchData(
            searchController: _usercontroller,
            searchInnerWidgetHeight: 50,
            searchInnerWidget: Container(
              height: 50,
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 4,
                right: 8,
                left: 8,
              ),
              child: TextFormField(
                expands: true,
                maxLines: null,
                controller: _usercontroller,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  hintText: 'ユーザーを検索',
                  hintStyle: const TextStyle(fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            searchMatchFn: (item, searchValue) {
              return (item.value.toString().contains(searchValue));
            },
          ),
          //This to clear the search value when you close the menu
          onMenuStateChange: (isOpen) {
            if (!isOpen) {
              _usercontroller.clear();
            }
          },
        ),
      ),
    );
  }

  Widget filterStatusPull() {
    return Center(
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'ステータスから絞り込む',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).hintColor,
            ),
          ),
          items: Status.status
              .map<DropdownMenuItem<String>>((value) => DropdownMenuItem(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ))
              .toList(),
          value: selectStatus,
          onChanged: (value) async {
            setState(() {
              minTable = 0;
              maxTable = 20;
              selectStatus = value as String;
            });
          },
          buttonStyleData: const ButtonStyleData(
            height: 40,
            width: 200,
          ),
          dropdownStyleData: const DropdownStyleData(
            maxHeight: 200,
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
          ),
        ),
      ),
    );
  }

  Widget filterKindsPull() {
    return Center(
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            '検索種別を選択',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).hintColor,
            ),
          ),
          items: filterKinds
              .map<DropdownMenuItem<String>>((value) => DropdownMenuItem(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ))
              .toList(),
          value: filterKind,
          onChanged: (value) async {
            setState(() {
              filterKind = value as String;
            });
          },
          buttonStyleData: const ButtonStyleData(
            height: 40,
            width: 200,
          ),
          dropdownStyleData: const DropdownStyleData(
            maxHeight: 200,
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
          ),
        ),
      ),
    );
  }

  void filterReset() {
    setState(() {
      minTable = 0;
      maxTable = 20;
      ref.read(itemFlgProvider.notifier).state = 0;
      ref.read(filterItemListProvider.notifier).state = [];
      selectedUser = null;
      _controller.text = "";
      selectStatus = null;
      selectedFilter = false;
    });
  }

  Widget header() {
    return BarcodeKeyboardListener(
      bufferDuration: const Duration(milliseconds: 200),
      onBarcodeScanned: (value) async {
        _controller.text = value.toUpperCase();
        setState(() {});
      },
      child: SizedBox(
        height: context.screenHeight * 0.15,
        child: Column(
          children: [
            SizedBox(height: context.screenHeight * 0.01),
            SizedBox(
              height: context.screenHeight * 0.07,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: context.screenWidth * 0.1,
                  ),
                  if (ref.watch(loginUserProvider).adimnFig)
                    SizedBox(
                        width: context.screenWidth * 0.15,
                        child: filterUserPull()),
                  SizedBox(
                      width: context.screenWidth * 0.15,
                      child: filterStatusPull()),
                  if (ref.watch(loginUserProvider).adimnFig)
                    SizedBox(
                        width: context.screenWidth * 0.1,
                        child: ElevatedButton(
                            child: const Center(child: Text("チェック済み")),
                            onPressed: () {
                              setState(() {
                                selectedFilter = true;
                              });
                              filter();
                            })),
                  SizedBox(
                      width: context.screenWidth * 0.12,
                      child: TextButton(
                        onPressed: () {
                          filterReset();
                        },
                        child: const Center(child: Text("フィルターを解除")),
                      )),
                  SizedBox(
                    width: context.screenWidth * 0.1,
                  ),
                ],
              ),
            ),
            Expanded(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  width: context.screenWidth * 0.2,
                  child: TextField(
                    inputFormatters: filterKind == "JAN"
                        ? [FilteringTextInputFormatter.allow(RegExp('[0-9]'))]
                        : null,
                    controller: _controller,
                    onChanged: (newText) {
                      minTable = 0;
                      maxTable = 20;
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: "$filterKindで検索",
                      suffixIcon: _controller.text.isEmpty
                          ? const Icon(Icons.search)
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _controller.clear();
                                });
                              },
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  width: context.screenWidth * 0.06,
                ),
                filterKindsPull(),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void errorMethod(context) {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    Future(() async {
      try {
        fullFilePath = "$filePath$fileName$fileExtension";
        ByteData data = await rootBundle.load(fullFilePath);
        var bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        excel = xlsio.Excel.decodeBytes(bytes);
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String userFileName;

    return ShowCaseWidget(
      builder: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: widget.arrivalFlg ? const Text('入荷一覧') : const Text('商品一覧'),
          ),
          body: FutureBuilder(
            future: filter().whenComplete(
                () => ref.read(pageChangeProvider.notifier).state = false),
            builder: (context, snapshot) {
              // if (ref.read(itemListProvider).isEmpty) {
              //   return const Center(
              //     child: CircularProgressIndicator(),
              //   );
              // }
              if (!snapshot.hasData || isLoading) {
                return Column(
                  children: [
                    header(),
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    SizedBox(
                      height: context.screenHeight * 0.1,
                    )
                  ],
                );
              }
              if (dataList!.isEmpty || ref.watch(itemListProvider).isEmpty) {
                return Column(
                  children: [
                    header(),
                    const Expanded(
                      child: Text("商品が見つかりませんでした"),
                    ),
                    SizedBox(
                      height: context.screenHeight * 0.1,
                    )
                  ],
                );
              }

              return Stack(children: [
                Column(children: [
                  SizedBox(child: header()),
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: CustomScrollBehavior(),
                      child: SingleChildScrollView(
                        // controller: controller,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          height: context.screenHeight,
                          width: context.screenWidth,
                          child: DataTable2(
                            // horizontalScrollController: controller,
                            showCheckboxColumn: false,
                            sortColumnIndex: currentSortColumn,
                            sortAscending: _isAscending,
                            columnSpacing: 10,
                            headingTextStyle: const TextStyle(
                                fontSize: 10, overflow: TextOverflow.clip),
                            dataTextStyle: const TextStyle(
                              fontSize: 10,
                            ),
                            columns: [
                              DataColumn2(
                                  label: Center(
                                      child: Checkbox(
                                          value: dataList!
                                              .where((element) =>
                                                  element.isSelected)
                                              .isNotEmpty,
                                          onChanged: (bool? value) {
                                            for (var element in dataList!) {
                                              element.isSelected = value!;
                                            }
                                            setState(() {});
                                          })),
                                  fixedWidth: 30),
                              const DataColumn2(
                                  label: Center(child: Text("リンク")),
                                  fixedWidth: 50),
                              const DataColumn2(
                                  label: Center(child: Text("入力日")),
                                  fixedWidth: 100),
                              // const DataColumn2(
                              //     label: Center(child: Text("到着予定日")),
                              //     fixedWidth: 100),
                              const DataColumn2(
                                label: Center(child: Text('商品名')),
                                size: ColumnSize.L,
                                fixedWidth: 500,
                              ),
                              DataColumn2(
                                label: const Center(child: Text('JAN')),
                                size: ColumnSize.L,
                                fixedWidth: 110,
                                onSort: (columnIndex, ascending) {
                                  currentSortColumn = columnIndex;
                                  if (_isAscending) {
                                    _isAscending = false;
                                  } else {
                                    _isAscending = true;
                                  }
                                  onsort = true;

                                  setState(() {});
                                },
                              ),
                              DataColumn2(
                                  size: ColumnSize.L,
                                  fixedWidth: 160,
                                  label: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (!openRow)
                                        SizedBox(
                                          width: context.screenWidth * 0.04,
                                        ),
                                      const SizedBox(
                                          child: Center(child: Text("ASIN"))),
                                      if (!openRow)
                                        SizedBox(
                                          child: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                openRow = true;
                                              });
                                            },
                                            child: const Center(
                                                child: Text("SKU\nFNSKU\nを表示",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                    ))),
                                          ),
                                        )
                                    ],
                                  )),
                              if (openRow)
                                const DataColumn2(
                                    size: ColumnSize.L,
                                    label: Center(child: Text("SKU"))),
                              if (openRow)
                                DataColumn2(
                                    size: ColumnSize.L,
                                    fixedWidth: 170,
                                    label: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: context.screenWidth * 0.04,
                                        ),
                                        const Center(child: Text("FNSKU")),
                                        SizedBox(
                                          child: TextButton(
                                            onPressed: () {
                                              setState(() {
                                                openRow = false;
                                              });
                                            },
                                            child: const Center(
                                                child: Text("SKU\nFNSKU\nを非表示",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                    ))),
                                          ),
                                        )
                                      ],
                                    )),
                              const DataColumn2(
                                label: Center(child: Text("セット数")),
                                numeric: true,
                                size: ColumnSize.S,
                              ),
                              const DataColumn2(
                                  size: ColumnSize.S,
                                  label: Center(
                                      child: Text(
                                    "予定出荷単位数",
                                    overflow: TextOverflow.clip,
                                  )),
                                  numeric: true),
                              const DataColumn2(
                                label: Center(child: Text("予定入荷総数")),
                                numeric: true,
                                size: ColumnSize.S,
                              ),
                              const DataColumn2(
                                  label: Center(child: Text("実入荷総数")),
                                  size: ColumnSize.S,
                                  numeric: true),
                              // const DataColumn2(
                              //     size: ColumnSize.L,
                              //     label: Center(child: Text("賞味期限"))),
                              if (ref.watch(loginUserProvider).adimnFig)
                                const DataColumn2(
                                    label: Center(child: Text("ユーザー"))),
                              const DataColumn2(
                                  label: Center(child: Text("ステータス"))),

                              const DataColumn2(
                                  label: Center(child: Text("")),
                                  size: ColumnSize.S),
                            ],
                            rows: List<DataRow>.generate(
                              dataList!.length,
                              (index) => DataRow(
                                // selected: dataList![index].isSelected,
                                onSelectChanged: (onPress) async {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20))),
                                    context: context,
                                    // showModalBottomSheetで表示される中身
                                    builder: (context) =>
                                        ViewComments(dataList![index], false),
                                  );
                                },
                                cells: [
                                  DataCell(
                                    onTap: () async {
                                      // setState(() {
                                      //   dataList![index].isSelected =
                                      //       !dataList![index].isSelected;
                                      // });
                                    },
                                    SizedBox(
                                      child: Center(
                                        child: Checkbox(
                                          value: dataList![index].isSelected,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              dataList![index].isSelected =
                                                  value!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                      const Center(
                                        child: Icon(Icons.explore),
                                      ), onTap: () async {
                                    final Uri url = Uri.parse(
                                        'https://www.amazon.co.jp/dp/${dataList![index].asin}');
                                    if (!await launchUrl(url)) {
                                      throw Exception('Could not launch $url');
                                    }
                                  }),
                                  DataCell(Center(
                                    child: Text(outputFormat
                                        .format(dataList![index].createdAt)),
                                  )),
                                  // DataCell(dataList![index].arriveDate == null
                                  //     ? const Text("")
                                  //     : Center(
                                  //         child: Text(outputFormat.format(
                                  //             dataList![index].arriveDate!)),
                                  //       )),
                                  DataCell(SizedBox(
                                    child: Text(
                                      dataList![index].amazonItemName,
                                      textAlign: TextAlign.left,
                                    ),
                                  )),
                                  DataCell(
                                    Center(
                                        child: Text(dataList![index]
                                            .itemList[0]
                                            .janCode
                                            .toString())),
                                  ),
                                  DataCell(Center(
                                      child: Text(dataList![index].asin))),
                                  if (openRow)
                                    DataCell(Center(
                                        child: Text(dataList![index].sku))),
                                  if (openRow)
                                    DataCell(Center(
                                        child:
                                            Text(dataList![index].fnskuCode))),
                                  DataCell(
                                    Center(
                                        child: Text(dataList![index]
                                            .setNum
                                            .toString())),
                                  ),
                                  DataCell(Center(
                                      child: Text(dataList![index]
                                          .shippingNum
                                          .toString()))),
                                  DataCell(
                                    Center(
                                        child: Text(dataList![index]
                                            .arriveNum
                                            .toString())),
                                  ),
                                  DataCell(
                                    Center(
                                        child: Text(dataList![index]
                                            .sumNum
                                            .toString())),
                                  ),
                                  // DataCell(dataList![index].expiryDate == null
                                  //     ? const Text("")
                                  //     : Center(
                                  //         child: Text(outputFormat.format(
                                  //             dataList![index].expiryDate!)),
                                  //       )),
                                  if (ref.watch(loginUserProvider).adimnFig)
                                    DataCell(Center(
                                        child:
                                            Text(dataList![index].userName))),
                                  DataCell(Center(
                                      child: Text(
                                          dataList![index].status.toString()))),

                                  DataCell(
                                    Center(
                                      child: !notDeteleStatus
                                              .contains(dataList![index].status)
                                          ? IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () async {
                                                itemDatabase
                                                    .removeItem(
                                                        dataList![index])
                                                    .then(
                                                  (value) async {
                                                    ref
                                                        .watch(itemListProvider)
                                                        .removeWhere(
                                                            (element) =>
                                                                element
                                                                    .itemId ==
                                                                dataList![index]
                                                                    .itemId);
                                                    setState(() {});
                                                  },
                                                );
                                              },
                                            )
                                          : const Text(""),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (ref.watch(pageNumProvider) == 6)
                    Visibility(
                      visible: ref
                          .watch(itemListProvider)
                          .where((element) => element.isSelected)
                          .toList()
                          .isNotEmpty,
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
                        // height: context.screenHeight * 0.1,
                        child: Column(
                          children: [
                            SizedBox(
                              height: context.screenHeight * 0.05,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'チェックがついた${ref.watch(itemListProvider).where((element) => element.isSelected).toList().length}個の商品でプランを作成します',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: context.screenHeight * 0.05,
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
                                        if (excel != null) {
                                          print("ダウンロード成功");
                                          List<String> selectUserList =
                                              List.generate(
                                                  dataList!
                                                      .where((element) =>
                                                          element.isSelected)
                                                      .toList()
                                                      .length,
                                                  (index) => dataList!
                                                      .where((element) =>
                                                          element.isSelected)
                                                      .toList()[index]
                                                      .userName);

                                          selectUserList =
                                              selectUserList.toSet().toList();

                                          for (var user in selectUserList) {
                                            List<AmazonItem> selectItem =
                                                dataList!
                                                    .where((element) =>
                                                        element.userName ==
                                                            user &&
                                                        element.isSelected)
                                                    .toList();

                                            xlsio.Sheet sheetObject = excel![
                                                "Create workflow – template"];

                                            try {
                                              for (int i = 0;
                                                  i < selectItem.length;
                                                  i++) {
                                                var cellSku = sheetObject.cell(
                                                    xlsio.CellIndex
                                                        .indexByString(
                                                            'A${i + 9}'));
                                                cellSku.value =
                                                    selectItem[i].sku;
                                                var cellQua = sheetObject.cell(
                                                    xlsio.CellIndex
                                                        .indexByString(
                                                            'B${i + 9}'));
                                                cellQua.value =
                                                    selectItem[i].shippingNum;
                                                var cellDate = sheetObject.cell(
                                                    xlsio.CellIndex
                                                        .indexByString(
                                                            'E${i + 9}'));
                                                cellDate.value = selectItem[i]
                                                            .expiryDate ==
                                                        null
                                                    ? ''
                                                    : excelDateFormat.format(
                                                        selectItem[i]
                                                            .expiryDate!);
                                                selectItem[i].status = 'プラン作成中';
                                                await itemDatabase
                                                    .editItem(selectItem[i]);
                                              }
                                              userFileName = user;
                                              excel!.save(
                                                  fileName:
                                                      "$fileName[$userFileName]$fileExtension");

                                              List<String> itemIds =
                                                  List.generate(
                                                      selectItem.length,
                                                      (index) =>
                                                          selectItem[index]
                                                              .itemId);
                                              planDatabase.addNewPlan(
                                                Plan(
                                                  boxHeight: null,
                                                  boxHorizontal: null,
                                                  boxNum: null,
                                                  boxWeight: null,
                                                  boxWidth: null,
                                                  itemIds: itemIds,
                                                  name: '',
                                                  mailStatus: '未送信',
                                                  planId: '',
                                                  selected: false,
                                                  shippingDate: null,
                                                  status: '未依頼',
                                                  uid: ref
                                                      .watch(loginUserProvider)
                                                      .uid,
                                                  note: "",
                                                  infoNum: null,
                                                  shippingWay: null,
                                                ),
                                              );
                                            } catch (e) {
                                              print(e);
                                              PopupAlert.alert(
                                                  context,
                                                  'Excelに書き込めませんでした。\n 再作成してください。',
                                                  errorMethod);
                                            }
                                          }

                                          setState(() {
                                            ref
                                                .watch(itemListProvider)
                                                .where((AmazonItem item) =>
                                                    item.isSelected)
                                                .forEach(
                                              (element) {
                                                element.isSelected = false;
                                              },
                                            );
                                          });
                                        } else {
                                          print("失敗");
                                        }
                                      },
                                      child: const Text('プラン作成'),
                                    ),
                                  ),
                                  SizedBox(width: context.screenHeight * 0.05),
                                  Container(
                                    width: context.screenWidth * 0.12,
                                    height: context.screenHeight * 0.05,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.grey.withOpacity(0.8),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          ref
                                              .watch(itemListProvider)
                                              .where((AmazonItem item) =>
                                                  item.isSelected)
                                              .forEach(
                                            (element) {
                                              element.isSelected = false;
                                            },
                                          );
                                        });
                                      },
                                      child: const Text('キャンセル'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: context.screenHeight * 0.01,
                            )
                          ],
                        ),
                      ),
                    ),
                  SizedBox(
                    height: context.screenHeight * 0.05,
                    child: RichText(
                        text: TextSpan(children: [
                      if (minTable + 1 != 1)
                        TextSpan(
                            text: '<    ',
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  minTable -= 20;
                                  maxTable -= 20;
                                });
                              }),
                      TextSpan(
                        text: (minTable + 1).toString(),
                      ),
                      const TextSpan(
                        text: 'to',
                      ),
                      if (minTable < maxTable)
                        TextSpan(
                          text: (maxTable).toString(),
                        ),
                      TextSpan(
                        text: '  of${maxDataTable.toString()}',
                      ),
                      if (maxDataTable != maxTable)
                        TextSpan(
                            text: '    >',
                            style: const TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                setState(() {
                                  minTable += 20;
                                  maxTable += 20;
                                });
                              }),
                    ])),
                  ),
                ]),
                if (ref.watch(pageNumProvider) != 6)
                  Visibility(
                    visible: dataList!
                        .where((element) => element.isSelected == true)
                        .toList()
                        .isNotEmpty,
                    child: Align(
                      alignment: const Alignment(0.5, 1),
                      child: Row(children: [
                        SizedBox(
                          height: context.screenHeight * 0.15,
                          width: context.screenWidth * 0.1,
                        ),
                        Container(
                            height: context.screenHeight * 0.15,
                            width: context.screenWidth * 0.2,
                            padding: const EdgeInsets.only(bottom: 50, top: 5),
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            child: ElevatedButton(
                              child: const Text("チェック済みの商品のステータスを進める"),
                              onPressed: () async {
                                List tmpList = dataList!
                                    .where((element) => element.isSelected)
                                    .toList();
                                for (AmazonItem tmpItem in tmpList) {
                                  if (tmpItem.status == "未入力") {
                                    tmpItem.status = "入荷待ち";
                                  } else if (tmpItem.status == "入荷待ち") {
                                    tmpItem.shippingNum =
                                        tmpItem.actualShippingNum;
                                    tmpItem.status = "入荷済み";
                                  } else if (tmpItem.status == "入荷済み") {
                                    tmpItem.status = "プラン作成中";
                                  } else if (tmpItem.status == "プラン作成中") {
                                    tmpItem.status = "発送準備中";
                                  } else if (tmpItem.status == "発送準備中") {
                                    tmpItem.status = "発送完了";
                                  }
                                  tmpItem.isSelected = false;
                                  await itemDatabase.editItem(tmpItem);
                                }
                                setState(() {});
                              },
                            )),
                        SizedBox(
                          height: context.screenHeight * 0.15,
                          width: context.screenWidth * 0.1,
                        ),
                        if (ref.watch(loginUserProvider).adimnFig)
                          Container(
                              height: context.screenHeight * 0.15,
                              width: context.screenWidth * 0.15,
                              padding:
                                  const EdgeInsets.only(bottom: 50, top: 5),
                              decoration: const BoxDecoration(
                                  color: Colors.transparent),
                              child: ElevatedButton(
                                child: const Text("まとめてラベル印刷"),
                                onPressed: () async {
                                  List tmpList = dataList!
                                      .where((element) => element.isSelected)
                                      .toList();
                                  final pdf = pw.Document();
                                  for (AmazonItem tmpItem in tmpList) {
                                    final font = await PdfGoogleFonts
                                        .shipporiMinchoBold();
                                    // final svgImage = pw.SvgImage(svg: svg);

                                    for (var i = 0;
                                        i < tmpItem.actualShippingNum;
                                        i++) {
                                      final basePage = pw.Page(
                                          pageTheme: pw.PageTheme(
                                            orientation:
                                                pw.PageOrientation.landscape,
                                            theme: pw.ThemeData.withFont(
                                                base: font),
                                            pageFormat: const PdfPageFormat(
                                                50 * PdfPageFormat.mm,
                                                30 * PdfPageFormat.mm),
                                          ),
                                          build: (pw.Context context) {
                                            return pw.Column(
                                              mainAxisAlignment:
                                                  pw.MainAxisAlignment.center,
                                              // alignment: pw.Alignment.topCenter,
                                              children: [
                                                pw.BarcodeWidget(
                                                    barcode: Barcode.code128(),
                                                    data: tmpItem.fnskuCode,
                                                    width:
                                                        40 * PdfPageFormat.mm,
                                                    height:
                                                        15 * PdfPageFormat.mm),
                                                pw.SizedBox(
                                                  width: 40 * PdfPageFormat.mm,
                                                  height: 10 * PdfPageFormat.mm,
                                                  child: pw.Text(
                                                      tmpItem.amazonItemName,
                                                      style: pw.TextStyle(
                                                          fontSize: 8,
                                                          font: font)),
                                                ),
                                              ],
                                            );
                                          });
                                      pdf.addPage(basePage); // Page
                                    }
                                  }
                                  await Printing.layoutPdf(
                                      onLayout: (_) => pdf.save());
                                  setState(() {});
                                },
                              )),
                        SizedBox(
                          height: context.screenHeight * 0.15,
                          width: context.screenWidth * 0.1,
                        ),
                        Container(
                            height: context.screenHeight * 0.15,
                            width: context.screenWidth * 0.15,
                            padding: const EdgeInsets.only(bottom: 50, top: 5),
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            child: ElevatedButton(
                              child: const Text("まとめて削除"),
                              onPressed: () async {
                                List tmpList = dataList!
                                    .where((element) => element.isSelected)
                                    .toList();
                                for (AmazonItem tmpItem in tmpList) {
                                  await itemDatabase.removeItem(tmpItem);
                                  ref.watch(itemListProvider).removeWhere(
                                      (element) =>
                                          element.itemId == tmpItem.itemId);
                                }
                                setState(() {});
                              },
                            )),
                      ]),
                    ),
                  ),
              ]);
            },
          ),
          floatingActionButton: Showcase(
            description: "商品追加後は更新をかけてください。",
            key: _one,
            child: SpeedDial(
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
                    update();
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.add),
                  backgroundColor: const Color.fromARGB(255, 165, 11, 231),
                  foregroundColor: Colors.white,
                  label: '商品追加',
                  labelStyle: const TextStyle(fontSize: 18.0),
                  onTap: () async {
                    //   await register();
                    await showModalBottomSheet(
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20))),
                      context: context,
                      // showModalBottomSheetで表示される中身
                      // 空白を入れる！
                      builder: (context) => ViewComments(
                          AmazonItem(
                            shippeddate: null,
                            itemId: "",
                            uid: ref.watch(loginUserProvider).uid,
                            userName: ref.watch(loginUserProvider).adimnFig
                                ? ref.watch(customerListProvider).first.name
                                : ref.watch(loginUserProvider).name,
                            amazonItemName: "",
                            asin: "",
                            itemList: [
                              Item(
                                  itemName: "",
                                  janCode: 0,
                                  setNum: 1,
                                  shippingNum: 1,
                                  sumNum: 0,
                                  arriveNum: 1,
                                  actualShippingNum: 0,
                                  place: "",
                                  expiryDate: null)
                            ],
                            arriveDate: null,
                            createdAt: DateTime.now(),
                            shippingNum: 1,
                            actualShippingNum: 0,
                            base: ref.watch(loginUserProvider).base[0],
                            status: "入荷待ち",
                            sku: "",
                            fnskuCode: "",
                            arriveNum: 1,
                            sumNum: 0,
                            notes: [],
                            setNum: 1,
                            expiryDate: null,
                            isSelected: false,
                            arrivedDate: null,
                            stickerNum: 0,
                            destructionNum: 0,
                            returnNum: 0,
                            largeFlg: false,
                            editJanFlg: false,
                            addAdminFlg: ref.read(loginUserProvider).adimnFig,
                          ),
                          true),
                    );
                    if (!mounted) return;
                    ShowCaseWidget.of(context).startShowCase([_one]);
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.add),
                  backgroundColor: const Color.fromARGB(255, 165, 11, 231),
                  foregroundColor: Colors.white,
                  label: 'CSVからインポート',
                  labelStyle: const TextStyle(fontSize: 18.0),
                  onTap: () async {
                    await showModalBottomSheet(
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20))),
                        context: context,
                        // showModalBottomSheetで表示される中身
                        // 空白を入れる！
                        builder: (context) => const LuggageImport());
                    if (!mounted) return;
                    ShowCaseWidget.of(context).startShowCase([_one]);

                    //   await register();
                    // 空白を入れる！
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class ViewComments extends ConsumerStatefulWidget {
  final AmazonItem item;
  final bool addFlg;
  const ViewComments(this.item, this.addFlg, {super.key});

  @override
  ConsumerState<ViewComments> createState() => _ViewCommentsState();
}

class _ViewCommentsState extends ConsumerState<ViewComments> {
  late List<TextEditingController> dateController;

  late List<TextEditingController> textController;
  late List<bool> editedList;
  late List<String> statusController;
  late String selectBase;
  late String selectedUser;
  TextEditingController noteController = TextEditingController();
  Printer? selectedPrinter;
  final GlobalKey<State<StatefulWidget>> pickWidget = GlobalKey();
  bool isLoading = false;

  ItemDatabase itemDatabase = ItemDatabase();

  Future<void> datepickmethod(dateController) async {
    DateTime initDate = DateTime.now();
    try {
      initDate = DateFormat('yyyy/MM/dd').parse(dateController.text);
    } catch (_) {}

    // DatePickerを表示する
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(
        const Duration(days: 360),
      ),
    );

    // DatePickerで取得した日付を文字列に変換
    String? formatedDate;
    try {
      formatedDate = DateFormat('yyyy/MM/dd').format(picked!);
    } catch (_) {}
    if (formatedDate != null) {
      dateController.text = formatedDate;
    }
  }

  Widget subRowCell(TextEditingController controller, Function method,
      bool readOnly, bool edited) {
    // controller.selection =
    // TextSelection.collapsed(offset: controller.text.length);
    if (widget.addFlg) {
      edited = true;
    }
    return Container(
        child: TextField(
      maxLines: null,
      style: const TextStyle(fontSize: 12),
      textAlign: TextAlign.center,
      controller: controller,
      readOnly: readOnly,
      onChanged: (value) {
        // setState(() {
        method();

        setState(() {});
        // });
      },
      decoration: InputDecoration(
        fillColor: controller.text == ""
            ? Colors.pink.shade100
            : Colors.lightBlueAccent,
        filled: widget.addFlg
            ? controller.text == "" && !readOnly
            : !readOnly && edited,
        border: InputBorder.none,
      ),
    ));
  }

  Widget subRowCellForJan(TextEditingController controller, Function method,
      bool readOnly, bool edited) {
    // controller.selection =
    // TextSelection.collapsed(offset: controller.text.length);
    if (widget.addFlg) {
      edited = true;
    }
    return Container(
        child: TextField(
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
      ],
      maxLines: null,
      style: const TextStyle(fontSize: 12),
      textAlign: TextAlign.center,
      controller: controller,
      readOnly: readOnly,
      onChanged: (value) {
        // setState(() {
        method();

        setState(() {});
        // });
      },
      decoration: InputDecoration(
        fillColor: controller.text == ""
            ? Colors.pink.shade100
            : Colors.lightBlueAccent,
        filled: widget.addFlg
            ? controller.text == "" && !readOnly
            : !readOnly && edited,
        border: InputBorder.none,
      ),
    ));
  }

  Widget subRowSumCell(TextEditingController controller, Function method,
      bool readOnly, bool edited) {
    // controller.selection =
    // TextSelection.collapsed(offset: controller.text.length);
    if (widget.addFlg) {
      edited = true;
    }
    return Container(
        child: TextField(
      maxLines: null,
      style: const TextStyle(fontSize: 12),
      textAlign: TextAlign.center,
      controller: controller,
      readOnly: readOnly,
      onChanged: (value) {
        // setState(() {
        method();

        setState(() {});
        // });
      },
      decoration: InputDecoration(
        fillColor: Colors.lightBlueAccent,
        filled: controller.text == "" ||
            controller.text == 0.toString() &&
                ref.watch(loginUserProvider).adimnFig,
        border: InputBorder.none,
      ),
    ));
  }

  Widget dateCell(TextEditingController dateController, method, bool readOnly) {
    return SizedBox(
      width: context.screenWidth * 0.4,
      child: TextField(
        controller: dateController,
        textInputAction: TextInputAction.next,
        enabled: true,
        readOnly: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '日付',
          // inputの端にカレンダーアイコンをつける
          suffixIcon: readOnly
              ? null
              : IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    await datepickmethod(dateController);
                    method();
                  }),
        ),
      ),
    );
  }

  Widget statusPullDown(stutus, method) {
    return SizedBox(
      width: context.screenWidth * 0.4,
      child: DropdownButton(
        underline: const SizedBox(),
        isExpanded: true,
        items: Status.status.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        value: stutus,
        onChanged: (value) {
          method(value);
        },
      ),
    );
  }

  Widget baseCell() {
    return Center(
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            '拠点',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).hintColor,
            ),
          ),
          items: ref
              .watch(loginUserProvider)
              .base
              .map<DropdownMenuItem<String>>((value) => DropdownMenuItem(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ))
              .toList(),
          value: selectBase,
          onChanged: (value) async {
            setState(() {
              selectBase = value as String;
              widget.item.base = selectBase;
            });
          },
          buttonStyleData: const ButtonStyleData(
            height: 40,
            width: 200,
          ),
          dropdownStyleData: const DropdownStyleData(
            maxHeight: 200,
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
          ),
        ),
      ),
    );
  }

  Widget userPull(usercontroller) {
    return Center(
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            'ユーザーから絞り込む',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).hintColor,
            ),
          ),
          items: <DropdownMenuItem<String>>[
            DropdownMenuItem(
              value: ref.watch(loginUserProvider).name,
              child: Text(
                ref.watch(loginUserProvider).name,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            ...ref
                .watch(customerListProvider)
                .map<DropdownMenuItem<String>>(
                    (Customer customer) => DropdownMenuItem(
                          value: customer.name,
                          child: Text(
                            customer.name,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ))
                .toList()
          ],
          value: selectedUser,
          onChanged: (value) {
            setState(() {
              selectedUser = value as String;
              widget.item.userName = selectedUser;
            });
          },
          buttonStyleData: const ButtonStyleData(
            height: 40,
            width: 200,
          ),
          dropdownStyleData: const DropdownStyleData(
            maxHeight: 200,
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
          ),
          dropdownSearchData: DropdownSearchData(
            searchController: usercontroller,
            searchInnerWidgetHeight: 50,
            searchInnerWidget: Container(
              height: 50,
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 4,
                right: 8,
                left: 8,
              ),
              child: TextFormField(
                expands: true,
                maxLines: null,
                controller: usercontroller,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  hintText: 'ユーザーを検索',
                  hintStyle: const TextStyle(fontSize: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            searchMatchFn: (item, searchValue) {
              return (item.value.toString().contains(searchValue));
            },
          ),
          //This to clear the search value when you close the menu
          onMenuStateChange: (isOpen) {
            if (!isOpen) {
              usercontroller.clear();
            }
          },
        ),
      ),
    );
  }

  void _init() {
    dateController = List.generate(
        3 + widget.item.itemList.length, (i) => TextEditingController());
    textController = List.generate(
        13 + (widget.item.itemList.length * 8), (i) => TextEditingController());
    editedList =
        List.generate(13 + (widget.item.itemList.length * 8), (i) => false);
    statusController = List.generate(4, (i) => "");

    dateController[0].text = widget.item.arrivedDate == null
        ? outputFormat.format(DateTime.now())
        : outputFormat.format(widget.item.arrivedDate!);

    dateController[1].text = widget.item.expiryDate == null
        ? ""
        : outputFormat.format(widget.item.expiryDate!);

    dateController[2].text = widget.item.arriveDate == null
        ? ""
        : outputFormat.format(widget.item.arriveDate!);

    textController[0].text = widget.item.amazonItemName;
    textController[1].text = widget.item.asin;
    textController[2].text = widget.item.sku;
    textController[3].text = widget.item.fnskuCode;
    // widget.item.arriveNum = widget.item.setNum * widget.item.shippingNum;
    textController[4].text = widget.item.setNum.toString();
    textController[5].text = widget.item.shippingNum.toString();
    textController[6].text = widget.item.arriveNum.toString();
    textController[7].text = widget.item.sumNum.toString();
    // textController[8].text = widget.item.userName;
    textController[9].text = widget.item.actualShippingNum.toString();
    textController[10].text = widget.item.stickerNum.toString();
    textController[11].text = widget.item.destructionNum.toString();
    textController[12].text = widget.item.returnNum.toString();
    statusController[0] = widget.item.status;
    selectBase = widget.item.base;
    selectedUser = widget.item.userName;
    for (var i = 0; i < widget.item.itemList.length; i++) {
      dateController[i + 3].text = widget.item.itemList[i].expiryDate == null
          ? ""
          : outputFormat.format(widget.item.itemList[i].expiryDate!);

      widget.item.itemList[i].arriveNum =
          widget.item.itemList[i].setNum * widget.item.itemList[i].shippingNum;
      // テキストを入れる
      textController[(i * 8) + 13].text = widget.item.itemList[i].janCode == 0
          ? ""
          : widget.item.itemList[i].janCode.toString();
      textController[(i * 8) + 14].text = widget.item.itemList[i].itemName;
      textController[(i * 8) + 15].text =
          widget.item.itemList[i].setNum.toString();
      textController[(i * 8) + 16].text =
          widget.item.itemList[i].shippingNum.toString();
      textController[(i * 8) + 17].text =
          widget.item.itemList[i].arriveNum.toString();
      textController[(i * 8) + 18].text = widget.item.itemList[i].sumNum == null
          ? ""
          : widget.item.itemList[i].sumNum.toString();
      textController[(i * 8) + 19].text = widget.item.itemList[i].place;
      textController[(i * 8) + 20].text =
          widget.item.itemList[i].actualShippingNum.toString();
    }
  }

  String buildBarcode(
    Barcode bc,
    String data, {
    String? filename,
    double? width,
    double? height,
    double? fontHeight,
  }) {
    /// Create the Barcode
    final svg = bc.toSvg(
      data,
      width: width ?? 0.8,
      height: height ?? 0.4,
      fontHeight: fontHeight,
    );

    // Save the image
    filename ??= bc.name.replaceAll(RegExp(r'\s'), '-').toLowerCase();
    return svg;
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, widget.item.isSelected);
        return Future.value(true);
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        height: context.screenHeight * 0.9,
        width: context.screenWidth,
        child: SingleChildScrollView(
          child: isLoading
              ? SizedBox(
                  height: context.screenHeight * 0.9,
                  child: const Center(child: CircularProgressIndicator()))
              : SizedBox(
                  child: Column(children: [
                    SizedBox(
                        height: context.screenHeight * 0.1,
                        child: SizedBox(
                          width: context.screenWidth,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: context.screenWidth * 0.3,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: context.screenWidth * 0.10,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              final Uri url = Uri.parse(
                                                  'https://www.amazon.co.jp/dp/${textController[1].text}');
                                              if (!await launchUrl(url)) {
                                                throw Exception(
                                                    'Could not launch $url');
                                              }
                                            },
                                            child: const Text("Amazonページ"),
                                          )),
                                      if (!widget.addFlg &&
                                          ref.watch(loginUserProvider).adimnFig)
                                        SizedBox(
                                          width: context.screenWidth * 0.1,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              setState(() {
                                                widget.item.editJanFlg = true;
                                              });
                                            },
                                            child: const Text("JAN更新"),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    width: context.screenWidth * 0.35,
                                    child: const Center(child: Text("商品概要"))),
                                SizedBox(
                                  width: context.screenWidth * 0.3,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (!widget.addFlg &&
                                          ref
                                              .watch(loginUserProvider)
                                              .adimnFig &&
                                          widget.item.status == "入荷待ち")
                                        SizedBox(
                                          width: context.screenWidth * 0.08,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                widget.item.status = "入荷済み";
                                                statusController[0] = "入荷済み";
                                              });
                                            },
                                            child: const Text(
                                              "入荷更新ST",
                                            ),
                                          ),
                                        ),
                                      SizedBox(
                                          width: context.screenWidth * 0.08,
                                          child: widget.addFlg
                                              ? ElevatedButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    await itemDatabase
                                                        .addNewItem(
                                                            widget.item);
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                    if (!mounted) return;
                                                    Navigator.pop(context,
                                                        widget.item.isSelected);
                                                  },
                                                  child: const Text("追加"),
                                                )
                                              : ElevatedButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      isLoading = true;
                                                    });

                                                    if (widget.item
                                                                .shippingNum ==
                                                            widget.item
                                                                .actualShippingNum ||
                                                        !ref
                                                            .watch(
                                                                loginUserProvider)
                                                            .adimnFig) {
                                                      await itemDatabase
                                                          .editItem(
                                                              widget.item);
                                                    } else {
                                                      await showDialog<void>(
                                                          context: context,
                                                          builder: (_) {
                                                            return YesNoDialog(
                                                                title: "アラート",
                                                                message:
                                                                    "予定出荷単位数と実出荷単位数が異なっています。\n入荷確定しますか",
                                                                onYesAction:
                                                                    () async {
                                                                  await itemDatabase
                                                                      .editItem(
                                                                          widget
                                                                              .item);
                                                                  if (!mounted) {
                                                                    return;
                                                                  }
                                                                  Navigator.pop(
                                                                      context);
                                                                });
                                                          });
                                                    }

                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                    if (!mounted) return;
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("更新"),
                                                )),
                                      if (!widget.addFlg &&
                                          ref.watch(loginUserProvider).adimnFig)
                                        SizedBox(
                                            width: context.screenWidth * 0.08,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                //     final svg = buildBarcode(
                                                //   Barcode.code128(),
                                                //   widget.item.fnskuCode,
                                                // );
                                                final font =
                                                    await PdfGoogleFonts
                                                        .shipporiMinchoBold();
                                                // final svgImage = pw.SvgImage(svg: svg);
                                                final pdf = pw.Document();

                                                for (var i = 0;
                                                    i <
                                                        widget.item
                                                            .actualShippingNum;
                                                    i++) {
                                                  final basePage = pw.Page(
                                                      pageTheme: pw.PageTheme(
                                                        orientation: pw
                                                            .PageOrientation
                                                            .landscape,
                                                        theme: pw.ThemeData
                                                            .withFont(
                                                                base: font),
                                                        pageFormat:
                                                            const PdfPageFormat(
                                                                50 *
                                                                    PdfPageFormat
                                                                        .mm,
                                                                30 *
                                                                    PdfPageFormat
                                                                        .mm),
                                                      ),
                                                      build:
                                                          (pw.Context context) {
                                                        return pw.Column(
                                                          mainAxisAlignment: pw
                                                              .MainAxisAlignment
                                                              .center,
                                                          // alignment: pw.Alignment.topCenter,
                                                          children: [
                                                            pw.BarcodeWidget(
                                                                barcode: Barcode
                                                                    .code128(),
                                                                data: widget
                                                                    .item
                                                                    .fnskuCode,
                                                                width: 40 *
                                                                    PdfPageFormat
                                                                        .mm,
                                                                height: 15 *
                                                                    PdfPageFormat
                                                                        .mm),
                                                            pw.SizedBox(
                                                              width: 40 *
                                                                  PdfPageFormat
                                                                      .mm,
                                                              height: 10 *
                                                                  PdfPageFormat
                                                                      .mm,
                                                              child: pw.Text(
                                                                  widget.item
                                                                      .amazonItemName,
                                                                  style: pw.TextStyle(
                                                                      fontSize:
                                                                          8,
                                                                      font:
                                                                          font)),
                                                            ),
                                                          ],
                                                        );
                                                      });
                                                  pdf.addPage(basePage); // Page
                                                }

                                                await Printing.layoutPdf(
                                                    onLayout: (_) =>
                                                        pdf.save());
                                              },
                                              child: const Text("ラベル発行"),
                                            )),
                                      SizedBox(
                                        width: context.screenWidth * 0.05,
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.pop(context,
                                                widget.item.isSelected);
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                        )),
                    ScrollConfiguration(
                      behavior: CustomScrollBehavior(),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          height: context.screenHeight * 0.2,
                          width: context.screenWidth * 1.01,
                          child: DataTable2(
                              dataRowHeight: context.screenHeight * 0.15,
                              headingTextStyle: const TextStyle(fontSize: 12),
                              dataTextStyle: const TextStyle(fontSize: 12),
                              columnSpacing: 15,
                              columns: [
                                // const DataColumn2(
                                //     label: Center(child: Text("到着予定日")),
                                //     size: ColumnSize.L,
                                //     fixedWidth: 150),
                                if (!widget.addFlg)
                                  const DataColumn2(
                                      label: Center(child: Text("到着日")),
                                      size: ColumnSize.L,
                                      fixedWidth: 150),
                                DataColumn2(
                                  label: Center(child: Text('商品名')),
                                  fixedWidth: !widget.addFlg ? 600 : null,
                                  size: ColumnSize.L,
                                ),
                                const DataColumn2(
                                    label: Center(child: Text("セット数")),
                                    numeric: true,
                                    size: ColumnSize.S,
                                    fixedWidth: 90),
                                const DataColumn2(
                                    label: Center(child: Text("予定出荷単位数")),
                                    numeric: true,
                                    size: ColumnSize.S,
                                    fixedWidth: 90),
                                const DataColumn2(
                                    label: Center(child: Text("予定入荷総数")),
                                    numeric: true,
                                    size: ColumnSize.S,
                                    fixedWidth: 90),
                                if (!widget.addFlg)
                                  const DataColumn2(
                                      label: Center(child: Text("実出荷単位数")),
                                      numeric: true,
                                      size: ColumnSize.S,
                                      fixedWidth: 90),
                                if (!widget.addFlg)
                                  const DataColumn2(
                                      label: Center(child: Text("実入荷総数")),
                                      numeric: true,
                                      size: ColumnSize.S,
                                      fixedWidth: 90),
                                const DataColumn2(
                                  label: Center(child: Text("賞味期限")),
                                  size: ColumnSize.L,
                                  fixedWidth: 150,
                                ),
                              ],
                              rows: [
                                DataRow(
                                  cells: [
                                    // DataCell(dateCell(
                                    //   dateController[2],
                                    //   () {
                                    //     setState(() {
                                    //       if (dateController[2].text == "") {
                                    //         widget.item.arriveDate = null;
                                    //       } else {
                                    //         widget.item.arriveDate =
                                    //             DateFormat('yyyy/MM/dd').parse(
                                    //                 dateController[2].text);
                                    //       }
                                    //     });
                                    //   },
                                    //   false,
                                    // )),
                                    if (!widget.addFlg)
                                      DataCell(dateCell(
                                        dateController[0],
                                        () {
                                          setState(() {
                                            if (dateController[0].text == "") {
                                              widget.item.arrivedDate = null;
                                            } else {
                                              widget.item.arrivedDate =
                                                  DateFormat('yyyy/MM/dd')
                                                      .parse(dateController[0]
                                                          .text);
                                            }
                                          });
                                        },
                                        false,
                                      )),
                                    DataCell(subRowCell(textController[0], () {
                                      widget.item.amazonItemName =
                                          textController[0].text;
                                      editedList[0] = true;
                                    }, false, editedList[0])),
                                    DataCell(subRowCell(textController[4], () {
                                      widget.item.setNum = int.tryParse(
                                              textController[4].text) ??
                                          0;

                                      if (widget.addFlg) {
                                        widget.item.arriveNum =
                                            widget.item.setNum *
                                                widget.item.shippingNum;

                                        textController[6].text =
                                            widget.item.arriveNum.toString();
                                      } else {
                                        widget.item.actualShippingNum =
                                            (widget.item.sumNum! /
                                                    widget.item.setNum)
                                                .round();

                                        textController[9].text = widget
                                            .item.actualShippingNum
                                            .toString();
                                      }
                                      editedList[4] = true;
                                    }, false, editedList[4])),
                                    DataCell(subRowCell(textController[5], () {
                                      widget.item.shippingNum = int.tryParse(
                                              textController[5].text) ??
                                          0;

                                      widget.item.arriveNum =
                                          widget.item.setNum *
                                              widget.item.shippingNum;

                                      textController[6].text =
                                          widget.item.arriveNum.toString();
                                      editedList[5] = true;
                                    }, false, editedList[5])),
                                    DataCell(subRowCell(textController[6], () {
                                      widget.item.arriveNum = int.tryParse(
                                              textController[6].text) ??
                                          0;
                                      editedList[6] = true;
                                    }, true, editedList[6])),
                                    if (!widget.addFlg)
                                      DataCell(
                                          subRowCell(textController[9], () {
                                        widget.item.actualShippingNum =
                                            int.tryParse(
                                                    textController[9].text) ??
                                                0;
                                        editedList[9] = true;
                                      }, true, editedList[9])),
                                    if (!widget.addFlg)
                                      DataCell(subRowSumCell(textController[7],
                                          () {
                                        widget.item.sumNum = int.tryParse(
                                                textController[7].text) ??
                                            0;

                                        widget.item.actualShippingNum =
                                            (widget.item.sumNum! /
                                                    widget.item.setNum)
                                                .round();

                                        textController[9].text = widget
                                            .item.actualShippingNum
                                            .toString();
                                        editedList[7] = true;
                                      }, !ref.watch(loginUserProvider).adimnFig,
                                          editedList[7])),
                                    DataCell(dateCell(
                                      dateController[1],
                                      () {
                                        setState(() {
                                          if (dateController[1].text == "") {
                                            widget.item.expiryDate = null;
                                          } else {
                                            widget.item.expiryDate =
                                                DateFormat('yyyy/MM/dd').parse(
                                                    dateController[1].text);
                                          }
                                        });
                                      },
                                      false,
                                    )),
                                  ],
                                ),
                              ]),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: context.screenHeight * 0.18,
                      child: DataTable2(
                          dataRowHeight: context.screenHeight * 0.15,
                          headingTextStyle: const TextStyle(fontSize: 10),
                          dataTextStyle: const TextStyle(fontSize: 12),
                          columnSpacing: 15,
                          // minWidth: context.screenWidth * 0.6,
                          columns: [
                            const DataColumn2(
                                label: Center(child: Text("ASIN"))),
                            DataColumn2(
                                size: ColumnSize.L,
                                fixedWidth: !widget.addFlg ? 200 : null,
                                label: Center(child: Text("SKU"))),
                            const DataColumn2(
                                size: ColumnSize.L,
                                label: Center(child: Text("FNSKU"))),
                            if (widget.item.itemList.length == 1)
                              const DataColumn2(
                                  label: Center(child: Text("JAN"))),
                            if (!widget.addFlg &&
                                ref.watch(loginUserProvider).adimnFig)
                              const DataColumn2(
                                  size: ColumnSize.S,
                                  label: Center(child: Text("シール"))),
                            if (!widget.addFlg &&
                                ref.watch(loginUserProvider).adimnFig)
                              const DataColumn2(
                                  size: ColumnSize.S,
                                  label: Center(child: Text("返送"))),
                            if (!widget.addFlg &&
                                ref.watch(loginUserProvider).adimnFig)
                              const DataColumn2(
                                  size: ColumnSize.S,
                                  label: Center(child: Text("破棄"))),
                            if (ref.watch(loginUserProvider).adimnFig)
                              DataColumn2(
                                label: widget.addFlg
                                    ? const Center(child: Text("拠点選択"))
                                    : const Center(child: Text("ユーザー")),
                              ),
                            if (!widget.addFlg &&
                                ref.watch(loginUserProvider).adimnFig)
                              const DataColumn2(
                                label: Center(child: Text("ステータス")),
                              ),
                          ],
                          rows: [
                            DataRow(
                              cells: [
                                DataCell(
                                    subRowCellForJan(textController[1], () {
                                  widget.item.asin = textController[1].text;

                                  editedList[1] = true;
                                }, false, editedList[1])),
                                DataCell(subRowCell(textController[2], () {
                                  widget.item.sku = textController[2].text;
                                  editedList[2] = true;
                                }, false, editedList[2])),
                                DataCell(
                                    subRowCellForJan(textController[3], () {
                                  widget.item.fnskuCode =
                                      textController[3].text;
                                }, false, editedList[3])),
                                if (widget.item.itemList.length == 1)
                                  DataCell(subRowCellForJan(textController[13],
                                      () {
                                    widget.item.itemList[0].janCode =
                                        int.tryParse(textController[13].text) ??
                                            0;
                                    editedList[13] = true;
                                  },
                                      widget.addFlg ||
                                              !ref
                                                  .watch(loginUserProvider)
                                                  .adimnFig
                                          ? false
                                          : !widget.item.editJanFlg,
                                      editedList[13])),
                                if (!widget.addFlg &&
                                    ref.watch(loginUserProvider).adimnFig)
                                  DataCell(subRowCell(textController[10], () {
                                    widget.item.stickerNum =
                                        int.tryParse(textController[10].text) ??
                                            0;
                                    editedList[10] = true;
                                  }, false, editedList[10])),
                                if (!widget.addFlg &&
                                    ref.watch(loginUserProvider).adimnFig)
                                  DataCell(subRowCell(textController[11], () {
                                    widget.item.returnNum =
                                        int.tryParse(textController[11].text) ??
                                            0;
                                  }, false, editedList[11])),
                                if (!widget.addFlg &&
                                    ref.watch(loginUserProvider).adimnFig)
                                  DataCell(subRowCell(textController[12], () {
                                    widget.item.destructionNum =
                                        int.tryParse(textController[12].text) ??
                                            0;
                                    editedList[12] = true;
                                  }, false, editedList[12])),
                                if (ref.watch(loginUserProvider).adimnFig)
                                  DataCell(widget.addFlg
                                      ? baseCell()
                                      : userPull(textController[8])),
                                if (!widget.addFlg &&
                                    ref.watch(loginUserProvider).adimnFig)
                                  DataCell(statusPullDown(statusController[0],
                                      (value) {
                                    setState(() {
                                      statusController[0] = value;
                                      widget.item.status = statusController[0];
                                    });
                                  })),
                              ],
                            ),
                          ]),
                    ),
                    SizedBox(
                      height: context.screenHeight * 0.05,
                      child: const Center(child: Text("商品一覧")),
                    ),
                    if (widget.item.itemList.length == 1)
                      SizedBox(
                        height: context.screenHeight * 0.2,
                        child: Center(
                          child: SizedBox(
                            width: context.screenWidth * 0.15,
                            height: context.screenHeight * 0.06,
                            child: ElevatedButton(
                              child: const Center(child: Text("セットを追加する")),
                              onPressed: () {
                                setState(() {
                                  widget.item.itemList.add(Item(
                                    janCode: 0,
                                    itemName: "",
                                    setNum: 0,
                                    shippingNum: 0,
                                    arriveNum: 0,
                                    sumNum: 0,
                                    expiryDate: null,
                                    place: "",
                                    actualShippingNum: 0,
                                  ));
                                });
                                widget.item.setNum += 1;
                                _init();
                              },
                            ),
                          ),
                        ),
                      ),
                    if (widget.item.itemList.length != 1)
                      SizedBox(
                        height: context.screenHeight * 0.7,
                        child: DataTable2(
                          dataRowHeight: context.screenHeight * 0.12,
                          headingTextStyle: const TextStyle(fontSize: 12),
                          dataTextStyle: const TextStyle(fontSize: 12),
                          columnSpacing: 6,
                          columns: [
                            const DataColumn2(
                                label: Center(child: Text("JAN"))),
                            const DataColumn2(
                              label: Center(child: Text('商品名')),
                              size: ColumnSize.L,
                            ),
                            const DataColumn2(
                              label: Center(child: Text("セット数")),
                              numeric: true,
                            ),
                            const DataColumn2(
                              label: Center(child: Text("予定出荷単位数")),
                              numeric: true,
                            ),
                            const DataColumn2(
                              label: Center(child: Text("予定入荷総数")),
                              numeric: true,
                            ),
                            if (!widget.addFlg)
                              const DataColumn2(
                                label: Center(child: Text("実出荷単位数")),
                                numeric: true,
                              ),
                            if (!widget.addFlg)
                              const DataColumn2(
                                label: Center(child: Text("実入荷総数")),
                                numeric: true,
                              ),
                            const DataColumn2(
                                label: Center(child: Text("賞味期限")),
                                fixedWidth: 150),
                            if (!widget.addFlg)
                              const DataColumn2(
                                  label: Center(child: Text("保管場所"))),
                            const DataColumn2(
                              label: Center(child: Text("")),
                            ),
                          ],
                          rows: List<DataRow>.generate(
                            widget.item.itemList.length,
                            (itemindex) => DataRow(
                              cells: [
                                DataCell(subRowCellForJan(
                                    textController[(itemindex * 8) + 13], () {
                                  widget.item.itemList[itemindex]
                                      .janCode = int.tryParse(
                                          textController[(itemindex * 8) + 13]
                                              .text) ??
                                      0;
                                  editedList[(itemindex * 8) + 13] = true;
                                },
                                    widget.addFlg ||
                                            !ref
                                                .watch(loginUserProvider)
                                                .adimnFig
                                        ? false
                                        : !widget.item.editJanFlg,
                                    editedList[(itemindex * 8) + 13])),
                                DataCell(subRowCell(
                                    textController[(itemindex * 8) + 14], () {
                                  widget.item.itemList[itemindex].itemName =
                                      textController[(itemindex * 8) + 14].text;
                                  editedList[(itemindex * 8) + 14] = true;
                                }, false, editedList[(itemindex * 8) + 14])),
                                DataCell(subRowCell(
                                    textController[(itemindex * 8) + 15], () {
                                  widget.item.itemList[itemindex]
                                      .setNum = int.tryParse(
                                          textController[(itemindex * 8) + 15]
                                              .text) ??
                                      0;
                                  editedList[(itemindex * 8) + 15] = true;
                                  if (widget.addFlg) {
                                    widget.item.itemList[itemindex].arriveNum =
                                        widget.item.itemList[itemindex].setNum *
                                            widget.item.itemList[itemindex]
                                                .shippingNum;

                                    textController[(itemindex * 8) + 17].text =
                                        widget
                                            .item.itemList[itemindex].arriveNum
                                            .toString();
                                  } else {
                                    widget.item.itemList[itemindex]
                                        .actualShippingNum = (widget.item
                                                .itemList[itemindex].sumNum! /
                                            widget.item.itemList[itemindex]
                                                .setNum)
                                        .round();
                                    textController[(itemindex * 8) + 20].text =
                                        widget.item.itemList[itemindex]
                                            .actualShippingNum
                                            .toString();
                                  }
                                }, false, editedList[(itemindex * 8) + 15])),
                                DataCell(subRowCell(
                                    textController[(itemindex * 8) + 16], () {
                                  widget.item.itemList[itemindex]
                                      .shippingNum = int.tryParse(
                                          textController[(itemindex * 8) + 16]
                                              .text) ??
                                      0;

                                  widget.item.itemList[itemindex].arriveNum =
                                      widget.item.itemList[itemindex].setNum *
                                          widget.item.itemList[itemindex]
                                              .shippingNum;

                                  textController[(itemindex * 8) + 17].text =
                                      widget.item.itemList[itemindex].arriveNum
                                          .toString();

                                  editedList[(itemindex * 8) + 16] = true;
                                }, false, editedList[(itemindex * 8) + 16])),
                                DataCell(subRowCell(
                                    textController[(itemindex * 8) + 17], () {
                                  widget.item.itemList[itemindex]
                                      .arriveNum = int.tryParse(
                                          textController[(itemindex * 8) + 17]
                                              .text) ??
                                      0;
                                }, true, editedList[(itemindex * 8) + 17])),
                                if (!widget.addFlg)
                                  DataCell(subRowCell(
                                      textController[(itemindex * 8) + 20], () {
                                    widget.item.itemList[itemindex]
                                        .actualShippingNum = int.tryParse(
                                            textController[(itemindex * 8) + 20]
                                                .text) ??
                                        0;
                                    editedList[(itemindex * 8) + 20] = true;
                                  }, true, editedList[(itemindex * 8) + 20])),
                                if (!widget.addFlg)
                                  DataCell(subRowSumCell(
                                      textController[(itemindex * 8) + 18], () {
                                    widget.item.itemList[itemindex]
                                        .sumNum = int.tryParse(
                                            textController[(itemindex * 8) + 18]
                                                .text) ??
                                        0;
                                    widget.item.itemList[itemindex]
                                        .actualShippingNum = (widget.item
                                                .itemList[itemindex].sumNum! /
                                            widget.item.itemList[itemindex]
                                                .setNum)
                                        .round();
                                    textController[(itemindex * 8) + 20].text =
                                        widget.item.itemList[itemindex]
                                            .actualShippingNum
                                            .toString();
                                    editedList[(itemindex * 8) + 18] = true;
                                  }, !ref.watch(loginUserProvider).adimnFig,
                                      editedList[(itemindex * 8) + 18])),
                                DataCell(dateCell(
                                  dateController[itemindex + 3],
                                  () {
                                    setState(() {
                                      if (dateController[itemindex + 3].text ==
                                          "") {
                                        widget.item.itemList[itemindex]
                                            .expiryDate = null;
                                      } else {
                                        widget.item.itemList[itemindex]
                                                .expiryDate =
                                            DateFormat('yyyy/MM/dd').parse(
                                                dateController[itemindex + 2]
                                                    .text);
                                      }
                                    });
                                  },
                                  false,
                                )),
                                if (!widget.addFlg)
                                  DataCell(subRowCell(
                                      textController[(itemindex * 8) + 19], () {
                                    widget.item.itemList[itemindex].place =
                                        textController[(itemindex * 8) + 19]
                                            .text;
                                  }, false, editedList[(itemindex * 8) + 19])),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      setState(() {
                                        widget.item.itemList
                                            .removeAt(itemindex);
                                      });
                                      _init();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (widget.item.itemList.length != 1)
                      SizedBox(
                        width: context.screenWidth * 0.15,
                        height: context.screenHeight * 0.06,
                        child: ElevatedButton(
                          child: const Center(child: Text("セットを追加する")),
                          onPressed: () {
                            setState(() {
                              widget.item.itemList.add(Item(
                                janCode: 0,
                                itemName: "",
                                setNum: 0,
                                shippingNum: 0,
                                arriveNum: 0,
                                sumNum: 0,
                                expiryDate: null,
                                place: "",
                                actualShippingNum: 0,
                              ));
                            });
                            // widget.item.setNum += 1;
                            _init();
                          },
                        ),
                      ),
                    SizedBox(
                      height: context.screenHeight * 0.05,
                      child: const Center(child: Text("備考")),
                    ),
                    Container(
                      height: context.screenHeight * 0.4,
                      decoration: BoxDecoration(border: Border.all(width: 1)),
                      child: Center(
                        child: ListView.builder(
                          itemCount: widget.item.notes.length + 1,
                          itemBuilder: (context, index) {
                            return index > widget.item.notes.length - 1
                                ? Column(
                                    children: [
                                      SizedBox(
                                        height: context.screenHeight * 0.2,
                                        width: context.screenWidth * 0.8,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                            width: 1,
                                          )),
                                          height: context.screenHeight * 0.1,
                                          width: context.screenWidth * 0.8,
                                          alignment: Alignment.bottomCenter,
                                          child: TextField(
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: null,
                                            controller: noteController,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: context.screenHeight * 0.02,
                                      ),
                                      SizedBox(
                                        width: context.screenWidth * 0.1,
                                        height: context.screenHeight * 0.03,
                                        child: Center(
                                          child: ElevatedButton(
                                            child: const Center(
                                                child: Text("備考を追加")),
                                            onPressed: () {
                                              setState(() {
                                                if (noteController.text != "") {
                                                  widget.item.notes
                                                      .add(noteController.text);
                                                  noteController.text = "";
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(
                                    height: context.screenHeight * 0.08,
                                    padding: const EdgeInsets.all(10),
                                    child: Text(widget.item.notes[index]),
                                  );
                          },
                        ),
                      ),
                    )
                  ]),
                ),
        ),
      ),
    );
  }
}
