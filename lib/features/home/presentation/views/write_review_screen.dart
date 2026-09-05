import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../generated/l10n.dart';
import '../cubits/Review_cubit/review_cubit.dart';
import '../cubits/Review_cubit/review_state.dart';

class WriteReviewScreen extends StatelessWidget {
  const WriteReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return BlocProvider(
      create: (context) => ReviewCubit(),
      child: BlocConsumer<ReviewCubit, ReviewState>(
        builder: (BuildContext context, ReviewState state) {
          return Scaffold(
            appBar: customAppBar(context, l.writeReview),
            body: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              AppImages.person1,
                              fit: BoxFit.cover,
                              width: 70,
                              height: 70,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Text(
                              l.leafPrintGuipureLacePanelButterflySleeveBlouse,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: AppStyles.styleMedium16(context).copyWith(
                                  color: isAppDarkMode()
                                      ? kDarkSecondColor
                                      : kLightThirdColor),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        l.whatsYourRate,
                        style: AppStyles.styleMedium16(context).copyWith(
                            color: isAppDarkMode()
                                ? kDarkThirdColor
                                : kLightThirdColor),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      RatingBar.builder(
                        initialRating: 5,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 40.0,
                        itemPadding: const EdgeInsets.only(right: 4.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          if (kDebugMode) {
                            print("Rating: $rating");
                          }
                        },
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(l.whatCanWeImprove,
                          style: AppStyles.styleMedium16(context).copyWith(
                            color: isAppDarkMode()
                                ? kDarkThirdColor
                                : kLightThirdColor,
                          )),
                      const SizedBox(
                        height: 16,
                      ),
                      CustomTextFormField(
                        maxLines: 7,
                        fillColor: kLightSecondColor,
                        filled: isAppDarkMode() ? true : false,
                        hintText: l.goodQuality,
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1D55F3),
                          // Button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                25), // Adjust the border radius as needed
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: Text(
                              l.submit,
                              style: AppStyles.styleMedium16(context)
                                  .copyWith(color: kWhiteColor),
                            ),
                          ),
                        ),
                      ),
                    ]),
              ),
            ),
          );
        },
        listener: (BuildContext context, state) {},
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16),
              height: 111,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xffF8F8F8)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                  cubit.reviewItemsAll[index].profileImage)),
                          borderRadius: BorderRadius.circular(50),
                          // color: Colors.red
                        ),
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      Expanded(
                        child: Text(
                          cubit.reviewItemsAll[index].reviewerText,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: isAppDarkMode() ? null : kLightThirdColor,
                              height: 2),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 54,
                      ),
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
                          color: Colors.amber, // Set the color of the star
                        ),
                        onRatingUpdate: (rating) {
                          if (kDebugMode) {
                            print(rating);
                          }
                        },
                      ),
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
                    // cubit.getProducts(index);
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
                            : kWhiteColor),
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
                                : isAppDarkMode()
                                    ? kDarkPrimaryColor
                                    : kLightPrimaryColor,
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
