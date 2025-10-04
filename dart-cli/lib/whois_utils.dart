import 'package:whois/whois.dart';

Future<DateTime?> whoisExpiry(String domain) async {
  // whois package sudah memetakan banyak TLD (termasuk .top, dsb.)
  final result = await Whois.lookup(domain);
  final text = result.text ?? '';
  // Pola umum: "Registry Expiry Date: 2026-02-21T08:56:22Z"
  final patterns = <RegExp>[
    RegExp(r'Expiry Date:\s*([0-9T:\-\.Z]+)', caseSensitive: false),
    RegExp(r'Expiration Date:\s*([0-9T:\-\.Z]+)', caseSensitive: false),
    RegExp(r'Registry Expiry Date:\s*([0-9T:\-\.Z]+)', caseSensitive: false),
    RegExp(r'paid-till:\s*([0-9\-T:\.Z ]+)', caseSensitive: false),
  ];
  for (final re in patterns) {
    final m = re.firstMatch(text);
    if (m != null) {
      final s = m.group(1)!.trim();
      final dt = DateTime.tryParse(s.replaceAll(' ', 'T').replaceAll('.0Z', 'Z'));
      if (dt != null) return dt;
    }
  }
  return null;
}
