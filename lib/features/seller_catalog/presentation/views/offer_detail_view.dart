import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/domain/model/catalog/offer.dart';
import '../../../../core/domain/model/inventory/inventory.dart';
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
                  16.sbh,
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
                  if (offer.description != null) ...<Widget>[
                    12.sbh,
                    SectionCard(
                      title: 'Deskripsi',
                      child: Text(
                        offer.description!,
                        style: AppStyles.styleRegular12(context),
                      ),
                    ),
                  ],
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
        style: AppStyles.styleMedium12(context)
            .copyWith(color: kLightThirdColor),
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
                  Text('Jumlah masuk',
                      style: AppStyles.styleMedium14(context)),
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
            Text('Riwayat pergerakan',
                style: AppStyles.styleMedium14(context)),
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
