import 'package:delivery_control_web/providers/customer_database_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

import './backgroundAnimation.dart';
import '../exSize.dart';
import './popup.dart';

class NewUserScreen extends StatefulWidget {
  const NewUserScreen({Key? key}) : super(key: key);

  @override
  NewUserScreenState createState() => NewUserScreenState();
}

class NewUserScreenState extends State<NewUserScreen> {
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool passwordCheck = false;
  bool confirmPasswordCheck = false;
  CustomerDatabase customerDatabase = CustomerDatabase();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FlutterPwValidatorState> validatorKey =
      GlobalKey<FlutterPwValidatorState>();

  void errorMethod(context) {
    Navigator.of(context).pop();
  }

  Future<void> submit() async {
    if (!_key.currentState!.validate()) return;
    try {
      await customerDatabase.tempRegistration(email, password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        PopupAlert.alert(context, '入力されたメールアドレスは登録されています', errorMethod);
      } else {
        PopupAlert.alert(context, '入力されたメールアドレスは使用できません', errorMethod);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(159, 127, 237, 223),
      extendBodyBehindAppBar: true,
      body:
          // BackgroundAnimation(
          //   size: MediaQuery.of(context).size,
          //   child:
          Form(
        key: _key,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: context.screenHeight * 0.1,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  height: context.screenHeight * 0.65,
                  width: context.screenWidth * 0.8,
                  // decoration: BoxDecoration(
                  //   boxShadow: [
                  //     BoxShadow(
                  //       color: Colors.grey,
                  //       spreadRadius: 5,
                  //       blurRadius: 5,
                  //       offset: Offset(1, 1),
                  //     )
                  //   ],
                  //   color: Colors.white,
                  // ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          width: context.screenWidth * 0.735,
                          child: const Text(
                            'メールアドレス（今後のログインIDとなります）',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.mail),
                            // hintText: 'メールアドレスを入力',
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
                              email = value;
                            });
                          },
                        ),
                        SizedBox(
                          height: context.screenHeight * 0.05,
                        ),
                        SizedBox(
                          width: context.screenWidth * 0.735,
                          child: const Text(
                            'パスワード（ログインに使用します）',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                            setState(
                              () {
                                password = value;
                              },
                            );
                          },
                          validator: (value) {
                            if (!passwordCheck) {
                              return 'パスワードが条件に反しています';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: context.screenHeight * 0.02,
                        ),
                        FlutterPwValidator(
                            strings: JaStrings(),
                            controller: passwordController,
                            minLength: 8,
                            width: context.screenWidth * 0.3,
                            height: context.screenHeight * 0.1,
                            onSuccess: () {
                              passwordCheck = true;
                            },
                            onFail: () {
                              passwordCheck = false;
                            }),
                        SizedBox(height: context.screenHeight * 0.01),
                        SizedBox(
                          width: context.screenWidth * 0.735,
                          child: const Text(
                            'パスワードを再入力',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextFormField(
                          onFieldSubmitted: (_) async {
                            await submit();
                          },
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
                                  hideConfirmPassword = !hideConfirmPassword;
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
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.screenHeight * 0.02),
                SizedBox(
                  width: context.screenWidth * 0.15,
                  height: context.screenHeight * 0.08,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent.withOpacity(0.8)),
                      onPressed: () async {
                        await submit();
                      },
                      child: const Text('登録')),
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
