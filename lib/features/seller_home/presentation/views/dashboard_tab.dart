import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/route/app_route_seller.dart';
import '../../../../core/domain/model/store/store.dart';
import '../../../../core/domain/repositories/auth_repository.dart';
import '../../../../core/function/components.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../../di/injector.dart';
import '../../../seller_store/presentation/cubits/store_cubit/store_cubit.dart';
import 'widgets/section_card.dart';

/// The store's home.
///
/// There is no summary endpoint on this backend either, so this is assembled
/// from the store row plus, as each domain lands, its own call. Right now it
/// shows what the account actually has: which shop is active, whether it can
/// sell yet, and how to reach the rest.
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  Future<void> _logout(BuildContext context) async {
    await injector<AuthRepository>().logout();
    if (!context.mounted) return;
    context.go(SellerRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text('Beranda', style: AppStyles.styleMedium18(context)),
              ),
              IconButton(
                tooltip: 'Muat ulang',
                color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => StoreCubit.get(context).load(),
              ),
              IconButton(
                tooltip: 'Keluar',
                color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
                icon: const Icon(Icons.logout_rounded),
                onPressed: () => _logout(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<StoreCubit, StoreState>(
            builder: (context, state) => switch (state) {
              StoreLoadInProgress() => const LoadingIndicatorView(),
              StoreLoadFailure(:final error) => ErrorStateView(
                  error: error,
                  onRetry: () => StoreCubit.get(context).load(),
                ),
              StoreLoadSuccess() => _content(context, state),
            },
          ),
        ),
      ],
    );
  }

  Widget _content(BuildContext context, StoreLoadSuccess state) {
    final store = state.activeStore;
    if (store == null) {
      return EmptyStateView(
        icon: Icons.storefront_outlined,
        message: 'Belum ada toko yang dipilih.',
        action: FilledButton(
          onPressed: () => context.push(SellerRoutes.storePicker),
          child: const Text('Pilih toko'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => StoreCubit.get(context).load(),
      child: ListView(
        padding: 20.pa,
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          store.name,
                          style: AppStyles.styleSemiBold18(context),
                        ),
                      ),
                      _StatusPill(status: store.status),
                    ],
                  ),
                  4.sbh,
                  Text(
                    StoreType.label(store.type),
                    style: AppStyles.styleRegular12(context)
                        .copyWith(color: kLightThirdColor),
                  ),
                  16.sbh,
                  if (!store.isActive) const _NotYetSellingCard(),
                  if (!store.isActive) 12.sbh,
                  SectionCard(
                    title: 'Toko',
                    child: Column(
                      children: <Widget>[
                        StatRow(
                          label: 'Alamat toko',
                          value:
                              store.publicSlug.isEmpty ? '-' : store.publicSlug,
                        ),
                        StatRow(
                          label: 'Rating',
                          value: store.ratingCount == 0
                              ? 'Belum ada ulasan'
                              : '${store.ratingAvg.toStringAsFixed(1)} '
                                  '(${store.ratingCount})',
                        ),
                      ],
                    ),
                  ),
                  if (state.stores.length > 1) ...<Widget>[
                    12.sbh,
                    SectionCard(
                      onTap: () => context.push(SellerRoutes.storePicker),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.swap_horiz_rounded, size: 18),
                          12.sbw,
                          Expanded(
                            child: Text(
                              'Pindah toko (${state.stores.length} toko)',
                              style: AppStyles.styleRegular14(context),
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                    ),
                  ],
                  32.sbh,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final isActive = status == StoreStatus.active;
    final color = isActive ? kSuccessColor : kWarningColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        StoreStatus.label(status),
        style: AppStyles.styleRegular12(context).copyWith(color: color),
      ),
    );
  }
}

/// A store opens `inactive` and cannot sell until it is verified.
class _NotYetSellingCard extends StatelessWidget {
  const _NotYetSellingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 16.pa,
      decoration: BoxDecoration(
        color: kWarningColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.info_outline_rounded,
              size: 18, color: kWarningColor),
          8.sbw,
          Expanded(
            child: Text(
              'Toko belum aktif, jadi belum bisa berjualan dan profilnya belum '
              'bisa dibuka pembeli. Ajukan verifikasi untuk mengaktifkannya.',
              style: AppStyles.styleRegular12(context),
            ),
          ),
        ],
      ),
    );
  }
}
