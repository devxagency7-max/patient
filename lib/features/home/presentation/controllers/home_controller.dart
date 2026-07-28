import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit للـ Navigation — الـ NavBar يتتبع التاب المحدد
class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);

  void setIndex(int index) {
    emit(index);
  }
}
