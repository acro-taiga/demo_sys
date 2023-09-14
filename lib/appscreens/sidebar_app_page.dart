import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_control_web/appscreens/barcode_scan_app.dart';
import 'package:delivery_control_web/appscreens/itemsearch_app.dart';
import 'package:delivery_control_web/models/loginUser.dart';
import 'package:delivery_control_web/providers/admin_database_provider.dart';
import 'package:delivery_control_web/providers/base_database_provider.dart';
import 'package:delivery_control_web/providers/customer_database_provider.dart';
import 'package:delivery_control_web/providers/item_database_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SidebarAppPage extends ConsumerStatefulWidget {
  const SidebarAppPage({super.key});
  @override
  SidebarAppPageState createState() => SidebarAppPageState();
}

class SidebarAppPageState extends ConsumerState<SidebarAppPage> {
  AdminDatabase adminDatabase = AdminDatabase();
  CustomerDatabase customerDatabase = CustomerDatabase();
  ItemDatabase itemDatabase = ItemDatabase();
  BaseDatabase baseDatabase = BaseDatabase();
  late Future<bool> res;

  static final _screens = [
    const ItemSearchApp(),
    const BarcodeReadApp(),
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        await ref.watch(loginUserProvider.notifier).create(LoginUserModel(
            uid: data["uid"],
            name: data["name"],
            base: List.from(data["base"]),
            adimnFig: true,
            superAdimnFig: data["super_flg"]));
      }
    }
    return approval;
  }

  Future<bool> _init() async {
    await getLoginUser(FirebaseAuth.instance.currentUser!.uid);
    await adminDatabase.getallAdmins(ref);
    await customerDatabase.getallCustomers(ref);
    await itemDatabase.getallItems(ref);
    await baseDatabase.getallBases(ref);

    return Future.value(true);
  }

  @override
  void initState() {
    res = _init();
    super.initState();
  }

  @override
  void dispose() {
    // ref.read(itemListProvider.notifier).dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: res,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return _screens[_selectedIndex];
            }),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.chrome_reader_mode), label: '入荷'),
            BottomNavigationBarItem(
                icon: Icon(Icons.barcode_reader), label: 'バーコードスキャン'),
          ],
          type: BottomNavigationBarType.fixed,
        ));
  }
}
