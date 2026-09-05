import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/model/finance/finance.dart';
import '../../../../core/domain/model/seller/bank_account.dart';
import '../../../../core/function/components.dart';
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
import '../cubits/finance_cubit/finance_cubit.dart';

class FinanceTab extends StatelessWidget {
  const FinanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinanceCubit>(
      create: (_) => FinanceCubit()..load(),
      child: const _FinanceBody(),
    );
  }
}

class _FinanceBody extends StatelessWidget {
  const _FinanceBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
          child: Row(
            children: <Widget>[
              Expanded(
                child:
                    Text('Keuangan', style: AppStyles.styleMedium18(context)),
              ),
              IconButton(
                tooltip: 'Muat ulang',
                color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => FinanceCubit.get(context).load(),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<FinanceCubit, FinanceState>(
            builder: (context, state) => switch (state) {
              FinanceLoadInProgress() => const LoadingIndicatorView(),
              FinanceLoadFailure(:final error) => ErrorStateView(
                  error: error,
                  onRetry: () => FinanceCubit.get(context).load(),
                ),
              FinanceLoadSuccess() => _FinanceContent(state: state),
            },
          ),
        ),
      ],
    );
  }
}

class _FinanceContent extends StatefulWidget {
  const _FinanceContent({required this.state});

  final FinanceLoadSuccess state;

  @override
  State<_FinanceContent> createState() => _FinanceContentState();
}

class _FinanceContentState extends State<_FinanceContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  BankAccount? _selectedAccount;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _withdraw() async {
    if (!_formKey.currentState!.validate()) return;

    final account = _selectedAccount ??
        (widget.state.verifiedAccounts.isEmpty
            ? null
            : widget.state.verifiedAccounts.first);
    if (account == null) return;

    final error = await FinanceCubit.get(context).withdraw(
      amount: parseRupiahInput(_amountController.text) ?? 0,
      bankAccountId: account.id,
    );

    if (!mounted) return;
    if (error != null) return showErrorSnackBar(context, error);

    _amountController.clear();
    showSuccessSnackBar(
      context,
      'Penarikan diajukan. Menunggu diproses Admin Finance.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return RefreshIndicator(
      onRefresh: () => FinanceCubit.get(context).load(showSpinner: false),
      child: ListView(
        padding: 20.pa,
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SectionCard(
                    title: 'Saldo',
                    child: Column(
                      children: <Widget>[
                        StatRow(
                          label: 'Bisa ditarik',
                          value: formatRupiah(state.balance.available),
                          emphasis: true,
                          valueColor: kSuccessColor,
                        ),
                        StatRow(
                          label: 'Masih ditahan',
                          value: formatRupiah(state.balance.held),
                          valueColor: kWarningColor,
                        ),
                        4.sbh,
                        Text(
                          'Dana ditahan T+3 (T+7 untuk pecah-belah), lebih lama '
                          'untuk toko baru, dan dibekukan per pengiriman bila '
                          'ada sengketa.',
                          style: AppStyles.styleRegular10(context)
                              .copyWith(color: kLightThirdColor),
                        ),
                      ],
                    ),
                  ),
                  12.sbh,
                  _WithdrawCard(
                    state: state,
                    formKey: _formKey,
                    amountController: _amountController,
                    selectedAccount: _selectedAccount,
                    onAccountChanged: (account) =>
                        setState(() => _selectedAccount = account),
                    onSubmit: _withdraw,
                  ),
                  12.sbh,
                  SectionCard(
                    title: 'Mutasi saldo',
                    child: state.ledger.isEmpty
                        ? Text(
                            'Belum ada mutasi.',
                            style: AppStyles.styleRegular12(context)
                                .copyWith(color: kLightThirdColor),
                          )
                        : Column(
                            children: state.ledger
                                .map((entry) => _LedgerRow(entry: entry))
                                .toList(),
                          ),
                  ),
                  24.sbh,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WithdrawCard extends StatelessWidget {
  const _WithdrawCard({
    required this.state,
    required this.formKey,
    required this.amountController,
    required this.selectedAccount,
    required this.onAccountChanged,
    required this.onSubmit,
  });

  final FinanceLoadSuccess state;
  final GlobalKey<FormState> formKey;
  final TextEditingController amountController;
  final BankAccount? selectedAccount;
  final ValueChanged<BankAccount?> onAccountChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final accounts = state.verifiedAccounts;

    if (accounts.isEmpty) {
      return SectionCard(
        title: 'Tarik dana',
        accent: kWarningColor,
        child: Text(
          'Belum ada rekening berstatus VERIFIED. Penarikan ke rekening yang '
          'belum diverifikasi ditolak server dengan 409.',
          style: AppStyles.styleRegular12(context),
        ),
      );
    }

    return SectionCard(
      title: 'Tarik dana',
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDropdownField<BankAccount>(
              label: 'Rekening tujuan',
              value: selectedAccount ?? accounts.first,
              items: accounts,
              itemLabel: (account) =>
                  '${account.bankName} · ${account.maskedAccountNo}',
              onChanged: onAccountChanged,
            ),
            16.sbh,
            Text('Jumlah', style: AppStyles.styleMedium14(context)),
            8.sbh,
            CustomTextFormField(
              controller: amountController,
              hintText: '5000000',
              keyboardType: TextInputType.number,
              filled: true,
              validator: (value) {
                final base = Validators.positiveAmount('Jumlah')(value);
                if (base != null) return base;

                final amount = parseRupiahInput(value) ?? 0;
                if (amount > state.balance.available) {
                  return 'Melebihi saldo tersedia '
                      '(${formatRupiah(state.balance.available)})';
                }
                final minimum = state.minimumWithdrawal;
                if (minimum != null && amount < minimum) {
                  return 'Minimum penarikan ${formatRupiah(minimum)}';
                }
                return null;
              },
            ),
            if (state.minimumWithdrawal != null) ...<Widget>[
              4.sbh,
              Text(
                'Minimum ${formatRupiah(state.minimumWithdrawal)} '
                '(dari parameter platform).',
                style: AppStyles.styleRegular10(context)
                    .copyWith(color: kLightThirdColor),
              ),
            ],
            16.sbh,
            CustomButton(
              height: 44,
              elevation: 0,
              borderRadius: BorderRadius.circular(12),
              onPressed: state.isBusy ? null : onSubmit,
              child: state.isBusy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: kWhiteColor,
                      ),
                    )
                  : const Text('Ajukan penarikan'),
            ),
            8.sbh,
            Text(
              'Penarikan butuh persetujuan Admin Finance — statusnya '
              '"menunggu diproses", bukan langsung cair.',
              style: AppStyles.styleRegular10(context)
                  .copyWith(color: kLightThirdColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  entry.entryType ?? 'Mutasi',
                  style: AppStyles.styleMedium12(context),
                ),
                if (entry.note != null)
                  Text(
                    entry.note!,
                    style: AppStyles.styleRegular10(context)
                        .copyWith(color: kLightThirdColor),
                  ),
                Text(
                  formatDateTime(entry.createdAt),
                  style: AppStyles.styleRegular10(context)
                      .copyWith(color: kLightThirdColor),
                ),
              ],
            ),
          ),
          8.sbw,
          Text(
            '${entry.isCredit ? '+' : ''}${formatRupiah(entry.amount)}',
            style: AppStyles.styleSemiBold12(context).copyWith(
              color: entry.isCredit ? kSuccessColor : kErrorColor,
            ),
          ),
        ],
      ),
    );
  }
}
