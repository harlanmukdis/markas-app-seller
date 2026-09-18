import 'package:flutter/material.dart';

import '../../../../../core/domain/model/catalog/product.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/extensions.dart';
import '../../../../../core/utils/format_helper.dart';

/// One row of the catalogue.
///
/// There is no image: `GET /stores/{id}/products` carries none, and the only
/// image a product can have lives on a variant that the list payload does not
/// include. A per-row detail call to fetch one would be an N+1 for decoration.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onToggleStatus,
  });

  final Product product;
  final VoidCallback? onTap;

  /// Publish / unpublish. Absent for a product whose status is neither draft
  /// nor active — archived rows are not toggled from a list.
  final VoidCallback? onToggleStatus;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: 16.pa,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kLightThirdColor.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.styleMedium14(context),
                  ),
                ),
                8.sbw,
                ProductStatusPill(status: product.status),
              ],
            ),
            8.sbh,
            Row(
              children: <Widget>[
                Text(
                  formatRupiah(product.basePrice),
                  style: AppStyles.styleSemiBold16(context),
                ),
                if (product.compareAtPrice != null &&
                    product.compareAtPrice! > product.basePrice) ...<Widget>[
                  8.sbw,
                  Text(
                    formatRupiah(product.compareAtPrice),
                    style: AppStyles.styleRegular12(context).copyWith(
                      color: kLightThirdColor,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
            6.sbh,
            Text(
              <String>[
                ProductType.label(product.productType),
                if (product.weightGrams != null) '${product.weightGrams} g',
                'Terjual ${product.soldCount}',
              ].join(' · '),
              style: AppStyles.styleRegular12(context)
                  .copyWith(color: kLightThirdColor),
            ),
            if (onToggleStatus != null) ...<Widget>[
              8.sbh,
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  onPressed: onToggleStatus,
                  icon: Icon(
                    product.isActive
                        ? Icons.visibility_off_outlined
                        : Icons.publish_outlined,
                    size: 18,
                  ),
                  label: Text(product.isActive ? 'Nonaktifkan' : 'Terbitkan'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Status is the field the catalogue screen is really about: a product is born
/// `draft` and stays invisible to buyers until it is published.
class ProductStatusPill extends StatelessWidget {
  const ProductStatusPill({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ProductStatus.active => kSuccessColor,
      ProductStatus.draft => kWarningColor,
      _ => kLightThirdColor,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        ProductStatus.label(status),
        style: AppStyles.styleRegular12(context).copyWith(color: color),
      ),
    );
  }
}
