/// Form validators shared across the seller screens.
///
/// These enforce client-side what the backend enforces server-side, so a store
/// finds out about a bad field while typing rather than through a 422.
abstract class Validators {
  static String? Function(String?) required(String label) => (value) {
        if ((value ?? '').trim().isEmpty) return '$label wajib diisi';
        return null;
      };

  static String? phone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Nomor HP wajib diisi';
    if (!RegExp(r'^[0-9+]{8,20}$').hasMatch(trimmed)) {
      return 'Nomor HP hanya boleh berisi angka';
    }
    return null;
  }

  static String? password(String? value) {
    if ((value ?? '').isEmpty) return 'Kata sandi wajib diisi';
    if (value!.length < 6) return 'Kata sandi minimal 6 karakter';
    return null;
  }

  /// Optional field — empty passes.
  static String? optionalEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  /// This API stores document and photo **URLs**; it never receives files
  /// (API doc 8). So the field being validated is a link, and a store pasting
  /// a local path needs to be told why it will not work.
  static String? fileUrl(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'URL berkas wajib diisi';
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'Masukkan URL lengkap, contoh https://storage.contoh/ktp.jpg';
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return 'URL harus diawali http:// atau https://';
    }
    return null;
  }

  static String? Function(String?) positiveAmount(String label) => (value) {
        final trimmed = value?.trim() ?? '';
        if (trimmed.isEmpty) return '$label wajib diisi';
        final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.isEmpty) return '$label harus berupa angka';
        if (int.parse(digits) <= 0) return '$label harus lebih dari 0';
        return null;
      };

  /// Optional surcharge: empty means zero.
  static String? optionalAmount(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    if (trimmed.replaceAll(RegExp(r'[^0-9]'), '').isEmpty) {
      return 'Harus berupa angka';
    }
    return null;
  }

  static String? accountNumber(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Nomor rekening wajib diisi';
    if (!RegExp(r'^[0-9]{6,25}$').hasMatch(trimmed)) {
      return 'Nomor rekening hanya boleh berisi angka';
    }
    return null;
  }
}
