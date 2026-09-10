import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/domain/model/catalog/offer.dart';
import '../../../../core/domain/model/inventory/inventory.dart';
import '../../../../core/domain/model/review/review.dart';
import '../../../../core/domain/model/seller/warehouse.dart';
import '../../../../core/domain/model/shipment/shipment.dart';
import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/format_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../seller_home/presentation/views/widgets/section_card.dart';
import '../cubits/offer_detail_cubit/offer_detail_cubit.dart';
import 'widgets/photo_editor.dart';
import 'widgets/price_tier_editor.dart';
import 'widgets/seller_product_item.dart';

/// Detail for one of the store's own listings.
///
/// Laid out like the kit's product detail — carousel, title, then stacked
/// sections — but answering a seller's questions instead of a buyer's: why is
/// this not live, how much stock is left, what are my price tiers.
class OfferDetailView extends StatelessWidget {
  const OfferDetailView({super.key, required this.offerId});

  final int offerId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OfferDetailCubit>(
      create: (_) => OfferDetailCubit(offerId)..load(),
      child: const _OfferDetailBody(),
    );
  }
}

class _OfferDetailBody extends StatelessWidget {
  const _OfferDetailBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Detail Produk'),
      body: SafeArea(
        child: BlocBuilder<OfferDetailCubit, OfferDetailState>(
          builder: (context, state) => switch (state) {
            OfferDetailLoadInProgress() => const LoadingIndicatorView(),
            OfferDetailLoadFailure(:final error) => ErrorStateView(
                error: error,
                onRetry: () => OfferDetailCubit.get(context).load(),
              ),
            OfferDetailLoadSuccess() => _Content(state: state),
          },
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state});

  final OfferDetailLoadSuccess state;

  @override
  Widget build(BuildContext context) {
    final offer = state.offer;

    return RefreshIndicator(
      onRefresh: () => OfferDetailCubit.get(context).load(showSpinner: false),
      child: ListView(
        padding: 24.psh,
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  24.sbh,
                  _PhotoCarousel(photos: offer.photos),
                  8.sbh,
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton.icon(
                      onPressed: state.isBusy
                          ? null
                          : () => _editPhotos(context, state),
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('Ubah foto'),
                    ),
                  ),
                  8.sbh,
                  Text(
                    state.displayName,
                    style: AppStyles.styleMedium16(context),
                  ),
                  8.sbh,
                  Row(
                    children: <Widget>[
                      _StatusPill(offer: offer),
                      12.sbw,
                      Text(
                        offer.isFreeform ? 'Produk sendiri' : 'SKU master',
                        style: AppStyles.styleRegular12(context)
                            .copyWith(color: kLightThirdColor),
                      ),
                    ],
                  ),
                  if (offer.isTemporaryListing) ...<Widget>[
                    8.sbh,
                    Text(
                      'Listing sementara — tayang otomatis karena permintaan '
                      'SKU belum dijawab tim katalog dalam 3×24 jam.',
                      style: AppStyles.styleRegular10(context)
                          .copyWith(color: kWarningColor),
                    ),
                  ],
                  20.sbh,
                  _GatesCard(state: state),
                  12.sbh,
                  _SpecCard(state: state),
                  12.sbh,
                  _PriceCard(state: state),
                  12.sbh,
                  _StockCard(state: state),
                  12.sbh,
                  _ReviewsCard(reviews: state.reviews),
                  12.sbh,
                  SectionCard(
                    title: 'Deskripsi',
                    trailing: _EditAction(
                      onPressed: state.isBusy
                          ? null
                          : () => _editDescription(context, state),
                    ),
                    child: Text(
                      offer.description?.trim().isNotEmpty ?? false
                          ? offer.description!
                          : 'Belum ada deskripsi.',
                      style: AppStyles.styleRegular12(context).copyWith(
                        color: offer.description?.trim().isNotEmpty ?? false
                            ? null
                            : kLightThirdColor,
                      ),
                    ),
                  ),
                  24.sbh,
                  _ActivateButton(state: state),
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
  const _StatusPill({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final color = offer.isActive ? kSuccessColor : kLightThirdColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        OfferStatus.label(offer.status),
        style: AppStyles.styleMedium12(context).copyWith(color: color),
      ),
    );
  }
}

/// The kit uses a carousel with a page indicator on its product detail; this
/// is the same idea over the offer's own photos, which are remote URLs and may
/// not load.
class _PhotoCarousel extends StatefulWidget {
  const _PhotoCarousel({required this.photos});

  final List<OfferPhoto> photos;

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.photos.isEmpty ? 1 : widget.photos.length;

    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 260,
            child: PageView.builder(
              controller: _controller,
              itemCount: count,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) =>
                  OfferPhotoView(photos: widget.photos, index: index),
            ),
          ),
        ),
        if (count > 1) ...<Widget>[
          12.sbh,
          SmoothPageIndicator(
            controller: _controller,
            count: count,
            effect: ExpandingDotsEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor:
                  isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor,
              dotColor: kLightThirdColor.withValues(alpha: 0.3),
            ),
          ),
        ],
        if (widget.photos.isNotEmpty) ...<Widget>[
          8.sbh,
          Text(
            'Foto ${_index + 1} dari ${widget.photos.length} · '
            '${widget.photos[_index].width}×${widget.photos[_index].height}',
            style: AppStyles.styleRegular10(context).copyWith(
              color: widget.photos[_index].meetsMinimum
                  ? kLightThirdColor
                  : kWarningColor,
            ),
          ),
        ],
      ],
    );
  }
}

/// The four listing gates, as a checklist rather than a generic error. Two of
/// them the client can see coming; the other two only the server knows.
class _GatesCard extends StatelessWidget {
  const _GatesCard({required this.state});

  final OfferDetailLoadSuccess state;

  @override
  Widget build(BuildContext context) {
    final gates = state.gates;

    if (gates == null) {
      return SectionCard(
        title: 'Syarat tayang',
        child: Text(
          'Memuat syarat…',
          style: AppStyles.styleRegular12(context)
              .copyWith(color: kLightThirdColor),
        ),
      );
    }

    final rows = <(String, bool)>[
      ('Toko berstatus VERIFIED', gates.sellerVerified),
      ('Punya tarif ongkir minimal 1 zona', gates.hasShippingRate),
      ('Punya tier harga RETAIL', gates.hasRetailTier),
      ('Foto minimal 3 dan masing-masing ≥ 800×800', gates.photosOk),
    ];

    return SectionCard(
      title: 'Syarat tayang',
      accent: gates.allPassed ? null : kWarningColor,
      trailing: Text(
        '${rows.where((row) => row.$2).length} dari 4',
        style:
            AppStyles.styleMedium12(context).copyWith(color: kLightThirdColor),
      ),
      child: Column(
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: <Widget>[
                    Icon(
                      row.$2
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 18,
                      color: row.$2 ? kSuccessColor : kWarningColor,
                    ),
                    8.sbw,
                    Expanded(
                      child: Text(
                        row.$1,
                        style: AppStyles.styleRegular12(context),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SpecCard extends StatelessWidget {
  const _SpecCard({required this.state});

  final OfferDetailLoadSuccess state;

  @override
  Widget build(BuildContext context) {
    final sku = state.sku;
    final offer = state.offer;

    return SectionCard(
      title: 'Spesifikasi',
      trailing: _EditAction(
        onPressed: state.isBusy ? null : () => _editSelling(context, state),
      ),
      child: Column(
        children: <Widget>[
          StatRow(
            label: 'Berat',
            value: state.weightKg == null
                ? '-'
                : '${state.weightKg!.toStringAsFixed(
                    state.weightKg! == state.weightKg!.roundToDouble() ? 0 : 2,
                  )} kg',
          ),
          if (sku != null)
            StatRow(label: 'Dimensi', value: sku.dimensionsLabel)
          else if (offer.freeformLengthCm != null)
            StatRow(
              label: 'Dimensi',
              value: '${offer.freeformLengthCm!.round()} × '
                  '${offer.freeformWidthCm?.round() ?? '-'} × '
                  '${offer.freeformHeightCm?.round() ?? '-'} cm',
            ),
          StatRow(
            label: 'Kelas penanganan',
            value: HandlingClass.label(
              offer.handlingClass ?? sku?.handlingClass,
            ),
          ),
          StatRow(
            label: 'Minimum order',
            value: '${offer.minOrderQty.round()}'
                '${sku?.baseUnit == null ? '' : ' ${sku!.baseUnit}'}',
          ),
          if (sku != null && sku.units.isNotEmpty)
            StatRow(
              label: 'Satuan',
              value: sku.units.map((unit) => unit.name).join(', '),
            ),
          if (!state.dimensionsAreEditable) ...<Widget>[
            8.sbh,
            Text(
              'Berat dan dimensi SKU master dikunci platform — toko tidak bisa '
              'mengubahnya. Kalau bisa, selisih ongkirnya akan ditanggung sopir '
              'di lokasi.',
              style: AppStyles.styleRegular10(context)
                  .copyWith(color: kLightThirdColor),
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.state});

  final OfferDetailLoadSuccess state;

  @override
  Widget build(BuildContext context) {
    final tiers = state.offer.priceTiers;

    return SectionCard(
      title: 'Harga bertingkat',
      trailing: _EditAction(
        onPressed: state.isBusy ? null : () => _editPrices(context, state),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (tiers.isEmpty)
            Text(
              'Belum ada tier harga. Minimal satu tier RETAIL wajib ada '
              'sebelum produk bisa tayang.',
              style: AppStyles.styleRegular12(context)
                  .copyWith(color: kWarningColor),
            )
          else
            ...tiers.map(
              (tier) => StatRow(
                label: '${PriceSegment.label(tier.segment)} · '
                    'min ${tier.minQty.round()}',
                value: formatRupiah(tier.price),
                valueColor: tier.isRetail ? null : kLightThirdColor,
              ),
            ),
          8.sbh,
          Text(
            'Mengubah harga mengirim ulang SELURUH daftar tier — endpoint ini '
            'mengganti, bukan menambah. Tier PROJECT hanya terlihat pembeli '
            'B2B terverifikasi.',
            style: AppStyles.styleRegular10(context)
                .copyWith(color: kLightThirdColor),
          ),
        ],
      ),
    );
  }
}

class _StockCard extends StatefulWidget {
  const _StockCard({required this.state});

  final OfferDetailLoadSuccess state;

  @override
  State<_StockCard> createState() => _StockCardState();
}

class _StockCardState extends State<_StockCard> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _qtyController = TextEditingController();
  Warehouse? _warehouse;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _stockIn() async {
    if (!_formKey.currentState!.validate()) return;

    final warehouse = _warehouse ?? widget.state.warehouses.firstOrNull;
    if (warehouse == null) return;

    final error = await OfferDetailCubit.get(context).stockIn(
      warehouseId: warehouse.id,
      qty: double.tryParse(_qtyController.text.trim()) ?? 0,
    );

    if (!mounted) return;
    if (error != null) return showErrorSnackBar(context, error);
    _qtyController.clear();
    showSuccessSnackBar(context, 'Stok masuk tercatat.');
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final warehouses = state.warehouses;

    return SectionCard(
      title: 'Stok',
      trailing: Text(
        state.available == null ? '…' : '${state.available!.round()}',
        style: AppStyles.styleSemiBold16(context).copyWith(
          color: (state.available ?? 1) <= 0 ? kErrorColor : kSuccessColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Stok tersedia = fisik − direservasi. Angka bisa turun tanpa ada '
            'pengiriman kalau ada pesanan yang belum dibayar mengunci stok.',
            style: AppStyles.styleRegular10(context)
                .copyWith(color: kLightThirdColor),
          ),
          if (warehouses.isEmpty) ...<Widget>[
            12.sbh,
            Text(
              'Belum ada gudang, jadi stok tidak bisa dimasukkan.',
              style: AppStyles.styleRegular12(context)
                  .copyWith(color: kWarningColor),
            ),
          ] else ...<Widget>[
            16.sbh,
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppDropdownField<Warehouse>(
                    label: 'Gudang',
                    value: _warehouse ?? warehouses.first,
                    items: warehouses,
                    itemLabel: (Warehouse warehouse) => warehouse.name,
                    onChanged: (warehouse) =>
                        setState(() => _warehouse = warehouse),
                  ),
                  12.sbh,
                  Text('Jumlah masuk', style: AppStyles.styleMedium14(context)),
                  8.sbh,
                  CustomTextFormField(
                    controller: _qtyController,
                    hintText: '100',
                    keyboardType: TextInputType.number,
                    filled: true,
                    validator: Validators.positiveAmount('Jumlah'),
                  ),
                  12.sbh,
                  CustomButton(
                    height: 42,
                    elevation: 0,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: state.isBusy ? null : _stockIn,
                    child: state.isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: kWhiteColor,
                            ),
                          )
                        : const Text('Catat stok masuk'),
                  ),
                ],
              ),
            ),
          ],
          if (state.ledger.isNotEmpty) ...<Widget>[
            16.sbh,
            Text('Riwayat pergerakan', style: AppStyles.styleMedium14(context)),
            8.sbh,
            ...state.ledger.take(6).map((entry) => _LedgerRow(entry: entry)),
          ],
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.entry});

  final InventoryLedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final delta = entry.qtyPhysicalDelta;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.movementType ?? 'Pergerakan',
                  style: AppStyles.styleRegular12(context),
                ),
                Text(
                  formatDateTime(entry.createdAt),
                  style: AppStyles.styleRegular10(context)
                      .copyWith(color: kLightThirdColor),
                ),
              ],
            ),
          ),
          Text(
            '${delta > 0 ? '+' : ''}${delta.round()}',
            style: AppStyles.styleSemiBold12(context).copyWith(
              color: delta >= 0 ? kSuccessColor : kErrorColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivateButton extends StatelessWidget {
  const _ActivateButton({required this.state});

  final OfferDetailLoadSuccess state;

  Future<void> _toggle(BuildContext context) async {
    final cubit = OfferDetailCubit.get(context);
    final error = state.offer.isActive
        ? await cubit.deactivate()
        : await cubit.activate();

    if (!context.mounted) return;
    if (error != null) return showErrorSnackBar(context, error);
    showSuccessSnackBar(
      context,
      state.offer.isActive ? 'Produk dinonaktifkan.' : 'Produk tayang.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActive = state.offer.isActive;
    final blocked = !isActive && state.blockers.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        CustomButton(
          height: 48,
          elevation: 0,
          borderRadius: BorderRadius.circular(14),
          backColor: isActive ? Colors.transparent : null,
          borderColor: isActive ? kLightThirdColor : Colors.transparent,
          txtColor: isActive ? kLightThirdColor : kWhiteColor,
          // Left tappable even when a gate is unmet: the server's 422 names
          // exactly which one, and that is more useful than a dead button.
          onPressed: state.isBusy ? null : () => _toggle(context),
          child: state.isBusy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kWhiteColor,
                  ),
                )
              : Text(isActive ? 'Nonaktifkan produk' : 'Tayangkan produk'),
        ),
        if (blocked) ...<Widget>[
          8.sbh,
          Text(
            'Masih ada syarat yang belum terpenuhi: '
            '${state.blockers.join('; ')}.',
            textAlign: TextAlign.center,
            style: AppStyles.styleRegular10(context)
                .copyWith(color: kWarningColor),
          ),
        ],
      ],
    );
  }
}

/// Buyer ratings on this listing.
///
/// A store cannot answer or remove these, so this is deliberately read-only.
/// It earns its place because rating is not cosmetic here: buyers filter by
/// `min_rating` and sort by `popular`, so a low rating quietly removes the
/// listing from results.
class _ReviewsCard extends StatelessWidget {
  const _ReviewsCard({required this.reviews});

  final OfferReviews? reviews;

  @override
  Widget build(BuildContext context) {
    final data = reviews;

    if (data == null) {
      return SectionCard(
        title: 'Ulasan pembeli',
        child: Text(
          'Memuat ulasan…',
          style: AppStyles.styleRegular12(context)
              .copyWith(color: kLightThirdColor),
        ),
      );
    }

    if (!data.hasReviews) {
      return SectionCard(
        title: 'Ulasan pembeli',
        child: Text(
          'Belum ada ulasan. Rating memengaruhi filter dan urutan pencarian '
          'pembeli, jadi ulasan pertama berarti banyak.',
          style: AppStyles.styleRegular12(context)
              .copyWith(color: kLightThirdColor),
        ),
      );
    }

    return SectionCard(
      title: 'Ulasan pembeli',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.star_rounded, size: 16, color: kWarningColor),
          4.sbw,
          Text(
            '${data.ratingLabel} · ${data.reviewCount} ulasan',
            style: AppStyles.styleMedium12(context),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: data.items
            .take(5)
            .map((review) => _ReviewRow(review: review))
            .toList(),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              ...List<Widget>.generate(
                5,
                (index) => Icon(
                  index < review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 14,
                  color: kWarningColor,
                ),
              ),
              8.sbw,
              Expanded(
                child: Text(
                  review.buyerName ?? 'Pembeli',
                  style: AppStyles.styleMedium12(context),
                ),
              ),
              Text(
                formatDate(review.createdAt),
                style: AppStyles.styleRegular10(context)
                    .copyWith(color: kLightThirdColor),
              ),
            ],
          ),
          if (review.comment != null) ...<Widget>[
            4.sbh,
            Text(
              review.comment!,
              style: AppStyles.styleRegular12(context)
                  .copyWith(color: kLightThirdColor),
            ),
          ],
        ],
      ),
    );
  }
}

/// The "Ubah" affordance every editable card carries, so they read as one
/// control rather than four different buttons.
class _EditAction extends StatelessWidget {
  const _EditAction({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text('Ubah'),
    );
  }
}

/// Every editor is a bottom sheet over the detail screen rather than a
/// separate route: the store is comparing what it types against the gates and
/// stock already on screen.
Future<T?> _showEditSheet<T>(
  BuildContext context,
  Widget Function(BuildContext) builder,
) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isAppDarkMode() ? kDarkColor : kWhiteColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: builder,
  );
}

Future<void> _editPhotos(
  BuildContext context,
  OfferDetailLoadSuccess state,
) async {
  final cubit = OfferDetailCubit.get(context);
  final photos = await _showEditSheet<List<OfferPhoto>>(
    context,
    (_) => _PhotoSheet(initial: state.offer.photos),
  );
  if (photos == null || !context.mounted) return;

  final error = await cubit.updateOffer(photos: photos);
  if (!context.mounted) return;
  if (error != null) {
    showErrorSnackBar(context, error);
    return;
  }
  showSuccessSnackBar(context, 'Foto diperbarui.');
}

Future<void> _editPrices(
  BuildContext context,
  OfferDetailLoadSuccess state,
) async {
  final cubit = OfferDetailCubit.get(context);
  final sent = await _showEditSheet<List<PriceTier>>(
    context,
    (_) => _PriceSheet(initial: state.offer.priceTiers),
  );
  if (sent == null || !context.mounted) return;

  final error = await cubit.replacePriceTiers(sent);
  if (!context.mounted) return;
  if (error != null) {
    showErrorSnackBar(context, error);
    return;
  }

  // A strikethrough price the store cannot prove is dropped without any
  // error, so the only way it learns is by comparing what came back.
  final latest = cubit.state;
  final dropped = latest is OfferDetailLoadSuccess &&
      sent.any((tier) => tier.strikethroughPrice != null) &&
      latest.offer.priceTiers.every((tier) => tier.strikethroughPrice == null);

  showSuccessSnackBar(
    context,
    dropped
        ? 'Harga disimpan, tapi harga coret dibuang server karena harga '
            'itu belum bertahan 14 hari di riwayat.'
        : 'Harga diperbarui.',
  );
}

Future<void> _editDescription(
  BuildContext context,
  OfferDetailLoadSuccess state,
) async {
  final cubit = OfferDetailCubit.get(context);
  final description = await _showEditSheet<String>(
    context,
    (_) => _DescriptionSheet(initial: state.offer.description ?? ''),
  );
  if (description == null || !context.mounted) return;

  final error = await cubit.updateOffer(description: description);
  if (!context.mounted) return;
  if (error != null) {
    showErrorSnackBar(context, error);
    return;
  }
  showSuccessSnackBar(context, 'Deskripsi diperbarui.');
}

Future<void> _editSelling(
  BuildContext context,
  OfferDetailLoadSuccess state,
) async {
  final cubit = OfferDetailCubit.get(context);
  final result = await _showEditSheet<_SellingEdit>(
    context,
    (_) => _SellingSheet(offer: state.offer),
  );
  if (result == null || !context.mounted) return;

  final error = await cubit.updateOffer(
    minOrderQty: result.minOrderQty,
    handlingClass: result.handlingClass,
    freeformName: result.freeformName,
  );
  if (!context.mounted) return;
  if (error != null) {
    showErrorSnackBar(context, error);
    return;
  }
  showSuccessSnackBar(context, 'Spesifikasi diperbarui.');
}

/// Shared chrome for the editor sheets: a title, a scrollable body that keeps
/// clear of the keyboard, and one save button.
class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({
    required this.title,
    required this.child,
    required this.onSave,
  });

  final String title;
  final Widget child;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * .85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(title, style: AppStyles.styleSemiBold16(context)),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: child,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: FilledButton(
                  onPressed: onSave,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoSheet extends StatefulWidget {
  const _PhotoSheet({required this.initial});

  final List<OfferPhoto> initial;

  @override
  State<_PhotoSheet> createState() => _PhotoSheetState();
}

class _PhotoSheetState extends State<_PhotoSheet> {
  late List<OfferPhoto> _photos = <OfferPhoto>[...widget.initial];

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Ubah foto',
      onSave: () => Navigator.of(context).pop(_photos),
      child: PhotoEditor(
        photos: _photos,
        onChanged: (photos) => setState(() => _photos = photos),
      ),
    );
  }
}

class _PriceSheet extends StatefulWidget {
  const _PriceSheet({required this.initial});

  final List<PriceTier> initial;

  @override
  State<_PriceSheet> createState() => _PriceSheetState();
}

class _PriceSheetState extends State<_PriceSheet> {
  late List<PriceTier> _tiers = <PriceTier>[...widget.initial];

  @override
  Widget build(BuildContext context) {
    // The endpoint refuses a list with no RETAIL tier, so block the save here
    // rather than let the store find out through a 422.
    final canSave = _tiers.any((tier) => tier.isRetail);

    return _SheetScaffold(
      title: 'Ubah harga',
      onSave: canSave ? () => Navigator.of(context).pop(_tiers) : null,
      child: PriceTierEditor(
        tiers: _tiers,
        onChanged: (tiers) => setState(() => _tiers = tiers),
      ),
    );
  }
}

class _DescriptionSheet extends StatefulWidget {
  const _DescriptionSheet({required this.initial});

  final String initial;

  @override
  State<_DescriptionSheet> createState() => _DescriptionSheetState();
}

class _DescriptionSheetState extends State<_DescriptionSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Ubah deskripsi',
      onSave: () => Navigator.of(context).pop(_controller.text.trim()),
      child: CustomTextFormField(
        controller: _controller,
        labelText: 'Deskripsi',
        maxLines: 6,
        textInputAction: TextInputAction.newline,
        // No Form wraps this sheet today, but the default validator would
        // block one the moment somebody adds it.
        validator: Validators.optional,
      ),
    );
  }
}

/// What the specification sheet can actually change. Weight and dimensions are
/// deliberately absent for a MASTER offer — they belong to the platform SKU.
class _SellingEdit {
  const _SellingEdit({
    required this.minOrderQty,
    this.handlingClass,
    this.freeformName,
  });

  final double minOrderQty;
  final String? handlingClass;
  final String? freeformName;
}

class _SellingSheet extends StatefulWidget {
  const _SellingSheet({required this.offer});

  final Offer offer;

  @override
  State<_SellingSheet> createState() => _SellingSheetState();
}

class _SellingSheetState extends State<_SellingSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _moqController = TextEditingController(
    text: widget.offer.minOrderQty.round().toString(),
  );
  late final TextEditingController _nameController = TextEditingController(
    text: widget.offer.freeformName ?? '',
  );
  late String? _handlingClass = widget.offer.handlingClass;

  @override
  void dispose() {
    _moqController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _SellingEdit(
        minOrderQty: double.parse(_moqController.text.trim()),
        handlingClass: _handlingClass,
        freeformName:
            widget.offer.isFreeform ? _nameController.text.trim() : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: 'Ubah spesifikasi',
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (widget.offer.isFreeform) ...<Widget>[
              CustomTextFormField(
                controller: _nameController,
                labelText: 'Nama produk',
                validator: Validators.required('Nama produk'),
              ),
              12.sbh,
            ],
            CustomTextFormField(
              controller: _moqController,
              labelText: 'Minimal pembelian',
              keyboardType: TextInputType.number,
              validator: (value) {
                final parsed = double.tryParse((value ?? '').trim());
                if (parsed == null || parsed <= 0) return 'Minimal 1';
                return null;
              },
            ),
            12.sbh,
            AppDropdownField<String>(
              label: 'Kelas penanganan',
              value: _handlingClass,
              items: HandlingClass.all,
              itemLabel: HandlingClass.label,
              hint: 'Ikuti bawaan SKU',
              onChanged: (value) => setState(() => _handlingClass = value),
            ),
            12.sbh,
            Text(
              widget.offer.isFreeform
                  ? 'Berat dan dimensi produk bebas belum bisa diubah lewat '
                      'endpoint ini — buat produk baru kalau salah.'
                  : 'Berat dan dimensi mengikuti SKU master dan dikunci '
                      'platform.',
              style: AppStyles.styleRegular10(context)
                  .copyWith(color: kLightThirdColor),
            ),
          ],
        ),
      ),
    );
  }
}
