import 'package:collection/collection.dart';
import 'package:delivery_control_web/models/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';
import '../exSize.dart';

class BarcodeRead extends ConsumerStatefulWidget {
  const BarcodeRead({super.key});

  @override
  _BarcodeRead createState() => _BarcodeRead();
}

class _BarcodeRead extends ConsumerState<BarcodeRead> {
  late final TextEditingController _fnskuController = TextEditingController();
  late final TextEditingController _janController = TextEditingController();
  bool checkFlg = false;
  AudioPlayer player = AudioPlayer();
  Future<void> checkBarocde() async {
    AmazonItem? item = ref.read(itemListProvider).firstWhereOrNull(
        (element) => element.fnskuCode == _fnskuController.text);
    if (item == null) {
      checkFlg = false;
      return;
    }
    if (int.tryParse(_janController.text) != null) {
      Item? itemjan = item.itemList.lastWhereOrNull(
          (element) => element.janCode == int.parse(_janController.text));

      if (itemjan == null) {
        setState(() {
          checkFlg = false;
        });
        await player.setAsset('assets/Quiz-Wrong_Buzzer02-1.mp3');
        player.play();
      } else {
        setState(() {
          checkFlg = true;
        });
        await player.setAsset('assets/Quiz-Correct_Answer01-1.mp3');
        player.play();
      }
    } else {
      setState(() {
        checkFlg = false;
      });
      await player.setAsset('assets/Quiz-Wrong_Buzzer02-1.mp3');
      player.play();
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
      body: Stack(children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          // child: Lottie.network(
          //   'https://assets8.lottiefiles.com/private_files/lf30_q4042luw.json',
          //   fit: BoxFit.cover,
          //   errorBuilder: (context, error, stackTrace) {
          //     return const Padding(
          //       padding: EdgeInsets.all(30.0),
          //     );
          //   },
          // ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: BarcodeKeyboardListener(
            bufferDuration: const Duration(milliseconds: 200),
            onBarcodeScanned: (value) async {
              if (value.length == 10) {
                _fnskuController.text = value.toUpperCase();
              } else if (value.length == 13) {
                _janController.text = value.toUpperCase();
              } else {
                return;
              }
              checkBarocde();
              setState(() {});
            },
            child: Center(
              child: Container(
                width: context.screenWidth * 0.7,
                child: Column(
                  children: [
                    SizedBox(
                      height: context.screenHeight * 0.1,
                    ),
                    Container(
                        height: context.screenHeight * 0.05,
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          'JANコード',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    Container(
                      height: context.screenHeight * 0.07,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: primeColor,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Center(
                          child: TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9]')),
                            ],
                            controller: _janController,
                            onChanged: (newText) {
                              checkBarocde();
                              setState(() {});
                            },
                            decoration: const InputDecoration(
                              hintText: 'JANコードを読み取ってください',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: context.screenHeight * 0.05,
                    ),
                    Container(
                      height: context.screenHeight * 0.05,
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'FNSKUコード',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: context.screenHeight * 0.07,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 2,
                          color: primeColor,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Center(
                          child: TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9]')),
                            ],
                            controller: _fnskuController,
                            onChanged: (newText) {
                              checkBarocde();
                              setState(() {});
                            },
                            decoration: const InputDecoration(
                              hintText: 'FNSKUコードを読み取ってください',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: context.screenHeight * 0.05,
                    ),
                    SizedBox(
                      height: context.screenHeight * 0.2,
                      child: _fnskuController.text == '' ||
                              _janController.text == ''
                          ? const Center(
                              child: Text(
                                'FNSKUコードもしくはJANコードが読み取られていません',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : checkFlg
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
                      width: context.screenWidth * 0.15,
                      height: context.screenHeight * 0.08,
                      child: ElevatedButton(
                        child: const Text("Amazonページ"),
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
          ),
        ),
      ]),
    );
  }
}
