import 'package:delivery_control_web/common/popup.dart';
import 'package:delivery_control_web/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:delivery_control_web/models/customer.dart';
import 'package:delivery_control_web/providers/customer_database_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../exSize.dart';

class NewUserDetailScreen extends StatefulWidget {
  final User user;
  final List<TextEditingController> userJoinController =
      List.generate(17, (i) => TextEditingController());
  NewUserDetailScreen({required this.user, super.key});

  @override
  NewUserDetailScreenState createState() => NewUserDetailScreenState();
}

class NewUserDetailScreenState extends State<NewUserDetailScreen> {
  var selectedValue = false;
  var nullFlg;
  CustomerDatabase customerDatabase = CustomerDatabase();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  final List<Icon> iconList = [
    const Icon(Icons.person),
    const Icon(Icons.email),
    // const Icon(Icons.home),
    const Icon(Icons.person_outlined),
    // const Icon(Icons.person_outline),
    const Icon(Icons.store),
    const Icon(Icons.person),
    const Icon(Icons.inventory),
    const Icon(Icons.category),
    const Icon(Icons.shopping_cart),
    // const Icon(Icons.paid),
    // const Icon(Icons.inventory_2),
    // const Icon(Icons.label),
    // const Icon(Icons.local_atm),
    // const Icon(Icons.request_page),
  ];

  final List<Icon> iconListPullDown = [
    const Icon(Icons.inventory_2),
    // const Icon(Icons.label),
  ];

  final List<String> textList = [
    'ロジモ太郎',
    'メールアドレス',
    // '拠点',
    'ロジモ太郎',
    // 'Logimo1234 （検索できるように設定をお願いします）',
    'ロジモプロ',
    'ロジモ花子 （いない場合は未入力）',
    'ロジモ太郎、ロジモ花子 （すべて記入してください）',
    '日用品、おもちゃ etc...',
    '10 （数字のみ）',
    // '月額課金 （数字のみ）',
    '大型商品を取り扱う予定について',
    // 'シールはがし',
    // '預託金',
    // '契約書',
    // '複数拠点'
    ''
  ];

  final List<String> titleList = [
    '氏名を入力してください',
    'メールアドレス',
    // '拠点',
    'LINE名を入力してください',
    // 'ラインIDを入力してください',
    'ショップ名を入力してください',
    'ご紹介者の氏名を入力してください',
    '配送予定名を入力してください',
    '取り扱いジャンルを入力してください',
    '月間平均出荷数を入力してください',
    // '月額課金予定額',
    '大型商品の有無を選択してください',
    // 'シールはがしの有無を選択してください',
    // '預託金',
    // '契約書',
    // '複数拠点'
    ''
  ];

  List<bool> userJoinBool = List.generate(2, (i) => false);

  void errorMethod(context) {
    Navigator.pop(context);
  }

  Widget userDetailForm(int index) {
    return TextFormField(
      controller: widget.userJoinController[index],
      readOnly: index == 1 ? true : false,
      decoration: InputDecoration(
        icon: iconList[index],
        labelText: textList[index],
      ),
      // validator: index == 4
      //     ? null
      //     : (value) {
      //         if ((value == null) ||
      //             (widget.userJoinController[index].text == '')) {
      //           return '入力必須項目です';
      //         }
      //         return null;
      //       },
      onChanged: (String value) {},
    );
  }

  Widget pullDownMenu(int index) {
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          icon: iconListPullDown[index],
        ),
        // underline: Container(),
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
        value: userJoinBool[index],
        onChanged: (bool? value) {
          setState(() {
            userJoinBool[index] = value!;
          });
        },
      ),
    );
  }

  Future<void> submit() async {
    // if (!_key.currentState!.validate()) return;
    await customerDatabase.addNewCustomer(Customer(
      uid: widget.user.uid,
      name: widget.userJoinController[0].text,
      mail: widget.user.email.toString(),
      base: [],
      line_name: widget.userJoinController[2].text,
      line_id: '',
      shop_name: widget.userJoinController[3].text,
      introducer: widget.userJoinController[4].text,
      driver_name: widget.userJoinController[5].text,
      category: widget.userJoinController[6].text,
      shipping_num: int.tryParse(widget.userJoinController[7].text) == null
          ? 0
          : int.parse(widget.userJoinController[7].text),
      monthly_charge: 0,
      large_product: userJoinBool[0],
      no_sticker: userJoinBool[1],
      commitment: false,
      deposit: false,
      flg: false,
      approval: false,
      baseFlg: false,
    ));
    if (!mounted) return;
    // await FirebaseAuth.instance.signOut();
    // Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const MyApp();
        },
      ),
    );

    // ログアウト
  }

  @override
  void initState() {
    widget.userJoinController[1].text = widget.user.email.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color.fromARGB(159, 127, 237, 223),
      extendBodyBehindAppBar: true,
      body:
          // BackgroundAnimation(
          //   size: MediaQuery.of(context).size,
          //   child:
          Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Form(
                key: _key,
                child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          SizedBox(
                            height: context.screenHeight * 0.05,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 40.0),
                              child: Text(
                                titleList[index],
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          index <= 7
                              ? userDetailForm(index)
                              : index < 9
                                  ? pullDownMenu(index - 8)
                                  : Column(
                                      children: [
                                        SizedBox(
                                          width: context.screenWidth * 0.15,
                                          height: context.screenHeight * 0.08,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors
                                                    .blueAccent
                                                    .withOpacity(0.8)),
                                            onPressed: () async {
                                              nullFlg = false;
                                              for (int cd = 0; cd < 8; cd++) {
                                                if (cd == 4) {
                                                  continue;
                                                } else if (widget
                                                        .userJoinController[cd]
                                                        .text
                                                        .length ==
                                                    0) {
                                                  nullFlg = true;
                                                }
                                              }
                                              if (nullFlg == true) {
                                                PopupAlert.alert(
                                                    context,
                                                    '空欄になっている項目があります \n 入力内容を再度確認してください',
                                                    errorMethod);
                                              } else {
                                                await submit();
                                                try {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('email')
                                                      .add(
                                                    {
                                                      'to': widget
                                                          .userJoinController[1]
                                                          .text,
                                                      'message': {
                                                        'subject':
                                                            '【自動返信】納品代行ラクロジへお申込みありがとうございます',
                                                        'html': 'この度はお申込みいただき、誠にありがとうございます。'
                                                            '<br>'
                                                            '納品代行申込みに関する自動返信メールです。'
                                                            '<br>'
                                                            'お申込みいただきました内容について、以下の通り受付いたしました。'
                                                            '<br>'
                                                            '<br>'
                                                            '━━━━━━━━━━━━━━━━━━━'
                                                            '<br>'
                                                            '■ お申込み内容 ■'
                                                            '<br>'
                                                            '━━━━━━━━━━━━━━━━━━━'
                                                            '<br>'
                                                            '以下、申込みフォームの入力内容となります'
                                                            '<br>'
                                                            '<br>'
                                                            '申込日時: ${DateFormat('yyyy年MM月dd日 HH時mm分').format(DateTime.now())}'
                                                            '<br>'
                                                            'お名前: ${widget.userJoinController[0].text}'
                                                            '<br>'
                                                            '会社名: ${widget.userJoinController[3].text}'
                                                            '<br>'
                                                            'メールアドレス: ${widget.userJoinController[1].text}'
                                                            '<br>'
                                                            'LINE名: ${widget.userJoinController[2].text}'
                                                            '<br>'
                                                            'ご紹介者氏名: ${widget.userJoinController[4].text}'
                                                            '<br>'
                                                            '配送予定名: ${widget.userJoinController[5].text}'
                                                            '<br>'
                                                            'ジャンル: ${widget.userJoinController[6].text}'
                                                            '<br>'
                                                            '月間平均出荷数: ${widget.userJoinController[7].text}'
                                                            '<br>'
                                                            '大型商品の有無: ${userJoinBool[0] == true ? "有" : "無"}'
                                                            '<br>'
                                                            '━━━━━━━━━━━━━━━━━━━'
                                                            '<br>'
                                                            '<br>'
                                                            '担当者より改めてご連絡差し上げますので、今しばらくお待ちください。'
                                                            '<br>'
                                                            '<br>'
                                                            'なお、お急ぎの場合やご不明点がございましたら、'
                                                            '<br>'
                                                            '下記の連絡先までお気軽にお問い合わせください。'
                                                            '<br>'
                                                            '<br>'
                                                            '【お問い合わせ先】'
                                                            '<br>'
                                                            'support@logex.jp'
                                                            '<br>'
                                                            '<br>'
                                                            '納品代行ラクロジ'
                                                            '<br>'
                                                            'サポートセンター'
                                                      },
                                                    },
                                                  );
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('email')
                                                      .add(
                                                    {
                                                      'to': 'support@logex.jp',
                                                      'message': {
                                                        'subject':
                                                            '【自動返信】納品代行ラクロジへお申込みありがとうございます',
                                                        'html': 'この度はお申込みいただき、誠にありがとうございます。'
                                                            '<br>'
                                                            '納品代行申込みに関する自動返信メールです。'
                                                            '<br>'
                                                            'お申込みいただきました内容について、以下の通り受付いたしました。'
                                                            '<br>'
                                                            '<br>'
                                                            '━━━━━━━━━━━━━━━━━━━'
                                                            '<br>'
                                                            '■ お申込み内容 ■'
                                                            '<br>'
                                                            '━━━━━━━━━━━━━━━━━━━'
                                                            '<br>'
                                                            '以下、申込みフォームの入力内容となります'
                                                            '<br>'
                                                            '<br>'
                                                            '申込日時: ${DateFormat('yyyy年MM月dd日 HH時mm分').format(DateTime.now())}'
                                                            '<br>'
                                                            'お名前: ${widget.userJoinController[0].text}'
                                                            '<br>'
                                                            '会社名: ${widget.userJoinController[3].text}'
                                                            '<br>'
                                                            'メールアドレス: ${widget.userJoinController[1].text}'
                                                            '<br>'
                                                            'LINE名: ${widget.userJoinController[2].text}'
                                                            '<br>'
                                                            'ご紹介者氏名: ${widget.userJoinController[4].text}'
                                                            '<br>'
                                                            '配送予定名: ${widget.userJoinController[5].text}'
                                                            '<br>'
                                                            'ジャンル: ${widget.userJoinController[6].text}'
                                                            '<br>'
                                                            '月間平均出荷数: ${widget.userJoinController[7].text}'
                                                            '<br>'
                                                            '大型商品の有無: ${userJoinBool[0] == true ? "有" : "無"}'
                                                            '<br>'
                                                            '━━━━━━━━━━━━━━━━━━━'
                                                            '<br>'
                                                            '<br>'
                                                            '担当者より改めてご連絡差し上げますので、今しばらくお待ちください。'
                                                            '<br>'
                                                            '<br>'
                                                            'なお、お急ぎの場合やご不明点がございましたら、'
                                                            '<br>'
                                                            '下記の連絡先までお気軽にお問い合わせください。'
                                                            '<br>'
                                                            '<br>'
                                                            '【お問い合わせ先】'
                                                            '<br>'
                                                            'support@logex.jp'
                                                            '<br>'
                                                            '<br>'
                                                            '納品代行ラクロジ'
                                                            '<br>'
                                                            'サポートセンター'
                                                      },
                                                    },
                                                  );
                                                } on Exception catch (e) {
                                                  debugPrint(e.toString());
                                                }
                                              }
                                            },
                                            child: const Text('登録'),
                                          ),
                                        ),
                                        SizedBox(
                                          height: context.screenHeight * 0.1,
                                        ),
                                      ],
                                    ),
                        ],
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
      // ),
    );
  }
}
