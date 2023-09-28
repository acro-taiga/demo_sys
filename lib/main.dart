import 'dart:io';

import 'package:delivery_control_web/appscreens/login_app.dart';
import 'package:delivery_control_web/appscreens/sidebar_app_page.dart';
import 'package:delivery_control_web/common/login_page.dart';
import 'package:delivery_control_web/common/sidebar.dart';
import 'package:delivery_control_web/exSize.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'),
        Locale('ar'),
        Locale('ja'),
      ],
      title: 'easy_sidemenu Demo',
      theme: ThemeData(
        primarySwatch: primeColor,
        useMaterial3: false,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // スプラッシュ画面などに書き換えても良い
          return const SizedBox();
        }
        if (snapshot.hasData) {
          // User が null でなない、つまりサインイン済みのホーム画面へ
          try {
            if (Platform.isAndroid || Platform.isIOS) {
              return const SidebarAppPage();
            }
          } catch (e) {
            print(e);
          }

          return const SidebarPage();
        }
        // User が null である、つまり未サインインのサインイン画面へ
        // こっちにログインページ

        try {
          if (Platform.isAndroid || Platform.isIOS) {
            return const LoginPageApp();
          }
        } catch (e) {
          print(e);
        }

        return const LoginPage();
      },
    ));
  }
}
