import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/model/catalog/offer.dart';
import '../../../../core/function/components.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/format_helper.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../cubits/offers_cubit/offers_cubit.dart';

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
              OffersLoadSuccess() => _OffersContent(state: state),
            },
          ),
        ),
      ],
    );
  }
}

class _OffersContent extends StatelessWidget {
  const _OffersContent({required this.state});

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
      child: ListView.builder(
        padding: 20.pa,
        itemCount: state.offers.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '${state.activeCount} dari ${state.offers.length} produk '
                    'tayang',
                    style: AppStyles.styleRegular12(context)
                        .copyWith(color: kLightThirdColor),
                  ),
                ),
              ),
            );
          }

          final offer = state.offers[index - 1];
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: _OfferCard(
                offer: offer,
                name: state.nameFor(offer),
                stock: state.stock[offer.id],
                isBusy: state.busyOfferId == offer.id,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.offer,
    required this.name,
    required this.stock,
    required this.isBusy,
  });

  final Offer offer;
  final String name;
  final double? stock;
  final bool isBusy;

  Future<void> _toggle(BuildContext context) async {
    final cubit = OffersCubit.get(context);
    final error = offer.isActive
        ? await cubit.deactivate(offer.id)
        : await cubit.activate(offer.id);

    if (!context.mounted) return;
    if (error != null) return showErrorSnackBar(context, error);
    showSuccessSnackBar(
      context,
      offer.isActive ? 'Produk dinonaktifkan.' : 'Produk tayang.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = isAppDarkMode();
    final retail = offer.retailTiers;
    final lowestRetail = retail.isEmpty
        ? null
        : retail.map((tier) => tier.price).reduce((a, b) => a < b ? a : b);

    // Everything the client can already tell about the listing gates, so the
    // store learns why it cannot go live before pressing the button.
    final blockers = <String>[
      if (!offer.hasRetailTier) 'belum ada tier RETAIL',
      if (!offer.photosOk) 'foto belum memenuhi syarat (≥3 foto, ≥800×800)',
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: 16.pa,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(name, style: AppStyles.styleSemiBold14(context)),
              ),
              8.sbw,
              Text(
                OfferStatus.label(offer.status),
                style: AppStyles.styleMedium12(context).copyWith(
                  color: offer.isActive ? kSuccessColor : kLightThirdColor,
                ),
              ),
            ],
          ),
          if (offer.isTemporaryListing) ...<Widget>[
            4.sbh,
            Text(
              'Listing sementara — tayang otomatis karena permintaan SKU '
              'belum dijawab tim katalog.',
              style: AppStyles.styleRegular10(context)
                  .copyWith(color: kWarningColor),
            ),
          ],
          8.sbh,
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: <Widget>[
              _Meta(
                icon: Icons.sell_outlined,
                label: lowestRetail == null
                    ? 'Harga belum diatur'
                    : 'Mulai ${formatRupiah(lowestRetail)}',
              ),
              _Meta(
                icon: Icons.inventory_outlined,
                label: stock == null
                    ? 'Stok —'
                    : 'Stok ${stock!.round()}',
              ),
              _Meta(
                icon: Icons.shopping_basket_outlined,
                label: 'Min ${offer.minOrderQty.round()}',
              ),
              _Meta(
                icon: Icons.photo_library_outlined,
                label: '${offer.photos.length} foto',
              ),
            ],
          ),
          if (blockers.isNotEmpty && !offer.isActive) ...<Widget>[
            8.sbh,
            Text(
              'Belum bisa tayang: ${blockers.join(', ')}.',
              style: AppStyles.styleRegular10(context)
                  .copyWith(color: kWarningColor),
            ),
          ],
          12.sbh,
          if (isBusy)
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            CustomButton(
              width: 160,
              height: 40,
              elevation: 0,
              borderRadius: BorderRadius.circular(12),
              backColor: offer.isActive ? Colors.transparent : null,
              borderColor: offer.isActive ? kLightThirdColor : Colors.transparent,
              txtColor: offer.isActive ? kLightThirdColor : kWhiteColor,
              onPressed: () => _toggle(context),
              child: Text(
                offer.isActive ? 'Nonaktifkan' : 'Tayangkan',
                style: AppStyles.styleMedium12(context).copyWith(
                  color: offer.isActive ? kLightThirdColor : kWhiteColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

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
