import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:delivery_control_web/common/new_user_detail_screen.dart';
import 'package:delivery_control_web/common/new_user_submit.dart';
import 'package:delivery_control_web/exSize.dart';
import 'package:delivery_control_web/models/admin.dart';
import 'package:delivery_control_web/models/base.dart';
import 'package:delivery_control_web/models/customer.dart';
import 'package:delivery_control_web/models/item.dart';
import 'package:delivery_control_web/models/loginUser.dart';
import 'package:delivery_control_web/models/plan.dart';
import 'package:delivery_control_web/providers/base_database_provider.dart';
import 'package:delivery_control_web/providers/page_set_provider.dart';
import 'package:delivery_control_web/providers/plan_database_provider.dart';
import 'package:delivery_control_web/screens/customer_info.dart';
import 'package:delivery_control_web/screens/luggage_search.dart';
import 'package:delivery_control_web/screens/plan_list.dart';
import 'package:delivery_control_web/screens/read_barcode.dart';
import 'package:delivery_control_web/screens/totalizer.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';

import 'package:delivery_control_web/screens/user_info.dart';
import 'package:delivery_control_web/screens/admin_info.dart';
import 'package:delivery_control_web/screens/base_info.dart';
import '../screens/dashboard.dart';

import 'package:delivery_control_web/providers/admin_database_provider.dart';
import 'package:delivery_control_web/providers/customer_database_provider.dart';
import 'package:delivery_control_web/providers/item_database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:async/async.dart';

class SidebarPage extends ConsumerStatefulWidget {
  const SidebarPage({super.key});
  @override
  _SidebarPageState createState() => _SidebarPageState();
}

class _SidebarPageState extends ConsumerState<SidebarPage> {
  Future<bool>? result;
  AdminDatabase adminDatabase = AdminDatabase();
  CustomerDatabase customerDatabase = CustomerDatabase();
  ItemDatabase itemDatabase = ItemDatabase();
  BaseDatabase baseDatabase = BaseDatabase();
  PlanDatabase planDatabase = PlanDatabase();
  bool isLoading = false;
  bool? res;
  bool itemFlg = false;
  bool isExpanded = true;
  bool firstBuild = true;
  final AsyncMemoizer memoizer = AsyncMemoizer();
  bool alertFlg = false;

  List<Widget> get _bodys {
    return [
      const Dashboard(),
      const UserListInfo(),
      const AdminInfo(),
      SearchLuggages(itemFlg),
      SearchLuggages(itemFlg),
      const BarcodeRead(),
      SearchLuggages(itemFlg),
      const PlanListScreen(),
      const BaseInfo(),
      const Totalizer(),
      Container(
        color: Colors.white,
        child: Center(
          child: TextButton(
            child: const Text('ログアウト'),
            onPressed: () {},
          ),
        ),
      ),
    ];
  }

  List<Widget> get _bodysCustomer {
    return [
      const Dashboard(),
      const SearchLuggages(false),
      CustomerInfo(ref.watch(customerListProvider).firstWhereOrNull(
          (element) => element.uid == ref.watch(loginUserProvider).uid)),
      const BaseInfo(),
      Container(
        color: Colors.white,
        child: Center(
          child: TextButton(
            child: const Text('ログアウト'),
            onPressed: () {},
          ),
        ),
      ),
    ];
  }

  Widget expandedButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: InkWell(
        onTap: expandOrShrinkDrawer,
        child: Container(
          height: 45,
          alignment: Alignment.center,
          child: isExpanded
              ? const Icon(
                  Icons.keyboard_arrow_left,
                  color: Colors.white,
                )
              : const Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }

  void expandOrShrinkDrawer() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  Widget sMenuButton(String subMenu, bool isTitle) {
    return InkWell(
      onTap: () async {
        switch (subMenu) {
          case "トップ":
            ref.read(pageNumProvider.notifier).state = 0;
            break;
          case "ユーザー":
            setState(() {
              selectedList[4] = false;
            });
            ref.read(pageNumProvider.notifier).state = 1;
            break;
          case "管理者":
            setState(() {
              selectedList[4] = false;
            });
            ref.read(pageNumProvider.notifier).state = 2;
            break;
          case "入荷一覧":
            setState(() {
              selectedList[1] = false;
            });

            ref.read(itemFlgProvider.notifier).state = 1;
            ref.read(pageNumProvider.notifier).state = 3;
            break;
          case "商品一覧":
            setState(() {
              selectedList[2] = false;
            });
            ref.read(itemFlgProvider.notifier).state = 0;
            ref.read(pageNumProvider.notifier).state = 4;
            break;
          case "バーコードリーダー":
            setState(() {
              selectedList[1] = false;
            });
            ref.read(pageNumProvider.notifier).state = 5;
            break;
          case "プラン作成":
            setState(() {
              selectedList[3] = false;
            });
            ref.read(itemFlgProvider.notifier).state = 9;
            ref.read(pageNumProvider.notifier).state = 6;
            break;
          case "プラン一覧":
            setState(() {
              selectedList[3] = false;
            });
            ref.read(pageNumProvider.notifier).state = 7;

            break;
          case "拠点一覧":
            setState(() {
              selectedList[4] = false;
            });
            ref.read(pageNumProvider.notifier).state = 8;
            break;

          case "未入力件数":
            setState(() {
              selectedList[2] = false;
            });
            ref.read(itemFlgProvider.notifier).state = 2;
            ref.read(pageNumProvider.notifier).state = 4;

            break;
          case "入荷待ち件数":
            setState(() {
              selectedList[2] = false;
            });
            ref.read(itemFlgProvider.notifier).state = 3;
            ref.read(pageNumProvider.notifier).state = 4;
            break;
          case "未発送件数":
            setState(() {
              selectedList[2] = false;
            });
            ref.read(itemFlgProvider.notifier).state = 4;
            ref.read(pageNumProvider.notifier).state = 4;
            break;
          case "発送件数":
            setState(() {
              selectedList[2] = false;
            });
            ref.read(itemFlgProvider.notifier).state = 5;
            ref.read(pageNumProvider.notifier).state = 4;
            break;
          case "要確認件数":
            setState(() {
              selectedList[2] = false;
            });
            ref.read(itemFlgProvider.notifier).state = 6;
            ref.read(pageNumProvider.notifier).state = 4;
            break;
          case "長期未入荷件数":
            setState(() {
              selectedList[2] = false;
            });
            ref.read(itemFlgProvider.notifier).state = 7;
            ref.read(pageNumProvider.notifier).state = 4;
            break;
          case "未発送遅延件数":
            setState(() {
              selectedList[2] = false;
            });
            ref.read(itemFlgProvider.notifier).state = 8;
            ref.read(pageNumProvider.notifier).state = 4;
            break;
          case "利益計算表":
            setState(() {
              selectedList[5] = false;
            });

            ref.read(pageNumProvider.notifier).state = 9;
            break;
        }
        //handle the function
        //if index==0? donothing: doyourlogic here
        // ref.read(pageNumProvider.notifier).state = index;
        ref.read(pageChangeProvider.notifier).state = true;
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          subMenu,
          style: TextStyle(
            fontSize: isTitle ? 17 : 14,
            color: isTitle ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget sUserMenuButton(String subMenu, bool isTitle) {
    return InkWell(
      onTap: () async {
        switch (subMenu) {
          case "トップ":
            ref.read(pageNumProvider.notifier).state = 0;
            break;
          case "ユーザー情報":
            setState(() {
              selectedUserList[2] = false;
            });
            ref.read(pageNumProvider.notifier).state = 2;
            break;

          case "商品一覧":
            setState(() {
              selectedUserList[1] = false;
            });
            ref.read(itemFlgProvider.notifier).state = 0;
            ref.read(pageNumProvider.notifier).state = 1;
            break;

          case "連絡先":
            setState(() {
              selectedUserList[2] = false;
            });
            ref.read(pageNumProvider.notifier).state = 3;
            break;

          case "未入力件数":
            setState(() {
              selectedUserList[1] = false;
            });
            ref.read(itemFlgProvider.notifier).state = 2;
            ref.read(pageNumProvider.notifier).state = 1;

            break;
          case "入荷待ち件数":
            setState(() {
              selectedUserList[1] = false;
            });
            ref.read(itemFlgProvider.notifier).state = 3;
            ref.read(pageNumProvider.notifier).state = 1;
            break;
          case "未発送件数":
            setState(() {
              selectedUserList[1] = false;
            });
            ref.read(itemFlgProvider.notifier).state = 4;
            ref.read(pageNumProvider.notifier).state = 1;
            break;
          case "発送件数":
            setState(() {
              selectedUserList[1] = false;
            });
            ref.read(itemFlgProvider.notifier).state = 5;
            ref.read(pageNumProvider.notifier).state = 1;
            break;
          case "要確認件数":
            setState(() {
              selectedUserList[1] = false;
            });
            ref.read(itemFlgProvider.notifier).state = 6;
            ref.read(pageNumProvider.notifier).state = 1;
            break;
          case "長期未入荷件数":
            setState(() {
              selectedUserList[1] = false;
            });
            ref.read(itemFlgProvider.notifier).state = 7;
            ref.read(pageNumProvider.notifier).state = 1;
            break;
        }
        //handle the function
        //if index==0? donothing: doyourlogic here
        // ref.read(pageNumProvider.notifier).state = index;
        ref.read(pageChangeProvider.notifier).state = true;
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          subMenu,
          style: TextStyle(
            fontSize: isTitle ? 17 : 14,
            color: isTitle ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget blackIconTiles(WidgetRef ref, List<bool> selectedList) {
    return Container(
      width: context.screenWidth * 0.15,
      color: canvasColor,
      child: Column(
        children: [
          // controlTile(),
          SizedBox(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset('toppage-logo.gif'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: menus.length,
              itemBuilder: (BuildContext context, int index) {
                //  if(index==0) return controlTile();

                Menus menu = menus[index];

                return ExpansionTile(
                    onExpansionChanged: (z) async {
                      if (menu.submenus.isEmpty) {
                        ref.read(pageNumProvider.notifier).state = index;
                        if (menu.title == "ログアウト") {
                          await FirebaseAuth.instance.signOut();
                          ref.read(adminListProvider.notifier).clearList();
                          ref.read(customerListProvider.notifier).clearList();
                          ref.read(itemListProvider.notifier).clearList();
                          ref.read(planListProvider.notifier).clearList();
                          ref.read(baseListProvider.notifier).clearList();
                        }
                      }

                      setState(() {
                        selectedList[index] = z;
                        // ref.read(pageNumProvider.notifier).state =
                        //     z ? index : -1;
                      });
                    },
                    leading: Icon(menu.icon, color: Colors.white),
                    title: Text(
                      menu.title,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    trailing: menu.submenus.isEmpty
                        ? null
                        : Icon(
                            selectedList[index]
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                    children: menu.submenus.map((subMenu) {
                      return sMenuButton(subMenu, false);
                    }).toList());
              },
            ),
          ),
          expandedButton(),
        ],
      ),
    );
  }

  Widget userBlackIconTiles(WidgetRef ref, List<bool> selectedList) {
    return Container(
      width: context.screenWidth * 0.15,
      color: canvasColor,
      child: Column(
        children: [
          // controlTile(),
          SizedBox(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset('assets/logo-T-color.jpg'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: userMenus.length,
              itemBuilder: (BuildContext context, int index) {
                //  if(index==0) return controlTile();

                Menus menu = userMenus[index];

                return ExpansionTile(
                    onExpansionChanged: (z) async {
                      if (menu.submenus.isEmpty) {
                        ref.read(pageNumProvider.notifier).state = index;
                        if (menu.title == "ログアウト") {
                          await FirebaseAuth.instance.signOut();
                          ref.read(adminListProvider.notifier).clearList();
                          ref.read(customerListProvider.notifier).clearList();
                          ref.read(itemListProvider.notifier).clearList();
                          ref.read(planListProvider.notifier).clearList();
                          ref.read(baseListProvider.notifier).clearList();
                          ref.read(pageNumProvider.notifier).state = 1;
                        }
                      }

                      setState(() {
                        selectedList[index] = z;
                        // ref.read(pageNumProvider.notifier).state =
                        //     z ? index : -1;
                      });
                    },
                    leading: Icon(menu.icon, color: Colors.white),
                    title: Text(
                      menu.title,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    trailing: menu.submenus.isEmpty
                        ? null
                        : Icon(
                            selectedList[index]
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                    children: menu.submenus.map((subMenu) {
                      return sUserMenuButton(subMenu, false);
                    }).toList());
              },
            ),
          ),
          expandedButton(),
        ],
      ),
    );
  }

  Widget blackIconMenu(WidgetRef ref) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: context.screenWidth * 0.05,
      color: canvasColor,
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Image.asset('assets/logo-T-color.jpg'),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: menus.length,
                itemBuilder: (contex, index) {
                  // if(index==0) return controlButton();
                  return InkWell(
                    onTap: () async {
                      setState(() {
                        selectedList[index] = !selectedList[index];
                      });
                      if (menus[index].submenus.isEmpty) {
                        ref.read(pageNumProvider.notifier).state = index;
                        if (index == 6) {
                          await FirebaseAuth.instance.signOut();
                          ref.read(adminListProvider.notifier).clearList();
                          ref.read(customerListProvider.notifier).clearList();
                          ref.read(itemListProvider.notifier).clearList();
                          ref.read(planListProvider.notifier).clearList();
                          ref.read(baseListProvider.notifier).clearList();
                          ref.read(pageNumProvider.notifier).state = 1;
                          ref.read(pageNumProvider.notifier).state = 1;
                        }
                      }
                    },
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      child: Icon(menus[index].icon, color: Colors.white),
                    ),
                  );
                }),
          ),
          expandedButton(),
        ],
      ),
    );
  }

  Widget userBlackIconMenu(WidgetRef ref) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: context.screenWidth * 0.05,
      color: canvasColor,
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Image.asset('assets/logo-T-color.jpg'),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: userMenus.length,
                itemBuilder: (contex, index) {
                  // if(index==0) return controlButton();
                  return InkWell(
                    onTap: () async {
                      setState(() {
                        selectedUserList[index] = !selectedUserList[index];
                      });
                      if (userMenus[index].submenus.isEmpty) {
                        ref.read(pageNumProvider.notifier).state = index;
                        if (index == 3) {
                          await FirebaseAuth.instance.signOut();
                          ref.read(adminListProvider.notifier).clearList();
                          ref.read(customerListProvider.notifier).clearList();
                          ref.read(itemListProvider.notifier).clearList();
                          ref.read(planListProvider.notifier).clearList();
                          ref.read(baseListProvider.notifier).clearList();
                          ref.read(pageNumProvider.notifier).state = 1;
                        }
                      }
                    },
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      child: Icon(userMenus[index].icon, color: Colors.white),
                    ),
                  );
                }),
          ),
          expandedButton(),
        ],
      ),
    );
  }

  Widget subMenuWidget(List<String> submenus, bool isValidSubMenu) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: isValidSubMenu ? submenus.length.toDouble() * 55 : 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: isValidSubMenu ? canvasColor : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          )),
      child: ListView.builder(
          padding: const EdgeInsets.all(6),
          itemCount: isValidSubMenu ? submenus.length : 0,
          itemBuilder: (context, index) {
            String subMenu = submenus[index];
            return ref.watch(loginUserProvider).adimnFig
                ? sMenuButton(subMenu, index == 0)
                : sUserMenuButton(subMenu, index == 0);
          }),
    );
  }

  Widget invisibleSubMenus(List<bool> selectedList) {
    // List<CDM> _cmds = cdms..removeAt(0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: isExpanded ? 0 : 125,
      // 透明背景
      color: Colors.transparent.withOpacity(0),
      child: Column(
        children: [
          Container(height: 95),
          Expanded(
            child: ListView.builder(
                itemCount: menus.length,
                itemBuilder: (context, index) {
                  Menus menu = menus[index];
                  // if(index==0) return Container(height:95);
                  //controll button has 45 h + 20 top + 30 bottom = 95

                  return subMenuWidget([menu.title, ...menu.submenus],
                      selectedList[index] && menu.submenus.isNotEmpty);
                }),
          ),
        ],
      ),
    );
  }

  Widget invisibleUserSubMenus(List<bool> selectedList) {
    // List<CDM> _cmds = cdms..removeAt(0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: isExpanded ? 0 : 125,
      // 透明背景
      color: Colors.transparent.withOpacity(0),
      child: Column(
        children: [
          Container(height: 95),
          Expanded(
            child: ListView.builder(
                itemCount: userMenus.length,
                itemBuilder: (context, index) {
                  Menus menu = userMenus[index];
                  // if(index==0) return Container(height:95);
                  //controll button has 45 h + 20 top + 30 bottom = 95

                  return subMenuWidget([menu.title, ...menu.submenus],
                      selectedList[index] && menu.submenus.isNotEmpty);
                }),
          ),
        ],
      ),
    );
  }

  List<bool> selectedList = List.generate(menus.length, (index) => false);
  List<bool> selectedUserList =
      List.generate(userMenus.length, (index) => false);
  Widget row(WidgetRef ref, bool adminFig) {
    if (adminFig) {
      return isExpanded
          ? blackIconTiles(ref, selectedList)
          : blackIconMenu(ref);
    } else {
      return isExpanded
          ? userBlackIconTiles(ref, selectedUserList)
          : userBlackIconMenu(ref);
    }
  }

  Future<bool> getLoginUser(uid) async {
    final store = FirebaseFirestore.instance;
    final docSnapshot =
        await store.collection('admins').where('uid', isEqualTo: uid).get();
    final queryDocSnapshot = docSnapshot.docs;
    bool approval = false;
    if (queryDocSnapshot.isEmpty) {
      final docUserSnapshot =
          await store.collection('users').where('uid', isEqualTo: uid).get();
      final queryDocSnapshotUser = docUserSnapshot.docs;
      if (queryDocSnapshotUser.isEmpty) {
        if (!mounted) return false;
        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              NewUserDetailScreen(user: FirebaseAuth.instance.currentUser!),
        ));
      }
      for (final snapshot in queryDocSnapshotUser) {
        final data = snapshot.data();
        approval = data["approval"];
        await ref.watch(loginUserProvider.notifier).create(LoginUserModel(
            uid: data["uid"],
            name: data["name"],
            base: List.from(data["base"]),
            adimnFig: false,
            superAdimnFig: false));
      }
    } else {
      for (final snapshot in queryDocSnapshot) {
        final data = snapshot.data();
        await ref.read(loginUserProvider.notifier).create(LoginUserModel(
            uid: data["uid"],
            name: data["name"],
            base: List.from(data["base"]),
            adimnFig: true,
            superAdimnFig: data["super_flg"]));

        print(data["super_flg"]);
      }
      approval = true;
    }

    return approval;
  }

  Future<bool> _init() async {
    res = await getLoginUser(FirebaseAuth.instance.currentUser!.uid);

    if (ref.watch(loginUserProvider).adimnFig) {
      await adminDatabase.getallAdmins(ref);
      await customerDatabase.getallCustomers(ref);
      await itemDatabase.getallItems(ref);
      await baseDatabase.getallBases(ref);
      await planDatabase.getallPlans(ref);
    } else {
      if (res!) {
        await customerDatabase.getallCustomers(ref);
        await itemDatabase.getallItems(ref);
        await baseDatabase.getallBases(ref);
        return true;
      } else {
        await customerDatabase.getallCustomers(ref);
        return res!;
        // Navigator.of(context).push(
        //   MaterialPageRoute(builder: (context) {
        //     return const NewUserSubmit();
        //   }),
        // );
      }
    }

    return true;
  }

  @override
  void dispose() {
    // ref.read(adminListProvider.notifier).clearList();
    // ref.read(customerListProvider.notifier).clearList();
    // ref.read(itemListProvider.notifier).clearList();
    // ref.read(loginUserProvider.notifier).();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    result = _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: result!.whenComplete(() {
          if (ref.read(loginUserProvider).adimnFig &&
              !ref.read(loginUserProvider).superAdimnFig &&
              firstBuild) {
            menus.removeAt(5);
          }
          firstBuild = false;
        }),
        builder: (context, snapshot) {
          if (result == null ||
              ref.watch(loginUserProvider).name == "" ||
              res == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!res! && !ref.watch(loginUserProvider).adimnFig) {
            return const NewUserSubmit();
          } else {
            return SafeArea(
              child: Row(
                children: [
                  row(ref, ref.watch(loginUserProvider).adimnFig),
                  Expanded(
                      child: Stack(
                    children: [
                      ref.watch(loginUserProvider).adimnFig
                          ? _bodys[ref.watch(pageNumProvider)]
                          : _bodysCustomer[ref.watch(pageNumProvider)],
                      if (ref.watch(loginUserProvider).adimnFig)
                        if (selectedList.where((element) => element).isNotEmpty)
                          invisibleSubMenus(selectedList),
                      if (!ref.watch(loginUserProvider).adimnFig)
                        if (selectedUserList
                            .where((element) => element)
                            .isNotEmpty)
                          invisibleUserSubMenus(selectedUserList),
                    ],
                  )),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);

class Menus {
  //complex drawer menu
  final IconData icon;
  final String title;
  final List<String> submenus;

  Menus(this.icon, this.title, this.submenus);
}

List<Menus> menus = [
  Menus(Icons.assessment, "トップ", []),
  Menus(Icons.local_shipping, "入荷", [
    "入荷一覧",
    "バーコードリーダー",
  ]),
  Menus(Icons.inventory, "商品検索", [
    "商品一覧",
    "入荷待ち件数",
    "未発送件数",
    "発送件数",
    "要確認件数",
    "長期未入荷件数",
    "未発送遅延件数",
  ]),
  Menus(Icons.description, "プラン", [
    "プラン一覧",
    "プラン作成",
  ]),
  Menus(Icons.person, "ユーザー", [
    "ユーザー",
    "管理者",
    "拠点一覧",
  ]),
  Menus(Icons.analytics, "レポート", [
    "利益計算表",
  ]),
  Menus(Icons.logout, "ログアウト", []),
];

List<Menus> userMenus = [
  Menus(Icons.assessment, "トップ", []),
  Menus(Icons.inventory, "商品検索", [
    "商品一覧",
    "未入力件数",
    "入荷待ち件数",
    "未発送件数",
    "発送件数",
    "要確認件数",
    "長期未入荷件数",
  ]),
  Menus(Icons.person, "ユーザー", [
    "ユーザー情報",
    "連絡先",
  ]),
  Menus(Icons.logout, "ログアウト", []),
];
