import 'package:flutter/material.dart';

import '../../../../../core/domain/model/wallet/store_wallet.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/extensions.dart';
import '../../../../../core/utils/format_helper.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/custom_text_form_field.dart';

class WithdrawDraft {
  const WithdrawDraft({
    required this.amount,
    required this.bankName,
    required this.bankAccountNumber,
    required this.bankAccountName,
  });

  final int amount;
  final String bankName;
  final String bankAccountNumber;
  final String bankAccountName;
}

Future<WithdrawDraft?> showWithdrawSheet(
  BuildContext context, {
  required StoreWallet wallet,
}) =>
    showModalBottomSheet<WithdrawDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _WithdrawSheet(wallet: wallet),
    );

/// Asks for a withdrawal.
///
/// The bank fields are required here because **the server does not validate
/// them**: it checks only the minimum and the balance, so with enough money a
/// missing bank name reaches a `NOT NULL` column and answers 500.
class _WithdrawSheet extends StatefulWidget {
  const _WithdrawSheet({required this.wallet});

  final StoreWallet wallet;

  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _bankName = TextEditingController();
  final TextEditingController _accountNumber = TextEditingController();
  final TextEditingController _accountName = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _bankName.dispose();
    _accountNumber.dispose();
    _accountName.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    final amount = parseRupiahInput(value);
    if (amount == null || amount == 0) return 'Jumlah wajib diisi';
    if (amount < StoreWallet.minimumWithdrawal) {
      return 'Minimum ${formatRupiah(StoreWallet.minimumWithdrawal)}';
    }
    if (amount > widget.wallet.balance) {
      return 'Melebihi saldo (${formatRupiah(widget.wallet.balance)})';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      WithdrawDraft(
        amount: parseRupiahInput(_amount.text) ?? 0,
        bankName: _bankName.text.trim(),
        bankAccountNumber: _accountNumber.text.trim(),
        bankAccountName: _accountName.text.trim(),
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
              Text('Tarik dana', style: AppStyles.styleSemiBold18(context)),
              4.sbh,
              Text(
                'Saldo ${formatRupiah(widget.wallet.balance)}. Saldo langsung '
                'berkurang saat pengajuan dikirim, bukan saat dana cair — '
                'pencairannya diproses admin marketplace.',
                style: AppStyles.styleRegular10(context)
                    .copyWith(color: kLightThirdColor),
              ),
              16.sbh,
              CustomTextFormField(
                controller: _amount,
                labelText: 'Jumlah (Rp)',
                keyboardType: TextInputType.number,
                validator: _validateAmount,
              ),
              20.sbh,
              Text('Rekening tujuan',
                  style: AppStyles.styleMedium14(context)),
              4.sbh,
              Text(
                'Server tidak memeriksa data rekening, jadi salah ketik di sini '
                'tidak akan ditolak — periksa sendiri sebelum mengirim.',
                style: AppStyles.styleRegular10(context)
                    .copyWith(color: kLightThirdColor),
              ),
              12.sbh,
              CustomTextFormField(
                controller: _bankName,
                labelText: 'Nama bank',
                validator: Validators.required('Nama bank'),
              ),
              16.sbh,
              CustomTextFormField(
                controller: _accountNumber,
                labelText: 'Nomor rekening',
                keyboardType: TextInputType.number,
                validator: Validators.accountNumber,
              ),
              16.sbh,
              CustomTextFormField(
                controller: _accountName,
                labelText: 'Nama pemilik rekening',
                validator: Validators.required('Nama pemilik rekening'),
              ),
              24.sbh,
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: const Text('Ajukan penarikan'),
              ),
              12.sbh,
            ],
          ),
        ),
      ),
    );
  }
}
