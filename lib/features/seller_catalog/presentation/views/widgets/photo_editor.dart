import 'package:flutter/material.dart';

import '../../../../../core/domain/model/catalog/offer.dart';
import '../../../../../core/function/components.dart';
import '../../../../../core/utils/app_styles.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/extensions.dart';
import '../../../../../core/utils/image_measure.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/custom_text_form_field.dart';

/// Builds the `photos_json` list for an offer.
///
/// There is no upload endpoint anywhere in the API, so a photo is a URL the
/// store already hosts. Each entry has to carry its true pixel size — the
/// activation gate reads `width`/`height` and never opens the file — so this
/// measures every URL as it is added and refuses to guess.
class PhotoEditor extends StatefulWidget {
  const PhotoEditor({super.key, required this.photos, required this.onChanged});

  final List<OfferPhoto> photos;
  final ValueChanged<List<OfferPhoto>> onChanged;

  @override
  State<PhotoEditor> createState() => _PhotoEditorState();
}

class _PhotoEditorState extends State<PhotoEditor> {
  final TextEditingController _urlController = TextEditingController();
  bool _isMeasuring = false;
  String? _measureError;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      setState(() => _measureError = 'URL harus diawali http:// atau https://');
      return;
    }
    if (widget.photos.any((photo) => photo.url == url)) {
      setState(() => _measureError = 'Foto ini sudah ada di daftar.');
      return;
    }

    setState(() {
      _isMeasuring = true;
      _measureError = null;
    });

    final size = await measureNetworkImage(url);
    if (!mounted) return;

    if (size == null) {
      setState(() {
        _isMeasuring = false;
        _measureError = 'Ukuran foto tidak bisa dibaca. Biasanya server foto '
            'belum mengizinkan akses lintas domain (CORS). Pakai URL lain, '
            'atau isi ukurannya sendiri lewat tombol di bawah.';
      });
      return;
    }

    setState(() {
      _isMeasuring = false;
      _urlController.clear();
    });
    widget.onChanged(<OfferPhoto>[
      ...widget.photos,
      OfferPhoto(
        url: url,
        width: size.width.round(),
        height: size.height.round(),
      ),
    ]);
  }

  Future<void> _addManually() async {
    final url = _urlController.text.trim();
    final size = await showDialog<Size>(
      context: context,
      builder: (_) => _ManualSizeDialog(url: url),
    );
    if (size == null || !mounted) return;

    setState(() {
      _urlController.clear();
      _measureError = null;
    });
    widget.onChanged(<OfferPhoto>[
      ...widget.photos,
      OfferPhoto(
        url: url,
        width: size.width.round(),
        height: size.height.round(),
      ),
    ]);
  }

  void _remove(int index) {
    final next = <OfferPhoto>[...widget.photos]..removeAt(index);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    final tooFew = photos.length < OfferPhoto.minimumCount;
    final tooSmall = photos.where((photo) => !photo.meetsMinimum).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (photos.isNotEmpty) ...<Widget>[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              for (int i = 0; i < photos.length; i++)
                _PhotoThumb(photo: photos[i], onRemove: () => _remove(i)),
            ],
          ),
          12.sbh,
        ],
        CustomTextFormField(
          controller: _urlController,
          labelText: 'URL foto',
          hintText: 'https://cdn-toko.com/produk-1.jpg',
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          validator: Validators.optional,
          onSubmitted: (_) => _isMeasuring ? null : _add(),
        ),
        8.sbh,
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isMeasuring ? null : _add,
                icon: _isMeasuring
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: Text(_isMeasuring ? 'Mengukur…' : 'Tambah foto'),
              ),
            ),
            if (_measureError != null) ...<Widget>[
              8.sbw,
              OutlinedButton(
                onPressed: _addManually,
                child: const Text('Isi ukuran manual'),
              ),
            ],
          ],
        ),
        if (_measureError != null) ...<Widget>[
          8.sbh,
          Text(
            _measureError!,
            style: AppStyles.styleRegular10(context)
                .copyWith(color: kWarningColor),
          ),
        ],
        8.sbh,
        Text(
          tooFew || tooSmall > 0
              ? <String>[
                  if (tooFew)
                    'Kurang ${OfferPhoto.minimumCount - photos.length} foto '
                        'lagi (minimal ${OfferPhoto.minimumCount}).',
                  if (tooSmall > 0)
                    '$tooSmall foto di bawah '
                        '${OfferPhoto.minimumEdge}×${OfferPhoto.minimumEdge}.',
                ].join(' ')
              : '${photos.length} foto, semuanya memenuhi syarat.',
          style: AppStyles.styleRegular10(context).copyWith(
            color: tooFew || tooSmall > 0 ? kWarningColor : kSuccessColor,
          ),
        ),
        4.sbh,
        Text(
          'Tidak ada endpoint unggah foto — pakai URL yang sudah Anda hosting '
          'sendiri. Ukuran diambil dari file aslinya karena server memeriksa '
          'angkanya, bukan gambarnya.',
          style: AppStyles.styleRegular10(context)
              .copyWith(color: kLightThirdColor),
        ),
      ],
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.photo, required this.onRemove});

  final OfferPhoto photo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ok = photo.meetsMinimum;

    return SizedBox(
      width: 108,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 108,
                  height: 108,
                  color: kBorderColor,
                  child: Image.network(
                    photo.url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image_outlined,
                      color: kLightThirdColor,
                    ),
                  ),
                ),
              ),
              PositionedDirectional(
                top: 2,
                end: 2,
                child: InkWell(
                  onTap: onRemove,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: (isAppDarkMode() ? kDarkColor : kWhiteColor)
                          .withValues(alpha: .9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 14, color: kDeleteColor),
                  ),
                ),
              ),
            ],
          ),
          4.sbh,
          Text(
            '${photo.width}×${photo.height}',
            style: AppStyles.styleRegular10(context)
                .copyWith(color: ok ? kSuccessColor : kWarningColor),
          ),
        ],
      ),
    );
  }
}

/// Fallback for a photo host that blocks cross-origin reads, where the browser
/// will render the image but never let the app measure it.
class _ManualSizeDialog extends StatefulWidget {
  const _ManualSizeDialog({required this.url});

  final String url;

  @override
  State<_ManualSizeDialog> createState() => _ManualSizeDialogState();
}

class _ManualSizeDialogState extends State<_ManualSizeDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null || parsed <= 0) return 'Isi angka piksel';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ukuran foto'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Isi ukuran asli file, bukan perkiraan. Server memakai angka ini '
              'apa adanya, jadi angka yang salah membuat produk gagal tayang '
              'tanpa penjelasan.',
              style: AppStyles.styleRegular10(context)
                  .copyWith(color: kLightThirdColor),
            ),
            12.sbh,
            CustomTextFormField(
              controller: _widthController,
              labelText: 'Lebar (px)',
              keyboardType: TextInputType.number,
              validator: _validate,
            ),
            12.sbh,
            CustomTextFormField(
              controller: _heightController,
              labelText: 'Tinggi (px)',
              keyboardType: TextInputType.number,
              validator: _validate,
            ),
          ],
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
              Size(
                double.parse(_widthController.text.trim()),
                double.parse(_heightController.text.trim()),
              ),
            );
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
