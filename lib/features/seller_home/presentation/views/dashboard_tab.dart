import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/route/app_route_seller.dart';
import '../../../../core/domain/model/enums.dart';
import '../../../../core/domain/model/report/reports.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/function/components.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/format_helper.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../../di/injector.dart';
import '../../../seller_onboarding/presentation/views/widgets/gate_tile.dart';
import '../cubits/dashboard_cubit/dashboard_cubit.dart';
import 'widgets/section_card.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (_) => DashboardCubit()..load(),
      child: const _DashboardBody(),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  Future<void> _logout(BuildContext context) async {
    await injector<AuthRepository>().logout();
    if (!context.mounted) return;
    context.go(SellerRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _Header(onLogout: () => _logout(context)),
        Expanded(
          child: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) => switch (state) {
              DashboardLoadInProgress() =>
                const LoadingIndicatorView(message: 'Memuat data toko…'),
              DashboardLoadFailure(:final error) => ErrorStateView(
                  error: error,
                  onRetry: () => DashboardCubit.get(context).load(),
                ),
              DashboardLoadSuccess() => _Content(state: state),
            },
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text('Beranda', style: AppStyles.styleMedium18(context)),
          ),
          IconButton(
            tooltip: 'Muat ulang',
            // Colour set explicitly: under Material 2 an icon on a transparent
            // surface takes primaryIconTheme (white) and disappears.
            color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => DashboardCubit.get(context).load(),
          ),
          IconButton(
            tooltip: 'Keluar',
            color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
            icon: const Icon(Icons.logout_rounded),
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state});

  final DashboardLoadSuccess state;

  @override
  Widget build(BuildContext context) {
    final seller = state.seller;
    final performance = state.performance;

    return RefreshIndicator(
      onRefresh: () => DashboardCubit.get(context).load(showSpinner: false),
      child: ListView(
        padding: 20.pa,
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  Text(
                    '${SellerType.label(seller.sellerType)} · '
                    'Skor ${seller.score.toStringAsFixed(0)} · '
                    '${seller.pkpStatus ?? 'NON_PKP'}',
                    style: AppStyles.styleRegular12(context)
                        .copyWith(color: kLightThirdColor),
                  ),
                  20.sbh,

                  // Activation is only surfaced when something is still open —
                  // a fully verified store should not be shown a checklist it
                  // has already finished.
                  if (state.needsActivation) ...<Widget>[
                    SectionCard(
                      accent: kWarningColor,
                      onTap: () => context.push(SellerRoutes.onboarding),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.pending_actions_rounded,
                              color: kWarningColor),
                          12.sbw,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Aktivasi belum selesai',
                                  style: AppStyles.styleSemiBold14(context),
                                ),
                                4.sbh,
                                Text(
                                  '${seller.activationGates.passedCount} dari 4 '
                                  'gerbang lolos. Toko belum bisa berjualan.',
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
                    12.sbh,
                  ],

                  if (state.pendingSubOrders > 0) ...<Widget>[
                    SectionCard(
                      accent: kErrorColor,
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.notifications_active_rounded,
                              color: kErrorColor),
                          12.sbw,
                          Expanded(
                            child: Text(
                              '${state.pendingSubOrders} pesanan menunggu '
                              'konfirmasi. Lewat batas 1×24 jam kerja pesanan '
                              'batal otomatis dan skor turun 3.',
                              style: AppStyles.styleMedium12(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    12.sbh,
                  ],

                  SectionCard(
                    title: 'Saldo',
                    child: Column(
                      children: <Widget>[
                        StatRow(
                          label: 'Bisa ditarik',
                          value: formatRupiah(state.balance?.available),
                          emphasis: true,
                          valueColor: kSuccessColor,
                        ),
                        StatRow(
                          label: 'Masih ditahan',
                          value: formatRupiah(state.balance?.held),
                        ),
                        4.sbh,
                        Text(
                          'Dana cair per pengiriman, bukan per pesanan. '
                          'Ongkir 100% milik toko.',
                          style: AppStyles.styleRegular10(context)
                              .copyWith(color: kLightThirdColor),
                        ),
                      ],
                    ),
                  ),
                  12.sbh,

                  SectionCard(
                    title: 'Kinerja toko',
                    child: Column(
                      children: <Widget>[
                        StatRow(
                          label: 'Total sub-pesanan',
                          value: '${performance?.totalSubOrders ?? 0}',
                        ),
                        StatRow(
                          label: 'Konfirmasi tepat waktu',
                          value: SellerPerformance.percentLabel(
                            performance?.slaConfirmationRate,
                          ),
                        ),
                        StatRow(
                          label: 'Rasio pembatalan',
                          value: SellerPerformance.percentLabel(
                            performance?.cancellationRatio,
                          ),
                          valueColor: _ratioColor(performance?.cancellationRatio),
                        ),
                        StatRow(
                          label: 'Rasio kalah sengketa',
                          value: SellerPerformance.percentLabel(
                            performance?.disputeLossRatio,
                          ),
                          valueColor: _ratioColor(performance?.disputeLossRatio),
                        ),
                        if (state.responseRate?.responseRate != null)
                          StatRow(
                            label: 'Tingkat balasan chat',
                            value: SellerPerformance.percentLabel(
                              state.responseRate!.responseRate,
                            ),
                          ),
                        4.sbh,
                        Text(
                          'Rasio pembatalan dan kalah sengketa yang tinggi '
                          'memasukkan toko ke daftar tinjauan Admin Ops.',
                          style: AppStyles.styleRegular10(context)
                              .copyWith(color: kLightThirdColor),
                        ),
                      ],
                    ),
                  ),
                  12.sbh,

                  SectionCard(
                    title: 'Pengaturan toko',
                    child: Column(
                      children: <Widget>[
                        _LinkRow(
                          icon: Icons.verified_outlined,
                          label: 'Status aktivasi',
                          onTap: () => context.push(SellerRoutes.onboarding),
                        ),
                        _LinkRow(
                          icon: Icons.local_shipping_outlined,
                          label: 'Tarif ongkir',
                          onTap: () => context.push(SellerRoutes.shippingRates),
                        ),
                        _LinkRow(
                          icon: Icons.warehouse_outlined,
                          label: 'Gudang',
                          onTap: () => context.push(SellerRoutes.warehouse),
                        ),
                        _LinkRow(
                          icon: Icons.account_balance_outlined,
                          label: 'Rekening pencairan',
                          onTap: () => context.push(SellerRoutes.bankAccount),
                        ),
                      ],
                    ),
                  ),
                  24.sbh,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Anything above 10% is worth flagging rather than reporting flatly.
  static Color? _ratioColor(double? ratio) {
    if (ratio == null) return null;
    final percent = ratio <= 1 ? ratio * 100 : ratio;
    if (percent >= 20) return kErrorColor;
    if (percent >= 10) return kWarningColor;
    return null;
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 18, color: kLightThirdColor),
            12.sbw,
            Expanded(
              child: Text(label, style: AppStyles.styleMedium14(context)),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: kLightThirdColor),
          ],
        ),
      ),
    );
  }
}
