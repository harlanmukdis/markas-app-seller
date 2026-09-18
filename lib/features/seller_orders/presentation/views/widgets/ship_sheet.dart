import 'package:flutter/material.dart';

import '../../../../../core/data_state.dart';
import '../../../../../core/domain/model/shipping/courier.dart';
import '../../../../../core/domain/repositories/auth_repository.dart';
import '../../../../../core/domain/repositories/shipping_repository.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/extensions.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/app_dropdown_field.dart';
import '../../../../../core/widgets/custom_text_form_field.dart';
import '../../../../../di/injector.dart';

class ShipDraft {
  const ShipDraft({required this.courierCode, required this.awbNumber});

  final String courierCode;
  final String awbNumber;
}

Future<ShipDraft?> showShipSheet(
  BuildContext context, {
  String? suggestedCourierCode,
}) =>
    showModalBottomSheet<ShipDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ShipSheet(suggestedCourierCode: suggestedCourierCode),
    );

/// Hands an order to a courier.
///
/// The courier list comes from the platform master list rather than free text,
/// because `courier_code` is matched against the `couriers` table downstream
/// and a typo would be stored as-is with nothing to catch it.
class _ShipSheet extends StatefulWidget {
  const _ShipSheet({this.suggestedCourierCode});

  /// What the buyer chose at checkout. Pre-selected, since shipping with a
  /// different courier than was paid for is the exception, not the rule.
  final String? suggestedCourierCode;

  @override
  State<_ShipSheet> createState() => _ShipSheetState();
}

class _ShipSheetState extends State<_ShipSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _awb = TextEditingController();

  List<Courier>? _couriers;
  DataError? _error;
  String? _courierCode;

  @override
  void initState() {
    super.initState();
    _courierCode = widget.suggestedCourierCode;
    _load();
  }

  @override
  void dispose() {
    _awb.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final storeId = injector<AuthRepository>().activeStoreId;
    final shipping = injector<ShippingRepository>();

    // The store's own selection first — those are the couriers it actually
    // works with. It is allowed to be empty, which means no restriction, so
    // fall back to the full platform list rather than showing nothing.
    var result = storeId == null
        ? await shipping.getCouriers()
        : await shipping.getStoreCouriers(storeId);
    if (result is DataEmpty<List<Courier>>) {
      result = await shipping.getCouriers();
    }
    if (!mounted) return;

    setState(() {
      switch (result) {
        case DataSuccess<List<Courier>>(:final value):
          _couriers = value;
          if (_courierCode == null && value.isNotEmpty) {
            _courierCode = value.first.code;
          }
        case DataFailed<List<Courier>>(:final failure):
          _error = failure;
        default:
          _couriers = const <Courier>[];
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final code = _courierCode;
    if (code == null) return;
    Navigator.of(context).pop(
      ShipDraft(courierCode: code, awbNumber: _awb.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final couriers = _couriers;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: 20.pa,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Serahkan ke kurir',
                  style: AppStyles.styleSemiBold18(context)),
              4.sbh,
              Text(
                'Nomor resi tidak bisa diubah setelah disimpan, jadi pastikan '
                'sudah benar.',
                style: AppStyles.styleRegular10(context)
                    .copyWith(color: kLightThirdColor),
              ),
              16.sbh,
              if (_error != null)
                Text(
                  'Daftar kurir gagal dimuat: ${_error!.message}',
                  style: AppStyles.styleRegular12(context)
                      .copyWith(color: kErrorColor),
                )
              else if (couriers == null)
                const Center(child: CircularProgressIndicator())
              else
                AppDropdownField<String>(
                  label: 'Kurir',
                  value: _courierCode,
                  items: couriers.map((courier) => courier.code).toList(),
                  itemLabel: (code) => couriers
                      .firstWhere(
                        (courier) => courier.code == code,
                        orElse: () => Courier(code: code, name: code),
                      )
                      .name,
                  onChanged: (value) => setState(() => _courierCode = value),
                  validator: (value) =>
                      value == null ? 'Kurir wajib dipilih' : null,
                ),
              16.sbh,
              CustomTextFormField(
                controller: _awb,
                labelText: 'Nomor resi (AWB)',
                validator: Validators.required('Nomor resi'),
              ),
              24.sbh,
              FilledButton(
                onPressed: couriers == null ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('Tandai dikirim'),
              ),
              12.sbh,
            ],
          ),
        ),
      ),
    );
  }
}
