import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../core/function/components.dart';
import '../../core/utils/app_images.dart';
import '../../core/utils/app_routes.dart';
import '../../core/utils/app_styles.dart';
import '../../core/utils/constant.dart';
import '../../core/widgets/custom_text_form_field.dart';
import '../../generated/l10n.dart';
import '../home/presentation/cubits/home_page_cubit/home_page_cubit.dart';
import '../home/presentation/cubits/home_page_cubit/home_page_state.dart';
import '../shared/widgets/custom_product_item.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return BlocProvider(
      create: (context) => HomePageCubit()..getProducts(0),
      child: BlocBuilder<HomePageCubit, HomePageState>(
        builder: (context, state) {
          var cubit = BlocProvider.of<HomePageCubit>(context);
          return Padding(
            padding: 24.psh,
            child: Column(
              children: [
                8.sbh,
                SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          borderRadius: BorderRadius.circular(16),
                          filled: true,
                          hintText: l.search,
                          prefix: SvgPicture.asset(
                            AppImages.searchNormal,
                            width: 24,
                            height: 24,
                            fit: BoxFit.scaleDown,
                            colorFilter: ColorFilter.mode(
                                isAppDarkMode()
                                    ? kDarkSecondColor
                                    : kLightSecondColor,
                                BlendMode.srcIn),
                          ),
                        ),
                      ),
                      8.sbw,
                      Container(
                        width: 48,
                        height: 48,
                        decoration: ShapeDecoration(
                          color: isAppDarkMode() ? kBlackColor : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x14718096),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Color(0x0A718096),
                              blurRadius: 1,
                              offset: Offset(0, 0),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AppImages.filter,
                            colorFilter: ColorFilter.mode(
                              isAppDarkMode()
                                  ? kDarkSecondColor
                                  : kLightSecondColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                24.sbh,
                Row(
                  children: [
                    Text(
                      l.showing,
                      style: AppStyles.styleMedium16(context).copyWith(
                          color: isAppDarkMode()
                              ? kDarkSecondColor
                              : kLightSecondColor),
                    ),
                    4.sbw,
                    Text(
                      '120 ${l.items}',
                      style: AppStyles.styleMedium16(context)
                          .copyWith(color: const Color(0xff0064E5)),
                    ),
                    const Spacer(),
                    Text(l.sort, style: AppStyles.styleMedium14(context)),
                    10.sbw,
                    Center(
                        child: SvgPicture.asset(
                      AppImages.sort,
                      colorFilter: ColorFilter.mode(
                          isAppDarkMode()
                              ? kDarkSecondColor
                              : kLightSecondColor,
                          BlendMode.srcIn),
                    )),
                  ],
                ),
                14.sbh,
                Expanded(
                  child: GridView.builder(
                    itemCount: cubit.products.products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (context.screenWidth / 250).round(),
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: .8,
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
                          isFavorite: true,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
