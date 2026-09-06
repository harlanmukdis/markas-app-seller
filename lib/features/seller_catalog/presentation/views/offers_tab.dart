import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/route/app_route_seller.dart';
import '../../../../core/function/components.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../cubits/offers_cubit/offers_cubit.dart';
import 'widgets/seller_product_item.dart';

class OffersTab extends StatelessWidget {
  const OffersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OffersCubit>(
      create: (_) => OffersCubit()..load(),
      child: const _OffersBody(),
    );
  }
}

class _OffersBody extends StatelessWidget {
  const _OffersBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text('Produk', style: AppStyles.styleMedium18(context)),
              ),
              IconButton(
                tooltip: 'Muat ulang',
                color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => OffersCubit.get(context).load(),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<OffersCubit, OffersState>(
            builder: (context, state) => switch (state) {
              OffersLoadInProgress() => const LoadingIndicatorView(),
              OffersLoadFailure(:final error) => ErrorStateView(
                  error: error,
                  onRetry: () => OffersCubit.get(context).load(),
                ),
              OffersLoadSuccess() => _OffersGrid(state: state),
            },
          ),
        ),
      ],
    );
  }
}

class _OffersGrid extends StatelessWidget {
  const _OffersGrid({required this.state});

  final OffersLoadSuccess state;

  @override
  Widget build(BuildContext context) {
    if (state.offers.isEmpty) {
      return const EmptyStateView(
        icon: Icons.inventory_2_outlined,
        message: 'Belum ada produk.\nBuat penawaran lewat SKU master atau '
            'produk bebas sesuai jalur kategori.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => OffersCubit.get(context).load(showSpinner: false),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${state.activeCount} dari ${state.offers.length} produk '
                    'tayang',
                    style: AppStyles.styleRegular12(context)
                        .copyWith(color: kLightThirdColor),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              // Same responsive rule as the kit's catalogue: one column per
              // ~250 logical pixels, so the card keeps its proportions from a
              // phone up to a desktop browser.
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              itemCount: state.offers.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (context.screenWidth / 250).round().clamp(1, 6),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: .7,
              ),
              itemBuilder: (context, index) {
                final offer = state.offers[index];
                return SellerProductItem(
                  offer: offer,
                  name: state.nameFor(offer),
                  stock: state.stock[offer.id],
                  tiersLoaded: state.tiersLoaded,
                  onTap: () async {
                    await context.push(
                      SellerRoutes.offerDetail,
                      extra: offer.id,
                    );
                    if (!context.mounted) return;
                    // Anything on the detail screen can change status or stock.
                    await OffersCubit.get(context).load(showSpinner: false);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
