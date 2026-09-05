/// Display formatting.
///
/// Deliberately not built on `intl`'s locale-aware formatters: those need
/// locale data to be loaded, and a missing `id_ID` dataset throws at runtime on
/// web. The rules here are small and fixed, so they are spelled out instead.
library;

const List<String> _monthAbbreviations = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// `750000` -> `Rp 750.000`.
///
/// Amounts are whole rupiah — the backend rounds half-up and there are no cents
/// anywhere in this API (doc 1.7).
String formatRupiah(num? value) {
  if (value == null) return '-';
  return 'Rp ${formatThousands(value.round())}';
}

String formatThousands(int value) {
  final isNegative = value < 0;
  final digits = value.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }

  return isNegative ? '-${buffer.toString()}' : buffer.toString();
}

/// `2026-09-05 09:39:13` -> `5 Sep 2026`.
String formatDate(DateTime? value) {
  if (value == null) return '-';
  return '${value.day} ${_monthAbbreviations[value.month - 1]} ${value.year}';
}

/// `2026-09-05 09:39:13` -> `5 Sep 2026, 09:39`.
///
/// Rendered as-is. These are server wall-clock timestamps with no timezone, so
/// converting them would silently shift every deadline shown to the store.
String formatDateTime(DateTime? value) {
  if (value == null) return '-';
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '${formatDate(value)}, $hour:$minute';
}

/// Parses a user-typed rupiah amount, tolerating `750.000`, `750,000`,
/// `Rp 750000` and stray spaces.
int? parseRupiahInput(String? input) {
  if (input == null) return null;
  final digitsOnly = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.isEmpty) return null;
  return int.tryParse(digitsOnly);
}
