import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/local_network.dart';
import '../../../favorites/favorites_view.dart';
import '../../../home/presentation/views/home_page.dart';
import '../../../my_cart/presentation/views/my_cart.dart';
import '../../../profile/presentaion/views/profile_view.dart';
import '../../../trending/trending_view.dart';

part 'home_layout_state.dart';

class HomeLayoutCubit extends Cubit<HomeLayoutState> {
  HomeLayoutCubit() : super(HomeViewInitial());

  static HomeLayoutCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;

  void changeBottomNavIndex(int index) {
    currentIndex = index;
    emit(HomeChangeBottomNav());
  }

  List<Widget> screens = [
    const HomePage(),
    const TrendingView(),
    const FavoritesView(),
    const MyCart(),
    const ProfileView(),
  ];

  Locale locale = const Locale('ar');

  Future<String> getCachedSavedLanguage() async {
    final String? cachedLanguageCode = await CachedHelper.getData('LOCALE');
    if (cachedLanguageCode != null) {
      debugPrint('cachedLanguageCode');
      return cachedLanguageCode;
    } else {
      debugPrint('cachedLanguageCodeEn');
      return 'en';
    }
  }

  Future<void> getSavedLanguage() async {
    final String cachedLanguageCode = await getCachedSavedLanguage();
    locale = Locale(cachedLanguageCode);
    emit(ChangeLocalState());
  }

  Future<void> cachedLanguageCode(String languageCode) async {
    CachedHelper.saveData('LOCALE', languageCode);
    locale = Locale(languageCode);
    emit(ChangeLocalState());
  }
}
