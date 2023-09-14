import 'package:delivery_control_web/models/base.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:delivery_control_web/models/loginUser.dart';
import 'package:delivery_control_web/models/admin.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:delivery_control_web/providers/admin_database_provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../exSize.dart';
import './admin_detail.dart';

final onAdminSelectProvider = StateProvider<bool>((ref) => false);
final StateProvider<List<int>> searchIndexListProvider =
    StateProvider((ref) => []);
final adminIndexProvider1 = StateProvider<int>((ref) => 0);
final textcheckProvider1 = StateProvider<String>((ref) => "");

class AdminInfo extends ConsumerStatefulWidget {
  const AdminInfo({super.key});

  @override
  _AdminInfo createState() => _AdminInfo();
}

class _AdminInfo extends ConsumerState<AdminInfo> {
  bool isLoading = false;
  final AdminDatabase adminDatabase = AdminDatabase();

  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  SelectBase selectBase = SelectBase();

  Future<void> submit(Admin admin, String password) async {
    if (!_key.currentState!.validate()) return;
    await adminDatabase.addNewAdmin(admin, password);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> register() async {
    String name = "";
    String mail = '';
    String password = '';
    String confirmPassword = '';
    bool hidePassword = true;
    bool hideConfirmPassword = true;
    bool passwordCheck = false;
    TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Form(
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
                                  '管理者登録',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: context.screenHeight * 0.01,
                                ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    icon: Icon(Icons.abc),
                                    hintText: '名前を入力',
                                    labelText: 'name',
                                  ),
                                  validator: (value) {
                                    if ((value == null)) {
                                      return '名前が空白です';
                                    }
                                    return null;
                                  },
                                  onChanged: (String value) {
                                    setState(() {
                                      name = value;
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: context.screenHeight * 0.01,
                                ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    icon: Icon(Icons.mail),
                                    hintText: 'メールアドレスを入力',
                                    labelText: 'Email Address',
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
                                      mail = value;
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: context.screenHeight * 0.01,
                                ),
                                SizedBox(
                                  height: context.screenHeight * 0.03,
                                  child: ElevatedButton(
                                    child: const Text("拠点選択"),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return selectBase.selectBasePull([],
                                                () {
                                              Navigator.pop(context);
                                            }, ref);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: context.screenHeight * 0.01,
                                ),
                                TextFormField(
                                  controller: passwordController,
                                  onFieldSubmitted: (_) async {
                                    //     await submit();
                                  },
                                  obscureText: hidePassword,
                                  decoration: InputDecoration(
                                    icon: const Icon(Icons.lock),
                                    hintText: 'パスワードを入力',
                                    labelText: 'Password',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        hidePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          hidePassword = !hidePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  onChanged: (String value) {
                                    setState(() {
                                      password = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (!passwordCheck) {
                                      return 'パスワードが条件に反しています';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: context.screenHeight * 0.01,
                                ),
                                FlutterPwValidator(
                                    strings: JaStrings(),
                                    controller: passwordController,
                                    minLength: 8,
                                    width: 400,
                                    height: 150,
                                    onSuccess: () {
                                      passwordCheck = true;
                                    },
                                    onFail: () {
                                      passwordCheck = false;
                                    }),
                                SizedBox(height: context.screenHeight * 0.01),
                                TextFormField(
                                  obscureText: hideConfirmPassword,
                                  decoration: InputDecoration(
                                    icon: const Icon(Icons.lock),
                                    hintText: 'パスワードを入力',
                                    labelText: 'Confirm Password',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        hideConfirmPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          hideConfirmPassword =
                                              !hideConfirmPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  onChanged: (String value) {
                                    setState(() {
                                      confirmPassword = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (confirmPassword != password) {
                                      return 'パスワードが一致しません';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: context.screenHeight * 0.01),
                                SizedBox(
                                  width: context.screenWidth * 0.15,
                                  height: context.screenHeight * 0.08,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blueAccent
                                              .withOpacity(0.8)),
                                      onPressed: () async {
                                        await submit(
                                            Admin(
                                                uid: "",
                                                name: name,
                                                mail: mail,
                                                base: List.generate(
                                                    ref
                                                        .watch(baseListProvider)
                                                        .where((element) =>
                                                            element.select)
                                                        .toList()
                                                        .length,
                                                    (index) => ref
                                                        .watch(baseListProvider)
                                                        .where((element) =>
                                                            element.select)
                                                        .toList()[index]
                                                        .name),
                                                superAdmin: false),
                                            password);
                                      },
                                      child: const Text('登録')),
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
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final adminIndex = ref.read(adminIndexProvider1);
    final textcheck = ref.read(textcheckProvider1.notifier);
    final adminList = ref.watch(adminListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('管理者リスト'),
      ),
      body: isLoading //「読み込み中」だったら「グルグル」表示
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Center(
                  child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: context.screenHeight * 0.01),
                        SizedBox(
                          child: TextField(
                            controller: _controller,
                            onChanged: (newText) {
                              setState(() {
                                textcheck.state = newText;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: '検索',
                              suffixIcon: _controller.text.isEmpty
                                  ? const Icon(Icons.search)
                                  : IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          textcheck.state = "";
                                          _controller.clear();
                                        });
                                      },
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: context.screenHeight * 0.01,
                        ),
                        _controller.text.isEmpty
                            ? AdminList(adminList)
                            : AdminList(adminList
                                .where((admin) =>
                                    admin.name.contains(_controller.text))
                                .toList())
                      ],
                    ),
                  ),
                  Visibility(
                    visible: ref.watch(onAdminSelectProvider),
                    child: adminList.isNotEmpty
                        // adminDetail作成
                        ? AdminDetail(
                            adminList[adminIndex], onAdminSelectProvider)
                        : const CircularProgressIndicator(),
                  )
                ],
              )),
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
            child: const Icon(Icons.sync),
            backgroundColor: Colors.blueAccent.withOpacity(0.8),
            foregroundColor: Colors.white,
            label: '更新',
            labelStyle: const TextStyle(fontSize: 18.0),
            onTap: () async {
              ref.watch(adminListProvider.notifier).clearList();
              await adminDatabase.getallAdmins(ref);
            },
          ),
          if (ref.watch(loginUserProvider).superAdimnFig)
            SpeedDialChild(
              child: const Icon(Icons.add),
              backgroundColor: const Color.fromARGB(255, 165, 11, 231),
              foregroundColor: Colors.white,
              label: '管理者追加',
              labelStyle: const TextStyle(fontSize: 18.0),
              onTap: () async {
                await register();
              },
            ),
        ],
      ),
    );
  }
}

class AdminList extends ConsumerWidget {
  final List _adminList;
  final AdminDatabase adminDatabase = AdminDatabase();
  AdminList(this._adminList, {super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Expanded(
      child: _adminList.isNotEmpty
          ? ListView.separated(
              // shrinkWrap: true,
              // physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              itemCount: _adminList.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
              itemBuilder: (BuildContext context, int index) {
                final Admin currentUser = _adminList[index];

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  child: ListTile(
                    leading: Text(
                      currentUser.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    title: Wrap(
                      spacing: 10,
                      children: [
                        Text(
                          currentUser.mail,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        // expandable
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        adminDatabase.removeAdmin(currentUser.uid);
                        ref.watch(adminListProvider.notifier).clearList();
                        await adminDatabase.getallAdmins(ref);
                      },
                    ),
                    onTap: () {
                      ref.watch(adminIndexProvider1.notifier).state = index;
                      ref.read(onAdminSelectProvider.notifier).state =
                          !ref.watch(onAdminSelectProvider);
                    },
                  ),
                );
              })
          : const Center(child: Text('No users yet')),
    );
  }
}
