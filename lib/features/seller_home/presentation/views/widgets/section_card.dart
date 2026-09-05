import 'package:flutter/material.dart';

import '../../../../../core/function/components.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/extensions.dart';

/// The bordered container every dashboard block sits in, so the tabs share one
/// visual rhythm instead of each inventing its own card.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.accent,
    this.onTap,
    this.padding,
  });

  final Widget child;
  final String? title;
  final Widget? trailing;
  final Color? accent;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = isAppDarkMode();

    final content = Container(
      width: double.infinity,
      padding: padding ?? 16.pa,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent ?? (isDark ? Colors.white12 : kBorderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null) ...<Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title!,
                    style: AppStyles.styleSemiBold14(context),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            12.sbh,
          ],
          child,
        ],
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: isDark ? kDarkColor : kWhiteColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: content,
      ),
    );
  }
}

/// A label/value pair. [emphasis] promotes the value to a heavier style for
/// the one number that matters most on a card.
class StatRow extends StatelessWidget {
  const StatRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: AppStyles.styleRegular12(context)
                  .copyWith(color: kLightThirdColor),
            ),
          ),
          8.sbw,
          Text(
            value,
            textAlign: TextAlign.end,
            style: emphasis
                ? AppStyles.styleSemiBold16(context).copyWith(color: valueColor)
                : AppStyles.styleMedium12(context).copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
