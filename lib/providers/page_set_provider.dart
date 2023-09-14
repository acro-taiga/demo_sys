 import 'package:delivery_control_web/models/item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

 
final pageNumProvider = StateProvider<int>((ref) {
    return 0;
  });


final itemFlgProvider = StateProvider<int>((ref) {
    return 0;
  });


// final controllerProvider = StateProvider<SidebarXController>((ref) {
//     return  SidebarXController(selectedIndex: 0, extended: true);
//   });



final filterItemListProvider = StateProvider<List<AmazonItem>>((ref) {
    return [];
  });

final pageChangeProvider = StateProvider<bool>((ref) {
    return false;
  });
