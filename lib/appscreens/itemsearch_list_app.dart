import 'package:async/async.dart';
import 'package:delivery_control_web/appscreens/itemsearch_detail_app.dart';
import 'package:delivery_control_web/exSize.dart';
import 'package:delivery_control_web/models/item.dart';
import 'package:delivery_control_web/providers/item_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchLuggagesApp extends ConsumerStatefulWidget {
  final String barcodeFnsku;
  final int? barcodeJan;
  const SearchLuggagesApp(this.barcodeFnsku, this.barcodeJan, {super.key});

  @override
  SearchLuggagesAppState createState() => SearchLuggagesAppState();
}

class SearchLuggagesAppState extends ConsumerState<SearchLuggagesApp> {
  late Future<int> result;
  ItemDatabase itemDatabase = ItemDatabase();
  final AsyncMemoizer memoizer = AsyncMemoizer();
  bool isLoading = false;
  late List<AmazonItem> dataList;

  Future<List<AmazonItem>> filter() {
    dataList = ref
        .watch(itemListProvider)
        .where((element) => element.status == "入荷待ち")
        .toList();

    if (widget.barcodeFnsku != "" && dataList.isNotEmpty) {
      dataList = dataList
          .where((element) =>
              element.status == "入荷待ち" &&
              element.fnskuCode == widget.barcodeFnsku)
          .toList();
    }

    if (widget.barcodeJan != null && dataList.isNotEmpty) {
      List<AmazonItem> tmp = [];
      for (AmazonItem amazonItem in dataList) {
        for (var item in amazonItem.itemList) {
          if (item.janCode == widget.barcodeJan ||
              amazonItem.status == "入荷待ち") {
            if (!tmp.contains(amazonItem)) {
              tmp.add(amazonItem);
            }
          }
        }
      }
      dataList = tmp;
    }

    return Future.value(dataList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("検索結果")),
        body: FutureBuilder(
          future: filter(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(width: 1.0, color: Colors.grey))),
                  child: ListTile(
                    title: Row(
                      children: [
                        SizedBox(
                          width: context.screenWidth * 0.22,
                          child: const Text(
                            "fnsku",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: context.screenWidth * 0.42,
                          child: const Text(
                            "商品名",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            "利用者名",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        shape: const RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.black,
                          ),
                        ),
                        title: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return SearchLuggagesAppDetail(
                                      dataList[index]);
                                },
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              SizedBox(
                                width: context.screenWidth * 0.22,
                                child: Text(
                                  dataList[index].fnskuCode,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              SizedBox(
                                width: context.screenWidth * 0.42,
                                child: Text(
                                  dataList[index].amazonItemName,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  dataList[index].userName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          },
        ));
  }
}
