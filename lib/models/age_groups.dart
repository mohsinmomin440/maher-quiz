// Single source of truth for user age groups. Bands match the
// `age_group` values in assets/data/questions_bank.json (4-7, 8-11, 12-14).
class AgeGroups {
  static const String class1 = 'Age 4-7 (Deeniyat Class 1)';
  static const String class2 = 'Age 8-11 (Deeniyat Class 2)';
  static const String class3 = 'Age 12-14 (Deeniyat Class 3)';
  static const String general = 'General / Adult';

  static const List<String> all = [class1, class2, class3, general];

  static const String defaultGroup = class2;

  // Maps legacy stored values (e.g. 'Age 8-10 (Deeniyat Class 2)',
  // 'Age 6 to 10 (Deeniyat Class 2)') onto the current options.
  static String normalize(String? value) {
    if (value == null || value.trim().isEmpty) return general;
    if (all.contains(value)) return value;
    final lower = value.toLowerCase();
    if (lower.contains('class 1')) return class1;
    if (lower.contains('class 2')) return class2;
    if (lower.contains('class 3')) return class3;
    return general;
  }
}
