import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:csv/csv.dart';
import 'package:dns_client/dns_client.dart';
import 'package:dns_client/hosts_file_resolver.dart';
import 'package:cekdomain_cli/pandi_rdap.dart';
import 'package:cekdomain_cli/whois_utils.dart';

const headerLine = '==================================================';
const backlinkLine = 'Supported by SatpamSiber.com | AhliWeb.com | AhliWeb.co.id | AhliWeb.my.id';

Future<bool> hasARecord(String domain) async {
  // Resolver: hosts file + Google DoH fallback
  final resolver = DnsOverHttps.google();
  try {
    final a = await resolver.lookup<RecordA>(domain);
    if (a.isNotEmpty) return true;
    final aaaa = await resolver.lookup<RecordAAAA>(domain);
    return aaaa.isNotEmpty;
  } catch (_) {
    // fallback: OS resolver
    try {
      final list = await InternetAddress.lookup(domain);
      return list.isNotEmpty;
    } catch (_) {
      return false;
    }
  } finally {
    resolver.close();
  }
}

bool isIdTld(String domain) => domain.toLowerCase().endsWith('.id');

String padPercent(int current, int total) {
  final pct = ((current / total) * 100).clamp(0, 100).toStringAsFixed(0);
  return pct.padLeft(3);
}

void printProgress(int idx, int total) {
  final pct = (idx * 100 ~/ total);
  final width = 30;
  final filled = (pct * width ~/ 100);
  final bar = '[${'=' * filled}${' ' * (width - filled)}] ${pct.toString().padLeft(3)}%';
  stdout.write('\r$bar');
}

void main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('input', abbr: 'i', defaultsTo: 'domains.txt')
    ..addOption('csv', defaultsTo: 'domain-status.csv')
    ..addOption('log', defaultsTo: 'domain-status.log')
    ..addFlag('verbose', abbr: 'v', defaultsTo: false);

  final opts = parser.parse(args);
  final inputFile = File(opts['input']);
  if (!await inputFile.exists()) {
    stderr.writeln('File ${opts['input']} tidak ditemukan.');
    exit(1);
  }
  final domains = (await inputFile.readAsLines())
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty && !l.startsWith('#'))
      .toList();

  final csvFile = File(opts['csv']);
  final logFile = File(opts['log']);
  final sinkLog = logFile.openWrite(mode: FileMode.writeOnly);
  sinkLog.writeln(headerLine);
  sinkLog.writeln('   DOMAIN STATUS & EXPIRY CHECKER - LOG FILE');
  sinkLog.writeln('   Powered by SatpamSiber.com');
  sinkLog.writeln('   Start time : ${DateTime.now()}');
  sinkLog.writeln('   Input file : ${opts['input']}');
  sinkLog.writeln('   Output CSV : ${opts['csv']}');
  sinkLog.writeln(headerLine);

  final rows = <List<String>>[
    ['Domain','Status','Expiry Date','Note'],
  ];

  final total = domains.length;
  for (var i = 0; i < domains.length; i++) {
    final d = domains[i];
    printProgress(i + 1, total);
    sinkLog.writeln('\n Memproses: $d');

    final active = await hasARecord(d);
    final status = active ? 'Active' : 'Inactive';

    DateTime? expiry;
    String note = '';

    if (isIdTld(d)) {
      sinkLog.writeln('➡️  Cek via RDAP PANDI: $d');
      final rdap = await fetchPandiRdap(d);
      expiry = rdap.expires;
      if (expiry == null) {
        note = 'RDAP tidak mengembalikan expiry';
      }
    } else {
      sinkLog.writeln('➡️  Cek via WHOIS: $d');
      expiry = await whoisExpiry(d);
      if (expiry == null) note = 'WHOIS expiry tidak ditemukan';
    }

    String label = status;
    if (active) {
      // coba tampilkan IP pertama dari OS resolver (opsional)
      try {
        final ips = await InternetAddress.lookup(d);
        if (ips.isNotEmpty) label = 'Active (${ips.first.address})';
      } catch (_) {}
    }

    // Highlight status expiry
    if (expiry != null) {
      final days = expiry.difference(DateTime.now().toUtc()).inDays;
      if (days < 0) {
        note = '❌ Expired';
      } else if (days <= 30) {
        note = '⚠️ Expiring Soon (≤30 hari)';
      } else {
        note = '✅ OK';
      }
    }

    rows.add([
      d,
      label,
      expiry?.toIso8601String() ?? '(N/A)',
      note,
    ]);
  }

  // Tampilkan progress 100%
  printProgress(total, total);
  stdout.writeln();

  // Tulis CSV aman (quoted)
  final csv = const ListToCsvConverter(fieldDelimiter: ',', textDelimiter: '"', textEndDelimiter: '"').convert(rows);
  await csvFile.writeAsString(csv + '\n');

  // Tutup log
  sinkLog.writeln('\n$headerLine');
  sinkLog.writeln('   END OF LOG');
  sinkLog.writeln('   Finish time : ${DateTime.now()}');
  sinkLog.writeln('   Total domain: $total');
  sinkLog.writeln('   Output CSV  : ${csvFile.path}');
  sinkLog.writeln('$headerLine');
  sinkLog.writeln(backlinkLine);
  await sinkLog.flush();
  await sinkLog.close();

  stdout.writeln(backlinkLine);
}
