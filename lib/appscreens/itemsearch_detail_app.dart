import 'package:delivery_control_web/common/popup.dart';
import 'package:delivery_control_web/exSize.dart';
import 'package:delivery_control_web/models/item.dart';
import 'package:delivery_control_web/models/status.dart';
import 'package:delivery_control_web/models/loginUser.dart';
import 'package:delivery_control_web/providers/item_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:url_launcher/url_launcher.dart';

DateFormat outputFormat = DateFormat('yyyy/MM/dd');

class SearchLuggagesAppDetail extends ConsumerStatefulWidget {
  final AmazonItem item;
  const SearchLuggagesAppDetail(this.item, {super.key});

  @override
  ConsumerState<SearchLuggagesAppDetail> createState() =>
      SearchLuggagesAppDetailState();
}

class SearchLuggagesAppDetailState
    extends ConsumerState<SearchLuggagesAppDetail> {
  late List<TextEditingController> dateController;

  late List<TextEditingController> textController;

  late List<String> statusController;
  late String selectBase;
  TextEditingController noteController = TextEditingController();

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
      bool readOnly, BoxDecoration? decoration) {
    // controller.selection =
    // TextSelection.collapsed(offset: controller.text.length);
    return Container(
        decoration: decoration,
        child: TextField(
          textAlign: TextAlign.center,
          controller: controller,
          readOnly: readOnly,
          onChanged: (value) {
            // setState(() {
            method();
            // });
          },
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
        ));
  }

  Widget dateCell(TextEditingController dateController, method, bool readOnly) {
    return Container(
      width: context.screenWidth * 0.4,
      decoration: BoxDecoration(border: Border.all()),
      child: TextField(
        controller: dateController,
        textInputAction: TextInputAction.next,
        enabled: true,
        readOnly: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
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
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      width: context.screenWidth * 0.4,
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
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
      ),
    );
  }

  Widget baseCell() {
    return Container(
      decoration: BoxDecoration(border: Border.all()),
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

  Widget headerText(String text) {
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      height: context.screenHeight * 0.05,
      child: Center(child: Text(text)),
    );
  }

  void _init() {
    dateController = List.generate(
        3 + widget.item.itemList.length, (i) => TextEditingController());
    textController = List.generate(
        10 + (widget.item.itemList.length * 8), (i) => TextEditingController());
    statusController = List.generate(1, (i) => "");

    dateController[0].text = widget.item.arrivedDate == null
        ? ""
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
    textController[8].text = widget.item.userName;
    textController[9].text = widget.item.actualShippingNum.toString();
    statusController[0] = widget.item.status;
    selectBase = widget.item.base;
    for (var i = 0; i < widget.item.itemList.length; i++) {
      dateController[i + 3].text = widget.item.itemList[i].expiryDate == null
          ? ""
          : outputFormat.format(widget.item.itemList[i].expiryDate!);

      widget.item.itemList[i].arriveNum =
          widget.item.itemList[i].setNum * widget.item.itemList[i].shippingNum;
      // テキストを入れる
      textController[(i * 8) + 10].text =
          widget.item.itemList[i].janCode.toString();
      textController[(i * 8) + 11].text = widget.item.itemList[i].itemName;
      textController[(i * 8) + 12].text =
          widget.item.itemList[i].setNum.toString();
      textController[(i * 8) + 13].text =
          widget.item.itemList[i].shippingNum.toString();
      textController[(i * 8) + 14].text =
          widget.item.itemList[i].arriveNum.toString();
      textController[(i * 8) + 15].text = widget.item.itemList[i].sumNum == null
          ? ""
          : widget.item.itemList[i].sumNum.toString();
      textController[(i * 8) + 16].text = widget.item.itemList[i].place;
      textController[(i * 8) + 17].text =
          widget.item.itemList[i].actualShippingNum.toString();
    }
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    // ref.read(itemListProvider.notifier).clearList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Future.value(true);
      },
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: context.screenHeight * 0.1,
                      child: Stack(
                        children: [
                          Align(
                            alignment: const Alignment(-1, 1),
                            child: SizedBox(
                              height: context.screenHeight * 0.1,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context, widget.item.isSelected);
                                },
                                icon: const Icon(
                                  Icons.close,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: const Alignment(-0.6, 0.8),
                            child: Container(
                              padding: const EdgeInsets.only(left: 5, top: 5),
                              child: GestureDetector(
                                onTap: () async {
                                  final Uri url = Uri.parse(
                                      'https://www.amazon.co.jp/dp/${widget.item.asin}');
                                  if (!await launchUrl(url)) {
                                    throw Exception('Could not launch $url');
                                  }
                                  // do something
                                },
                                child: Container(
                                  decoration:
                                      BoxDecoration(border: Border.all()),
                                  child: Image.network(
                                    "https://images-fe.ssl-images-amazon.com/images/P/${widget.item.asin}.09.MZZZZZZZ",
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Center(child: Text("商品概要")),
                          Align(
                            alignment: const Alignment(1, -1),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SizedBox(
                                  width: context.screenWidth * 0.2,
                                  child: Center(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        setState(() {
                                          isLoading = true;
                                        });

                                        if (widget.item.shippingNum ==
                                                widget.item.actualShippingNum ||
                                            !ref
                                                .watch(loginUserProvider)
                                                .adimnFig) {
                                          await itemDatabase
                                              .editItem(widget.item);
                                        } else {
                                          await showDialog<void>(
                                              context: context,
                                              builder: (_) {
                                                return YesNoDialog(
                                                    title: "アラート",
                                                    message:
                                                        "予定出荷単位数と実出荷単位数が異なっています。\n入荷確定しますか",
                                                    onYesAction: () async {
                                                      await itemDatabase
                                                          .editItem(
                                                              widget.item);
                                                      if (!mounted) {
                                                        return;
                                                      }
                                                      Navigator.pop(context);
                                                    });
                                              });
                                        }

                                        setState(() {
                                          isLoading = false;
                                        });
                                        if (!mounted) return;
                                        Navigator.pop(context);
                                      },
                                      child: const Text("入荷"),
                                    ),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      height: context.screenHeight * 0.15,
                      child: Row(children: [
                        SizedBox(
                          width: context.screenWidth * 0.4,
                          child: Column(
                            children: [
                              headerText("到着予定日"),
                              SizedBox(
                                  child: dateCell(
                                dateController[2],
                                () {
                                  setState(() {
                                    if (dateController[2].text == "") {
                                      widget.item.arriveDate = null;
                                    } else {
                                      widget.item.arriveDate =
                                          DateFormat('yyyy/MM/dd')
                                              .parse(dateController[2].text);
                                    }
                                  });
                                },
                                false,
                              ))
                            ],
                          ),
                        ),
                        SizedBox(
                          width: context.screenWidth * 0.4,
                          child: Column(
                            children: [
                              headerText("到着日"),
                              dateCell(
                                dateController[0],
                                () {
                                  setState(() {
                                    if (dateController[0].text == "") {
                                      widget.item.arrivedDate = null;
                                    } else {
                                      widget.item.arrivedDate =
                                          DateFormat('yyyy/MM/dd')
                                              .parse(dateController[0].text);
                                    }
                                  });
                                },
                                false,
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: context.screenWidth * 0.4,
                          child: Column(
                            children: [
                              headerText("商品名"),
                              subRowCell(
                                textController[0],
                                () {
                                  widget.item.amazonItemName =
                                      textController[0].text;
                                },
                                false,
                                BoxDecoration(border: Border.all()),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: context.screenWidth * 0.4,
                          child: Column(
                            children: [
                              headerText("ASIN"),
                              subRowCell(
                                textController[1],
                                () {
                                  widget.item.asin = textController[1].text;
                                },
                                false,
                                BoxDecoration(border: Border.all()),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: context.screenWidth * 0.4,
                          child: Column(
                            children: [
                              headerText("SKU"),
                              subRowCell(
                                textController[2],
                                () {
                                  widget.item.sku = textController[2].text;
                                },
                                false,
                                BoxDecoration(border: Border.all()),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: context.screenWidth * 0.4,
                          child: Column(
                            children: [
                              headerText("FNSKU"),
                              subRowCell(
                                textController[3],
                                () {
                                  widget.item.fnskuCode =
                                      textController[3].text;
                                },
                                false,
                                BoxDecoration(border: Border.all()),
                              )
                            ],
                          ),
                        ),
                        if (widget.item.itemList.length == 1)
                          SizedBox(
                            width: context.screenWidth * 0.4,
                            child: Column(
                              children: [
                                headerText("JAN"),
                                subRowCell(
                                  textController[10],
                                  () {
                                    widget.item.itemList[0].janCode =
                                        int.tryParse(textController[10].text) ??
                                            0;
                                  },
                                  false,
                                  BoxDecoration(border: Border.all()),
                                )
                              ],
                            ),
                          ),
                        SizedBox(
                          width: context.screenWidth * 0.4,
                          child: Column(
                            children: [
                              headerText("セット数"),
                              subRowCell(textController[4], () {
                                widget.item.setNum =
                                    int.tryParse(textController[4].text) ?? 0;
                                widget.item.actualShippingNum =
                                    (widget.item.sumNum! / widget.item.setNum)
                                        .round();

                                textController[9].text =
                                    widget.item.actualShippingNum.toString();
                              },
                                  false,
                                  BoxDecoration(
                                      border: Border.all(), color: Colors.pink))
                            ],
                          ),
                        ),
                        SizedBox(
                          width: context.screenWidth * 0.4,
                          child: Column(
                            children: [
                              headerText("予定出荷単位数"),
                              subRowCell(
                                textController[5],
                                () {
                                  widget.item.shippingNum =
                                      int.parse(textController[5].text);
                                  widget.item.arriveNum = widget.item.setNum *
                                      widget.item.shippingNum;
                                },
                                true,
                                BoxDecoration(border: Border.all()),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: context.screenWidth * 0.4,
                          child: Column(
                            children: [
                              headerText("予定入荷総数"),
                              subRowCell(textController[6], () {
                                widget.item.arriveNum =
                                    int.tryParse(textController[6].text) ?? 0;
                              }, true, BoxDecoration(border: Border.all()))
                            ],
                          ),
                        ),
                        SizedBox(
                          width: context.screenWidth * 0.4,
                          child: Column(
                            children: [
                              headerText("実出荷単位数"),
                              subRowCell(
                                textController[9],
                                () {
                                  widget.item.actualShippingNum =
                                      int.tryParse(textController[9].text) ?? 0;
                                },
                                true,
                                BoxDecoration(border: Border.all()),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: context.screenWidth * 0.4,
                          child: Column(
                            children: [
                              headerText("実入荷総数"),
                              subRowCell(
                                textController[7],
                                () {
                                  widget.item.sumNum =
                                      int.tryParse(textController[7].text) ?? 0;
                                  widget.item.actualShippingNum =
                                      (widget.item.sumNum! / widget.item.setNum)
                                          .round();

                                  textController[9].text =
                                      widget.item.actualShippingNum.toString();
                                },
                                false,
                                BoxDecoration(
                                    border: Border.all(), color: Colors.pink),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: context.screenWidth * 0.4,
                          child: Column(
                            children: [
                              headerText("賞味期限"),
                              dateCell(
                                dateController[1],
                                () {
                                  setState(() {
                                    if (dateController[1].text == "") {
                                      widget.item.expiryDate = null;
                                    } else {
                                      widget.item.expiryDate =
                                          DateFormat('yyyy/MM/dd')
                                              .parse(dateController[1].text);
                                    }
                                  });
                                },
                                false,
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: context.screenWidth * 0.4,
                          child: Column(
                            children: [
                              headerText("ユーザー"),
                              subRowCell(
                                textController[8],
                                () {
                                  widget.item.userName = textController[8].text;
                                },
                                true,
                                BoxDecoration(border: Border.all()),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: context.screenWidth * 0.4,
                          child: Column(
                            children: [
                              headerText("ステータス"),
                              statusPullDown(statusController[0], (value) {
                                setState(() {
                                  statusController[0] = value;
                                  widget.item.status = statusController[0];
                                });
                              })
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                  SizedBox(
                    height: context.screenHeight * 0.05,
                    child: const Center(child: Text("商品一覧")),
                  ),
                  // ここsizedboxでもいけないか
                  SizedBox(
                    height: context.screenHeight * 0.2,
                    child: SingleChildScrollView(
                        child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: widget.item.itemList.length == 1
                          ? Center(
                              child: SizedBox(
                                width: context.screenWidth * 0.2,
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
                            )
                          : SizedBox(
                              height: context.screenHeight * 0.2,
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: context.screenHeight * 0.1,
                                    width: context.screenWidth * 3.7,
                                    child: Row(children: [
                                      SizedBox(
                                        width: context.screenWidth * 0.4,
                                        child: headerText("JAN"),
                                      ),
                                      SizedBox(
                                        width: context.screenWidth * 0.4,
                                        child: headerText("商品名"),
                                      ),
                                      SizedBox(
                                        width: context.screenWidth * 0.4,
                                        child: headerText("セット数"),
                                      ),
                                      SizedBox(
                                        width: context.screenWidth * 0.4,
                                        child: headerText("予定出荷単位数"),
                                      ),
                                      SizedBox(
                                        width: context.screenWidth * 0.4,
                                        child: headerText("予定入荷総数"),
                                      ),
                                      SizedBox(
                                        width: context.screenWidth * 0.4,
                                        child: headerText("実出荷単位数"),
                                      ),
                                      SizedBox(
                                        width: context.screenWidth * 0.4,
                                        child: headerText("実入荷総数"),
                                      ),
                                      SizedBox(
                                        width: context.screenWidth * 0.4,
                                        child: headerText("賞味期限"),
                                      ),
                                      SizedBox(
                                        width: context.screenWidth * 0.4,
                                        child: headerText("保管場所"),
                                      ),
                                      SizedBox(
                                        width: context.screenWidth * 0.2,
                                        child: headerText("削除"),
                                      ),
                                    ]),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: SizedBox(
                                        height: context.screenHeight * 0.15,
                                        width: context.screenWidth * 3.7,
                                        child: ListView.builder(
                                          itemCount:
                                              widget.item.itemList.length,
                                          itemBuilder: (context, itemindex) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width:
                                                      context.screenWidth * 0.4,
                                                  child: subRowCell(
                                                      textController[
                                                          (itemindex * 8) + 10],
                                                      () {
                                                    widget
                                                        .item
                                                        .itemList[itemindex]
                                                        .janCode = int.tryParse(
                                                            textController[
                                                                    (itemindex *
                                                                            8) +
                                                                        10]
                                                                .text) ??
                                                        0;
                                                  },
                                                      false,
                                                      BoxDecoration(
                                                          border:
                                                              Border.all())),
                                                ),
                                                SizedBox(
                                                  width:
                                                      context.screenWidth * 0.4,
                                                  child: subRowCell(
                                                      textController[
                                                          (itemindex * 8) + 11],
                                                      () {
                                                    widget
                                                            .item
                                                            .itemList[itemindex]
                                                            .itemName =
                                                        textController[
                                                                (itemindex *
                                                                        8) +
                                                                    11]
                                                            .text;
                                                  },
                                                      false,
                                                      BoxDecoration(
                                                        border: Border.all(),
                                                      )),
                                                ),
                                                SizedBox(
                                                    width: context.screenWidth *
                                                        0.4,
                                                    child: subRowCell(
                                                      textController[
                                                          (itemindex * 8) + 12],
                                                      () {
                                                        widget
                                                            .item
                                                            .itemList[itemindex]
                                                            .setNum = int.tryParse(
                                                                textController[
                                                                        (itemindex *
                                                                                8) +
                                                                            12]
                                                                    .text) ??
                                                            0;
                                                        widget
                                                            .item
                                                            .itemList[itemindex]
                                                            .actualShippingNum = (widget
                                                                    .item
                                                                    .itemList[
                                                                        itemindex]
                                                                    .sumNum! /
                                                                widget
                                                                    .item
                                                                    .itemList[
                                                                        itemindex]
                                                                    .setNum)
                                                            .round();
                                                        textController[
                                                                    (itemindex *
                                                                            8) +
                                                                        17]
                                                                .text =
                                                            widget
                                                                .item
                                                                .itemList[
                                                                    itemindex]
                                                                .actualShippingNum
                                                                .toString();
                                                      },
                                                      false,
                                                      const BoxDecoration(
                                                          color: Colors.pink),
                                                    )),
                                                SizedBox(
                                                    width: context.screenWidth *
                                                        0.4,
                                                    child: subRowCell(
                                                      textController[
                                                          (itemindex * 8) + 13],
                                                      () {
                                                        widget
                                                            .item
                                                            .itemList[itemindex]
                                                            .shippingNum = int.tryParse(
                                                                textController[
                                                                        (itemindex *
                                                                                8) +
                                                                            13]
                                                                    .text) ??
                                                            0;
                                                      },
                                                      false,
                                                      BoxDecoration(
                                                          border: Border.all()),
                                                    )),
                                                SizedBox(
                                                    width: context.screenWidth *
                                                        0.4,
                                                    child: subRowCell(
                                                      textController[
                                                          (itemindex * 8) + 14],
                                                      () {
                                                        widget
                                                            .item
                                                            .itemList[itemindex]
                                                            .arriveNum = int.tryParse(
                                                                textController[
                                                                        (itemindex *
                                                                                8) +
                                                                            14]
                                                                    .text) ??
                                                            0;
                                                      },
                                                      true,
                                                      BoxDecoration(
                                                          border: Border.all()),
                                                    )),
                                                SizedBox(
                                                    width: context.screenWidth *
                                                        0.4,
                                                    child: subRowCell(
                                                      textController[
                                                          (itemindex * 8) + 17],
                                                      () {
                                                        widget
                                                            .item
                                                            .itemList[itemindex]
                                                            .actualShippingNum = int
                                                                .tryParse(textController[
                                                                        (itemindex *
                                                                                8) +
                                                                            17]
                                                                    .text) ??
                                                            0;
                                                      },
                                                      true,
                                                      BoxDecoration(
                                                          border: Border.all()),
                                                    )),
                                                SizedBox(
                                                    width: context.screenWidth *
                                                        0.4,
                                                    child: subRowCell(
                                                      textController[
                                                          (itemindex * 8) + 15],
                                                      () {
                                                        widget
                                                            .item
                                                            .itemList[itemindex]
                                                            .sumNum = int.tryParse(
                                                                textController[
                                                                        (itemindex *
                                                                                8) +
                                                                            15]
                                                                    .text) ??
                                                            0;
                                                        widget
                                                            .item
                                                            .itemList[itemindex]
                                                            .actualShippingNum = (widget
                                                                    .item
                                                                    .itemList[
                                                                        itemindex]
                                                                    .sumNum! /
                                                                widget
                                                                    .item
                                                                    .itemList[
                                                                        itemindex]
                                                                    .setNum)
                                                            .round();
                                                        textController[
                                                                    (itemindex *
                                                                            8) +
                                                                        17]
                                                                .text =
                                                            widget
                                                                .item
                                                                .itemList[
                                                                    itemindex]
                                                                .actualShippingNum
                                                                .toString();
                                                      },
                                                      false,
                                                      const BoxDecoration(
                                                          color: Colors.pink),
                                                    )),
                                                SizedBox(
                                                    width: context.screenWidth *
                                                        0.4,
                                                    child: dateCell(
                                                      dateController[
                                                          itemindex + 3],
                                                      () {
                                                        setState(() {
                                                          if (dateController[
                                                                      itemindex +
                                                                          3]
                                                                  .text ==
                                                              "") {
                                                            widget
                                                                .item
                                                                .itemList[
                                                                    itemindex]
                                                                .expiryDate = null;
                                                          } else {
                                                            widget
                                                                .item
                                                                .itemList[
                                                                    itemindex]
                                                                .expiryDate = DateFormat(
                                                                    'yyyy/MM/dd')
                                                                .parse(dateController[
                                                                        itemindex +
                                                                            2]
                                                                    .text);
                                                          }
                                                        });
                                                      },
                                                      false,
                                                    )),
                                                SizedBox(
                                                    width: context.screenWidth *
                                                        0.4,
                                                    child: subRowCell(
                                                      textController[
                                                          (itemindex * 8) + 16],
                                                      () {
                                                        widget
                                                            .item
                                                            .itemList[itemindex]
                                                            .place = textController[
                                                                (itemindex *
                                                                        8) +
                                                                    16]
                                                            .text;
                                                      },
                                                      false,
                                                      BoxDecoration(
                                                          border: Border.all()),
                                                    )),
                                                SizedBox(
                                                  width:
                                                      context.screenWidth * 0.2,
                                                  child: IconButton(
                                                    icon: const Icon(
                                                        Icons.delete),
                                                    onPressed: () async {
                                                      setState(() {
                                                        widget.item.itemList
                                                            .removeAt(
                                                                itemindex);
                                                      });
                                                      _init();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                    )),
                  ),

                  // ),
                  if (widget.item.itemList.length != 1)
                    SizedBox(
                      width: context.screenWidth * 0.2,
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
                    height: context.screenHeight * 0.17,
                    decoration: BoxDecoration(border: Border.all(width: 1)),
                    child: Center(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.item.notes.length + 1,
                        itemBuilder: (context, index) {
                          return index > widget.item.notes.length - 1
                              ? Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Colors.lightGreen
                                              .withOpacity(0.4)),
                                      width: context.screenWidth * 0.8,
                                      child: TextField(
                                        controller: noteController,
                                      ),
                                    ),
                                    SizedBox(
                                      height: context.screenHeight * 0.02,
                                    ),
                                    SizedBox(
                                      width: context.screenWidth * 0.3,
                                      height: context.screenHeight * 0.08,
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
                              : Padding(
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
    );
  }
}
