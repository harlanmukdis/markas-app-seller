import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/constant.dart';
import '../utils/local_network.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppInitial());

  Future<void> toggleAppTheme(BuildContext context) async {
    final currentTheme = CachedHelper.getData(kAppTheme);

    final newTheme = currentTheme == kDark ? kLight : kDark;

    await CachedHelper.saveData(kAppTheme, newTheme);
    emit(AppThemeChanged());
  }
}
