import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/model/wallet/store_wallet.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/format_helper.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../cubits/wallet_cubit/wallet_cubit.dart';
import 'widgets/withdraw_sheet.dart';

/// The store's earnings, and the only way to get them out.
class WalletView extends StatelessWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WalletCubit>(
      create: (_) => WalletCubit()..load(),
      child: const _WalletBody(),
    );
  }
}

class _WalletBody extends StatelessWidget {
  const _WalletBody();

  Future<void> _withdraw(BuildContext context, StoreWallet wallet) async {
    final cubit = WalletCubit.get(context);
    final draft = await showWithdrawSheet(context, wallet: wallet);
    if (draft == null || !context.mounted) return;

    final error = await cubit.withdraw(
      amount: draft.amount,
      bankName: draft.bankName,
      bankAccountNumber: draft.bankAccountNumber,
      bankAccountName: draft.bankAccountName,
    );
    if (!context.mounted) return;
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }
    showSuccessSnackBar(
      context,
      'Pengajuan penarikan terkirim. Saldo sudah berkurang; '
      'pencairannya menunggu admin.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Dompet toko'),
      body: SafeArea(
        child: BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) => switch (state) {
            WalletInProgress() => const LoadingIndicatorView(),
            WalletNoStore() => const EmptyStateView(
                icon: Icons.storefront_outlined,
                message: 'Pilih toko dulu untuk melihat dompetnya.',
              ),
            WalletFailure(:final error) => ErrorStateView(
                error: error,
                onRetry: () => WalletCubit.get(context).load(),
              ),
            WalletLoaded() => _content(context, state),
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, WalletLoaded state) {
    final wallet = state.wallet;

    return RefreshIndicator(
      onRefresh: () => WalletCubit.get(context).load(),
      child: ListView(
        padding: 20.pa,
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _BalanceCard(
                    wallet: wallet,
                    isBusy: state.isBusy,
                    onWithdraw: () => _withdraw(context, wallet),
                  ),
                  if (wallet.isFrozen) ...<Widget>[12.sbh, const _FrozenNotice()],
                  16.sbh,
                  Text('Riwayat', style: AppStyles.styleMedium14(context)),
                  4.sbh,
                  Text(
                    state.isUntouched
                        ? 'Hasil penjualan masuk ke sini saat pesanan berstatus '
                            'selesai — bukan saat dikirim.'
                        : 'Server menyimpan 50 transaksi terakhir; yang lebih '
                            'lama tidak bisa ditarik lewat API.',
                    style: AppStyles.styleRegular10(context)
                        .copyWith(color: kLightThirdColor),
                  ),
                  12.sbh,
                  if (wallet.transactions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: EmptyStateView(
                        icon: Icons.account_balance_wallet_outlined,
                        message: 'Belum ada transaksi.',
                      ),
                    )
                  else
                    for (final transaction in wallet.transactions)
                      _TransactionRow(transaction: transaction),
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

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.wallet,
    required this.isBusy,
    required this.onWithdraw,
  });

  final StoreWallet wallet;
  final bool isBusy;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    // `held_balance` is deliberately not shown: no code on the backend ever
    // writes it, so a "pending" figure here would always read zero and imply
    // a mechanism that does not exist.
    return Container(
      padding: 20.pa,
      decoration: BoxDecoration(
        color: kLightPrimaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Saldo bisa ditarik',
            style: AppStyles.styleRegular12(context)
                .copyWith(color: kLightThirdColor),
          ),
          6.sbh,
          Text(
            formatRupiah(wallet.balance),
            style: AppStyles.styleSemiBold18(context),
          ),
          16.sbh,
          FilledButton(
            onPressed: isBusy || !wallet.canWithdraw ? null : onWithdraw,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Tarik dana'),
          ),
          if (!wallet.canWithdraw && !wallet.isFrozen) ...<Widget>[
            8.sbh,
            Text(
              'Penarikan bisa diajukan mulai '
              '${formatRupiah(StoreWallet.minimumWithdrawal)}.',
              style: AppStyles.styleRegular10(context)
                  .copyWith(color: kLightThirdColor),
            ),
          ],
        ],
      ),
    );
  }
}

class _FrozenNotice extends StatelessWidget {
  const _FrozenNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 16.pa,
      decoration: BoxDecoration(
        color: kErrorColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.lock_outline, size: 18, color: kErrorColor),
          8.sbw,
          Expanded(
            child: Text(
              'Dompet toko sedang dibekukan, jadi penarikan tidak bisa '
              'diajukan. API tidak menyertakan alasannya — hubungi admin '
              'marketplace.',
              style: AppStyles.styleRegular12(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  WalletTransactionType.label(transaction.type),
                  style: AppStyles.styleRegular14(context),
                ),
                2.sbh,
                Text(
                  <String>[
                    formatDateTime(transaction.createdAt),
                    if (transaction.isOrderRevenue)
                      'Pesanan #${transaction.referenceId}',
                  ].join(' · '),
                  style: AppStyles.styleRegular10(context)
                      .copyWith(color: kLightThirdColor),
                ),
              ],
            ),
          ),
          12.sbw,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              // The server stores every amount as a positive number and leaves
              // the direction to `type`, so the sign is put back here.
              Text(
                '${isCredit ? '+' : '−'}${formatRupiah(transaction.amount)}',
                style: AppStyles.styleMedium14(context)
                    .copyWith(color: isCredit ? kSuccessColor : kErrorColor),
              ),
              2.sbh,
              Text(
                'Saldo ${formatRupiah(transaction.balanceAfter)}',
                style: AppStyles.styleRegular10(context)
                    .copyWith(color: kLightThirdColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
