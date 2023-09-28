// import 'package:delivery_control_web/models/customer.dart';
// import 'package:delivery_control_web/models/loginUser.dart';
// import 'package:delivery_control_web/models/plan.dart';
// import 'package:delivery_control_web/providers/item_database_provider.dart';
// import 'package:delivery_control_web/providers/plan_database_provider.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';

// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:intl/intl.dart';
// import 'package:excel/excel.dart' as xlsio;
// import 'package:flutter/services.dart' show ByteData, rootBundle;

// import '../exSize.dart';
// import '../models/item.dart';
// import '../common/popup.dart';

// final textcheckProvider = StateProvider<String>((ref) => "");
// DateFormat outputFormat = DateFormat('yyyy/MM/dd');
// DateFormat excelDateFormat = DateFormat('MM/dd/yyyy');
// final isMyFavProvider = StateProvider<int>((ref) => 0);
// final checkProvider = StateProvider<bool>((ref) => false);

// class PlansListInfo extends ConsumerStatefulWidget {
//   const PlansListInfo({super.key});

//   @override
//   _PlansInfo createState() => _PlansInfo();
// }

// class _PlansInfo extends ConsumerState<PlansListInfo> {
//   final TextEditingController _controller = TextEditingController();
//   String? selectedUser;
//   late bool isMyFav = false;
//   late List<AmazonItem> dataList;
//   PlanDatabase planDatabase = PlanDatabase();
//   final storageRef = FirebaseStorage.instance.ref();
//   late final Reference islandRef;
//   bool isLoading = false;
//   ItemDatabase itemDatabase = ItemDatabase();

//   String filePath = "assets/";
//   final fileName = "ManifestFileUpload_Template_IncludeExpirationDate_MPL.xlsx";
//   late String fullFilePath;
//   xlsio.Excel? excel;

//   var workbook = xlsio.Excel.createExcel();
//   late xlsio.Sheet sheet;

//   void errorMethod(context) {
//     Navigator.of(context).pop();
//   }

//   Future<List<AmazonItem>> filter() {
//     dataList = ref
//         .watch(itemListProvider)
//         .where((element) => element.status == '入荷済み')
//         .toList();
//     if (selectedUser != null) {
//       dataList = dataList
//           .where((element) => element.userName.contains(selectedUser!))
//           .toList();
//     }

//     return Future.value(dataList);
//   }

//   Future<void> update() async {
//     setState(() {
//       isLoading = true;
//     });
//     ref.read(itemListProvider.notifier).clearList();
//     await itemDatabase.getallItems(ref);

//     await filter();
//     setState(() {
//       isLoading = false;
//     });
//   }

//   Widget filterUserPull() {
//     return Center(
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton2<String>(
//           isExpanded: true,
//           hint: Text(
//             'ユーザーから絞り込む',
//             style: TextStyle(
//               fontSize: 10,
//               color: Theme.of(context).hintColor,
//             ),
//           ),
//           items: <DropdownMenuItem<String>>[
//             const DropdownMenuItem(
//               value: "開発者",
//               child: Text(
//                 "開発者",
//                 style: TextStyle(
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//             ...ref
//                 .watch(customerListProvider)
//                 .map<DropdownMenuItem<String>>(
//                     (Customer customer) => DropdownMenuItem(
//                           value: customer.name,
//                           child: Text(
//                             customer.name,
//                             style: const TextStyle(
//                               fontSize: 14,
//                             ),
//                           ),
//                         ))
//                 .toList()
//           ],
//           value: selectedUser,
//           onChanged: (value) {
//             setState(() {
//               selectedUser = value as String;
//             });
//           },
//           buttonStyleData: const ButtonStyleData(
//             height: 40,
//             width: 200,
//           ),
//           dropdownStyleData: const DropdownStyleData(
//             maxHeight: 200,
//           ),
//           menuItemStyleData: const MenuItemStyleData(
//             height: 40,
//           ),
//           dropdownSearchData: DropdownSearchData(
//             searchController: _controller,
//             searchInnerWidgetHeight: 50,
//             searchInnerWidget: Container(
//               height: 50,
//               padding: const EdgeInsets.only(
//                 top: 8,
//                 bottom: 4,
//                 right: 8,
//                 left: 8,
//               ),
//               child: TextFormField(
//                 expands: true,
//                 maxLines: null,
//                 controller: _controller,
//                 decoration: InputDecoration(
//                   isDense: true,
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 8,
//                   ),
//                   hintText: 'ユーザーを検索',
//                   hintStyle: const TextStyle(fontSize: 12),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ),
//             searchMatchFn: (item, searchValue) {
//               return (item.value.toString().contains(searchValue));
//             },
//           ),
//           //This to clear the search value when you close the menu
//           onMenuStateChange: (isOpen) {
//             if (!isOpen) {
//               _controller.clear();
//             }
//           },
//         ),
//       ),
//     );
//   }

//   void filterReset() {
//     setState(() {
//       selectedUser = null;
//     });
//   }

//   Widget header() {
//     return SizedBox(
//       height: context.screenHeight * 0.15,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           SizedBox(
//             width: context.screenWidth * 0.1,
//           ),
//           SizedBox(width: context.screenWidth * 0.15, child: filterUserPull()),
//           SizedBox(
//             width: context.screenWidth * 0.12,
//             child: TextButton(
//               onPressed: () {
//                 setState(() {
//                   dataList.where((AmazonItem item) => !item.isSelected).forEach(
//                     (element) {
//                       element.isSelected = true;
//                     },
//                   );
//                 });
//               },
//               child: const Center(
//                 child: Text('全選択'),
//               ),
//             ),
//           ),
//           SizedBox(
//               width: context.screenWidth * 0.12,
//               child: TextButton(
//                 onPressed: () {
//                   filterReset();
//                 },
//                 child: const Center(child: Text("フィルターを解除")),
//               )),
//           SizedBox(
//             width: context.screenWidth * 0.1,
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void initState() {
//     Future(() async {
//       fullFilePath = "$filePath$fileName";
//       ByteData data = await rootBundle.load(fullFilePath);
//       var bytes =
//           data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//       try {
//         excel = xlsio.Excel.decodeBytes(bytes);
//       } catch (e) {
//         print(e);
//       }
//     });
//     super.initState();
//   }

//   Widget gridItem() {
//     return GridView.count(
//       crossAxisCount: 2,
//       childAspectRatio:
//           (context.screenWidth * 1.7 / context.screenHeight * 1.5),
//       children: List.generate(
//         dataList.length,
//         (index) => Container(
//           // padding: EdgeInsets.all(10),
//           margin: const EdgeInsets.all(5),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.2),
//                 spreadRadius: 0,
//                 blurRadius: 2,
//                 offset: const Offset(0, 1),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               SizedBox(
//                 width: context.screenWidth * 0.01,
//               ),
//               GestureDetector(
//                 onTap: () {
//                   setState(
//                     () {
//                       dataList[index].isSelected = !dataList[index].isSelected;
//                     },
//                   );
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.only(right: 5.0, left: 5),
//                   child: AnimatedContainer(
//                     height: context.screenHeight * 0.05,
//                     // padding: const EdgeInsets.only(right: 5),
//                     duration: const Duration(milliseconds: 300),
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: dataList[index].isSelected
//                             ? Colors.lightGreen.shade100
//                             : Colors.grey.shade300,
//                       ),
//                     ),
//                     child: Center(
//                       child: dataList[index].isSelected
//                           ? const Icon(
//                               Icons.check_box,
//                               color: Colors.lightGreen,
//                             )
//                           : Icon(
//                               Icons.check_box_outline_blank_outlined,
//                               color: Colors.grey.shade600,
//                             ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: context.screenWidth * 0.04,
//                 child: Text(
//                   dataList[index].userName,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     overflow: TextOverflow.ellipsis,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 // width: context.screenWidth * 0.07,
//                 // color: Colors.pink,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     SizedBox(
//                       height: context.screenHeight * 0.02,
//                     ),
//                     Container(
//                       height: context.screenHeight * 0.03,
//                       alignment: Alignment.centerLeft,
//                       child: Text(dataList[index].amazonItemName,
//                           style: const TextStyle(
//                               overflow: TextOverflow.ellipsis,
//                               color: Colors.black,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w500)),
//                     ),
//                     Container(
//                       height: context.screenHeight * 0.03,
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         dataList[index].sku,
//                         style: TextStyle(
//                           overflow: TextOverflow.ellipsis,
//                           color: Colors.grey[500],
//                         ),
//                         strutStyle: const StrutStyle(height: 1.5),
//                       ),
//                     ),
//                     Row(children: [
//                       Container(
//                         height: context.screenHeight * 0.05,
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 8, horizontal: 15),
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             color: Colors.grey.shade200),
//                         child: Text(
//                           '個数:${dataList[index].shippingNum}個'.toString(),
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         width: context.screenWidth * 0.02,
//                       ),
//                       Container(
//                         width: context.screenWidth * 0.15,
//                         height: context.screenHeight * 0.05,
//                         decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             color:
//                                 Color(int.parse("0xff0000ff")).withAlpha(20)),
//                         child: dataList[index].expiryDate == null
//                             ? const Center(
//                                 child: Text(
//                                   '賞味期限なし',
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               )
//                             : Center(
//                                 child: Text(
//                                   '賞味期限:${outputFormat.format(dataList[index].expiryDate!)}'
//                                       .toString(),
//                                   style: TextStyle(
//                                       overflow: TextOverflow.ellipsis,
//                                       color: Color(int.parse("0xff0000ff"))),
//                                 ),
//                               ),
//                       ),
//                     ])
//                   ],
//                 ),
//               ),
//               // GestureDetector(
//               //   onTap: () {
//               //     setState(
//               //       () {
//               //         dataList[index].isSelected = !dataList[index].isSelected;
//               //       },
//               //     );
//               //   },
//               //   child: Padding(
//               //     padding: const EdgeInsets.only(right: 5.0, left: 5),
//               //     child: AnimatedContainer(
//               //       height: context.screenHeight * 0.05,
//               //       // padding: const EdgeInsets.only(right: 5),
//               //       duration: const Duration(milliseconds: 300),
//               //       decoration: BoxDecoration(
//               //         borderRadius: BorderRadius.circular(12),
//               //         border: Border.all(
//               //           color: dataList[index].isSelected
//               //               ? Colors.lightGreen.shade100
//               //               : Colors.grey.shade300,
//               //         ),
//               //       ),
//               //       child: Center(
//               //         child: dataList[index].isSelected
//               //             ? const Icon(
//               //                 Icons.check_box,
//               //                 color: Colors.lightGreen,
//               //               )
//               //             : Icon(
//               //                 Icons.check_box_outline_blank_outlined,
//               //                 color: Colors.grey.shade600,
//               //               ),
//               //       ),
//               //     ),
//               //   ),
//               // )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: filter(),
//       builder: (context, snapshot) {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('プラン作成'),
//           ),
//           body: isLoading
//               ? const Center(
//                   child: CircularProgressIndicator(),
//                 )
//               : Padding(
//                   padding: const EdgeInsets.all(10),
//                   child: Center(
//                     child: Column(
//                       children: [
//                         SizedBox(height: context.screenHeight * 0.01),
//                         header(),
//                         SizedBox(
//                           height: context.screenHeight * 0.01,
//                         ),
//                         dataList.isNotEmpty
//                             ? Expanded(child: gridItem())
//                             : const Text('入荷済みの商品はありません'),
//                         Visibility(
//                           visible: ref
//                               .watch(itemListProvider)
//                               .where((element) => element.isSelected)
//                               .toList()
//                               .isNotEmpty,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.2),
//                                   spreadRadius: 0,
//                                   blurRadius: 2,
//                                   offset: const Offset(0, 1),
//                                 ),
//                               ],
//                               borderRadius: BorderRadius.circular(3),
//                               color: Colors.white,
//                             ),
//                             width: double.infinity,
//                             // height: context.screenHeight * 0.1,
//                             child: Column(
//                               children: [
//                                 SizedBox(
//                                   height: context.screenHeight * 0.05,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(
//                                       'チェックがついた${ref.watch(itemListProvider).where((element) => element.isSelected).toList().length}個の商品でプランを作成します',
//                                       style: const TextStyle(
//                                         color: Colors.black,
//                                         fontSize: 15,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Container(
//                                   height: context.screenHeight * 0.05,
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Container(
//                                         width: context.screenWidth * 0.12,
//                                         height: context.screenHeight * 0.05,
//                                         child: ElevatedButton(
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: Colors.blueAccent
//                                                 .withOpacity(0.8),
//                                           ),
//                                           onPressed: () async {
//                                             if (excel != null) {
//                                               print("ダウンロード成功");
//                                               List<String> selectUserList =
//                                                   List.generate(
//                                                       dataList
//                                                           .where((element) =>
//                                                               element
//                                                                   .isSelected)
//                                                           .toList()
//                                                           .length,
//                                                       (index) => dataList
//                                                           .where((element) =>
//                                                               element
//                                                                   .isSelected)
//                                                           .toList()[index]
//                                                           .userName);

//                                               selectUserList = selectUserList
//                                                   .toSet()
//                                                   .toList();

//                                               for (var user in selectUserList) {
//                                                 List<AmazonItem> selectItem =
//                                                     dataList
//                                                         .where((element) =>
//                                                             element.userName ==
//                                                                 user &&
//                                                             element.isSelected)
//                                                         .toList();

//                                                 xlsio.Sheet sheetObject = excel![
//                                                     "Create workflow – template"];

//                                                 try {
//                                                   for (int i = 0;
//                                                       i < selectItem.length;
//                                                       i++) {
//                                                     var cellSku = sheetObject
//                                                         .cell(xlsio.CellIndex
//                                                             .indexByString(
//                                                                 'A${i + 9}'));
//                                                     cellSku.value =
//                                                         selectItem[i].sku;
//                                                     var cellQua = sheetObject
//                                                         .cell(xlsio.CellIndex
//                                                             .indexByString(
//                                                                 'B${i + 9}'));
//                                                     cellQua.value =
//                                                         selectItem[i]
//                                                             .shippingNum;
//                                                     var cellDate = sheetObject
//                                                         .cell(xlsio.CellIndex
//                                                             .indexByString(
//                                                                 'E${i + 9}'));
//                                                     cellDate
//                                                         .value = selectItem[i]
//                                                                 .expiryDate ==
//                                                             null
//                                                         ? ''
//                                                         : excelDateFormat
//                                                             .format(selectItem[
//                                                                     i]
//                                                                 .expiryDate!);
//                                                     selectItem[i].status =
//                                                         'プラン作成中';
//                                                     await itemDatabase.editItem(
//                                                         selectItem[i]);
//                                                   }

//                                                   excel!
//                                                       .save(fileName: fileName);

//                                                   List<String> itemIds =
//                                                       List.generate(
//                                                           selectItem.length,
//                                                           (index) =>
//                                                               selectItem[index]
//                                                                   .itemId);
//                                                   planDatabase.addNewPlan(
//                                                     Plan(
//                                                       boxHeight: null,
//                                                       boxHorizontal: null,
//                                                       boxNum: null,
//                                                       boxWeight: null,
//                                                       boxWidth: null,
//                                                       itemIds: itemIds,
//                                                       name: '',
//                                                       mailStatus: '未送信',
//                                                       planId: '',
//                                                       selected: false,
//                                                       shippingDate: null,
//                                                       status: '未依頼',
//                                                       uid: ref
//                                                           .watch(
//                                                               loginUserProvider)
//                                                           .uid,
//                                                       note: "",
//                                                       infoNum: null,
//                                                       shippingWay: null,
//                                                     ),
//                                                   );
//                                                 } catch (e) {
//                                                   print(e);
//                                                   PopupAlert.alert(
//                                                       context,
//                                                       'Excelに書き込めませんでした。\n 再作成してください。',
//                                                       errorMethod);
//                                                 }
//                                               }

//                                               setState(() {
//                                                 ref
//                                                     .watch(itemListProvider)
//                                                     .where((AmazonItem item) =>
//                                                         item.isSelected)
//                                                     .forEach(
//                                                   (element) {
//                                                     element.isSelected = false;
//                                                   },
//                                                 );
//                                                 ref
//                                                     .watch(isMyFavProvider
//                                                         .notifier)
//                                                     .state = 0;
//                                               });
//                                             } else {
//                                               print("失敗");
//                                             }
//                                           },
//                                           child: const Text('プラン作成'),
//                                         ),
//                                       ),
//                                       SizedBox(
//                                           width: context.screenHeight * 0.05),
//                                       Container(
//                                         width: context.screenWidth * 0.12,
//                                         height: context.screenHeight * 0.05,
//                                         child: ElevatedButton(
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor:
//                                                 Colors.grey.withOpacity(0.8),
//                                           ),
//                                           onPressed: () {
//                                             setState(() {
//                                               ref
//                                                   .watch(itemListProvider)
//                                                   .where((AmazonItem item) =>
//                                                       item.isSelected)
//                                                   .forEach(
//                                                 (element) {
//                                                   element.isSelected = false;
//                                                 },
//                                               );
//                                               ref
//                                                   .watch(
//                                                       isMyFavProvider.notifier)
//                                                   .state = 0;
//                                             });
//                                           },
//                                           child: const Text('キャンセル'),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Container(
//                                   height: context.screenHeight * 0.01,
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//           floatingActionButton: SpeedDial(
//             icon: Icons.menu,
//             activeIcon: Icons.close,
//             spacing: 3,
//             direction: SpeedDialDirection.up,
//             backgroundColor: Colors.blueAccent.withOpacity(0.8),
//             foregroundColor: Colors.white,
//             activeBackgroundColor: Colors.grey,
//             activeForegroundColor: Colors.white,
//             visible: true,
//             closeManually: false,
//             curve: Curves.bounceIn,
//             renderOverlay: false,
//             shape: const CircleBorder(),
//             children: [
//               SpeedDialChild(
//                 child: const Icon(Icons.sync),
//                 backgroundColor: Colors.blueAccent.withOpacity(0.8),
//                 foregroundColor: Colors.white,
//                 label: '更新',
//                 labelStyle: const TextStyle(fontSize: 18.0),
//                 onTap: () async {
//                   update();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
