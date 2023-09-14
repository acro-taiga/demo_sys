import 'package:async/async.dart';
import 'package:delivery_control_web/exSize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Base {
  String name;
  String mail;
  String phoneNum;
  String postNum;
  String post;
  bool select;
  Base(
      {required this.name,
      required this.mail,
      required this.phoneNum,
      required this.postNum,
      required this.post,
      required this.select});
}

class BaseList extends StateNotifier<List<Base>> {
  BaseList() : super([]);

  void addBase(Base base) {
    state = [...state, base];
  }

  void clearList() {
    state = [];
  }
}

final baseListProvider = StateNotifierProvider<BaseList, List<Base>>((ref) {
  return BaseList();
});

class SelectBase {
  final AsyncMemoizer memoizer = AsyncMemoizer();
  Widget selectBasePull(
      List<String> baseNames, Function method, WidgetRef ref) {
    // Future<void> _init() async {
    //   memoizer.runOnce(() async {
    //     for (var base in ref.watch(baseListProvider)) {
    //       base.select = false;
    //     }
    //     if (baseNames.isNotEmpty) {
    //       for (var baseName in baseNames) {
    //         for (var base in ref.watch(baseListProvider)) {
    //           if (base.name == baseName) {
    //             base.select = true;
    //           }
    //         }
    //       }
    //     } else {
    //       for (var base in ref.watch(baseListProvider)) {
    //         if (ref.read(loginUserProvider).base.contains(base.name)) {
    //           base.select = true;
    //         }
    //       }
    //     }
    //   });
    // }

    return StatefulBuilder(builder: (context, setState) {
      return SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: context.screenHeight * 0.65,
            width: context.screenWidth * 0.3,
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: ref.read(baseListProvider).length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                childAspectRatio: 2.0,
              ),
              itemBuilder: (context, index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: context.screenWidth * 0.01,
                      child: Checkbox(
                          value: ref.read(baseListProvider)[index].select,
                          onChanged: (value) {
                            setState(() {
                              ref.read(baseListProvider)[index].select =
                                  !ref.read(baseListProvider)[index].select;
                            });
                          }),
                    ),
                    SizedBox(
                      width: context.screenWidth * 0.01,
                    ),
                    SizedBox(
                      width: context.screenWidth * 0.1,
                      child: Text(
                        ref.read(baseListProvider)[index].name,
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(
              height: context.screenHeight * 0.1,
              child: ElevatedButton(
                child: const Text("確定して戻る"),
                onPressed: () {
                  method();
                },
              ))
        ],
      ));
    });
  }
}

// 委託先	一般	大型	要・危	シール	セット	月額
// プレワーク	10	10	0	0	20	0
// mediccary	10	10	0	0	20	0
// すまいるスプリング	5	5	0	0	10	0
// 栗の実	20	20	0	0	40	0
// ワークスタジオ	10	10	0	0	20	0
// 複数	10	10	0	0	20	0
// 武蔵野ワーキングセンター	10	10	0	0	20	0
// アビリティ	10	10	0	0	20	0
// まぁぶるひろ	10	10	0	0	20	0
// おりべ	10	10	0	0	20	0
// SBワークス	5	5	0	0	10	0
// ミラクル	5	5	0	0	10	0
// 未来サポート	20	20	0	0	40	0
// CFP	20	20	0	0	40	0
// 複数拠点	10	10	0	0	20	0
// plusA	10	10	0	0	20	0
// をmap型で保存
List<Map<String, dynamic>> baseMasterData = [
  {
    "委託先": "プレワーク",
    "一般": 10,
    "大型": 0,
    "要・危": 0,
    "シール": 20,
    "セット": 0,
    "月額": 0,
  },
  {
    "委託先": "medicarry",
    "一般": 10,
    "大型": 0,
    "要・危": 0,
    "シール": 20,
    "セット": 0,
    "月額": 0,
  },
  {
    "委託先": "すまいるスプリング",
    "一般": 5,
    "大型": 0,
    "要・危": 0,
    "シール": 10,
    "セット": 0,
    "月額": 0,
  },
  {
    "委託先": "栗の実",
    "一般": 20,
    "大型": 0,
    "要・危": 0,
    "シール": 40,
    "セット": 0,
    "月額": 0,
  },
  {
    "委託先": "ワークスタジオ",
    "一般": 10,
    "大型": 0,
    "要・危": 0,
    "シール": 20,
    "セット": 0,
    "月額": 0,
  },
  {
    "委託先": "複数",
    "一般": 10,
    "大型": 0,
    "要・危": 0,
    "シール": 20,
    "セット": 0,
    "月額": 0,
  },
  {
    "委託先": "武蔵野ワーキングセンター",
    "一般": 10,
    "大型": 0,
    "要・危": 0,
    "シール": 20,
    "セット": 0,
    "月額": 0,
  },
  {
    "委託先": "アビリティ",
    "一般": 10,
    "大型": 0,
    "要・危": 0,
    "シール": 20,
    "セット": 0,
    "月額": 0,
  },
  {
    "委託先": "まぁぶるひろ",
    "一般": 10,
    "大型": 0,
    "要・危": 0,
    "シール": 20,
    "セット": 0,
    "月額": 0,
  },
  {
    "委託先": "おりべ",
    "一般": 10,
    "大型": 0,
    "要・危": 0,
    "シール": 20,
    "セット": 0,
    "月額": 0,
  },
  {
    "委託先": "SBワークス",
    "一般": 5,
    "大型": 0,
    "要・危": 0,
    "シール": 10,
    "セット": 0,
    "月額": 0,
  },
  {
    "委託先": "ミラクル",
    "一般": 5,
    "大型": 0,
    "要・危": 0,
    "シール": 10,
    "セット": 0,
    "月額": 0,
  },
  {
    "委託先": "未来サポート",
    "一般": 20,
    "大型": 0,
    "要・危": 0,
    "シール": 40,
    "セット": 0,
    "月額": 0,
  },
  {
    "委託先": "CFP",
    "一般": 20,
    "大型": 0,
    "要・危": 0,
    "シール": 40,
    "セット": 0,
    "月額": 0,
  },
  {
    "委託先": "複数拠点",
    "一般": 10,
    "大型": 0,
    "要・危": 0,
    "シール": 20,
    "セット": 0,
    "月額": 0,
  },
  {
    "委託先": "plusA",
    "一般": 10,
    "大型": 0,
    "要・危": 0,
    "シール": 20,
    "セット": 0,
    "月額": 0,
  }
];
