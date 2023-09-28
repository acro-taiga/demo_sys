import 'package:delivery_control_web/appscreens/itemsearch_list_app.dart';
import 'package:delivery_control_web/exSize.dart';
import 'package:delivery_control_web/models/item.dart';
import 'package:delivery_control_web/providers/item_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ItemSearchApp extends ConsumerStatefulWidget {
  const ItemSearchApp({super.key});

  @override
  ItemSearchAppState createState() => ItemSearchAppState();
}

class ItemSearchAppState extends ConsumerState {
  final TextEditingController _fnskuController = TextEditingController();
  final TextEditingController _janController = TextEditingController();
  bool checkFlg = false;
  bool isLoading = false;
  ItemDatabase itemDatabase = ItemDatabase();

  Future<void> scanBarcodeNormal(TextEditingController controller) async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      controller.text = barcodeScanRes;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("入荷"),
        ),
        body: Navigator(onGenerateRoute: (_) {
          return MaterialPageRoute(builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: context.screenHeight * 0.03,
                    ),
                    Container(
                      height: context.screenHeight * 0.1,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(width: 2, color: Colors.yellowAccent)),
                      child: Row(
                        children: [
                          SizedBox(
                            width: context.screenWidth * 0.5,
                            child: TextField(
                              controller: _janController,
                              onChanged: (newText) {
                                setState(() {});
                              },
                              decoration: const InputDecoration(
                                hintText: 'jan',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: context.screenWidth * 0.02,
                          ),
                          Container(
                            decoration: BoxDecoration(border: Border.all()),
                            child: Center(
                              child: IconButton(
                                onPressed: () async {
                                  await scanBarcodeNormal(_janController);

                                  setState(() {});
                                },
                                icon: const Icon(Icons.camera_alt),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: context.screenHeight * 0.1,
                    ),
                    Container(
                      height: context.screenHeight * 0.1,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(width: 2, color: Colors.greenAccent)),
                      child: Row(
                        children: [
                          SizedBox(
                            width: context.screenWidth * 0.5,
                            child: TextField(
                              controller: _fnskuController,
                              onChanged: (newText) {
                                setState(() {});
                              },
                              decoration: const InputDecoration(
                                hintText: 'Fnsku',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: context.screenWidth * 0.02,
                          ),
                          Container(
                            decoration: BoxDecoration(border: Border.all()),
                            child: Center(
                              child: IconButton(
                                onPressed: () async {
                                  await scanBarcodeNormal(_fnskuController);

                                  setState(() {});
                                },
                                icon: const Icon(Icons.camera_alt),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: context.screenHeight * 0.1,
                    ),
                    SizedBox(
                      child: ElevatedButton(
                        child: const Text("検索"),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return SearchLuggagesApp(_fnskuController.text,
                                    int.tryParse(_janController.text));
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: context.screenHeight * 0.05,
                    ),
                  ],
                ),
              ),
            );
          });
        }),
        floatingActionButton: SpeedDial(
          icon: Icons.menu,
          activeIcon: Icons.close,
          spacing: 3,
          direction: SpeedDialDirection.up,
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
              label: '更新',
              labelStyle: const TextStyle(fontSize: 18.0),
              onTap: () async {
                setState(() {
                  isLoading = true;
                });
                ref.read(itemListProvider.notifier).clearList();
                await itemDatabase.getallItems(ref);

                setState(() {
                  isLoading = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
