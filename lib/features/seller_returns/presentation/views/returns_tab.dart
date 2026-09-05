import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/model/dispute/dispute.dart';
import '../../../../core/domain/model/returns/return_model.dart';
import '../../../../core/function/components.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_dropdown_field.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../seller_home/presentation/views/widgets/section_card.dart';
import '../../../seller_orders/presentation/views/widgets/deadline_chip.dart';
import '../cubits/returns_cubit/returns_cubit.dart';

class ReturnsTab extends StatelessWidget {
  const ReturnsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReturnsCubit>(
      create: (_) => ReturnsCubit()..load(),
      child: const _ReturnsBody(),
    );
  }
}

class _ReturnsBody extends StatelessWidget {
  const _ReturnsBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text('Purna jual',
                    style: AppStyles.styleMedium18(context)),
              ),
              IconButton(
                tooltip: 'Muat ulang',
                color: isAppDarkMode() ? kDarkSecondColor : kLightSecondColor,
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => ReturnsCubit.get(context).load(),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ReturnsCubit, ReturnsState>(
            builder: (context, state) => switch (state) {
              ReturnsLoadInProgress() => const LoadingIndicatorView(),
              ReturnsLoadFailure(:final error) => ErrorStateView(
                  error: error,
                  onRetry: () => ReturnsCubit.get(context).load(),
                ),
              ReturnsLoadSuccess() => _Content(state: state),
            },
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state});

  final ReturnsLoadSuccess state;

  @override
  Widget build(BuildContext context) {
    if (state.returns.isEmpty && state.disputes.isEmpty) {
      return const EmptyStateView(
        icon: Icons.assignment_return_outlined,
        message: 'Belum ada retur atau sengketa.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ReturnsCubit.get(context).load(showSpinner: false),
      child: ListView(
        padding: 20.pa,
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (state.needsAction.isNotEmpty) ...<Widget>[
                    SectionCard(
                      accent: kErrorColor,
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.timer_outlined, color: kErrorColor),
                          12.sbw,
                          Expanded(
                            child: Text(
                              '${state.needsAction.length} retur menunggu Anda. '
                              'Tidak dijawab dalam 2×24 jam berarti retur '
                              'dianggap DITERIMA; tidak diperiksa berarti '
                              'barang dianggap SESUAI dan dana dikembalikan.',
                              style: AppStyles.styleMedium12(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    12.sbh,
                  ],
                  if (state.returns.isNotEmpty) ...<Widget>[
                    Text('Retur', style: AppStyles.styleSemiBold16(context)),
                    8.sbh,
                    ...state.returns.map(
                      (entry) => _ReturnCard(
                        entry: entry,
                        isBusy: state.busyReturnId == entry.id,
                      ),
                    ),
                  ],
                  if (state.disputes.isNotEmpty) ...<Widget>[
                    12.sbh,
                    Text('Sengketa', style: AppStyles.styleSemiBold16(context)),
                    8.sbh,
                    ...state.disputes.map(
                      (dispute) => _DisputeCard(dispute: dispute),
                    ),
                  ],
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

class _ReturnCard extends StatelessWidget {
  const _ReturnCard({required this.entry, required this.isBusy});

  final ReturnModel entry;
  final bool isBusy;

  Future<void> _respond(BuildContext context, String decision) async {
    final options = await showDialog<_RespondChoice>(
      context: context,
      builder: (_) => _RespondDialog(decision: decision),
    );
    if (options == null || !context.mounted) return;

    final error = await ReturnsCubit.get(context).respond(
      entry.id,
      decision: decision,
      refundRoute: options.refundRoute,
      fault: options.fault,
    );
    if (!context.mounted) return;
    if (error != null) return showErrorSnackBar(context, error);
    showSuccessSnackBar(
      context,
      decision == ReturnDecision.approve ? 'Retur disetujui.' : 'Retur ditolak.',
    );
  }

  Future<void> _inspect(BuildContext context, String result) async {
    final (error, disputeId) =
        await ReturnsCubit.get(context).inspect(entry.id, result: result);
    if (!context.mounted) return;
    if (error != null) return showErrorSnackBar(context, error);

    showSuccessSnackBar(
      context,
      disputeId == null
          ? 'Pemeriksaan tersimpan. Refund diproses.'
          : 'Beda kondisi dicatat. Sengketa #$disputeId dibuka — '
              'unggah foto pengemasan sebagai bukti.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final deadline = entry.activeDeadline;

    return SectionCard(
      title: '${entry.returnNo ?? 'Retur #${entry.id}'}'
          '${entry.shipmentId == null ? '' : ' · pengiriman ${entry.shipmentId}'}',
      trailing: Text(
        ReturnStatus.label(entry.status),
        style: AppStyles.styleMedium12(context).copyWith(
          color: entry.awaitingResponse ? kErrorColor : kLightThirdColor,
        ),
      ),
      accent: entry.awaitingResponse ? kErrorColor : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (entry.reason != null)
            StatRow(label: 'Alasan', value: entry.reason!),
          if (entry.qtyReturned > 0)
            StatRow(
              label: 'Jumlah diretur',
              value: entry.qtyReturned.round().toString(),
            ),
          if (entry.returnCourierType != null)
            StatRow(
              label: 'Rute barang',
              value: entry.needsPickup
                  ? 'Dijemput toko'
                  : entry.returnCourierType!,
            ),
          if (entry.evidencePhotos.isNotEmpty)
            StatRow(
              label: 'Foto bukti pembeli',
              value: '${entry.evidencePhotos.length} foto',
            ),
          if (deadline != null) ...<Widget>[
            12.sbh,
            DeadlineChip(
              deadline: deadline,
              label: entry.awaitingResponse ? 'Batas jawab' : 'Batas periksa',
              consequence: entry.awaitingResponse
                  ? 'diam = retur diterima'
                  : 'diam = barang dianggap sesuai',
            ),
          ],
          if (entry.needsPickup && entry.pickupDeadline != null) ...<Widget>[
            8.sbh,
            DeadlineChip(
              deadline: entry.pickupDeadline!,
              label: 'Batas jemput barang',
              consequence: 'lewat = barang jadi milik pembeli',
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                if (entry.awaitingResponse) ...<Widget>[
                  _Btn(
                    label: 'Setujui retur',
                    onPressed: () =>
                        _respond(context, ReturnDecision.approve),
                  ),
                  _Btn(
                    label: 'Tolak retur',
                    color: kErrorColor,
                    onPressed: () => _respond(context, ReturnDecision.reject),
                  ),
                ],
                if (entry.awaitingInspection) ...<Widget>[
                  _Btn(
                    label: 'Barang sesuai',
                    onPressed: () => _inspect(context, InspectResult.sesuai),
                  ),
                  _Btn(
                    label: 'Beda kondisi',
                    color: kWarningColor,
                    onPressed: () =>
                        _inspect(context, InspectResult.bedaKondisi),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _DisputeCard extends StatelessWidget {
  const _DisputeCard({required this.dispute});

  final Dispute dispute;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Sengketa #${dispute.id}',
      trailing: Text(
        dispute.status ?? '-',
        style: AppStyles.styleMedium12(context)
            .copyWith(color: kLightThirdColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (dispute.decision != null)
            StatRow(
              label: 'Keputusan',
              value: DisputeDecision.label(dispute.decision),
            ),
          if (dispute.decisionReason != null) ...<Widget>[
            4.sbh,
            Text(
              dispute.decisionReason!,
              style: AppStyles.styleRegular12(context)
                  .copyWith(color: kLightThirdColor),
            ),
          ],
          if (dispute.deadlineBukti != null) ...<Widget>[
            12.sbh,
            DeadlineChip(
              deadline: dispute.deadlineBukti!,
              label: 'Batas serah bukti',
              consequence: 'lewat = diputus dengan bukti yang ada',
            ),
          ],
          8.sbh,
          Text(
            'Bukti hanya bisa ditambah, tidak bisa dihapus — termasuk oleh '
            'admin. Foto pengemasan adalah pelindung utama toko di sengketa.',
            style: AppStyles.styleRegular10(context)
                .copyWith(color: kLightThirdColor),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.label, required this.onPressed, this.color});

  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent =
        color ?? (isAppDarkMode() ? kDarkPrimaryColor : kLightPrimaryColor);
    return CustomButton(
      width: 160,
      height: 40,
      elevation: 0,
      backColor: accent,
      borderRadius: BorderRadius.circular(12),
      onPressed: onPressed,
      child: Text(
        label,
        style: AppStyles.styleMedium12(context).copyWith(color: kWhiteColor),
      ),
    );
  }
}

class _RespondChoice {
  const _RespondChoice({this.refundRoute, this.fault});

  final String? refundRoute;
  final String? fault;
}

class _RespondDialog extends StatefulWidget {
  const _RespondDialog({required this.decision});

  final String decision;

  @override
  State<_RespondDialog> createState() => _RespondDialogState();
}

class _RespondDialogState extends State<_RespondDialog> {
  String? _refundRoute;
  String? _fault;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: isAppDarkMode() ? kDarkColor : kWhiteColor,
      title: Text(
        ReturnDecision.label(widget.decision),
        style: AppStyles.styleSemiBold16(context),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Biarkan rute kosong agar server yang memilih. Bila ongkos kirim '
            'balik melebihi nilai barang, server memilih refund tanpa barang '
            'kembali — dan itu biasanya keputusan yang benar.',
            style: AppStyles.styleRegular12(context)
                .copyWith(color: kLightThirdColor),
          ),
          16.sbh,
          AppDropdownField<String>(
            label: 'Rute refund (opsional)',
            hint: 'Ditentukan sistem',
            value: _refundRoute,
            items: RefundRoute.all,
            itemLabel: RefundRoute.label,
            onChanged: (value) => setState(() => _refundRoute = value),
          ),
          16.sbh,
          AppDropdownField<String>(
            label: 'Pihak yang salah (opsional)',
            hint: 'Tidak ditentukan',
            value: _fault,
            items: FaultParty.all,
            itemLabel: FaultParty.label,
            onChanged: (value) => setState(() => _fault = value),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            _RespondChoice(refundRoute: _refundRoute, fault: _fault),
          ),
          child: const Text('Kirim'),
        ),
      ],
    );
  }
}
