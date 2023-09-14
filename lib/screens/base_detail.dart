import 'package:flutter/material.dart';

import 'package:delivery_control_web/models/base.dart';
import 'package:delivery_control_web/providers/base_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exSize.dart';

// baseテーブルの中のデータに対する操作を行うクラス
class BaseDetail extends ConsumerStatefulWidget {
  final Base base;
  final onSelectProvider;
  final WidgetRef ref;

  const BaseDetail(this.base, this.onSelectProvider, this.ref, {super.key});

  @override
  ConsumerState<BaseDetail> createState() => _BaseDetailState();
}

class _BaseDetailState extends ConsumerState<BaseDetail> {
  late bool selectLargeProduct;
  late bool selectNoSticker;
  late bool selectCommitment;
  late bool selectDeposit;
  late bool selectFlg;
  String? selectedBase;
  bool loading = false;
  BaseDatabase baseDatabase = BaseDatabase();

  BaseDatabase customerDatabase = BaseDatabase();
  List<TextEditingController> baseController =
      List.generate(5, (i) => TextEditingController());

  List<bool> dropDownItems = List.generate(7, (i) => true);

  Future<void> setBaseInfo() async {
    setState(() {
      loading = true;
      baseController[0].text = widget.base.name;
      baseController[1].text = widget.base.mail;
      baseController[2].text = widget.base.phoneNum;
      baseController[3].text = widget.base.postNum;
      baseController[4].text = widget.base.post;
      loading = false;
    });
  }

  final List<String> textList = [
    '拠点名',
    '代表メールアドレス',
    '代表電話番号',
    '郵便番号',
    '住所',
  ];

  Future<void> _edit() async {
    await baseDatabase.editAdmin(
      Base(
        name: baseController[0].text,
        mail: baseController[1].text,
        phoneNum: baseController[2].text,
        postNum: baseController[3].text,
        post: baseController[4].text,
        select: false,
      ),
    );
  }

  @override
  void initState() {
    Future(
      () async {
        await setBaseInfo();
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
                    child: ListView.builder(
                      itemCount: 5,
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
                              Card(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  controller: baseController[index],
                                  onChanged: (value) {
                                    setState(
                                      () {
                                        baseController[index].text = value;
                                      },
                                    );
                                  },
                                ),
                              ),
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
