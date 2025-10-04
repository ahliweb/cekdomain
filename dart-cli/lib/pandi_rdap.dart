import 'dart:convert';
import 'package:http/http.dart' as http;

class RdapResult {
  final DateTime? expires;
  final String? raw;
  RdapResult({this.expires, this.raw});
}

Future<RdapResult> fetchPandiRdap(String domain) async {
  // IANA menyatakan RDAP server PANDI: https://rdap.pandi.id/rdap/
  // Format: /rdap/domain/{domain}
  final uri = Uri.parse('https://rdap.pandi.id/rdap/domain/$domain');
  final res = await http.get(uri, headers: {'accept': 'application/rdap+json'});
  if (res.statusCode != 200) {
    return RdapResult(raw: 'HTTP ${res.statusCode}: ${res.body}');
  }
  final Map<String, dynamic> data = json.decode(res.body);
  // Cari event "expiration"
  DateTime? exp;
  final events = (data['events'] as List?) ?? const [];
  for (final e in events) {
    if (e is Map && (e['eventAction'] == 'expiration' || e['eventAction'] == 'expire')) {
      final date = e['eventDate'] as String?;
      if (date != null) {
        exp = DateTime.tryParse(date);
        break;
      }
    }
  }
  return RdapResult(expires: exp, raw: res.body);
}
