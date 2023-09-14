import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class PopupAlert {
  // PopupAlert({Key? key}) : super(key: key);

  static Future<void> alert(context, text, errorMethod) async {
    return showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(''),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                errorMethod(context);
                // Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> alertdialog(
      context, text, deleteMethod, cancellMethod) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer(builder: (context, ref, _) {
          return AlertDialog(
            title: const Text(''),
            content: Text(text),
            actions: [
              Builder(builder: (context) {
                return TextButton(
                  onPressed: () {
                    deleteMethod(ref, context);
                  },
                  child: const Text('削除する'),
                );
              }),
              Builder(builder: (context) {
                return TextButton(
                  onPressed: () {
                    cancellMethod(context);
                  },
                  child: const Text('キャンセル'),
                );
              }),
            ],
          );
        });
      },
    );
  }
}

class YesNoDialog extends StatelessWidget {
  final String title;
  final String message;
  final Function() onYesAction;
  const YesNoDialog(
      {required this.title, required this.message, required this.onYesAction});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: Container(
            padding:
                const EdgeInsets.only(top: 16, right: 8, bottom: 16, left: 16),
            child: Text('いいえ'),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Container(
            padding:
                const EdgeInsets.only(top: 16, right: 16, bottom: 16, left: 8),
            child: Text('はい'),
          ),
          onPressed: () {
            onYesAction();
          },
        )
      ],
    );
  }
}

class YesDialog extends StatelessWidget {
  final String title;
  final String message;
  const YesDialog({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          child: Container(
            padding:
                const EdgeInsets.only(top: 16, right: 16, bottom: 16, left: 8),
            child: Text('はい'),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
