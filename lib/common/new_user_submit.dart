import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import './backgroundAnimation.dart';
import './login_page.dart';
import '../exSize.dart';

class NewUserSubmit extends StatefulWidget {
  const NewUserSubmit({super.key});

  @override
  _NewUserSubmitState createState() => _NewUserSubmitState();
}

class _NewUserSubmitState extends State<NewUserSubmit> {
  Future<void> changePage() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(159, 127, 237, 223),
      body:
          // BackgroundAnimation(
          //   size: MediaQuery.of(context).size,
          //   child:
          Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
            SizedBox(
              height: context.screenHeight * 0.3,
              child: const Text(
                'ご登録いただきありがとうございます。\n QRコードからLINE友達追加の後、\n 「納品代行利用」というメッセージを送信して下さい。\n承認後にログイン可能となります。',
                textAlign: TextAlign.center,
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
              height: context.screenHeight * 0.2,
              child: Image.asset(
                'assets/QRcord.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(
              height: context.screenHeight * 0.1,
            ),
            SizedBox(
              width: context.screenWidth * 0.15,
              height: context.screenHeight * 0.08,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent.withOpacity(0.8)),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    // await changePage();
                    // Navigator.of(context).pushReplacement(
                    //   MaterialPageRoute(builder: (context) {
                    //     await changePage();
                    //   }),
                    // );
                  },
                  child: const Text('ログイン画面へ戻る')),
            ),
          ])),
      // ),
    );
  }
}
