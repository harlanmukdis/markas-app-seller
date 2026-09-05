import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:navy_wear/core/utils/extensions.dart';
import 'package:navy_wear/features/my_cart/presentation/views/widgets/checkout_details.dart';

import '../../../../core/function/components.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../generated/l10n.dart';
import '../cubit/my_card_cubit.dart';
import '../cubit/my_card_state.dart';

class MyCart extends StatefulWidget {
  const MyCart({super.key});

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return BlocProvider(
      create: (context) => MyCartCubit()..getItems(),
      child: BlocConsumer<MyCartCubit, MyCartState>(
        listener: (BuildContext context, MyCartState state) {},
        builder: (BuildContext context, MyCartState state) {
          var cubit = BlocProvider.of<MyCartCubit>(context);

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${cubit.myCardItems.length} ${l.itemAtCart}',
                            style: AppStyles.styleMedium18(context)),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            l.seeAll,
                            textAlign: TextAlign.right,
                            style: AppStyles.styleMedium16(context).copyWith(
                              color: isAppDarkMode()
                                  ? kDarkPrimaryColor
                                  : kLightPrimaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  cubit.myCardItems.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              l.yourCartIsEmpty,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: 16.psh,
                          itemCount: cubit.myCardItems.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(8),
                              child: Dismissible(
                                key:
                                    Key(cubit.myCardItems[index].id.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  decoration: ShapeDecoration(
                                    color: isAppDarkMode()
                                        ? kDarkPrimaryColor
                                        : kLightPrimaryColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  alignment: Alignment.centerRight,
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Image(
                                        image: AssetImage(AppImages.trash)),
                                  ),
                                ),
                                onDismissed: (direction) {
                                  cubit.removeItem(index).then((value) {
                                    // Optional: Show a snackbar if needed
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6.0, vertical: 6),
                                  // height: 83,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0x115A6CEA)
                                            .withOpacity(.07),
                                        blurRadius: 50,
                                        offset: const Offset(12, 26),
                                        spreadRadius: 0,
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(8),
                                    color: isAppDarkMode()
                                        ? kLightSecondColor
                                        : kWhiteColor,
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        cubit.myCardItems[index].image,
                                        fit: BoxFit.cover,
                                        width: 55,
                                        height: 55,
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cubit.myCardItems[index].name,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: AppStyles.styleMedium16(
                                                      context)
                                                  .copyWith(
                                                color: isAppDarkMode()
                                                    ? kDarkThirdColor
                                                    : kLightThirdColor,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '\$ ${cubit.myCardItems[index].price}',
                                                  style:
                                                      AppStyles.styleMedium16(
                                                              context)
                                                          .copyWith(
                                                    color: isAppDarkMode()
                                                        ? kDarkPrimaryColor
                                                        : kLightPrimaryColor,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.remove,
                                                        color: isAppDarkMode()
                                                            ? kDarkSecondColor
                                                            : kLightSecondColor,
                                                        size: 15,
                                                      ),
                                                      onPressed: () {
                                                        // Reduce quantity logic
                                                      },
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8.0),
                                                      child: Text(
                                                        cubit.myCardItems[index]
                                                            .numOfPieces
                                                            .toString(),
                                                        style: AppStyles
                                                            .styleSemiBold14(
                                                                context),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.add,
                                                        color: isAppDarkMode()
                                                            ? kDarkSecondColor
                                                            : kLightSecondColor,
                                                        size: 16,
                                                      ),
                                                      onPressed: () {
                                                        // Increase quantity logic
                                                      },
                                                      padding: EdgeInsets.zero,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: 24.psh,
                    child: const CheckoutDetails(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
