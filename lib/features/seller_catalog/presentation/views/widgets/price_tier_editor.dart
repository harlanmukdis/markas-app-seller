import 'package:flutter/material.dart';

import '../../../../../core/domain/model/catalog/offer.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/extensions.dart';
import '../../../../../core/utils/format_helper.dart';
import '../../../../../core/widgets/app_dropdown_field.dart';
import '../../../../../core/widgets/custom_text_form_field.dart';

/// Builds the complete tier list for an offer.
///
/// `POST /offers/{id}/price_tiers` **replaces** every tier, so the editor works
/// on the whole list rather than one row: whatever is on screen when the store
/// saves is exactly what the offer will have afterwards.
class PriceTierEditor extends StatelessWidget {
  const PriceTierEditor({
    super.key,
    required this.tiers,
    required this.onChanged,
  });

  final List<PriceTier> tiers;
  final ValueChanged<List<PriceTier>> onChanged;

  Future<void> _edit(BuildContext context, {int? index}) async {
    final result = await showDialog<PriceTier>(
      context: context,
      builder: (_) => _TierDialog(tier: index == null ? null : tiers[index]),
    );
    if (result == null) return;

    final next = <PriceTier>[...tiers];
    if (index == null) {
      next.add(result);
    } else {
      next[index] = result;
    }
    next.sort((a, b) {
      if (a.segment != b.segment) return a.isRetail ? -1 : 1;
      return a.minQty.compareTo(b.minQty);
    });
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final hasRetail = tiers.any((tier) => tier.isRetail);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (tiers.isEmpty)
          Text(
            'Belum ada tier harga.',
            style: AppStyles.styleRegular12(context)
                .copyWith(color: kWarningColor),
          )
        else
          for (int i = 0; i < tiers.length; i++)
            _TierRow(
              tier: tiers[i],
              onEdit: () => _edit(context, index: i),
              onRemove: () => onChanged(<PriceTier>[...tiers]..removeAt(i)),
            ),
        8.sbh,
        OutlinedButton.icon(
          onPressed: () => _edit(context),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Tambah tier'),
        ),
        8.sbh,
        Text(
          hasRetail
              ? 'Menyimpan mengganti SELURUH daftar tier, bukan menambah — '
                  'yang tampil di sini adalah yang akan berlaku.'
              : 'Wajib ada minimal satu tier RETAIL. Tanpa itu server menolak '
                  'dengan MISSING_RETAIL_TIER dan produk tidak bisa tayang.',
          style: AppStyles.styleRegular10(context)
              .copyWith(color: hasRetail ? kLightThirdColor : kWarningColor),
        ),
      ],
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({
    required this.tier,
    required this.onEdit,
    required this.onRemove,
  });

  final PriceTier tier;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${PriceSegment.label(tier.segment)} · min '
                  '${formatThousands(tier.minQty.round())}',
                  style: AppStyles.styleRegular12(context),
                ),
                Text(
                  tier.strikethroughPrice == null
                      ? formatRupiah(tier.price)
                      : '${formatRupiah(tier.price)} · coret '
                          '${formatRupiah(tier.strikethroughPrice!)}',
                  style: AppStyles.styleMedium14(context),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Ubah',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
          ),
          IconButton(
            tooltip: 'Hapus',
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded,
                size: 18, color: kDeleteColor),
          ),
        ],
      ),
    );
  }
}

class _TierDialog extends StatefulWidget {
  const _TierDialog({this.tier});

  final PriceTier? tier;

  @override
  State<_TierDialog> createState() => _TierDialogState();
}

class _TierDialogState extends State<_TierDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _minQtyController;
  late final TextEditingController _priceController;
  late final TextEditingController _strikethroughController;
  late String _segment;

  @override
  void initState() {
    super.initState();
    final tier = widget.tier;
    _segment = tier?.segment ?? PriceSegment.retail;
    _minQtyController =
        TextEditingController(text: (tier?.minQty ?? 1).round().toString());
    _priceController =
        TextEditingController(text: tier == null ? '' : '${tier.price}');
    _strikethroughController = TextEditingController(
      text:
          tier?.strikethroughPrice == null ? '' : '${tier!.strikethroughPrice}',
    );
  }

  @override
  void dispose() {
    _minQtyController.dispose();
    _priceController.dispose();
    _strikethroughController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.tier == null ? 'Tier harga baru' : 'Ubah tier harga'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              AppDropdownField<String>(
                label: 'Segmen',
                value: _segment,
                items: PriceSegment.all,
                itemLabel: PriceSegment.label,
                helperText: 'Tier PROJECT hanya terlihat pembeli B2B '
                    'terverifikasi.',
                onChanged: (value) =>
                    setState(() => _segment = value ?? PriceSegment.retail),
              ),
              12.sbh,
              CustomTextFormField(
                controller: _minQtyController,
                labelText: 'Minimal jumlah',
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = int.tryParse((value ?? '').trim());
                  if (parsed == null || parsed < 1) return 'Minimal 1';
                  return null;
                },
              ),
              12.sbh,
              CustomTextFormField(
                controller: _priceController,
                labelText: 'Harga per unit (Rp)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = parseRupiahInput(value ?? '');
                  if (parsed == null || parsed <= 0) return 'Isi harga';
                  return null;
                },
              ),
              12.sbh,
              CustomTextFormField(
                controller: _strikethroughController,
                labelText: 'Harga coret (opsional)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  final text = (value ?? '').trim();
                  if (text.isEmpty) return null;
                  final parsed = parseRupiahInput(text);
                  final price = parseRupiahInput(_priceController.text);
                  if (parsed == null || parsed <= 0) return 'Isi angka';
                  if (price != null && parsed <= price) {
                    return 'Harga coret harus di atas harga jual';
                  }
                  return null;
                },
              ),
              8.sbh,
              Text(
                'Harga coret dibuang diam-diam kalau harga itu belum bertahan '
                '14 hari di riwayat. Kalau hilang setelah disimpan, itu '
                'sebabnya.',
                style: AppStyles.styleRegular10(context)
                    .copyWith(color: kLightThirdColor),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(
              PriceTier(
                segment: _segment,
                minQty: double.parse(_minQtyController.text.trim()),
                price: parseRupiahInput(_priceController.text)!,
                strikethroughPrice:
                    parseRupiahInput(_strikethroughController.text),
              ),
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
