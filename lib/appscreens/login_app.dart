import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_control_web/appscreens/sidebar_app_page.dart';
import 'package:delivery_control_web/common/backgroundAnimation.dart';
import 'package:delivery_control_web/common/popup.dart';
import 'package:delivery_control_web/models/loginUser.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../exSize.dart';

class LoginPageApp extends ConsumerStatefulWidget {
  const LoginPageApp({Key? key}) : super(key: key);

  @override
  LoginPageAppState createState() => LoginPageAppState();
}

class LoginPageAppState extends ConsumerState<LoginPageApp> {
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool hidePassword = true;
  late LoginUserModel loginUser;

  void errorMethod(context) {
    Navigator.pop(context);
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

  Future<void> submit() async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // await getLoginUser(FirebaseAuth.instance.currentUser!.uid);
      if (mounted) {
        try {
          if (Platform.isAndroid || Platform.isIOS) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return const SidebarAppPage();
                },
              ),
            );
          }
        } catch (e) {
          print(e);
        }
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return const SidebarAppPage();
            },
          ),
        );
      }
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
      body: SafeArea(
        child: 
        // BackgroundAnimation(
        //   size: MediaQuery.of(context).size,
        //   child: 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: context.screenHeight * 0.03,
                  ),
                  SizedBox(
                    height: context.screenHeight * 0.45,
                    width: context.screenWidth * 0.45,
                    child: Image.asset("assets/logo-T-color.jpg"),
                  ),
                  SizedBox(
                    height: context.screenHeight * 0.01,
                  ),
                  SizedBox(
                    width: context.screenWidth * 0.5,
                    height: context.screenHeight * 0.05,
                    child: const Text('ログインID',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  SizedBox(
                    width: context.screenWidth * 0.5,
                    height: context.screenHeight * 0.1,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.mail),
                        // hintText: 'メールアドレスを入力',
                        labelText: 'Email Address',
                      ),
                      onChanged: (String value) {
                        setState(() {
                          email = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: context.screenHeight * 0.02),
                  SizedBox(
                    width: context.screenWidth * 0.5,
                    height: context.screenHeight * 0.05,
                    child: const Text('パスワード',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  SizedBox(
                    width: context.screenWidth * 0.5,
                    height: context.screenHeight * 0.1,
                    child: TextFormField(
                      onFieldSubmitted: (_) async {
                        await submit();
                      },
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.lock),
                        // hintText: 'パスワードを入力',
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
                  SizedBox(height: context.screenHeight * 0.02),
                  SizedBox(
                    width: context.screenWidth * 0.4,
                    height: context.screenHeight * 0.05,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.blueAccent.withOpacity(0.8)),
                        onPressed: () async {
                          submit();
                        },
                        child: const Text('ログイン')),
                  ),
                  SizedBox(
                    height: context.screenHeight * 0.02,
                  ),
                ],
              ),
            ),
          ),
        ),
      // ),
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
