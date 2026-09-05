import 'package:flutter/material.dart';

import '../../../../../core/domain/model/order/order_model.dart';
import '../../../../../core/function/components.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/extensions.dart';

/// Rejection reasons come from a closed list (ORD-10). No free-text field is
/// offered — anything else is rejected with `422 INVALID_REASON`, and the
/// pattern of these codes is what flags a store for review.
Future<String?> showRejectReasonSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: isAppDarkMode() ? kDarkColor : kWhiteColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: 20.pa,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Alasan menolak pesanan',
                style: AppStyles.styleSemiBold16(sheetContext)),
            8.sbh,
            Text(
              'Menolak menurunkan skor toko sebanyak 2 poin dan melepas stok '
              'yang direservasi.',
              style: AppStyles.styleRegular12(sheetContext)
                  .copyWith(color: kLightThirdColor),
            ),
            16.sbh,
            ...RejectReason.all.map(
              (reason) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  RejectReason.label(reason),
                  style: AppStyles.styleMedium14(sheetContext),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () => Navigator.of(sheetContext).pop(reason),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
