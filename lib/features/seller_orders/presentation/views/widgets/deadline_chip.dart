import 'package:flutter/material.dart';

import '../../../../../core/utils/app_styles.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/extensions.dart';
import '../../../../../core/utils/format_helper.dart';

/// A countdown to a server-supplied deadline.
///
/// Only the *remaining* time is computed here — never the deadline itself.
/// Deadlines are in working hours and skip weekends and holidays, so the
/// server's timestamp is the only correct source (API doc 1.7).
class DeadlineChip extends StatelessWidget {
  const DeadlineChip({
    super.key,
    required this.deadline,
    required this.label,
    this.consequence,
  });

  final DateTime deadline;
  final String label;

  /// What happens when it lapses. Worth saying plainly — these are the moments
  /// that cost a store money.
  final String? consequence;

  @override
  Widget build(BuildContext context) {
    final remaining = deadline.difference(DateTime.now());
    final expired = remaining.isNegative;
    final urgent = !expired && remaining.inHours < 6;
    final color =
        expired ? kErrorColor : (urgent ? kWarningColor : kLightThirdColor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                expired ? Icons.timer_off_outlined : Icons.timer_outlined,
                size: 14,
                color: color,
              ),
              6.sbw,
              Text(
                expired
                    ? '$label lewat batas'
                    : '$label · sisa ${_format(remaining)}',
                style: AppStyles.styleMedium12(context).copyWith(color: color),
              ),
            ],
          ),
          2.sbh,
          Text(
            '${formatDateTime(deadline)}'
            '${consequence == null ? '' : ' · $consequence'}',
            style:
                AppStyles.styleRegular10(context).copyWith(color: kLightThirdColor),
          ),
        ],
      ),
    );
  }

  static String _format(Duration duration) {
    if (duration.inDays >= 1) {
      final hours = duration.inHours % 24;
      return '${duration.inDays} hari $hours jam';
    }
    if (duration.inHours >= 1) {
      final minutes = duration.inMinutes % 60;
      return '${duration.inHours} jam $minutes menit';
    }
    return '${duration.inMinutes} menit';
  }
}
