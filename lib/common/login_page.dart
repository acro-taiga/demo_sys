import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_control_web/common/new_user_screen.dart';

import 'package:delivery_control_web/models/loginUser.dart';
import 'package:delivery_control_web/providers/page_set_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './backgroundAnimation.dart';

import 'package:lottie/lottie.dart';

import '../exSize.dart';
import './popup.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends ConsumerState<LoginPage> {
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool hidePassword = true;
  late LoginUserModel loginUser;
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  void errorMethod(context) {
    Navigator.pop(context);
  }

  Future<void> submitMail() async {
    if (!mounted) return;
    Navigator.pop(context);
  }

  // Future<bool> getLoginUser(uid) async {
  //   final store = FirebaseFirestore.instance;
  //   final docSnapshot =
  //       await store.collection('admins').where('uid', isEqualTo: uid).get();
  //   final queryDocSnapshot = docSnapshot.docs;
  //   bool approval = false;
  //   if (queryDocSnapshot.isEmpty) {
  //     final docUserSnapshot =
  //         await store.collection('users').where('uid', isEqualTo: uid).get();
  //     final queryDocSnapshotUser = docUserSnapshot.docs;
  //     for (final snapshot in queryDocSnapshotUser) {
  //       final data = snapshot.data();
  //       approval = data["approval"];
  //       await ref.watch(loginUserProvider.notifier).create(LoginUserModel(
  //           uid: data["uid"],
  //           name: data["name"],
  //           base: List.from(data["base"]),
  //           adimnFig: false,
  //           superAdimnFig: false));
  //     }
  //   } else {
  //     for (final snapshot in queryDocSnapshot) {
  //       final data = snapshot.data();
  //       await ref.watch(loginUserProvider.notifier).create(LoginUserModel(
  //           uid: data["uid"],
  //           name: data["name"],
  //           base: List.from(data["base"]),
  //           adimnFig: true,
  //           superAdimnFig: data["super_flg"]));
  //     }
  //   }
  //   return approval;
  // }

  Future<void> submit() async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      ref.read(pageNumProvider.notifier).state = 0;
      // await getLoginUser(FirebaseAuth.instance.currentUser!.uid);
      // if (mounted) {
      //   Navigator.of(context).push(
      //     MaterialPageRoute(
      //       builder: (context) {
      //         return const SidebarPage();
      //       },
      //     ),
      //   );
      // }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        PopupAlert.alert(context, 'メールアドレスのフォーマットが正しくありません', errorMethod);
      } else if (e.code == 'user-disabled') {
        PopupAlert.alert(context, '入力されたメールアドレスは使用できません', errorMethod);
      } else if (e.code == 'user-not-found') {
        PopupAlert.alert(context, '入力されたメールアドレスは登録されていません', errorMethod);
      } else if (e.code == 'wrong-password') {
        PopupAlert.alert(context, 'パスワードが誤っています', errorMethod);
      } else {
        PopupAlert.alert(context, '入力されたメールアドレスもしくはパスワードが誤っています', errorMethod);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> resetPass(String mail) async {
    if (!_key.currentState!.validate()) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: mail);
    } catch (e) {
      print(e);
    }

    if (!mounted) return;
    PopupAlert.alert(context, 'メールが送信されました。', errorMethod);
  }

  Future<void> resetting(context) async {
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
                                    decoration: const InputDecoration(
                                      icon: Icon(Icons.abc),
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
                                          await submitMail();
                                          await resetPass(mail);
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

  // @override
  // void dispose() {
  //   ref.read(adminListProvider.notifier).clearList();
  //   ref.read(customerListProvider.notifier).clearList();
  //   ref.read(itemListProvider.notifier).clearList();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(159, 127, 237, 223),
      extendBodyBehindAppBar: true,
      body: BackgroundAnimation(
        size: MediaQuery.of(context).size,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: context.screenHeight * 0.03,
                ),
                SizedBox(
                  height: context.screenHeight * 0.35,
                  child: Lottie.network(
                    "https://lottie.host/b03d82d9-749c-4f6d-b117-5e15824f3d5f/eKCBTidGBB.json",
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  // height: context.screenHeight * 0.5,
                  width: context.screenWidth * 0.8,
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // SizedBox(
                      //   width: context.screenWidth * 0.5,
                      //   height: context.screenHeight * 0.05,
                      //   child: const Text('ログインID',
                      //       style: TextStyle(
                      //         fontSize: 20,
                      //         fontWeight: FontWeight.bold,
                      //       )),
                      // ),
                      SizedBox(
                        width: context.screenWidth * 0.5,
                        height: context.screenHeight * 0.08,
                        child: TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.mail),
                            hintText: 'メールアドレスを入力',
                            labelText: 'LOGIN ID',
                          ),
                          onChanged: (String value) {
                            setState(() {
                              email = value;
                            });
                          },
                        ),
                      ),
                      // SizedBox(
                      //   width: context.screenWidth * 0.5,
                      //   height: context.screenHeight * 0.05,
                      //   child: const Text('パスワード',
                      //       style: TextStyle(
                      //         fontSize: 20,
                      //         fontWeight: FontWeight.bold,
                      //       )),
                      // ),
                      SizedBox(
                        height: context.screenHeight * 0.05,
                      ),
                      SizedBox(
                        width: context.screenWidth * 0.5,
                        height: context.screenHeight * 0.08,
                        child: TextFormField(
                          onFieldSubmitted: (_) async {
                            await submit();
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
                        ),
                      ),
                      Container(
                        width: context.screenWidth * 0.5,
                        height: context.screenHeight * 0.05,
                        // color: Colors.red,
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            // 忘れた方はこちらページ
                            await resetting(context);
                          },
                          child: const Text('※パスワードを忘れた方はこちら',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Color.fromARGB(255, 131, 131, 131),
                              )),
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
                              submit();
                            },
                            child: const Text('ログイン')),
                      ),
                      // SizedBox(height: context.screenHeight * 0.02),
                      // Container(
                      //   height: context.screenHeight * 0.05,
                      //   child: TextButton(
                      //     onPressed: () async {
                      //       // 忘れた方はこちらページ
                      //       await resetting(context);
                      //     },
                      //     child: const Text('※忘れた方はこちら',
                      //         style: TextStyle(
                      //           decoration: TextDecoration.underline,
                      //           color: Colors.black,
                      //         )),
                      //   ),
                      // ),
                      SizedBox(height: context.screenHeight * 0.05),
                      SizedBox(
                        width: context.screenWidth * 0.15,
                        height: context.screenHeight * 0.08,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.redAccent.withOpacity(0.8)),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const NewUserScreen(),
                              ));
                            },
                            child: const Text('新規利用者登録')),
                      ),
                      SizedBox(
                        height: context.screenHeight * 0.01,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // );
      ),
    );
  }
}

class BackgroundAnimation2 extends StatefulWidget {
  const BackgroundAnimation2({
    Key? key,
    required this.size,
    required this.child,
  }) : super(key: key);
  final Size size;
  final Widget child;

  @override
  BackgroundAnimation2State createState() => BackgroundAnimation2State();
}

class BackgroundAnimation2State extends State<BackgroundAnimation2> {
  late Timer timer;
  double time = 0;

  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 1000 ~/ 60); // 60fps
    timer = Timer.periodic(duration, (timer) {
      setState(() {
        time += 0.0025;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        CustomPaint(
          size: size,
          painter: AnimationPainter2(
            waveColor: Colors.blueAccent.withOpacity(0.8),
            height: 0.25,
            time: time,
          ),
        ),
        Center(
          child: widget.child,
        ),
      ],
    );
  }
}
