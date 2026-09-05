import 'package:flutter/material.dart';

import '../../../../../core/domain/model/seller/activation_gates.dart';
import '../../../../../core/function/components.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/extensions.dart';

/// One row of the activation checklist.
///
/// Both the four gates and the warehouse requirement render through this, so
/// they cannot drift apart visually — they are the same kind of thing to the
/// reader (something that is or is not done yet), even though only four of
/// them are gates.
class ChecklistTile extends StatelessWidget {
  const ChecklistTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isDone,
    this.pendingLabel,
    this.pendingIcon,
    this.pendingAccent,
    this.onTap,
    this.highlightBorder = false,
  });

  final String title;
  final String subtitle;
  final bool isDone;

  /// Shown in the leading circle while pending — a step number for the gates.
  final String? pendingLabel;

  /// Used instead of [pendingLabel] when there is no number to show.
  final IconData? pendingIcon;

  final Color? pendingAccent;
  final VoidCallback? onTap;

  /// Draws the border in the accent colour to pull attention to a blocker.
  final bool highlightBorder;

  @override
  Widget build(BuildContext context) {
    final isDark = isAppDarkMode();
    final accent = isDone
        ? kSuccessColor
        : (pendingAccent ??
            (isDark ? kDarkPrimaryColor : kLightPrimaryColor));

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
                color: (highlightBorder && !isDone)
                    ? accent
                    : (isDark ? Colors.white12 : kBorderColor),
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
                  child: _leading(context, accent),
                ),
                12.sbw,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title, style: AppStyles.styleSemiBold14(context)),
                      4.sbh,
                      Text(
                        subtitle,
                        style: AppStyles.styleRegular12(context).copyWith(
                          color: isDone ? kSuccessColor : kLightThirdColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Hidden once done: there is nothing left to go and do.
                if (onTap != null && !isDone)
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

  Widget _leading(BuildContext context, Color accent) {
    if (isDone) {
      return const Icon(Icons.check_rounded, size: 18, color: kSuccessColor);
    }
    if (pendingLabel != null) {
      return Text(
        pendingLabel!,
        style: AppStyles.styleSemiBold14(context).copyWith(color: accent),
      );
    }
    return Icon(pendingIcon ?? Icons.circle_outlined, size: 18, color: accent);
  }
}

/// An activation gate. A gate the store cannot act on is described as waiting
/// rather than as a task, so nobody sits on the KYC screen re-uploading
/// documents while the real blocker is an admin queue.
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
    return ChecklistTile(
      title: gate.title,
      subtitle: subtitle ?? (isPassed ? 'Selesai' : gate.waitingOn),
      isDone: isPassed,
      pendingLabel: '$index',
      pendingAccent: gate.isSelfServe
          ? (isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor)
          : kWarningColor,
      onTap: onTap,
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
