import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../core/function/components.dart';
import '../../core/utils/app_routes.dart';
import '../../core/utils/app_styles.dart';
import '../../core/utils/constant.dart';
import '../../generated/l10n.dart';
import '../home/presentation/cubits/home_page_cubit/home_page_cubit.dart';
import '../home/presentation/cubits/home_page_cubit/home_page_state.dart';
import '../shared/widgets/custom_product_item.dart';

class TrendingView extends StatelessWidget {
  const TrendingView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 16,
          elevation: 0,
          backgroundColor:
              isAppDarkMode() ? kLightSecondColor : Colors.transparent,
          bottom: TabBar(
            indicatorColor:
                isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
            indicatorWeight: 3,
            labelColor:
                isAppDarkMode() ? kDarkSecondColor : const Color(0xff222222),
            unselectedLabelColor:
                isAppDarkMode() ? kDarkSecondColor : const Color(0xff222222),
            labelStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
            tabs: [
              Tab(text: l.women),
              Tab(text: l.men),
              Tab(text: l.kids),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TapBAr1(),
            TapBAr1(),
            TapBAr1(),
          ],
        ),
      ),
    );
  }
}

class TapBAr1 extends StatefulWidget {
  const TapBAr1({super.key});

  @override
  State<TapBAr1> createState() => _TapBAr1State();
}

class _TapBAr1State extends State<TapBAr1> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return BlocProvider(
      create: (context) => HomePageCubit()..getProducts(0),
      child: BlocBuilder<HomePageCubit, HomePageState>(
        builder: (context, state) {
          final cubit = BlocProvider.of<HomePageCubit>(context);
          return Column(
            children: [
              24.sbh,
              SizedBox(
                height: 32,
                child: Align(
                  alignment: isLanguageRTL()
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: ListView(
                    padding: 24.ps,
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding: 10.pe,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(40),
                          onTap: () {
                            if (_currentIndex == 0) return;
                            setState(() {
                              _currentIndex = 0;
                            });
                          },
                          child: _customContainer(
                              title: l.all, isSelected: _currentIndex == 0),
                        ),
                      ),
                      Padding(
                        padding: 10.pe,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(40),
                          onTap: () {
                            if (_currentIndex == 1) return;
                            setState(() {
                              _currentIndex = 1;
                            });
                          },
                          child: _customContainer(
                              title: l.tShirt, isSelected: _currentIndex == 1),
                        ),
                      ),
                      Padding(
                        padding: 10.pe,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(40),
                          onTap: () {
                            if (_currentIndex == 2) return;
                            setState(() {
                              _currentIndex = 2;
                            });
                          },
                          child: _customContainer(
                              title: l.shoes, isSelected: _currentIndex == 2),
                        ),
                      ),
                      Padding(
                        padding: 10.pe,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(40),
                          onTap: () {
                            if (_currentIndex == 3) return;
                            setState(() {
                              _currentIndex = 3;
                            });
                          },
                          child: _customContainer(
                              title: l.blazers, isSelected: _currentIndex == 3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              16.sbh,
              Expanded(
                child: GridView.builder(
                  padding: 24.psh,
                  // shrinkWrap: true,
                  // physics: const NeverScrollableScrollPhysics(),
                  itemCount: cubit.products.products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: (context.screenWidth / 250).round(),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        router.push(
                          AppRoutes.productDetails,
                          extra: cubit.products.products[index].image,
                        );
                      },
                      child: CustomProductItem(
                        item: cubit.products.products[index],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _customContainer({required String title, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 32,
      decoration: BoxDecoration(
        color: isSelected
            ? isAppDarkMode()
                ? kDarkPrimaryColor
                : kLightPrimaryColor
            : Colors.transparent,
        border: isSelected
            ? null
            : Border.all(
                color:
                    isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Text(
        title,
        style: AppStyles.styleMedium14(context).copyWith(
          color: isSelected
              ? kWhiteColor
              : (isAppDarkMode()
                  ? const Color(0xffDAE8FF)
                  : isAppDarkMode()
                      ? kDarkPrimaryColor
                      : kLightPrimaryColor),
        ),
      ),
    );
  }
}
