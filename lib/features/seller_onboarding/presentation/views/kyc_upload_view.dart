import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/model/enums.dart';
import '../../../../core/function/components.dart';
import '../../../../core/function/custom_app_bar.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/utils/constant.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_buttons.dart';
import '../../../../core/widgets/custom_text_form_field.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../cubits/kyc_cubit/kyc_cubit.dart';
import 'widgets/gate_tile.dart';

/// Gate 1. The store submits documents; an admin approves them.
class KycUploadView extends StatelessWidget {
  const KycUploadView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<KycCubit>(
      create: (_) => KycCubit(),
      child: const _KycUploadBody(),
    );
  }
}

class _KycUploadBody extends StatefulWidget {
  const _KycUploadBody();

  @override
  State<_KycUploadBody> createState() => _KycUploadBodyState();
}

class _KycUploadBodyState extends State<_KycUploadBody> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _urlController = TextEditingController();
  String _docType = KycDocType.ktp;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await KycCubit.get(context).upload(
      docType: _docType,
      fileUrl: _urlController.text.trim(),
    );

    if (!mounted) return;

    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }

    _urlController.clear();
    showSuccessSnackBar(
      context,
      '${KycDocType.label(_docType)} terkirim, menunggu tinjauan admin.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, 'Dokumen KYC'),
      body: SafeArea(
        child: BlocBuilder<KycCubit, KycState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: 20.pa,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const _NoUploadEndpointNotice(),
                        20.sbh,
                        Text(
                          'Dokumen yang biasanya dibutuhkan',
                          style: AppStyles.styleSemiBold16(context),
                        ),
                        4.sbh,
                        Text(
                          'KTP, NPWP, NIB atau SIUP, dan buku rekening. '
                          'Dokumen pertama memindahkan toko dari DRAFT ke '
                          'PENDING_KYC.',
                          style: AppStyles.styleRegular12(context)
                              .copyWith(color: kLightThirdColor),
                        ),
                        12.sbh,
                        ...KycDocType.requiredForGate.map(
                          (docType) => _RequiredDocRow(
                            docType: docType,
                            isSubmitted: state.isSubmitted(docType),
                          ),
                        ),
                        24.sbh,
                        Text('Kirim dokumen',
                            style: AppStyles.styleSemiBold16(context)),
                        16.sbh,
                        Text('Jenis dokumen',
                            style: AppStyles.styleMedium14(context)),
                        8.sbh,
                        DropdownButtonFormField<String>(
                          initialValue: _docType,
                          decoration: _dropdownDecoration(),
                          items: KycDocType.all
                              .map(
                                (type) => DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(KycDocType.label(type)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(
                            () => _docType = value ?? KycDocType.ktp,
                          ),
                        ),
                        16.sbh,
                        Text('URL berkas',
                            style: AppStyles.styleMedium14(context)),
                        8.sbh,
                        CustomTextFormField(
                          controller: _urlController,
                          hintText: 'https://storage.contoh/ktp.jpg',
                          keyboardType: TextInputType.url,
                          filled: true,
                          validator: Validators.fileUrl,
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
                              : const Text('Kirim dokumen'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration() => InputDecoration(
        filled: true,
        fillColor:
            isAppDarkMode() ? kLightSecondColor : const Color(0xffF4F6F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      );
}

/// The single most surprising thing about this API for anyone building the
/// upload screen, so it is stated at the top rather than in a tooltip.
class _NoUploadEndpointNotice extends StatelessWidget {
  const _NoUploadEndpointNotice();

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
          const Icon(Icons.cloud_off_outlined,
              size: 18, color: kWarningColor),
          8.sbw,
          Expanded(
            child: Text(
              'Backend tidak menerima berkas — hanya URL. Unggah foto ke '
              'storage Anda sendiri lebih dulu, lalu tempel tautannya di sini.',
              style: AppStyles.styleRegular12(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequiredDocRow extends StatelessWidget {
  const _RequiredDocRow({required this.docType, required this.isSubmitted});

  final String docType;
  final bool isSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Icon(
            isSubmitted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: isSubmitted ? kSuccessColor : kLightThirdColor,
          ),
          8.sbw,
          Expanded(
            child: Text(
              KycDocType.label(docType),
              style: AppStyles.styleMedium14(context),
            ),
          ),
          if (isSubmitted)
            // "Terkirim" and not "Disetujui": this is a local note that this
            // device sent the document. Approval lives on the gate, and the API
            // has no endpoint to read document status back.
            const StatusBadge(label: 'Terkirim', color: kSuccessColor),
        ],
      ),
    );
  }
}
