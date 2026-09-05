import 'package:flutter/material.dart';
import 'package:navy_wear/core/utils/extensions.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../generated/l10n.dart';

class NewFashionView extends StatefulWidget {
  const NewFashionView({super.key});

  @override
  State<NewFashionView> createState() => _NewFashionViewState();
}

class _NewFashionViewState extends State<NewFashionView> {
  int _currentIndex = 0;

  final List<Category> _categories = [
    Category(title: 'All', id: 0),
    Category(title: 'T-Shirts', id: 1),
    Category(title: 'Shoes', id: 2),
    Category(title: 'Blazers', id: 3),
  ];

  final List<FashionItem> _fashionItems = List.generate(
    6,
    (index) => FashionItem(
      image: "assets/images/product${index + 1}.png",
      title: 'Item ${index + 1}',
      category: 'Category ${index + 1}',
      rating: 4.5 + (index % 5) * 0.1,
      reviews: 100 + index,
      price: (20.0 + index * 5).toStringAsFixed(2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = S.of(context);
    return Scaffold(
      appBar: customAppBar(context, l.newFashion),
      body: Column(
        children: [
          16.sbh,
          _buildCategorySelector(),
          16.sbh,
          Expanded(
            child: ListView.builder(
              padding: 24.psh,
              itemCount: _fashionItems.length,
              itemBuilder: (context, index) {
                return CustomNewFashionItem(item: _fashionItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 32,
      child: Align(
        alignment:
            isLanguageRTL() ? Alignment.centerRight : Alignment.centerLeft,
        child: ListView.separated(
          padding: 24.ps,
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (context, index) => 10.sbw,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () {
                if (_currentIndex == category.id) return;
                setState(() {
                  _currentIndex = category.id;
                });
              },
              child: _customContainer(
                title: category.title,
                isSelected: _currentIndex == category.id,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _customContainer({required String title, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
              : isAppDarkMode()
                  ? const Color(0xffDAE8FF)
                  : kLightPrimaryColor,
        ),
      ),
    );
  }
}

class CustomNewFashionItem extends StatelessWidget {
  final FashionItem item;

  const CustomNewFashionItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: 16.pb,
      decoration: ShapeDecoration(
        color: isAppDarkMode() ? kLightSecondColor : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadows: [
          BoxShadow(
            color: kBlackColor.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 104, maxHeight: 104),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(
                item.image,
                fit: BoxFit.fill,
              ),
            ),
          ),
          12.sbw,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppStyles.styleMedium14(context).copyWith(
                        color: isAppDarkMode()
                            ? kDarkSecondColor
                            : kLightThirdColor),
                  ),
                  Text(
                    item.category,
                    style: AppStyles.styleRegular11(context).copyWith(
                        color: isAppDarkMode()
                            ? const Color(0xffD0D0D0)
                            : const Color(0xff9B9B9B)),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Color(0xffFBBF24),
                        size: 16,
                      ),
                      4.sbw,
                      Text(
                        item.rating.toStringAsFixed(1),
                        style: AppStyles.styleMedium12(context).copyWith(
                          color: isAppDarkMode()
                              ? kDarkSecondColor
                              : kLightSecondColor,
                        ),
                      ),
                      8.sbw,
                      Text(
                        '(${item.reviews} reviews)',
                        style: AppStyles.styleRegular10(context).copyWith(
                          color: isAppDarkMode()
                              ? const Color(0xffD0D0D0)
                              : kLightThirdColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${item.price} USD',
                    style: AppStyles.styleMedium14(context).copyWith(
                      color: isAppDarkMode()
                          ? const Color(0xffD0D0D0)
                          : const Color(0xff222222),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildActionIcons(context),
        ],
      ),
    );
  }

  Widget _buildActionIcons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 11, bottom: 11, right: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Transform.translate(
            offset: const Offset(0, -10),
            child: PopupMenuButton(
              icon: const Icon(
                Icons.more_vert_outlined,
                color: Color(0xff9B9B9B),
              ),
              itemBuilder: (context) => [],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, 5),
            child: Container(
              width: 36,
              height: 36,
              decoration: ShapeDecoration(
                color: isAppDarkMode() ? kBlackColor : Colors.white,
                shape: const OvalBorder(),
                shadows: [
                  BoxShadow(
                    color: isAppDarkMode()
                        ? kBlackColor.withOpacity(.08)
                        : const Color(0x14000000),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite_border_outlined,
                size: 18,
                color: isAppDarkMode() ? kDarkSecondColor : kLightThirdColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Category {
  final String title;
  final int id;

  Category({required this.title, required this.id});
}

class FashionItem {
  final String image;
  final String title;
  final String category;
  final double rating;
  final int reviews;
  final String price;

  FashionItem({
    required this.image,
    required this.title,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.price,
  });
}
