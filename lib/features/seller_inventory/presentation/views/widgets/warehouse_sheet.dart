import 'package:flutter/material.dart';

import '../../../../../core/domain/model/inventory/warehouse.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/extensions.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/app_dropdown_field.dart';
import '../../../../../core/widgets/custom_text_form_field.dart';

/// What the sheet collected. Null from [showWarehouseSheet] means cancelled.
class WarehouseDraft {
  const WarehouseDraft({
    required this.name,
    required this.address,
    required this.city,
    required this.province,
    required this.postalCode,
    this.status,
  });

  final String name;
  final String address;
  final String city;
  final String province;
  final String postalCode;

  /// Only meaningful when editing; a new warehouse is always created active.
  final String? status;
}

Future<WarehouseDraft?> showWarehouseSheet(
  BuildContext context, {
  Warehouse? existing,
}) =>
    showModalBottomSheet<WarehouseDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _WarehouseSheet(existing: existing),
    );

/// Creates or edits a warehouse.
///
/// Every field here is a real column. The backend puts the request body
/// straight into its SQL without a whitelist, so an extra key would come back
/// as a 500 HTML page rather than a validation error — which is why this form
/// is the only thing that builds the payload.
class _WarehouseSheet extends StatefulWidget {
  const _WarehouseSheet({this.existing});

  final Warehouse? existing;

  @override
  State<_WarehouseSheet> createState() => _WarehouseSheetState();
}

class _WarehouseSheetState extends State<_WarehouseSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _city;
  late final TextEditingController _province;
  late final TextEditingController _postalCode;
  late String _status;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _address = TextEditingController(text: existing?.address ?? '');
    _city = TextEditingController(text: existing?.city ?? '');
    _province = TextEditingController(text: existing?.province ?? '');
    _postalCode = TextEditingController(text: existing?.postalCode ?? '');
    _status = existing?.status ?? WarehouseStatus.active;
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _city.dispose();
    _province.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      WarehouseDraft(
        name: _name.text.trim(),
        address: _address.text.trim(),
        city: _city.text.trim(),
        province: _province.text.trim(),
        postalCode: _postalCode.text.trim(),
        status: _isEditing ? _status : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              Text(
                _isEditing ? 'Ubah gudang' : 'Gudang baru',
                style: AppStyles.styleSemiBold18(context),
              ),
              if (!_isEditing) ...<Widget>[
                8.sbh,
                Text(
                  'Gudang pertama otomatis jadi gudang utama — itu keputusan '
                  'server, bukan pilihan di sini.',
                  style: AppStyles.styleRegular10(context)
                      .copyWith(color: kLightThirdColor),
                ),
              ],
              16.sbh,
              CustomTextFormField(
                controller: _name,
                labelText: 'Nama gudang',
                validator: Validators.required('Nama gudang'),
              ),
              16.sbh,
              CustomTextFormField(
                controller: _address,
                labelText: 'Alamat',
                maxLines: 2,
                validator: Validators.required('Alamat'),
              ),
              16.sbh,
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomTextFormField(
                      controller: _city,
                      labelText: 'Kota',
                      validator: Validators.required('Kota'),
                    ),
                  ),
                  12.sbw,
                  Expanded(
                    child: CustomTextFormField(
                      controller: _province,
                      labelText: 'Provinsi',
                      validator: Validators.required('Provinsi'),
                    ),
                  ),
                ],
              ),
              16.sbh,
              CustomTextFormField(
                controller: _postalCode,
                labelText: 'Kode pos',
                keyboardType: TextInputType.number,
                validator: Validators.required('Kode pos'),
              ),
              if (_isEditing) ...<Widget>[
                16.sbh,
                AppDropdownField<String>(
                  label: 'Status',
                  value: _status,
                  items: WarehouseStatus.all,
                  itemLabel: WarehouseStatus.label,
                  onChanged: (value) => setState(
                    () => _status = value ?? WarehouseStatus.active,
                  ),
                ),
              ],
              24.sbh,
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(_isEditing ? 'Simpan' : 'Tambah gudang'),
              ),
              12.sbh,
            ],
          ),
        ),
      ),
    );
  }
}
