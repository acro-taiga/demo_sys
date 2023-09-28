import 'package:delivery_control_web/models/base.dart';
import 'package:delivery_control_web/models/loginUser.dart';
import 'package:delivery_control_web/providers/base_database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer.dart';
import '../providers/customer_database_provider.dart';
import '../exSize.dart';

// usersテーブルの中のデータに対する操作を行うクラス
class UserDetail extends ConsumerStatefulWidget {
  final Customer currentUser;
  final onSelectProvider;

  const UserDetail(this.currentUser, this.onSelectProvider, {super.key});

  @override
  ConsumerState<UserDetail> createState() => _UserDetailState();
}

class _UserDetailState extends ConsumerState<UserDetail> {
  late bool selectLargeProduct;
  late bool selectNoSticker;
  late bool selectCommitment;
  late bool selectDeposit;
  late bool selectFlg;

  bool loading = false;
  BaseDatabase baseDatabase = BaseDatabase();
  int pageNum = 1;
  SelectBase selectBase = SelectBase();

  CustomerDatabase customerDatabase = CustomerDatabase();
  List<TextEditingController> customerController =
      List.generate(11, (i) => TextEditingController());

  List<bool> dropDownItems = List.generate(7, (i) => true);

  Widget pullDownMenu(int Index) {
    return SizedBox(
      width: context.screenWidth * 0.3,
      child: DropdownButton(
        underline: Container(),
        isExpanded: true,
        items: const [
          DropdownMenuItem(
            value: true,
            child: Text('○'),
          ),
          DropdownMenuItem(
            value: false,
            child: Text('-'),
          ),
        ],
        value: dropDownItems[Index],
        onChanged: (bool? value) {
          setState(() {
            dropDownItems[Index] = value!;
          });
        },
      ),
    );
  }

  Future<void> setUserInfo() async {
    if (widget.currentUser.base.isNotEmpty) {
      for (var baseName in widget.currentUser.base) {
        for (var base in ref.read(baseListProvider)) {
          if (base.name == baseName) {
            base.select = true;
          }
        }
      }
    } else {
      for (var base in ref.read(baseListProvider)) {
        if (ref.read(loginUserProvider).base.contains(base.name)) {
          base.select = true;
        }
      }
    }
    setState(() {
      loading = true;
      customerController[0].text = widget.currentUser.name;
      customerController[1].text = widget.currentUser.mail;
      customerController[3].text = widget.currentUser.line_name;
      customerController[4].text = widget.currentUser.line_id;
      customerController[5].text = widget.currentUser.shop_name;
      customerController[6].text = widget.currentUser.introducer;
      customerController[7].text = widget.currentUser.driver_name;
      customerController[8].text = widget.currentUser.category;
      customerController[9].text = widget.currentUser.shipping_num.toString();
      customerController[10].text =
          widget.currentUser.monthly_charge.toString();
      dropDownItems[0] = widget.currentUser.large_product;
      dropDownItems[1] = widget.currentUser.no_sticker;
      dropDownItems[2] = widget.currentUser.deposit;
      dropDownItems[3] = widget.currentUser.commitment;
      dropDownItems[4] = widget.currentUser.flg;
      dropDownItems[5] = widget.currentUser.approval;
      dropDownItems[6] = widget.currentUser.baseFlg;

      loading = false;
    });
  }

  final List<String> textList = [
    '名前',
    'メールアドレス',
    '拠点',
    'LINE名',
    'LINEID',
    'ショップ名',
    '紹介者',
    '配送名',
    'カテゴリー',
    '平均出荷数 （数字のみ）',
    '月額課金 （数字のみ）',
    '大型商品',
    'シールはがし',
    '預託金',
    '契約書',
    '特別権限',
    '承認',
    '複数拠点'
  ];

  Future<void> _edit() async {
    await customerDatabase.editCustomer(
      Customer(
        uid: widget.currentUser.uid,
        name: customerController[0].text,
        mail: customerController[1].text,
        base: List.generate(
            ref
                .watch(baseListProvider)
                .where((element) => element.select)
                .toList()
                .length,
            (index) => ref
                .watch(baseListProvider)
                .where((element) => element.select)
                .toList()[index]
                .name),
        line_name: customerController[3].text,
        line_id: customerController[4].text,
        shop_name: customerController[5].text,
        introducer: customerController[6].text,
        driver_name: customerController[7].text,
        category: customerController[8].text,
        large_product: dropDownItems[0],
        no_sticker: dropDownItems[1],
        commitment: dropDownItems[2],
        deposit: dropDownItems[3],
        flg: dropDownItems[4],
        shipping_num: int.parse(customerController[9].text),
        monthly_charge: int.parse(customerController[10].text),
        approval: dropDownItems[5],
        baseFlg: dropDownItems[6],
      ),
    );
  }

  @override
  void initState() {
    Future(
      () async {
        print(ref.watch(baseListProvider).length);
        await setUserInfo();
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: context.screenWidth * 0.3,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: const Color.fromARGB(255, 231, 231, 231),
                    width: context.screenWidth * 0.002,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: context.screenHeight * 0.07,
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                      color: const Color.fromARGB(255, 231, 231, 231),
                      width: context.screenWidth * 0.002,
                    ))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: context.screenWidth * 0.03,
                        ),
                        SizedBox(
                          width: context.screenWidth * 0.07,
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                await _edit();
                                setState(() {
                                  loading = true;
                                });
                                await Future.delayed(const Duration(seconds: 1), () {
                                  setState(() {
                                    loading = false;
                                  });
                                });
                              } catch (e) {
                                print(e);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.blueAccent.withOpacity(0.8),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: const Text('更新'),
                          ),
                        ),
                        Flexible(
                          child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                ref
                                        .read(widget.onSelectProvider.notifier)
                                        .state =
                                    !ref.watch(widget.onSelectProvider);
                              }),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: pageNum == 2
                        ? selectBase.selectBasePull(widget.currentUser.base,
                            () {
                            setState(() {
                              pageNum = 1;
                            });
                          }, ref)
                        : ListView.builder(
                            itemCount: 18,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          textList[index],
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    index <= 10
                                        ? index == 2
                                            ? GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    pageNum = 2;
                                                  });
                                                },
                                                child: Card(
                                                  child: SizedBox(
                                                    height:
                                                        context.screenHeight *
                                                            0.03,
                                                    width: context.screenWidth *
                                                        0.15,
                                                    child: const Center(
                                                        child: Text("拠点選択")),
                                                  ),
                                                ),
                                              )
                                            : Card(
                                                child: TextFormField(
                                                  decoration:
                                                      const InputDecoration(
                                                    border: InputBorder.none,
                                                  ),
                                                  controller:
                                                      customerController[index],
                                                  onChanged: (value) {
                                                    setState(
                                                      () {
                                                        // customerController[
                                                        //         index]
                                                        //     .text = value;
                                                      },
                                                    );
                                                  },
                                                ),
                                              )
                                        : Card(
                                            child: pullDownMenu(index - 11),
                                          )
                                  ],
                                ),
                              );
                            },
                          ),
                  )
                ],
              ),
            ),
          );
  }
}
