import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/model/enums.dart';
import '../../../../core/domain/model/seller/bank_account.dart';
import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../cubits/bank_account_cubit/bank_account_cubit.dart';
import 'widgets/gate_tile.dart';

/// Gate 2. The store adds an account; Admin Finance verifies it.
class BankAccountView extends StatelessWidget {
  const BankAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BankAccountCubit>(
      create: (_) => BankAccountCubit()..load(),
      child: const _BankAccountBody(),
    );
  }
}

class _BankAccountBody extends StatefulWidget {
  const _BankAccountBody();

  @override
  State<_BankAccountBody> createState() => _BankAccountBodyState();
}

class _BankAccountBodyState extends State<_BankAccountBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNoController = TextEditingController();
  final TextEditingController _accountHolderController =
      TextEditingController();

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNoController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await BankAccountCubit.get(context).add(
      bankName: _bankNameController.text.trim(),
      accountNo: _accountNoController.text.trim(),
      accountHolder: _accountHolderController.text.trim(),
    );

    if (!mounted) return;

    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }

    _formKey.currentState!.reset();
    _bankNameController.clear();
    _accountNoController.clear();
    _accountHolderController.clear();
    showSuccessSnackBar(
      context,
      'Rekening ditambahkan, menunggu verifikasi Admin Finance.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Rekening Pencairan'),
      body: SafeArea(
        child: BlocBuilder<BankAccountCubit, BankAccountState>(
          builder: (context, state) {
            return switch (state) {
              BankAccountLoadInProgress() => const LoadingIndicatorView(),
              BankAccountLoadFailure(:final error) => ErrorStateView(
                  error: error,
                  onRetry: () => BankAccountCubit.get(context).load(),
                ),
              BankAccountLoadSuccess() => _content(context, state),
            };
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, BankAccountLoadSuccess state) {
    return SingleChildScrollView(
      padding: 20.pa,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _GateOrderNotice(),
              20.sbh,
              Text('Rekening terdaftar',
                  style: AppStyles.styleSemiBold16(context)),
              12.sbh,
              if (state.accounts.isEmpty)
                Text(
                  'Belum ada rekening.',
                  style: AppStyles.styleRegular12(context)
                      .copyWith(color: kLightThirdColor),
                )
              else
                ...state.accounts.map(
                  (account) => _BankAccountRow(account: account),
                ),
              28.sbh,
              Text('Tambah rekening',
                  style: AppStyles.styleSemiBold16(context)),
              16.sbh,
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('Nama bank',
                        style: AppStyles.styleMedium14(context)),
                    8.sbh,
                    CustomTextFormField(
                      controller: _bankNameController,
                      hintText: 'BCA',
                      filled: true,
                      validator: Validators.required('Nama bank'),
                    ),
                    16.sbh,
                    Text('Nomor rekening',
                        style: AppStyles.styleMedium14(context)),
                    8.sbh,
                    CustomTextFormField(
                      controller: _accountNoController,
                      hintText: '1234567890',
                      keyboardType: TextInputType.number,
                      filled: true,
                      validator: Validators.accountNumber,
                    ),
                    16.sbh,
                    Text('Atas nama',
                        style: AppStyles.styleMedium14(context)),
                    8.sbh,
                    CustomTextFormField(
                      controller: _accountHolderController,
                      hintText: 'PT Toko Jaya',
                      textInputAction: TextInputAction.done,
                      filled: true,
                      validator: Validators.required('Nama pemilik rekening'),
                      onSubmitted: (_) => _submit(),
                    ),
                    24.sbh,
                    CustomButton(
                      onPressed: state.isBusy ? null : _submit,
                      child: state.isBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: kWhiteColor,
                              ),
                            )
                          : const Text('Tambah rekening'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gate 2 has an ordering dependency that produces a genuinely confusing
/// outcome — verified account, gate still shut — so it is called out here.
class _GateOrderNotice extends StatelessWidget {
  const _GateOrderNotice();

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
          const Icon(Icons.rule_rounded, size: 18, color: kWarningColor),
          8.sbw,
          Expanded(
            child: Text(
              'Gerbang rekening baru terbuka jika KYC sudah disetujui lebih '
              'dulu. Jika rekening diverifikasi sebelum KYC lolos, gerbang '
              'tetap tertutup sampai ada aksi lain yang memicu pengecekan '
              'ulang.',
              style: AppStyles.styleRegular12(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankAccountRow extends StatelessWidget {
  const _BankAccountRow({required this.account});

  final BankAccount account;

  @override
  Widget build(BuildContext context) {
    final isDark = isAppDarkMode();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: 16.pa,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : kBorderColor),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(account.bankName,
                    style: AppStyles.styleSemiBold14(context)),
                4.sbh,
                Text(
                  '${account.maskedAccountNo} • ${account.accountHolder}',
                  style: AppStyles.styleRegular12(context)
                      .copyWith(color: kLightThirdColor),
                ),
              ],
            ),
          ),
          StatusBadge(
            label: DocStatus.label(account.status),
            color: account.isVerified ? kSuccessColor : kWarningColor,
          ),
        ],
      ),
    );
  }
}
