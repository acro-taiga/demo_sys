import 'package:delivery_control_web/models/loginUser.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:delivery_control_web/models/base.dart';
import 'package:delivery_control_web/providers/base_database_provider.dart';
import 'package:delivery_control_web/providers/admin_database_provider.dart';
import '../exSize.dart';
import '../models/admin.dart';

class AdminDetail extends ConsumerStatefulWidget {
  final Admin currentUser;
  final onAdminSelectProvider;

  const AdminDetail(this.currentUser, this.onAdminSelectProvider, {super.key});

  @override
  ConsumerState<AdminDetail> createState() => _AdminDetailState();
}

class _AdminDetailState extends ConsumerState<AdminDetail> {
  bool loading = false;
  BaseDatabase baseDatabase = BaseDatabase();
  int pageNum = 1;
  SelectBase selectBase = SelectBase();

  AdminDatabase adminDatabase = AdminDatabase();
  List<TextEditingController> adminController =
      List.generate(3, (i) => TextEditingController());

  Future<void> setAdminInfo() async {
    for (var base in ref.read(baseListProvider)) {
      base.select = false;
    }
    if (widget.currentUser.superAdmin) {
      for (var base in ref.read(baseListProvider)) {
        base.select = true;
      }
    } else {
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
    }

    setState(() {
      loading = true;
      adminController[0].text = widget.currentUser.name;
      adminController[1].text = widget.currentUser.mail;
    });
  }

  final List<String> textList = ['名前', 'メールアドレス', '拠点'];

  Future<void> _edit() async {
    await adminDatabase.editAdmin(
      Admin(
        uid: widget.currentUser.uid,
        name: adminController[0].text,
        mail: adminController[1].text,
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
        superAdmin: widget.currentUser.superAdmin,
      ),
    );
  }

  // Widget basePullDown(WidgetRef ref) {
  //   return SizedBox(
  //     width: context.screenWidth * 0.3,
  //     child: DropdownButton(
  //         underline: Container(),
  //         isExpanded: true,
  //         value: selectedBase,
  //         items: ref.watch(baseListProvider).map((Base base) {
  //           return DropdownMenuItem(
  //             value: base.name,
  //             child: Text(base.name),
  //           );
  //         }).toList(),
  //         onChanged: (value) {
  //           setState(() {
  //             selectedBase = value!;
  //           });
  //         }),
  //   );
  // }

  @override
  void initState() {
    Future(
      () async {
        await setAdminInfo();
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: context.screenWidth * 0.3,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Color.fromARGB(255, 231, 231, 231),
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
                color: Color.fromARGB(255, 231, 231, 231),
                width: context.screenWidth * 0.002,
              ))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await _edit();
                          setState(() {
                            loading = true;
                          });
                          await Future.delayed(Duration(seconds: 1), () {
                            setState(() {
                              loading = false;
                            });
                          });
                        } catch (e) {
                          print(e);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent.withOpacity(0.8),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('更新'),
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        ref.read(widget.onAdminSelectProvider.notifier).state =
                            !ref.watch(widget.onAdminSelectProvider);
                      }),
                ],
              ),
            ),
            Expanded(
              child: pageNum == 2
                  ? selectBase.selectBasePull(widget.currentUser.base, () {
                      setState(() {
                        pageNum = 1;
                      });
                    }, ref)
                  : ListView.builder(
                      itemCount: 3,
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
                              index == 2
                                  ? GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          pageNum = 2;
                                        });
                                      },
                                      child: Card(
                                        child: SizedBox(
                                          height: context.screenHeight * 0.03,
                                          width: context.screenWidth * 0.15,
                                          child: Center(child: Text("拠点選択")),
                                        ),
                                      ),
                                    )
                                  : Card(
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                        controller: adminController[index],
                                        onChanged: (value) {
                                          setState() {
                                            // adminController[index].text = value;
                                          }
                                        },
                                      ),
                                    ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
