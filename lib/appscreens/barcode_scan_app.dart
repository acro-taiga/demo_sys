import 'dart:async';

import 'package:collection/collection.dart';
import 'package:delivery_control_web/exSize.dart';
import 'package:delivery_control_web/models/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:url_launcher/url_launcher.dart';

class BarcodeReadApp extends ConsumerStatefulWidget {
  const BarcodeReadApp({super.key});

  @override
  BarcodeReadAppState createState() => BarcodeReadAppState();
}

class BarcodeReadAppState extends ConsumerState<BarcodeReadApp> {
  final TextEditingController _fnskuController = TextEditingController();
  final TextEditingController _janController = TextEditingController();
  bool checkFlg = false;
  AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
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

  Future<void> checkBarocde() async {
    print("tes");
    AmazonItem? item = ref.watch(itemListProvider).firstWhereOrNull(
        (element) => element.fnskuCode == _fnskuController.text);
    if (item == null) {
      return;
    }
    if (int.tryParse(_janController.text) != null) {
      Item? itemjan = item.itemList.lastWhereOrNull(
          (element) => element.janCode == int.parse(_janController.text));

      if (itemjan == null) {
        setState(() {
          checkFlg = false;
        });
      } else {
        setState(() {
          checkFlg = true;
        });
        await player.setAsset('assets/OK.mp3');
        player.play();
      }
    } else {
      setState(() {
        checkFlg = false;
      });
    }
  }

  Future<void> _launchUrl() async {
    AmazonItem? item = ref.watch(itemListProvider).firstWhereOrNull(
        (element) => element.fnskuCode == _fnskuController.text);

    if (item == null) {
      return;
    }

    final Uri url = Uri.parse('https://www.amazon.co.jp/dp/${item.asin}');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        "バーコードスキャン",
      )),
      body: Padding(
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
                    border: Border.all(width: 2, color: Colors.yellowAccent)),
                child: Row(
                  children: [
                    SizedBox(
                      width: context.screenWidth * 0.5,
                      child: TextField(
                        controller: _janController,
                        onChanged: (newText) {
                          checkBarocde();
                          setState(() {});
                        },
                        decoration: const InputDecoration(
                          hintText: 'JAN',
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
                            checkBarocde();
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
                    border: Border.all(width: 2, color: Colors.greenAccent)),
                child: Row(
                  children: [
                    SizedBox(
                      width: context.screenWidth * 0.5,
                      child: TextField(
                        controller: _fnskuController,
                        onChanged: (newText) {
                          checkBarocde();
                          setState(() {});
                        },
                        decoration: const InputDecoration(
                          hintText: 'FNSKU',
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
                            checkBarocde();
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
                height: context.screenHeight * 0.2,
                child: checkFlg
                    ? const Center(
                        child: Text(
                          "OK",
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Colors.blue),
                        ),
                      )
                    : const Center(
                        child: Text(
                          "NG",
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: Colors.red),
                        ),
                      ),
              ),
              SizedBox(
                height: context.screenHeight * 0.05,
              ),
              SizedBox(
                child: ElevatedButton(
                  child: const Text("amazonページへ"),
                  onPressed: () {
                    _launchUrl();
                  },
                ),
              ),
              SizedBox(
                height: context.screenHeight * 0.05,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
