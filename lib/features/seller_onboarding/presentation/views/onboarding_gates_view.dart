import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/route/app_route_seller.dart';
import '../../../../core/domain/model/seller/activation_gates.dart';
import '../../../../core/domain/model/seller/seller_model.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/function/components.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/format_helper.dart';
import '../../../../core/domain/model/enums.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../../di/injector.dart';
import '../cubits/onboarding_cubit/onboarding_cubit.dart';
import 'widgets/gate_tile.dart';

/// The store's landing page: how far along activation is, and what to do next.
class OnboardingGatesView extends StatelessWidget {
  const OnboardingGatesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingCubit>(
      create: (_) => OnboardingCubit()..load(),
      child: const _OnboardingGatesBody(),
    );
  }
}

class _OnboardingGatesBody extends StatelessWidget {
  const _OnboardingGatesBody();

  Future<void> _logout(BuildContext context) async {
    await injector<AuthRepository>().logout();
    if (!context.mounted) return;
    context.go(SellerRoutes.login);
  }

  /// Pushes a sub-screen and refreshes on return — any of them can move a gate.
  Future<void> _openThenRefresh(BuildContext context, String route) async {
    await context.push(route);
    if (!context.mounted) return;
    await OnboardingCubit.get(context).load(showSpinner: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Aktivasi Toko', style: AppStyles.styleMedium18(context)),
        actions: <Widget>[
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => OnboardingCubit.get(context).load(),
          ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _logout(context),
          ),
          8.sbw,
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<OnboardingCubit, OnboardingState>(
          builder: (context, state) {
            return switch (state) {
              OnboardingLoadInProgress() => const LoadingIndicatorView(
                  message: 'Memuat data toko…',
                ),
              OnboardingLoadFailure(:final error) => ErrorStateView(
                  error: error,
                  onRetry: () => OnboardingCubit.get(context).load(),
                ),
              OnboardingLoadSuccess() => _GatesContent(
                  state: state,
                  onOpen: (route) => _openThenRefresh(context, route),
                ),
            };
          },
        ),
      ),
    );
  }
}

class _GatesContent extends StatelessWidget {
  const _GatesContent({required this.state, required this.onOpen});

  final OnboardingLoadSuccess state;
  final Future<void> Function(String route) onOpen;

  static const Map<SellerGate, String> _routeForGate = <SellerGate, String>{
    SellerGate.kyc: SellerRoutes.kyc,
    SellerGate.bank: SellerRoutes.bankAccount,
    SellerGate.shippingRate: SellerRoutes.shippingRates,
    SellerGate.agreement: SellerRoutes.agreement,
  };

  @override
  Widget build(BuildContext context) {
    final seller = state.seller;
    final gates = state.gates;

    return RefreshIndicator(
      onRefresh: () => OnboardingCubit.get(context).load(showSpinner: false),
      child: ListView(
        padding: 20.pa,
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _StoreHeader(seller: seller),
                  20.sbh,
                  _ProgressBar(passed: gates.passedCount),
                  24.sbh,
                  if (state.isReadyToSell) ...<Widget>[
                    const _ReadyBanner(),
                    20.sbh,
                  ],
                  Text(
                    'Empat gerbang aktivasi',
                    style: AppStyles.styleSemiBold16(context),
                  ),
                  4.sbh,
                  Text(
                    'Status berpindah ke VERIFIED otomatis begitu gerbang '
                    'terakhir terpenuhi, apa pun urutannya.',
                    style: AppStyles.styleRegular12(context)
                        .copyWith(color: kLightThirdColor),
                  ),
                  16.sbh,
                  ...SellerGate.values.map(
                    (gate) => GateTile(
                      gate: gate,
                      index: SellerGate.values.indexOf(gate) + 1,
                      isPassed: gates.isPassed(gate),
                      onTap: () => onOpen(_routeForGate[gate]!),
                    ),
                  ),
                  12.sbh,
                  _WarehouseCard(state: state, onOpen: onOpen),
                  if (seller.isOnTrial) ...<Widget>[
                    12.sbh,
                    _TrialCard(seller: seller),
                  ],
                  24.sbh,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({required this.seller});

  final SellerModel seller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                seller.name,
                style: AppStyles.styleSemiBold24(context),
              ),
            ),
            8.sbw,
            StatusBadge(
              label: SellerStatus.label(seller.status),
              color: sellerStatusColor(seller.status),
            ),
          ],
        ),
        8.sbh,
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: <Widget>[
            _MetaChip(
              icon: Icons.storefront_outlined,
              label: SellerType.label(seller.sellerType),
            ),
            _MetaChip(
              icon: Icons.star_outline_rounded,
              // Starts at 100 and feeds search ranking, so it is shown from
              // day one rather than buried in a report.
              label: 'Skor ${seller.score.toStringAsFixed(0)}',
            ),
            _MetaChip(
              icon: Icons.receipt_long_outlined,
              label: seller.pkpStatus ?? 'NON_PKP',
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: kLightThirdColor),
        4.sbw,
        Text(
          label,
          style: AppStyles.styleRegular12(context)
              .copyWith(color: kLightThirdColor),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.passed});

  final int passed;

  @override
  Widget build(BuildContext context) {
    final isDark = isAppDarkMode();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Progres aktivasi',
                style: AppStyles.styleMedium14(context)),
            Text('$passed dari 4',
                style: AppStyles.styleSemiBold14(context)),
          ],
        ),
        8.sbh,
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: passed / SellerGate.values.length,
            minHeight: 8,
            backgroundColor: isDark ? Colors.white12 : kBorderColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              passed == SellerGate.values.length
                  ? kSuccessColor
                  : (isDark ? kDarkPrimaryColor : kLightPrimaryColor),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadyBanner extends StatelessWidget {
  const _ReadyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 16.pa,
      decoration: BoxDecoration(
        color: kSuccessColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.verified_rounded, color: kSuccessColor),
          12.sbw,
          Expanded(
            child: Text(
              'Toko siap berjualan. Semua gerbang lolos dan gudang sudah '
              'terdaftar.',
              style: AppStyles.styleMedium14(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// The warehouse requirement is not a gate, which is exactly why it needs its
/// own card: a store can be `VERIFIED` with every gate green and still have
/// every checkout fail with `409 NO_WAREHOUSE`.
class _WarehouseCard extends StatelessWidget {
  const _WarehouseCard({required this.state, required this.onOpen});

  final OnboardingLoadSuccess state;
  final Future<void> Function(String route) onOpen;

  @override
  Widget build(BuildContext context) {
    final isDark = isAppDarkMode();
    final needsWarehouse = state.needsWarehouse;
    final error = state.warehouseError;

    final String subtitle;
    if (error != null) {
      subtitle = 'Gagal memuat daftar gudang (${error.code}).';
    } else if (needsWarehouse) {
      subtitle = 'Belum ada gudang. Tanpa gudang, checkout pembeli gagal '
          'dengan 409 NO_WAREHOUSE meski semua gerbang lolos.';
    } else {
      subtitle = '${state.warehouses.length} gudang terdaftar.';
    }

    return Material(
      color: isDark ? kDarkColor : kWhiteColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => onOpen(SellerRoutes.warehouse),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: 16.pa,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: needsWarehouse
                  ? kWarningColor
                  : (isDark ? Colors.white12 : kBorderColor),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                needsWarehouse
                    ? Icons.warehouse_outlined
                    : Icons.check_circle_outline_rounded,
                color: needsWarehouse ? kWarningColor : kSuccessColor,
              ),
              12.sbw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Gudang (di luar gerbang aktivasi)',
                      style: AppStyles.styleSemiBold14(context),
                    ),
                    4.sbh,
                    Text(
                      subtitle,
                      style: AppStyles.styleRegular12(context)
                          .copyWith(color: kLightThirdColor),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: kLightThirdColor),
            ],
          ),
        ),
      ),
    );
  }
}

/// Explains why a new store's money moves slower, instead of leaving it to be
/// discovered on the finance screen.
class _TrialCard extends StatelessWidget {
  const _TrialCard({required this.seller});

  final SellerModel seller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 16.pa,
      decoration: BoxDecoration(
        color: kWarningColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.info_outline_rounded,
                  size: 18, color: kWarningColor),
              8.sbw,
              Text('Masa percobaan toko baru',
                  style: AppStyles.styleSemiBold14(context)),
            ],
          ),
          8.sbh,
          if (seller.trialMaxOrderValue != null)
            Text(
              'Nilai order maksimal ${formatRupiah(seller.trialMaxOrderValue)}.',
              style: AppStyles.styleRegular12(context),
            ),
          if (seller.trialHoldDaysOverride != null)
            Text(
              'Masa tahan pencairan ${seller.trialHoldDaysOverride} hari '
              '(lebih lama dari normal).',
              style: AppStyles.styleRegular12(context),
            ),
          if (seller.trialStartedAt != null)
            Text(
              'Dimulai ${formatDate(seller.trialStartedAt)}.',
              style: AppStyles.styleRegular12(context)
                  .copyWith(color: kLightThirdColor),
            ),
        ],
      ),
    );
  }
}
