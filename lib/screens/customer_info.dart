import 'package:delivery_control_web/models/customer.dart';
import 'package:delivery_control_web/providers/customer_database_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:delivery_control_web/models/item.dart';
import 'package:delivery_control_web/providers/item_database_provider.dart';

import '../exSize.dart';

class CustomerInfo extends ConsumerStatefulWidget {
  final Customer? getUser;
  CustomerInfo(this.getUser, {super.key});

  @override
  _CustomerInfo createState() => _CustomerInfo();
}

class _CustomerInfo extends ConsumerState<CustomerInfo> {
  bool editFig = false;
  CustomerDatabase customerDatabase = CustomerDatabase();
  List<TextEditingController> controller =
      List.generate(4, (i) => TextEditingController());
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  ItemDatabase itemDatabase = ItemDatabase();
  Widget textfiled(String targetValue, bool flg, controller, text) {
    return Center(
      child: Container(
        height: context.screenHeight * 0.1,
        width: context.screenWidth * 0.55,
        child: Row(
          children: [
            Container(
              width: context.screenWidth * 0.1,
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              width: context.screenWidth * 0.4,
              decoration: BoxDecoration(
                border: Border.all(
                  color: primeColor,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextField(
                  controller: controller,
                  readOnly: !flg,
                  onChanged: (value) {
                    targetValue = controller.text;
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void errorMethod(context) {
    Navigator.pop(context);
  }

  Future<void> submitYes() async {
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> resetPass(String mail) async {
    if (!_key.currentState!.validate()) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: mail);
      ref.read(customerListProvider.notifier).clearList();
      ref.read(itemListProvider.notifier).clearList();
      errorMethod(context);
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
    }
  }

  Future<void> confirmation(context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Container(
                  height: context.screenHeight * 0.4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: context.screenHeight * 0.15,
                        child: Text(
                          'メールが送信されました \n 再ログインしてください',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
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
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.blueAccent.withOpacity(0.8)),
                            onPressed: () async {
                              // await submitYes();
                              errorMethod(context);
                            },
                            child: const Text('再ログインする')),
                      ),
                    ],
                  )),
            );
          },
        );
      },
    );
  }

  Future<void> resetting() async {
    String mail = '';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Container(
                height: context.screenHeight * 0.4,
                child: Form(
                  key: _key,
                  child: Navigator(
                    onGenerateRoute: (_) {
                      return MaterialPageRoute(
                        builder: ((context) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'パスワード再設定登録',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: context.screenHeight * 0.01,
                                  ),
                                  TextFormField(
                                    onFieldSubmitted: (_) async {
                                      await resetPass(mail);
                                      await confirmation(context);
                                    },
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.mail),
                                      hintText: '登録のメールアドレス',
                                      labelText: 'mail',
                                    ),
                                    validator: (value) {
                                      if ((value == null)) {
                                        return 'メールアドレス';
                                      }
                                      return null;
                                    },
                                    onChanged: (String value) {
                                      setState(() {
                                        mail = value;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    height: context.screenHeight * 0.05,
                                  ),
                                  SizedBox(
                                    width: context.screenWidth * 0.15,
                                    height: context.screenHeight * 0.08,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent
                                                .withOpacity(0.8)),
                                        onPressed: () async {
                                          await resetPass(mail);
                                          await confirmation(context);
                                        },
                                        child: const Text('メール送信')),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    if (widget.getUser != null) {
      controller[0].text = widget.getUser!.name;
      controller[1].text = widget.getUser!.mail;
      controller[2].text = widget.getUser!.driver_name;
      controller[3].text = widget.getUser!.shop_name;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ユーザー情報"),
      ),
      body: widget.getUser == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  // child: Lottie.network(
                  //   'https://assets6.lottiefiles.com/packages/lf20_ysbhqsuf.json',
                  //   fit: BoxFit.cover,
                  //   errorBuilder: (context, error, stackTrace) {
                  //     return const Padding(
                  //       padding: EdgeInsets.all(30.0),
                  //     );
                  //   },
                  // ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: context.screenWidth * 0.7,
                    alignment: Alignment.center,
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: context.screenHeight * 0.05,
                          ),
                          textfiled(widget.getUser!.name, editFig,
                              controller[0], "名前"),
                          Visibility(
                            visible: editFig,
                            child: SizedBox(
                              height: context.screenHeight * 0.05,
                              child: const Center(
                                child: Text(
                                  "メールアドレスを変更したい場合は管理者へご連絡ください",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          textfiled(widget.getUser!.mail, false, controller[1],
                              "メールアドレス"),
                          textfiled(widget.getUser!.driver_name, editFig,
                              controller[2], "配送名"),
                          textfiled(widget.getUser!.shop_name, editFig,
                              controller[3], "ショップ名"),
                          SizedBox(
                            height: context.screenHeight * 0.05,
                          ),
                          Visibility(
                              visible: editFig,
                              child: SizedBox(
                                height: context.screenHeight * 0.05,
                                width: context.screenWidth * 0.3,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      await customerDatabase.editCustomer(
                                          Customer(
                                              uid: widget.getUser!.uid,
                                              base: widget.getUser!.base,
                                              name: controller[0].text,
                                              mail: widget.getUser!.mail,
                                              line_name:
                                                  widget.getUser!.line_name,
                                              line_id: widget.getUser!.line_id,
                                              shop_name: controller[3].text,
                                              introducer:
                                                  widget.getUser!.introducer,
                                              driver_name: controller[2].text,
                                              category:
                                                  widget.getUser!.category,
                                              large_product:
                                                  widget.getUser!.large_product,
                                              no_sticker:
                                                  widget.getUser!.no_sticker,
                                              commitment:
                                                  widget.getUser!.commitment,
                                              deposit: widget.getUser!.deposit,
                                              flg: widget.getUser!.flg,
                                              monthly_charge: widget
                                                  .getUser!.monthly_charge,
                                              shipping_num:
                                                  widget.getUser!.shipping_num,
                                              approval:
                                                  widget.getUser!.approval,
                                              baseFlg:
                                                  widget.getUser!.baseFlg));
                                      List<AmazonItem> items = ref
                                          .watch(itemListProvider)
                                          .where((element) =>
                                              element.userName ==
                                              widget.getUser!.name)
                                          .toList();
                                      for (AmazonItem item in items) {
                                        item.userName = controller[0].text;
                                        await itemDatabase.editItem(item);
                                      }
                                      widget.getUser!.name = controller[0].text;
                                      widget.getUser!.driver_name =
                                          controller[2].text;
                                      widget.getUser!.driver_name =
                                          controller[3].text;
                                      setState(() {
                                        editFig = false;
                                      });
                                    },
                                    child: const Text("更新")),
                              )),
                          Visibility(
                              visible: !editFig,
                              child: SizedBox(
                                height: context.screenHeight * 0.05,
                                width: context.screenWidth * 0.3,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      await resetting();
                                    },
                                    child: const Text("パスワード再設定")),
                              )),
                          SizedBox(
                            height: context.screenHeight * 0.05,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SpeedDial(
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
            child: const Icon(Icons.edit),
            backgroundColor: Colors.blueAccent.withOpacity(0.8),
            foregroundColor: Colors.white,
            label: '編集',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () async {
              setState(() {
                editFig = !editFig;
              });
            },
          ),
        ],
      ),
    );
  }
}
