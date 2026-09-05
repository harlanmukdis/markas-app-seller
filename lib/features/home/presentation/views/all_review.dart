import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../generated/l10n.dart';
import '../cubits/Review_cubit/review_cubit.dart';
import '../cubits/Review_cubit/review_state.dart';

class AllReviewScreen extends StatelessWidget {
  const AllReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return BlocProvider(
      create: (context) => ReviewCubit(),
      child: BlocBuilder<ReviewCubit, ReviewState>(
        builder: (BuildContext context, ReviewState state) {
          var cubit = BlocProvider.of<ReviewCubit>(context);
          return Scaffold(
            appBar: customAppBar(context, l.reviews),
            body: Column(children: [
              ReviewCategory(cubit: cubit),
              const SizedBox(
                height: 15,
              ),
              ReviewItems(cubit: cubit),
            ]),
            floatingActionButton: FloatingActionButton(
              backgroundColor:
                  isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                router.push(AppRoutes.writeReview);
              },
            ),
          );
        },
      ),
    );
  }
}

class ReviewItems extends StatelessWidget {
  const ReviewItems({
    super.key,
    required this.cubit,
  });

  final ReviewCubit cubit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: cubit.reviewItemsAll.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Container(
              padding: 24.pa,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isAppDarkMode()
                      ? kLightSecondColor
                      : const Color(0xffF8F8F8)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          cubit.reviewItemsAll[index].profileImage,
                          fit: BoxFit.cover,
                          height: 45,
                          width: 45,
                        ),
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cubit.reviewItemsAll[index].reviewerText,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: AppStyles.styleRegular12(context).copyWith(
                                  color: isAppDarkMode()
                                      ? kDarkSecondColor
                                      : kLightThirdColor,
                                  height: 1.6),
                            ),
                            16.sbh,
                            RatingBar.builder(
                              itemSize: 18,
                              initialRating: cubit.reviewItemsAll[index].rating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              // itemPadding: EdgeInsets.symmetric(horizontal: 4.0), // Padding between stars
                              itemBuilder: (context, _) => const Icon(
                                Icons.star, // Use the star icon
                                color:
                                    Colors.amber, // Set the color of the star
                              ),
                              onRatingUpdate: (rating) {
                                if (kDebugMode) {
                                  print(rating);
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    ],
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

class ReviewCategory extends StatelessWidget {
  const ReviewCategory({
    super.key,
    required this.cubit,
  });

  final ReviewCubit cubit;

  @override
  Widget build(BuildContext context) {
    final List<String> itemReview = [
      S.of(context).all,
      '5.0',
      '4.0',
      '3.0',
      '2.0',
      '1.0',
    ];
    return Padding(
      padding: const EdgeInsets.only(left: 14.0),
      child: SizedBox(
        height: 53,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: itemReview.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 20.0, right: 2),
                child: ElevatedButton(
                  onPressed: () {
                    cubit.changeReviewIndex(index);
                    cubit.getAllReview(index);
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(const EdgeInsets.only(
                        left: 15,
                        top: 4,
                        bottom: 4,
                        right: 20)), // Set padding to 0

                    elevation: WidgetStateProperty.all(0),
                    backgroundColor:
                        WidgetStateProperty.all(cubit.reviewIndex == index
                            ? isAppDarkMode()
                                ? kDarkPrimaryColor
                                : kLightPrimaryColor
                            : Colors.transparent),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                          side: BorderSide(
                              color: isAppDarkMode()
                                  ? kDarkPrimaryColor
                                  : kLightPrimaryColor)),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      index == 0
                          ? const SizedBox()
                          : const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                      index == 0
                          ? const SizedBox()
                          : const SizedBox(
                              width: 5,
                            ),
                      Padding(
                        padding: index == 0
                            ? const EdgeInsets.symmetric(horizontal: 12.0)
                            : const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          itemReview[index],
                          style: TextStyle(
                            color: cubit.reviewIndex == index
                                ? kWhiteColor
                                : (isAppDarkMode()
                                    ? const Color(0xffDAE8FF)
                                    : isAppDarkMode()
                                        ? kDarkPrimaryColor
                                        : kLightPrimaryColor),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
