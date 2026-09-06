import 'package:flutter/material.dart';

import '../../../../../core/domain/model/catalog/offer.dart';
import '../../../../../core/function/components.dart';
import '../../../../../core/function/get_responsive_font_size.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/format_helper.dart';

/// The kit's product card, rebuilt for a seller's own listing.
///
/// Same shape as [CustomProductItem]: bordered image with a pill top-left and
/// a round action top-right, then name, then the price row. What changes is
/// what those slots mean — a store looks at its own catalogue to answer "is
/// this live, and how much stock is left", not "how big is the discount".
class SellerProductItem extends StatelessWidget {
  const SellerProductItem({
    super.key,
    required this.offer,
    required this.name,
    this.stock,
    this.tiersLoaded = false,
    this.onTap,
  });

  final Offer offer;
  final String name;
  final double? stock;
  final bool tiersLoaded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = isAppDarkMode();
    final retail = offer.retailTiers;
    final lowest = retail.isEmpty
        ? null
        : retail.reduce((a, b) => a.price <= b.price ? a : b);

    return GestureDetector(
      onTap: onTap,
      // Opaque, not the default deferToChild: the card is mostly padding, gaps
      // between the text lines, and a decorated box, so a tap that lands
      // anywhere but directly on a glyph would otherwise do nothing.
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  width: 1,
                  color: isDark ? Colors.white24 : Colors.grey,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  OfferPhotoView(photos: offer.photos),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: _Pill(
                              label: OfferStatus.label(offer.status),
                              color: offer.isActive
                                  ? kSuccessColor
                                  : kLightThirdColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: ShapeDecoration(
                                color: isDark ? kBlackColor : Colors.white,
                                shape: const OvalBorder(),
                                shadows: <BoxShadow>[
                                  BoxShadow(
                                    color: isDark
                                        ? kBlackColor.withValues(alpha: .08)
                                        : const Color(0x14000000),
                                    blurRadius: 4,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.edit_outlined,
                                size: 16,
                                color: isDark
                                    ? kDarkSecondColor
                                    : kLightThirdColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Two lines are reserved whether the name needs them or not.
          // Letting the text block grow would eat into the Expanded image
          // above it, and in a grid of mixed-length names — which is most of a
          // building-materials catalogue — that leaves every card a different
          // height.
          SizedBox(
            height: getResponsiveFontSize(context, fontSize: 14) * 2.4,
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.styleMedium14(context).copyWith(
                color: isDark ? kDarkThirdColor : kLightThirdColor,
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  lowest != null
                      ? formatRupiah(lowest.price)
                      : (tiersLoaded ? 'Harga belum diatur' : 'Harga …'),
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.styleSemiBold14(context).copyWith(
                    color: lowest == null && tiersLoaded ? kWarningColor : null,
                  ),
                ),
              ),
              if (lowest?.strikethroughPrice != null) ...<Widget>[
                const SizedBox(width: 8),
                Text(
                  formatRupiah(lowest!.strikethroughPrice),
                  style: AppStyles.styleMedium10(context).copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: isDark ? kDarkPrimaryColor : kLightPrimaryColor,
                  ),
                ),
              ],
            ],
          ),
          Text(
            stock == null ? 'Stok …' : 'Stok ${stock!.round()}',
            style: AppStyles.styleRegular10(context).copyWith(
              color: (stock ?? 1) <= 0 ? kErrorColor : kLightThirdColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: AppStyles.styleMedium12(context).copyWith(
            color: kWhiteColor,
            fontSize: getResponsiveFontSize(context, fontSize: 8),
          ),
        ),
      ),
    );
  }
}

/// Renders the first photo of an offer.
///
/// Product photos are remote URLs the store supplied — this API stores links,
/// never files — so they can and do fail to load. A broken image must degrade
/// to a neutral placeholder rather than a grid full of error boxes, and an
/// offer with no photos at all is a normal DRAFT state, not an error.
class OfferPhotoView extends StatelessWidget {
  const OfferPhotoView({super.key, required this.photos, this.index = 0});

  final List<OfferPhoto> photos;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (index >= photos.length) return const _PhotoPlaceholder();

    return Image.network(
      photos[index].url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _PhotoPlaceholder(),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const _PhotoPlaceholder(loading: true),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({this.loading = false});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    final isDark = isAppDarkMode();
    return ColoredBox(
      color: isDark ? kLightSecondColor : const Color(0xffF4F6F9),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                Icons.image_outlined,
                size: 28,
                color: isDark ? kDarkThirdColor : kLightThirdColor,
              ),
      ),
    );
  }
}
