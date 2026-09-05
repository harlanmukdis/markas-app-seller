import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/format_helper.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../cubits/onboarding_cubit/onboarding_cubit.dart';

/// Gate 4. Self-serve, and the one with legal weight: every penalty, balance
/// deduction and fund freeze in this platform only has a basis once this is
/// signed (USR-11). So the terms are laid out and the confirm button stays
/// disabled until the store ticks the acknowledgement.
class AgreementView extends StatelessWidget {
  const AgreementView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingCubit>(
      create: (_) => OnboardingCubit()..load(),
      child: const _AgreementBody(),
    );
  }
}

class _AgreementBody extends StatefulWidget {
  const _AgreementBody();

  @override
  State<_AgreementBody> createState() => _AgreementBodyState();
}

class _AgreementBodyState extends State<_AgreementBody> {
  bool _acknowledged = false;

  Future<void> _sign() async {
    final error = await OnboardingCubit.get(context).signAgreement();
    if (!mounted) return;

    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }

    showSuccessSnackBar(context, 'Perjanjian kerja sama ditandatangani.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Perjanjian Kerja Sama'),
      body: SafeArea(
        child: BlocBuilder<OnboardingCubit, OnboardingState>(
          builder: (context, state) {
            return switch (state) {
              OnboardingLoadInProgress() => const LoadingIndicatorView(),
              OnboardingLoadFailure(:final error) => ErrorStateView(
                  error: error,
                  onRetry: () => OnboardingCubit.get(context).load(),
                ),
              OnboardingLoadSuccess() => _content(context, state),
            };
          },
        ),
      ),
    );
  }

  Widget _content(BuildContext context, OnboardingLoadSuccess state) {
    final signedAt = state.seller.agreementSignedAt;
    final isSigned = state.gates.agreementSigned;

    return SingleChildScrollView(
      padding: 20.pa,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (isSigned) ...<Widget>[
                Container(
                  padding: 16.pa,
                  decoration: BoxDecoration(
                    color: kSuccessColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.verified_user_rounded,
                          color: kSuccessColor),
                      12.sbw,
                      Expanded(
                        child: Text(
                          'Sudah ditandatangani ${formatDateTime(signedAt)}.',
                          style: AppStyles.styleMedium14(context),
                        ),
                      ),
                    ],
                  ),
                ),
                20.sbh,
              ],
              const _SourceOfTruthNotice(),
              20.sbh,
              Text('Isi pokok perjanjian',
                  style: AppStyles.styleSemiBold16(context)),
              12.sbh,
              ..._terms.map((term) => _TermRow(term: term)),
              24.sbh,
              if (!isSigned) ...<Widget>[
                CheckboxListTile(
                  value: _acknowledged,
                  onChanged: (value) =>
                      setState(() => _acknowledged = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Saya telah membaca dan menyetujui seluruh ketentuan di '
                    'atas.',
                    style: AppStyles.styleRegular14(context),
                  ),
                ),
                16.sbh,
                CustomButton(
                  onPressed: (!_acknowledged || state.isBusy) ? null : _sign,
                  backColor: (!_acknowledged || state.isBusy)
                      ? kLightThirdColor
                      : null,
                  child: state.isBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kWhiteColor,
                          ),
                        )
                      : const Text('Tanda tangani perjanjian'),
                ),
              ],
              24.sbh,
            ],
          ),
        ),
      ),
    );
  }
}

/// The backend exposes no endpoint that serves the agreement text, so what is
/// rendered below is assembled from the documented platform rules. Saying so is
/// the honest thing to do on a screen that carries a signature.
class _SourceOfTruthNotice extends StatelessWidget {
  const _SourceOfTruthNotice();

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
          const Icon(Icons.gavel_rounded, size: 18, color: kWarningColor),
          8.sbw,
          Expanded(
            child: Text(
              'Ringkasan ketentuan platform di bawah disusun dari aturan '
              'operasional. Naskah perjanjian resmi belum disediakan lewat API '
              '— sebelum rilis, teks final harus dimuat dari backend.',
              style: AppStyles.styleRegular12(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _Term {
  const _Term(this.title, this.body);

  final String title;
  final String body;
}

const List<_Term> _terms = <_Term>[
  _Term(
    'Semua biaya dideklarasikan di muka',
    'Setiap komponen biaya wajib muncul sebelum pembeli membayar. Biaya yang '
        'tidak dideklarasikan di sistem dilarang ditagih di lokasi; '
        'pelanggaran ditanggung toko dan menurunkan skor.',
  ),
  _Term(
    'Batas waktu konfirmasi pesanan',
    'Pesanan wajib dikonfirmasi dalam 1×24 jam kerja. Lewat batas, pesanan '
        'dibatalkan otomatis, dana pembeli dikembalikan, dan skor toko '
        'berkurang 3.',
  ),
  _Term(
    'Batas waktu serah ke armada',
    'Barang wajib diserahkan ke armada dalam 4×24 jam kerja (peringatan pada '
        '2×24 jam). Lewat batas, pesanan dibatalkan otomatis dan skor toko '
        'berkurang 3.',
  ),
  _Term(
    'Pembatalan oleh toko',
    'Menolak pesanan hanya dengan alasan dari daftar tertutup, dan menurunkan '
        'skor toko sebesar 2. Barang custom yang sudah dikonfirmasi tidak bisa '
        'dibatalkan.',
  ),
  _Term(
    'Retur: diam berarti menerima',
    'Pengajuan retur wajib dijawab dalam 2×24 jam; lewat batas retur dianggap '
        'disetujui. Pemeriksaan barang retur juga 2×24 jam; lewat batas barang '
        'dianggap sesuai dan dana dikembalikan ke pembeli.',
  ),
  _Term(
    'Penjemputan barang retur',
    'Bila rute retur adalah penjemputan oleh toko, batasnya 3×24 jam. Lewat '
        'batas, retur dianggap sah, dana dikembalikan, dan barang menjadi milik '
        'pembeli.',
  ),
  _Term(
    'Pencairan dana',
    'Dana cair per pengiriman, bukan per pesanan, setelah masa tahan T+3 '
        '(T+7 untuk barang pecah-belah). Toko baru dikenakan masa tahan lebih '
        'lama. Ongkir sepenuhnya milik toko tanpa potongan platform.',
  ),
  _Term(
    'Potongan dari pencairan',
    'Komisi kategori, PPh 22 sebesar 0,5% (kecuali toko dikecualikan), dan '
        'beban voucher toko dipotong dari nilai bruto setiap pengiriman. '
        'Rincian tiap komponen ditampilkan pada detail pencairan.',
  ),
  _Term(
    'Sengketa',
    'Bukti hanya dapat ditambahkan dan tidak dapat dihapus, termasuk oleh '
        'admin. Batas penyerahan bukti 2×24 jam. Keputusan CS bersifat final '
        'di dalam platform dan dieksekusi lewat saldo toko.',
  ),
  _Term(
    'Pembekuan dana',
    'Sengketa yang terbuka membekukan pencairan pengiriman terkait saja, '
        'maksimal 30 hari. Pengiriman lain tetap cair seperti biasa.',
  ),
];

class _TermRow extends StatelessWidget {
  const _TermRow({required this.term});

  final _Term term;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(term.title, style: AppStyles.styleSemiBold14(context)),
          6.sbh,
          Text(
            term.body,
            style: AppStyles.styleRegular12(context)
                .copyWith(color: kLightThirdColor, height: 1.5),
          ),
        ],
      ),
    );
  }
}
