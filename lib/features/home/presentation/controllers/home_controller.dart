import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controller للـ Navigation — الـ NavBar يتتبع التاب المحدد
class NavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

/// Provider لتتبع التاب المحدد في الـ NavBar
final selectedNavIndexProvider = NotifierProvider<NavIndexNotifier, int>(
  NavIndexNotifier.new,
);
