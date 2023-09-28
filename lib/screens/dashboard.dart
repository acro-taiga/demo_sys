import 'package:delivery_control_web/models/item.dart';
import 'package:delivery_control_web/models/loginUser.dart';
import 'package:delivery_control_web/providers/page_set_provider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../exSize.dart';

DateTime _focusedDay = DateTime.now();

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  bool isLoading = false;

// 全アイテム件数
  late List<AmazonItem> itemList;
// 未発送件数=ステータスが入荷済み、プラン作成中、発送準備中
  late List<AmazonItem> notShipItemList;
// 管理者のみ未発送遅延件数=未発送件数から入荷日から5日間経過したもの
  late List<AmazonItem> alertItemList;
// 入荷待ち件数=ステータス入荷待ち(長期未入荷件数は含む)
  late List<AmazonItem> notArriveItemList;
// 長期未入荷件数=入力日から3週間経過した商品。未入力ステータスも含む。
  late List<AmazonItem> longTimeNotArriveItemList;
  // 発送件数=発送完了
  late List<AmazonItem> shippedItemList;
  // 未入力件数(ユーザーのみ)=ステータス未入力
  late List<AmazonItem> notInputItemList;
// 要確認件数=ステータス要確認
  late List<AmazonItem> needCheckItemList;
  bool alert = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    itemList = ref.watch(itemListProvider);

    notArriveItemList = itemList
        .where((element) => element.status == "入荷待ち" || element.status == "未入力")
        .toList();
    longTimeNotArriveItemList = notArriveItemList
        .where((element) => element.createdAt
            .add(const Duration(days: 21))
            .isBefore(DateTime.now()))
        .toList();
    notShipItemList = itemList
        .where((element) =>
            element.status == "入荷済み" ||
            element.status == "プラン作成中" ||
            element.status == "発送準備中")
        .toList();
    alertItemList = notShipItemList
        .where((element) =>
            element.arrivedDate != null &&
            element.arrivedDate!
                .add(const Duration(days: 5))
                .isBefore(DateTime.now()))
        .toList();
    alert = alertItemList.isNotEmpty;
    shippedItemList =
        itemList.where((element) => element.status == "発送完了").toList();

    notInputItemList =
        itemList.where((element) => element.status == "未入力").toList();

    needCheckItemList =
        itemList.where((element) => element.status == "要確認").toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TOP'),
      ),
      body: isLoading //「読み込み中」だったら「グルグル」表示
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: context.screenHeight * 0.01,
                    ),
                    SizedBox(
                      height: context.screenHeight * 0.4,
                      child: Row(
                        children: [
                          SizedBox(
                            width: context.screenWidth * 0.58,
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.blueGrey,
                                  height: context.screenHeight * 0.05,
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    'お知らせ',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                    height: context.screenHeight * 0.15,
                                    alignment: Alignment.topLeft,
                                    child: const Text(
                                      'yyyy/MM/dd  ラクロジシステムリリースのお知らせ',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: context.screenWidth * 0.02),
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.pink,
                                  height: context.screenHeight * 0.05,
                                  width: context.screenWidth * 0.5,
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    'カレンダー',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          const Color.fromARGB(255, 88, 88, 88),
                                    ),
                                  ),
                                  height: context.screenHeight * 0.35,
                                  child: TableCalendar(
                                    calendarStyle: const CalendarStyle(
                                        defaultTextStyle:
                                            TextStyle(fontSize: 13)),
                                    calendarBuilders: CalendarBuilders(
                                      dowBuilder: (context, day) {
                                        if (day.weekday == DateTime.sunday) {
                                          final text =
                                              DateFormat.E('ja').format(day);
                                          return Center(
                                            child: Text(
                                              text,
                                              style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 13),
                                            ),
                                          );
                                        } else if (day.weekday ==
                                            DateTime.saturday) {
                                          final text =
                                              DateFormat.E('ja').format(day);
                                          return Center(
                                            child: Text(
                                              text,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.blue),
                                            ),
                                          );
                                        }
                                        return null;
                                      },
                                      defaultBuilder:
                                          (context, day, focusedDay) {
                                        if (day.weekday == DateTime.sunday) {
                                          final textDay =
                                              DateFormat.d().format(day);
                                          return Center(
                                            child: Text(
                                              textDay,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.red),
                                            ),
                                          );
                                        } else if (day.weekday ==
                                            DateTime.saturday) {
                                          final textDay =
                                              DateFormat.d().format(day);
                                          return Center(
                                            child: Text(
                                              textDay,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.blue),
                                            ),
                                          );
                                        }
                                        return null;
                                      },
                                    ),
                                    shouldFillViewport: true,
                                    locale: 'ja',
                                    firstDay: DateTime.utc(2023, 1, 1),
                                    lastDay: DateTime.utc(
                                        _focusedDay.year + 3, 12, 31),
                                    focusedDay: _focusedDay,
                                    daysOfWeekHeight: 32,
                                    headerStyle: const HeaderStyle(
                                      formatButtonVisible: false,
                                      titleCentered: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.screenHeight * 0.02),
                    Expanded(
                      //↓--進捗の横にwidget出す場合は、コメントアウトを外して、172行目のchild削除
                      // child: Row(
                      //   children: [
                      //↑--ここまでのコメントアウトを外して、172行目のchild削除
                      child: SizedBox(
                        // 進捗の横にwidget出す場合は、widthのコメントアウトを入れ替える
                        // width: context.screenWidth * 0.58,
                        // width: double.infinity,
                        width: context.screenWidth * 1,
                        child: Column(
                          children: [
                            Container(
                              color: Colors.blueGrey,
                              height: context.screenHeight * 0.05,
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                '作業進捗状況',
                                softWrap: false,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                // color: Colors.white,
                                // width: double.infinity,
                                alignment: Alignment.center,
                                child: Container(
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      if (!ref
                                        .watch(loginUserProvider)
                                        .adimnFig)
                                      const Spacer(),
                                      if (!ref
                                          .watch(loginUserProvider)
                                          .adimnFig)
                                        Expanded(
                                          child: Container(
                                            width: context.screenWidth * 0.1,
                                            color: Colors.white,
                                            alignment: Alignment.bottomCenter,
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: context.screenHeight *
                                                      0.03,
                                                ),
                                                SizedBox(
                                                  height: context.screenHeight *
                                                      0.15,
                                                  child: const Icon(
                                                    Icons.edit_off,
                                                    size: 50,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: context.screenHeight *
                                                      0.06,
                                                  child: const Text(
                                                    '未入力件数',
                                                    softWrap: false,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: context.screenHeight *
                                                      0.06,
                                                  child: TextButton(
                                                    onPressed: () {
                                                      ref
                                                          .read(
                                                              filterItemListProvider
                                                                  .notifier)
                                                          .state = notInputItemList;
                                                      ref
                                                          .read(itemFlgProvider
                                                              .notifier)
                                                          .state = 10;
                                                      ref
                                                          .read(pageNumProvider
                                                              .notifier)
                                                          .state =1;
                                                    },
                                                    child: Text(
                                                      '${notInputItemList.length}件',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 30,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                  
                                        // SizedBox(
                                        //   width: context.screenWidth * 0.02,
                                        // ),
                                        const Spacer(),
                                  
                                        Expanded(
                                          child: Container(
                                            width: context.screenWidth * 0.1,
                                            color: Colors.white,
                                            alignment: Alignment.bottomCenter,
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: context.screenHeight *
                                                      0.03,
                                                ),
                                                SizedBox(
                                                  height: context.screenHeight *
                                                      0.15,
                                                  child: const Icon(
                                                    Icons
                                                        .production_quantity_limits,
                                                    size: 50,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: context.screenHeight *
                                                      0.06,
                                                  child: const Text(
                                                    '入荷待ち件数',
                                                    softWrap: false,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: context.screenHeight *
                                                      0.06,
                                                  child: TextButton(
                                                    onPressed: () {
                                                      ref
                                                              .read(
                                                                  filterItemListProvider
                                                                      .notifier)
                                                              .state =
                                                          notArriveItemList;
                                                      ref
                                                          .read(itemFlgProvider
                                                              .notifier)
                                                          .state = 10;
                                                      if (!ref
                                          .watch(loginUserProvider)
                                          .adimnFig){
                                             ref
                                                          .read(pageNumProvider
                                                              .notifier)
                                                          .state = 1;
                                          }else{
                                               ref
                                                          .read(pageNumProvider
                                                              .notifier)
                                                          .state = 4;
                                          }
                                                   
                                                    },
                                                    child: Text(
                                                      '${notArriveItemList.length}件',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 30,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      // SizedBox(
                                      //   width: context.screenWidth * 0.02,
                                      // ),
                                      const Spacer(),
                                      Expanded(
                                        child: Container(
                                          width: context.screenWidth * 0.1,
                                          color: Colors.white,
                                          alignment: Alignment.bottomCenter,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height:
                                                    context.screenHeight * 0.03,
                                              ),
                                              SizedBox(
                                                height:
                                                    context.screenHeight * 0.15,
                                                child: const Icon(
                                                  Icons.cancel_schedule_send,
                                                  size: 50,
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    context.screenHeight * 0.06,
                                                child: const Text(
                                                  '未発送件数',
                                                  softWrap: false,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    context.screenHeight * 0.06,
                                                child: TextButton(
                                                  onPressed: () {
                                                    ref
                                                        .read(
                                                            filterItemListProvider
                                                                .notifier)
                                                        .state = notShipItemList;
                                                    ref
                                                        .read(itemFlgProvider
                                                            .notifier)
                                                        .state = 10;
                                                   if (!ref
                                          .watch(loginUserProvider)
                                          .adimnFig){
                                             ref
                                                          .read(pageNumProvider
                                                              .notifier)
                                                          .state = 1;
                                          }else{
                                               ref
                                                          .read(pageNumProvider
                                                              .notifier)
                                                          .state = 4;
                                          }
                                                  },
                                                  child: Text(
                                                    '${notShipItemList.length}件',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 30,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      // SizedBox(
                                      //   width: context.screenWidth * 0.02,
                                      // ),
                                      const Spacer(),
                                      Expanded(
                                        child: Container(
                                          width: context.screenWidth * 0.1,
                                          color: Colors.white,
                                          alignment: Alignment.bottomCenter,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height:
                                                    context.screenHeight * 0.03,
                                              ),
                                              SizedBox(
                                                height:
                                                    context.screenHeight * 0.15,
                                                child: const Icon(
                                                  Icons.send,
                                                  size: 50,
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    context.screenHeight * 0.06,
                                                child: const Text(
                                                  '発送件数',
                                                  softWrap: false,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    context.screenHeight * 0.06,
                                                child: TextButton(
                                                  onPressed: () {
                                                    ref
                                                        .read(
                                                            filterItemListProvider
                                                                .notifier)
                                                        .state = shippedItemList;
                                                    ref
                                                        .read(itemFlgProvider
                                                            .notifier)
                                                        .state = 10;
                                                  if (!ref
                                          .watch(loginUserProvider)
                                          .adimnFig){
                                             ref
                                                          .read(pageNumProvider
                                                              .notifier)
                                                          .state = 1;
                                          }else{
                                               ref
                                                          .read(pageNumProvider
                                                              .notifier)
                                                          .state = 4;
                                          }
                                                  },
                                                  child: Text(
                                                    '${shippedItemList.length}件',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 30,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // SizedBox(
                                      //   width: context.screenWidth * 0.02,
                                      // ),
                                      const Spacer(),
                                      Expanded(
                                        child: Container(
                                          width: context.screenWidth * 0.1,
                                          color: Colors.white,
                                          alignment: Alignment.bottomCenter,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height:
                                                    context.screenHeight * 0.03,
                                              ),
                                              SizedBox(
                                                height:
                                                    context.screenHeight * 0.15,
                                                child: const Icon(
                                                  Icons.preview,
                                                  size: 50,
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    context.screenHeight * 0.06,
                                                child: const Text(
                                                  '要確認件数',
                                                  softWrap: false,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    context.screenHeight * 0.06,
                                                child: TextButton(
                                                  onPressed: () {
                                                    ref
                                                        .read(
                                                            filterItemListProvider
                                                                .notifier)
                                                        .state = needCheckItemList;
                                                    ref
                                                        .read(itemFlgProvider
                                                            .notifier)
                                                        .state = 10;
                                                  if (!ref
                                          .watch(loginUserProvider)
                                          .adimnFig){
                                             ref
                                                          .read(pageNumProvider
                                                              .notifier)
                                                          .state = 1;
                                          }else{
                                               ref
                                                          .read(pageNumProvider
                                                              .notifier)
                                                          .state = 4;
                                          }
                                                  },
                                                  child: Text(
                                                    '${needCheckItemList.length}件',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 30,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      // SizedBox(
                                      //   width: context.screenWidth * 0.02,
                                      // ),
                                      const Spacer(),
                                      Expanded(
                                        child: Container(
                                          width: context.screenWidth * 0.1,
                                          color: Colors.white,
                                          alignment: Alignment.bottomCenter,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height:
                                                    context.screenHeight * 0.03,
                                              ),
                                              SizedBox(
                                                height:
                                                    context.screenHeight * 0.15,
                                                child: const Icon(
                                                  Icons.watch_later,
                                                  size: 50,
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    context.screenHeight * 0.06,
                                                child: const Text(
                                                  '長期未入荷件数',
                                                  softWrap: false,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height:
                                                    context.screenHeight * 0.06,
                                                child: TextButton(
                                                  onPressed: () {
                                                    ref
                                                            .read(
                                                                filterItemListProvider
                                                                    .notifier)
                                                            .state =
                                                        longTimeNotArriveItemList;
                                                    ref
                                                        .read(itemFlgProvider
                                                            .notifier)
                                                        .state = 10;
                                                 if (!ref
                                          .watch(loginUserProvider)
                                          .adimnFig){
                                             ref
                                                          .read(pageNumProvider
                                                              .notifier)
                                                          .state = 1;
                                          }else{
                                               ref
                                                          .read(pageNumProvider
                                                              .notifier)
                                                          .state = 4;
                                          }
                                                  },
                                                  child: Text(
                                                    '${longTimeNotArriveItemList.length}件',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 30,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // SizedBox(
                                      //   width: context.screenWidth * 0.02,
                                      // ),
                                      if (ref.watch(loginUserProvider).adimnFig)
                                        const Spacer(),
                                      if (ref.watch(loginUserProvider).adimnFig)
                                        Expanded(
                                          child: Container(
                                            width: context.screenWidth * 0.1,
                                            color: Colors.white,
                                            alignment: Alignment.bottomCenter,
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: context.screenHeight *
                                                      0.03,
                                                ),
                                                SizedBox(
                                                  height: context.screenHeight *
                                                      0.15,
                                                  child: const Icon(
                                                    Icons.crisis_alert,
                                                    size: 50,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: context.screenHeight *
                                                      0.06,
                                                  child: const Text(
                                                    '未発送遅延件数',
                                                    softWrap: false,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: context.screenHeight *
                                                      0.06,
                                                  child: TextButton(
                                                    onPressed: () {
                                                      ref
                                                          .read(
                                                              filterItemListProvider
                                                                  .notifier)
                                                          .state = alertItemList;
                                                      ref
                                                          .read(itemFlgProvider
                                                              .notifier)
                                                          .state = 10;
                                                      ref
                                                          .read(pageNumProvider
                                                              .notifier)
                                                          .state = 4;
                                                    },
                                                    child: Text(
                                                      '${alertItemList.length}件',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 30,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      const Spacer(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      //進捗の横にwidget出す場合は、ここからのコメントアウトを外す

                      // SizedBox(
                      //   width: context.screenWidth * 0.02,
                      // ),
                      // Expanded(
                      // child: Column(
                      //   children: [
                      //     Container(
                      //       color: Colors.green,
                      //       height: context.screenHeight * 0.05,
                      //       width: context.screenWidth * 0.5,
                      //       alignment: Alignment.centerLeft,
                      //       child: Text(
                      //         '昨日実績',
                      //         textAlign: TextAlign.left,
                      //         style: const TextStyle(
                      //           fontWeight: FontWeight.bold,
                      //           color: Colors.black,
                      //         ),
                      //       ),
                      //     ),
                      //     Container(
                      //       decoration: BoxDecoration(
                      //         border: Border.all(
                      //           color: Color.fromARGB(255, 88, 88, 88),
                      //         ),
                      //       ),
                      //       // color: Colors.blue,
                      //       height: context.screenHeight * 0.17,
                      //       alignment: Alignment.topLeft,
                      //       child: Text('発送件数、入荷件数、在庫件数'),
                      //     ),
                      // Container(
                      //   height: context.screenHeight * 0.05,
                      //   alignment: Alignment.centerLeft,
                      //   child: Text(
                      //     '今月の累計/先月の実績',
                      //     style: const TextStyle(
                      //       fontWeight: FontWeight.bold,
                      //       color: Colors.black,
                      //     ),
                      //   ),
                      // ),
                      // Expanded(
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       border: Border.all(
                      //         color: Color.fromARGB(255, 88, 88, 88),
                      //       ),
                      //     ),
                      //     alignment: Alignment.topLeft,
                      //     child: Text(
                      //       '発送件数、入荷件数、在庫件数',
                      //     ),
                      //   ),
                      // ),
                      // ],
                      // ),
                      // ),
                      // ],
                      // ),

                      // 進捗の横にwidget出す場合は、ここまでのコメントアウトを外す
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
