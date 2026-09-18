import 'package:flutter/material.dart';

import '../../../../../core/domain/model/order/order.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../core/utils/constant.dart';

/// Colour-codes what the status means **to the seller**, not how far along the
/// order is: blue where the seller is the one holding things up, grey where the
/// wait is somebody else's, red for the endings that lost the sale.
class OrderStatusPill extends StatelessWidget {
  const OrderStatusPill({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OrderStatus.paid ||
      OrderStatus.processed ||
      OrderStatus.packed =>
        kLightPrimaryColor,
      OrderStatus.refundRequested => kWarningColor,
      OrderStatus.cancelled ||
      OrderStatus.refundApproved =>
        kErrorColor,
      OrderStatus.completed || OrderStatus.delivered => kSuccessColor,
      _ => kLightThirdColor,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        OrderStatus.label(status),
        style: AppStyles.styleRegular12(context).copyWith(color: color),
      ),
    );
  }
}
