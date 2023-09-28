import 'dart:convert';
import 'dart:html';
import 'package:csv/csv.dart';
import 'package:delivery_control_web/common/popup.dart';
import 'package:delivery_control_web/exSize.dart';
import 'package:delivery_control_web/models/customer.dart';
import 'package:delivery_control_web/models/item.dart';
import 'package:delivery_control_web/models/loginUser.dart';
import 'package:delivery_control_web/providers/item_database_provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:url_launcher/url_launcher.dart';

class LuggageImport extends ConsumerStatefulWidget {
  const LuggageImport({super.key});

  @override
  ConsumerState<LuggageImport> createState() => _LuggageImport();
}

class _LuggageImport extends ConsumerState<LuggageImport> {
  late DropzoneViewController _controller;
  final TextEditingController _usercontroller = TextEditingController();
  String? _filename;
  String? _fileMIME;
  Uint8List? _fileData;
  bool _hoverFlag = false;
  String? selectBase;
  bool isLoading = false;
  List<dynamic> todoList = [];
  ItemDatabase itemDatabase = ItemDatabase();
  List<String> errAsin = [];

  String? selectedUser;

  Future<bool> addItem(Uint8List uint8) async {
    List<List<String>> utfData =
        const CsvToListConverter(shouldParseNumbers: false)
            .convert(utf8.decode(uint8));

    if (selectBase == null) {
      await PopupAlert.alert(context, '拠点が未選択です。', (context) {
        Navigator.of(context).pop();
      });
      setState(() {
        _fileMIME = null;
      });
      return false;
    }

    if (ref.read(loginUserProvider).adimnFig && selectedUser == null) {
      await PopupAlert.alert(context, 'ユーザーが未選択です。', (context) {
        Navigator.of(context).pop();
      });
      setState(() {
        _fileMIME = null;
      });
      return false;
    }
    bool errorFlg = false;

    List<List<String>> utfGetData = [];

    for (var row = 0; row < utfData.length; row++) {
      if (row == 101) {
        errorFlg = true;
        break;
      }

      // 出品者SKU,FNSKU,ASIN,商品名,JAN,セット数,予定出荷単位数

      List<String> data = utfData[row];
      if (data.length != 7) {
        setState(() {
          _fileMIME = "lengtherror";
        });
        errorFlg = true;
        continue;
      }

      if (data[0] == "出品者SKU") {
        continue;
      }
      int getSetNum = int.tryParse(data[5]) ?? 0;
      int getShippingNum = int.tryParse(data[6]) ?? 0;

      if (int.tryParse(data[4]) == null) {
        errAsin.add(data[2]);
        continue;
      }
      if (getSetNum == 0 || getShippingNum == 0) {
        errAsin.add(data[2]);
        continue;
      }

      if (data[0] == "" ||
          data[1] == "" ||
          data[2] == "" ||
          data[3] == "" ||
          data[4] == "" ||
          data[5] == "" ||
          data[6] == "") {
        errAsin.add(data[2]);
        continue;
      }

      utfGetData.add(data);
    }

    if (errorFlg) {
      return errorFlg;
    }

    await showDialog<void>(
        context: context,
        builder: (_) {
          return YesNoDialog(
              title: "確認",
              message:
                  "取り込み：${utfGetData.length}件\n失敗：${errAsin.length}件\n\n取り込みを実行しますか。",
              onYesAction: () async {
                for (var data in utfGetData) {
                  int getSetNum = int.tryParse(data[5]) ?? 0;
                  int getShippingNum = int.tryParse(data[6]) ?? 0;
                  // itemDatabase.addNewItem(AmazonItem(
                  //   shippeddate: null,
                  //   itemId: "",
                  //   uid: ref.read(loginUserProvider).uid,
                  //   userName: ref.read(loginUserProvider).adimnFig
                  //       ? selectedUser!
                  //       : ref.read(loginUserProvider).name,
                  //   amazonItemName: data[3],
                  //   asin: data[2],
                  //   itemList: [
                  //     Item(
                  //         itemName: data[3],
                  //         janCode: int.tryParse(data[4]) ?? 0,
                  //         setNum: 1,
                  //         shippingNum: 1,
                  //         actualShippingNum: 0,
                  //         sumNum: 0,
                  //         arriveNum: 1,
                  //         place: "",
                  //         expiryDate: null),
                  //   ],
                  //   arriveDate: DateTime.now().weekday == 1
                  //       ? DateTime.now()
                  //           .add(Duration(days: 6 - DateTime.now().weekday))
                  //       : DateTime.now().add(
                  //           Duration(days: 6 - DateTime.now().weekday + 7)),
                  //   createdAt: DateTime.now(),
                  //   shippingNum: getShippingNum,
                  //   actualShippingNum: 0,
                  //   base: selectBase!,
                  //   status: "未入力",
                  //   sku: data[0],
                  //   fnskuCode: data[1],
                  //   arriveNum: getSetNum * getShippingNum,
                  //   sumNum: 0,
                  //   notes: [],
                  //   setNum: getSetNum,
                  //   expiryDate: null,
                  //   isSelected: false,
                  //   arrivedDate: null,
                  //   stickerNum: 0,
                  //   destructionNum: 0,
                  //   returnNum: 0,
                  //   largeFlg: false,
                  //   editJanFlg: false,
                  //   addAdminFlg: ref.read(loginUserProvider).adimnFig,
                  // ));
                }

                if (!mounted) {
                  return;
                }
                Navigator.pop(context);
              });
        });

    return errorFlg;
  }

  // ファイルがドロップされたら情報を読み込んでから、画面を更新する。
  void _handleFileDrop(dynamic ev) async {
    // ファイル情報を読み込む。
    setState(() {
      isLoading = true;
    });
    try {
      // inspect(ev);
      _filename = await _controller.getFilename(ev);
      _fileMIME = await _controller.getFileMIME(ev);
      _fileData = await _controller.getFileData(ev);

      // 一時的なリンクを生成して表示する。
      print(_fileMIME);
      // _controller.releaseFileUrl(url);
      if (_fileMIME == "text/csv") {
        bool res = await addItem(_fileData!);
        if (res) {
          if (_fileMIME == "lengtherror") {
            if (!mounted) return;
            await showDialog<void>(
                context: context,
                builder: (_) {
                  return const YesDialog(
                    title: "アラート",
                    message: "取り込んだCSVに予期しないデータが含まれています。\n確認して再度アップロードしてください",
                  );
                });
          } else {
            if (!mounted) return;
            await showDialog<void>(
                context: context,
                builder: (_) {
                  return const YesDialog(
                    title: "アラート",
                    message: "100件が取り込み上限です。\n分割して再度アップロードしてください",
                  );
                });
            setState(() {
              _fileMIME = 'lineOver';
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        _fileMIME = 'err';
      });
      print(e);
    }
    // ホバー状態の表示を解除する。
    _hoverFlag = false;

    // ファイル情報が揃ったら描画を更新する。
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

  TextSpan span(String test) {
    return TextSpan(text: test, style: TextStyle(color: Colors.black));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: context.screenHeight * 0.8,
          width: context.screenWidth * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: context.screenHeight * 0.1,
              ),
              SizedBox(
                child: baseCell(),
              ),
              if (ref.watch(loginUserProvider).adimnFig)
                SizedBox(
                  height: context.screenHeight * 0.1,
                ),
              if (ref.watch(loginUserProvider).adimnFig)
                SizedBox(
                  child: filterUserPull(),
                ),
              Expanded(
                child: SizedBox(
                  child: Stack(children: [
                    DropzoneView(
                      operation: DragOperation.move,
                      cursor: CursorType.auto,
                      onCreated: (ctrl) => _controller = ctrl,
                      onDrop: (ev) => _handleFileDrop(ev),
                      onError: (ev) => print('Error: $ev'),
                      onHover: () => setState(() {
                        _hoverFlag = true;
                      }),
                      onLeave: () => setState(() {
                        _hoverFlag = false;
                      }),
                    ),
                    Container(
                      color: _hoverFlag ? Colors.grey : null,
                      child: dropViewArea(context),
                    ),
                    if (_fileMIME == null)
                      SizedBox(
                        height: context.screenHeight * 0.2,
                        child: Align(
                          alignment: const Alignment(0, 0),
                          child: ElevatedButton(
                            onPressed: () async {
                              const XTypeGroup typeGroup = XTypeGroup(
                                label: 'csvデータ',
                                extensions: ['csv'],
                              );
                              final XFile? file = await openFile(
                                  acceptedTypeGroups: [typeGroup]);
                              if (file == null) {
                                return;
                              }
                              setState(() {
                                _fileMIME = 'text/csv';
                                isLoading = true;
                              });
                              Uint8List b = await file.readAsBytes();
                              try {
                                bool res = await addItem(b);

                                if (res) {
                                  if (_fileMIME == "lengtherror") {
                                    if (!mounted) return;
                                    await showDialog<void>(
                                        context: context,
                                        builder: (_) {
                                          return const YesDialog(
                                            title: "アラート",
                                            message:
                                                "取り込んだCSVに予期しないデータが含まれています。\n確認して再度アップロードしてください",
                                          );
                                        });
                                  } else {
                                    if (!mounted) return;
                                    await showDialog<void>(
                                        context: context,
                                        builder: (_) {
                                          return const YesDialog(
                                            title: "アラート",
                                            message:
                                                "100件が取り込み上限です。\n分割して再度アップロードしてください",
                                          );
                                        });
                                    setState(() {
                                      _fileMIME = 'lineOver';
                                    });
                                  }
                                }
                              } catch (e) {
                                setState(() {
                                  _fileMIME = 'err';
                                });
                                print(e);
                              }

                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: const Text("ファイル読込",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RichText(
              text: TextSpan(children: [
            span(
              '・手順',
            ),
            span('\n1 '),
            TextSpan(
                text: 'こちら',
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    final csv = const ListToCsvConverter().convert([
                      [
                        "出品者SKU",
                        "FNSKU",
                        "ASIN",
                        "商品名",
                        "JAN",
                        "セット数",
                        "予定出荷単位数",
                      ],
                      [],
                    ]);
                    AnchorElement anchorElement;
                    final bomUtf8Csv = [0xEF, 0xBB, 0xBF, ...utf8.encode(csv)];
                    final base64CsvBytes = base64Encode(bomUtf8Csv);
                    anchorElement = AnchorElement(
                      href:
                          'data:text/plain;charset=utf-8;base64,$base64CsvBytes',
                    );
                    anchorElement
                      ..setAttribute('download', 'csvformat.csv')
                      ..click();
                  }),
            span(
              'からcsvフォーマットをダウンロード',
            ),
            span(
              '\n2 ダウンロードしたファイルにデータを挿入',
            ),
            span(
              '\n　以下のサイトを使うと便利です。',
            ),
            TextSpan(
                text: '\n　https://caju.jp/ikkatu/henkan',
                style: const TextStyle(color: Colors.blue),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final Uri url = Uri.parse('https://caju.jp/ikkatu/henkan');
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                  }),
            span(
              '\n3 csvファイルの文字コードや改行コードを確認',
            ),
            span(
              '\n　※文字コード:utf-8　改行コード:CRLF',
            ),
            span(
              '\n4 指定のファイルをドラッグアンドドロップか',
            ),
            span(
              '\n　「ファイル読み込み」から選択',
            ),
            span(
              '\n5 更新ボタンを押下',
            ),
            span(
              '\n6 JANやその他の項目が適切か確認し、',
            ),
            span(
              '\n　ステータスを「入荷待ち」に変える',
            ),
            span(
              '\n※FNSKUの確認方法',
            ),
            span(
              '\n　セラーセントラル→レポート→フルフィルメント→FBA 在庫管理→',
            ),
            span(
              '\n 「csv形式でのダウンロードをリクエスト」後のCSVからFNSKUの確認が可能です。',
            ),
            span(
              '\n※JANコードの未記入や誤りは追加料金をいただきますので',
            ),
            span(
              '\n　必ずご確認ください。',
            ),
          ])),
        ),
      ],
    );
  }

  Widget dropViewArea(BuildContext context) => Builder(builder: (context) {
        if (_fileMIME == null) {
          // まだドロップされていないとき。
          return const Center(child: Text('ここにファイルをドロップしてください'));
        } else if (_fileMIME!.startsWith('text/csv') ||
            _fileMIME!.startsWith('lengtherror')) {
          // テキストファイルのとき。
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Column(children: [
              if (errAsin.isNotEmpty)
                Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    height: context.screenHeight * 0.09,
                    child:
                        const Center(child: Text("以下のASINで未記入または入力不備がありました。"))),
              if (errAsin.isNotEmpty)
                Expanded(
                    child: Center(
                  child: SizedBox(
                    width: context.screenWidth * 0.3,
                    child: ListView.builder(
                        padding: const EdgeInsets.all(7),
                        itemCount: errAsin.length,
                        itemBuilder: (context, index) {
                          return Text('・ ${errAsin[index]}');
                        }),
                  ),
                )),
              SizedBox(
                height: context.screenHeight * 0.03,
              ),
              SizedBox(
                height: context.screenHeight * 0.05,
                child: ElevatedButton(
                    child: const Text("やり直す"),
                    onPressed: () {
                      setState(() {
                        errAsin = [];
                        _fileMIME = null;
                      });
                    }),
              ),
              SizedBox(
                height: context.screenHeight * 0.02,
              ),
              SizedBox(
                height: context.screenHeight * 0.05,
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("完了")),
              ),
            ]),
          );
        } else if (_fileMIME!.startsWith('lineOver')) {
          final str = [
            '上限を超えたデータを検出しました。',
          ].join('\n');
          return Center(
            child: Column(children: [
              Text(str),
              SizedBox(
                child: ElevatedButton(
                    child: const Text("やり直す"),
                    onPressed: () {
                      setState(() {
                        errAsin = [];
                        _fileMIME = null;
                      });
                    }),
              ),
            ]),
          );
        } else {
          // 想定していないタイプのファイルがドロップされたとき。
          final str = [
            '対応していない形式のファイルがアップロードされました',
            'csvファイルで、文字コードがutf-8、改行コードがCRLFであることを確認してください',
          ].join('\n');
          return Center(
            child: Column(children: [
              Text(str),
              SizedBox(
                child: ElevatedButton(
                    child: const Text("やり直す"),
                    onPressed: () {
                      setState(() {
                        errAsin = [];
                        _fileMIME = null;
                      });
                    }),
              ),
            ]),
          );
        }
      });
}
