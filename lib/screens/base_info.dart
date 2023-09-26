import 'package:delivery_control_web/models/loginUser.dart';
import 'package:flutter/material.dart';

import 'package:delivery_control_web/providers/base_database_provider.dart';
import 'package:async/async.dart';
import 'package:delivery_control_web/models/base.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:email_validator/email_validator.dart';

import '../exSize.dart';
import '../models/customer.dart';
import './base_detail.dart';

final onSelectProvider = StateProvider<bool>((ref) => false);
final baseIndexProvider = StateProvider<int>((ref) => 0);

class BaseInfo extends ConsumerStatefulWidget {
  const BaseInfo({super.key});

  @override
  _BaseInfo createState() => _BaseInfo();
}

class _BaseInfo extends ConsumerState {
  final AsyncMemoizer memoizer = AsyncMemoizer();
  final BaseDatabase baseDatabase = BaseDatabase();
  late Future<int> result;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final regPostNum = RegExp(r'^\d{3}-?\d{4}$');
  final regTel = RegExp(r'^\d{1,5}-?\d{1,4}-?\d{4}$');
  bool deleteFlg = false;

  Future<int> _init(ref) async {
    // memoizer.runOnce(() async {
    //   //   WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   ref.read(baseListProvider.notifier).clearList();
    //   await baseDatabase.getallBases(ref);
    // });
    // });
    return Future.value(1);
  }

  Future<void> submit(Base base) async {
    if (!_key.currentState!.validate()) return;
    // await baseDatabase.addNewBase(base);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> baseRegister() async {
    String baseName = "";
    String basePost = "";
    String basePostNum = "";
    String baseMail = "";
    String baseTel = "";

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: ((context, setState) {
            return AlertDialog(
              content: Container(
                height: context.screenHeight * 0.7,
                width: context.screenWidth * 0.3,
                child: Form(
                  key: _key,
                  child: Navigator(onGenerateRoute: (_) {
                    return MaterialPageRoute(
                      builder: ((context) {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Center(
                              child: Column(
                                // mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text(
                                    '拠点登録',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: context.screenHeight * 0.01),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.abc),
                                      hintText: '拠点名を入力',
                                    ),
                                    validator: (value) {
                                      if ((value == null)) {
                                        return '拠点名が空白です';
                                      }
                                      return null;
                                    },
                                    onChanged: (String value) {
                                      setState(() {
                                        baseName = value;
                                      });
                                    },
                                  ),
                                  SizedBox(height: context.screenHeight * 0.01),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.mail),
                                      hintText: '代表メールアドレスを入力',
                                    ),
                                    validator: (value) {
                                      if ((value == null) ||
                                          !EmailValidator.validate(value)) {
                                        return 'メールアドレスのフォーマットが正しくありません';
                                      }
                                      return null;
                                    },
                                    onChanged: (String value) {
                                      setState(() {
                                        baseMail = value;
                                      });
                                    },
                                  ),
                                  SizedBox(height: context.screenHeight * 0.01),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.phone),
                                      hintText: '代表電話番号を入力',
                                    ),
                                    validator: (value) {
                                      if ((value == null) ||
                                          !regTel.hasMatch(value)) {
                                        return '電話番号のフォーマットが正しくありません';
                                      }
                                      return null;
                                    },
                                    onChanged: (String value) {
                                      setState(() {
                                        baseTel = value;
                                      });
                                    },
                                  ),
                                  SizedBox(height: context.screenHeight * 0.01),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.home),
                                      hintText: '郵便番号を入力',
                                    ),
                                    validator: (value) {
                                      if ((value == null) ||
                                          !regPostNum.hasMatch(value)) {
                                        return '郵便番号のフォーマットが正しくありません';
                                      }
                                      return null;
                                    },
                                    onChanged: (String value) {
                                      setState(() {
                                        basePostNum = value;
                                      });
                                    },
                                  ),
                                  SizedBox(height: context.screenHeight * 0.01),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.home_outlined),
                                      hintText: '住所を入力',
                                    ),
                                    validator: (value) {
                                      if (value == null) {
                                        return '住所を入力してください';
                                      }
                                      return null;
                                    },
                                    onChanged: (String value) {
                                      setState(() {
                                        basePost = value;
                                      });
                                    },
                                  ),
                                  SizedBox(height: context.screenHeight * 0.03),
                                  SizedBox(
                                    width: context.screenWidth * 0.15,
                                    height: context.screenHeight * 0.08,
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent
                                                .withOpacity(0.8)),
                                        onPressed: () async {
                                          await submit(
                                            Base(
                                              name: baseName,
                                              mail: baseMail,
                                              phoneNum: baseTel,
                                              postNum: basePostNum,
                                              post: basePost,
                                              select: false,
                                            ),
                                          );
                                          ref
                                              .watch(baseListProvider.notifier)
                                              .clearList();
                                          await baseDatabase.getallBases(ref);
                                        },
                                        child: const Text('登録')),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  void initState() {
    // result = _init(ref);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final baseIndex = ref.watch(baseIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("拠点リスト"),
      ),
      body: FutureBuilder(
        future: _init(ref),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.error != null) {
            return const Center(
              child: Text('エラーが起きました'),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(30),
            child: Row(
              children: [
                Expanded(
                  child: ref.watch(baseListProvider).isNotEmpty
                      ? ListView.builder(
                          padding: EdgeInsets.only(bottom: 50),
                          shrinkWrap: true,
                          itemCount: ref.watch(baseListProvider).length,
                          itemBuilder: (context, index) {
                            final base = ref.watch(baseListProvider)[index];
                            final userData = ref
                                .watch(customerListProvider)
                                .where((element) =>
                                    element.base.contains(base.name))
                                .toList();

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5.0),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 20.0,
                                    color: Colors.grey.withOpacity(0.5),
                                    offset: Offset(5, 5),
                                  ),
                                ],
                              ),
                              width: context.screenWidth * 0.5,
                              child: ExpansionTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: context.screenHeight * 0.05,
                                        child: GestureDetector(
                                          onTap: () {
                                            ref
                                                .watch(
                                                    baseIndexProvider.notifier)
                                                .state = index;
                                            ref
                                                    .read(onSelectProvider.notifier)
                                                    .state =
                                                !ref.watch(onSelectProvider);
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                width:
                                                    context.screenWidth * 0.01,
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  base.name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  base.post,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  base.phoneNum,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  base.mail,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: deleteFlg,
                                                child: Expanded(
                                                  flex: 1,
                                                  child: IconButton(
                                                    icon: const Icon(
                                                        Icons.delete),
                                                    onPressed: () async {
                                                      baseDatabase
                                                          .removeBase(base)
                                                          .then(
                                                        (value) async {
                                                          ref
                                                              .watch(
                                                                  baseListProvider
                                                                      .notifier)
                                                              .clearList();
                                                          await baseDatabase
                                                              .getallBases(ref);
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: context.screenWidth * 0.01,
                                          ),
                                          Container(
                                            width: context.screenWidth * 0.5,
                                            height: context.screenHeight * 0.03,
                                            child: Text(
                                              'ユーザーリスト',
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.blueAccent
                                                    .withOpacity(0.8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(left: 30),
                                      height: context.screenHeight * 0.03,
                                      child: GridView.builder(
                                        itemCount: userData.length,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4, //ボックスを横に並べる数
                                        ),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final user = userData[index];
                                          return Text(
                                            user.name,
                                            style: TextStyle(fontSize: 12),
                                          );
                                        },
                                      ),
                                    ),
                                  ]),
                            );
                          })
                      : const Text('No base yet'),
                ),
                if (ref.watch(loginUserProvider).adimnFig)
                  Visibility(
                    visible: ref.watch(onSelectProvider),
                    child: ref.watch(baseListProvider).isNotEmpty
                        ? BaseDetail(ref.watch(baseListProvider)[baseIndex],
                            onSelectProvider, ref)
                        : const CircularProgressIndicator(),
                  )
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: ref.watch(loginUserProvider).adimnFig
          ? FloatingActionButtonLocation.endFloat
          : null,
      floatingActionButton: ref.watch(loginUserProvider).adimnFig
          ? SpeedDial(
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
                  child: const Icon(Icons.sync),
                  backgroundColor: Colors.blueAccent.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  label: '更新',
                  labelStyle: const TextStyle(fontSize: 18.0),
                  onTap: () async {
                    ref.watch(baseListProvider.notifier).clearList();
                    await baseDatabase.getallBases(ref);
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.add),
                  backgroundColor: const Color.fromARGB(255, 165, 11, 231),
                  foregroundColor: Colors.white,
                  label: '拠点追加',
                  labelStyle: const TextStyle(fontSize: 18.0),
                  onTap: () async {
                    await baseRegister();
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.delete_forever),
                  backgroundColor: const Color.fromARGB(255, 165, 11, 231),
                  foregroundColor: Colors.white,
                  label: '削除モード',
                  labelStyle: const TextStyle(fontSize: 18.0),
                  onTap: () async {
                    setState(() {
                      deleteFlg = !deleteFlg;
                    });
                  },
                ),
              ],
            )
          : null,
    );
  }
}
