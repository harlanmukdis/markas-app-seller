import 'package:flutter/material.dart';

import '../../../../../core/domain/model/seller/activation_gates.dart';
import '../../../../../core/function/components.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/extensions.dart';

/// One row of the activation checklist.
///
/// A gate the store cannot act on is shown as waiting rather than as a task,
/// so nobody sits on the KYC screen re-uploading documents while the real
/// blocker is an admin queue.
class GateTile extends StatelessWidget {
  const GateTile({
    super.key,
    required this.gate,
    required this.isPassed,
    required this.index,
    this.onTap,
    this.subtitle,
  });

  final SellerGate gate;
  final bool isPassed;
  final int index;
  final VoidCallback? onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = isAppDarkMode();
    final accent = isPassed
        ? kSuccessColor
        : (gate.isSelfServe
            ? (isDark ? kDarkPrimaryColor : kLightPrimaryColor)
            : kWarningColor);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isDark ? kDarkColor : kWhiteColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: 16.pa,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white12 : kBorderColor,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.12),
                  ),
                  child: isPassed
                      ? const Icon(Icons.check_rounded,
                          size: 18, color: kSuccessColor)
                      : Text(
                          '$index',
                          style: AppStyles.styleSemiBold14(context)
                              .copyWith(color: accent),
                        ),
                ),
                12.sbw,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        gate.title,
                        style: AppStyles.styleSemiBold14(context),
                      ),
                      4.sbh,
                      Text(
                        subtitle ??
                            (isPassed ? 'Selesai' : gate.waitingOn),
                        style: AppStyles.styleRegular12(context).copyWith(
                          color: isPassed ? kSuccessColor : kLightThirdColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null && !isPassed)
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: kLightThirdColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A short coloured pill — used for store status and for document/account
/// verification states.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppStyles.styleMedium12(context).copyWith(color: color),
      ),
    );
  }
}

/// Colour for a `sellers.status` value.
Color sellerStatusColor(String? status) => switch (status) {
      'VERIFIED' => kSuccessColor,
      'KYC_REJECTED' || 'SUSPENDED' => kErrorColor,
      'PENDING_KYC' => kWarningColor,
      _ => kLightThirdColor,
    };
