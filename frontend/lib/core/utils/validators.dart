/// Reusable form validators.
/// Return null on success, error string on failure.
class Validators {
  Validators._();

  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    return v.contains('@') ? null : 'Enter a valid email address';
  }

  static String? Function(String?) minLength(int min) =>
      (String? v) => (v != null && v.length >= min)
          ? null
          : 'Minimum $min characters required';

  static String? number(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    return double.tryParse(v) != null ? null : 'Enter a valid number';
  }
}
