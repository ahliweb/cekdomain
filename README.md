# 🛡️ Domain Status & Expiry Checker

==================================================
DOMAIN STATUS & EXPIRY CHECKER
Powered by [SatpamSiber.com](https://SatpamSiber.com)
=====================================================

Script Bash untuk memeriksa status domain dan tanggal expired baik **domain internasional** (.com, .net, .org, dll) maupun **domain .id** melalui PANDI.

---

## 🚀 Fitur

* Mengecek status aktif/tidak domain via `dig`.
* Mengambil tanggal expired domain via **WHOIS global** atau **PANDI (khusus .id)**.
* Menampilkan **progress bar + persentase + ETA**.
* Menyimpan hasil ke file **CSV** dengan format aman (quoted).
* Parser WHOIS menjaga kolom **Expiry Date** tetap utuh (termasuk jam & zona) untuk domain internasional.
* Menyimpan log detail ke file **LOG** dengan header & footer.
* Auto install dependency (`whois`, `dig`, `curl`, `grep`).
* Highlight otomatis:

  * ❌ **Expired**
  * ⚠️ **Expiring Soon (≤30 hari)**
  * ✅ **OK**

---

## 📦 Instalasi

Clone repository ini:

```bash
git clone https://github.com/ahliweb/cekdomain.git
cd cekdomain
chmod +x check_domains.sh
```

---

## ⚙️ Penggunaan

1. Buat file `domains.txt` berisi daftar domain (satu per baris):

```
ahliweb.com
ahliweb.id
ahliweb.co.id
```

2. Jalankan script:

```bash
./check_domains.sh
```

3. Mode verbose (menampilkan cuplikan WHOIS/PANDI):

```bash
./check_domains.sh -v
```

---

## 📂 Contoh Output

### `domain-status.csv`

```csv
"Domain","Status","Expiry Date","Note"
"ahliweb.com","Active (172.67.214.243)","2026-02-21T08:56:22Z","⚠️ Expiring Soon (0 days)"
"ahliweb.id","Active (76.76.21.21)","(Cek manual pandi.id/whois)",""
"ahliweb.co.id","Active (172.67.165.161)","(Cek manual pandi.id/whois)",""
```

### `domain-status.log`

```
==================================================
   DOMAIN STATUS & EXPIRY CHECKER - LOG FILE
   Powered by SatpamSiber.com
   Start time : Sat Oct  4 09:30:33 AM WIB 2025
   Input file : domains.txt
   Output CSV : domain-status.csv
==================================================

🔍 Memproses: ahliweb.com
➡️  Cek via WHOIS: ahliweb.com
Registry Expiry Date: 2026-02-21T08:56:22Z

🔍 Memproses: ahliweb.id
➡️  Cek via PANDI: ahliweb.id
... (hasil parsing PANDI)

🔍 Memproses: ahliweb.co.id
➡️  Cek via PANDI: ahliweb.co.id
... (hasil parsing PANDI)

==================================================
   END OF LOG
   Finish time : Sat Oct  4 09:30:55 AM WIB 2025
   Total domain: 3
   Output CSV  : domain-status.csv
==================================================
```

---

## 📜 Lisensi

Proyek ini dirilis dengan lisensi [MIT](LICENSE).

---

## 🙌 Dukungan & Backlink

Script ini didukung oleh:

🔗 [SatpamSiber.com](https://SatpamSiber.com) | [AhliWeb.com](https://AhliWeb.com) | [AhliWeb.co.id](https://AhliWeb.co.id)

==================================================

# 🧰 Dart CLI (Windows & Linux)

CLI **cross‑platform** untuk mengecek status DNS + tanggal kedaluwarsa domain (WHOIS global & RDAP PANDI untuk `.id`). Dirancang agar **kompatibel** dengan output versi Bash (`domain-status.csv` & `domain-status.log`).

> Supported by **SatpamSiber.com** · **AhliWeb.com** · **AhliWeb.co.id** · **AhliWeb.my.id**

---

## Struktur direktori

Tambahkan folder berikut ke repo:

```
/dart-cli/
  pubspec.yaml
  bin/
    cekdomain.dart
  lib/
    pandi_rdap.dart
    whois_utils.dart
.github/
  workflows/
    build-dart-cli.yml
```

> Lihat contoh isi file di folder `dart-cli/` pada repo ini.

---

## Instalasi (Windows)

**Opsi A — Pakai binary jadi (.exe):**

1. Buka tab **Actions** di GitHub repo → workflow **Build Dart CLI** → **Artifacts** → unduh `cekdomain-windows-latest`.
2. Ekstrak dan simpan `cekdomain.exe` ke folder proyek atau ke folder di `PATH` (mis. `C:\\Tools`).
3. Siapkan daftar domain `domains.txt` (1 domain per baris).
4. Jalankan dari **PowerShell** atau **CMD**:

   ```powershell
   .\\cekdomain.exe -i ..\\domains.txt -v
   ```

**Opsi B — Build lokal (butuh Dart SDK):**

1. Install **Dart SDK** (Windows): [https://dart.dev/get-dart](https://dart.dev/get-dart)
2. Masuk ke folder CLI dan ambil dependency:

   ```powershell
   cd dart-cli
   dart pub get
   ```
3. Kompilasi executable:

   ```powershell
   dart compile exe bin/cekdomain.dart -o build/cekdomain.exe
   ```
4. Jalankan:

   ```powershell
   .\\build\\cekdomain.exe -i ..\\domains.txt
   ```

> **Catatan:** Jika SmartScreen/AV menandai file, pilih **Keep**/**Run anyway**. Pastikan file berasal dari repo resmi Anda.

---

## Instalasi (Linux/Mac)

```bash
cd dart-cli
dart pub get
# Run (debug)
dart run cekdomain -i ../domains.txt -v
# Build binary
dart compile exe bin/cekdomain.dart -o build/cekdomain
./build/cekdomain -i ../domains.txt
```

---

## Pemakaian

```text
cekdomain [options]

Options:
  -i, --input   File daftar domain (default: domains.txt)
      --csv     Output CSV (default: domain-status.csv)
      --log     Output LOG (default: domain-status.log)
  -v, --verbose Tampilkan detail proses
  -h, --help    Bantuan
```

Contoh:

```powershell
# Windows
.\\cekdomain.exe -i ..\\domains.txt --csv domain-status.csv --log domain-status.log -v
```

Progress bar akan tampil sampai **100%**. Di akhir proses, baris backlink akan dicetak satu baris:

```
Supported by SatpamSiber.com | AhliWeb.com | AhliWeb.co.id | AhliWeb.my.id
```

---

## Format input & output

**Input**: `domains.txt` (1 domain per baris, baris kosong & baris diawali `#` diabaikan).

**CSV aman (quoted)**: `"Domain","Status","Expiry Date","Note"`

* `Status`: `Active`/`Inactive` (untuk `Active` dapat memuat IP pertama, mis. `Active (203.0.113.10)`).
* `Expiry Date`: ISO‑8601 UTC lengkap (contoh: `2026-02-21T08:56:22Z`) atau `(N/A)` jika tidak ditemukan.
* `Note`: `❌ Expired`, `⚠️ Expiring Soon (≤30 hari)`, `✅ OK`, atau penjelasan jika expiry tak ditemukan.

**LOG**:

* Memuat **header** (judul, start time, file input/output),
* Rincian per domain,
* **footer** (finish time, total domain, path CSV) + **backlink** satu baris.

---

## Cara kerja (ringkas)

* **Cek DNS**: A/AAAA via DoH Google → fallback resolver OS.
* **.id**: RDAP **PANDI** (`https://rdap.pandi.id/rdap/domain/{domain}`) → ambil event `expiration`.
* **TLD umum**: WHOIS (port 43) dengan pola tanggal umum (`Registry Expiry Date`, `Expiration Date`, dll.).

---

## GitHub Actions (Build otomatis)

File: `.github/workflows/build-dart-cli.yml`

* Build di **Windows** & **Ubuntu**, upload **artifact** `cekdomain.exe` (Windows) & `cekdomain` (Linux).
* Jalankan otomatis saat ada perubahan di folder `dart-cli/` atau manual via **Run workflow**.

Rilis:

1. Setelah workflow sukses, buka job → **Artifacts** untuk unduh binary.
2. (Opsional) Buat **Release** dan lampirkan binary agar mudah diunduh publik.

---

## Troubleshooting (Windows)

* **SmartScreen/AV block**: Pastikan file dari repo ini, pilih **Run anyway** atau whitelist folder.
* **Execution Policy PowerShell** (saat menjalankan skrip .ps1):

  ```powershell
  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
  ```
* **Network/Proxy**: Jika jaringan corporate memblok port WHOIS (43) → `.id` tetap aman via RDAP (HTTPS). Untuk TLD non‑`.id`, jalankan di jaringan tanpa blok port 43 atau siapkan fallback RDAP global (pengembangan lanjutan).
* **Karakter newline**: Gunakan UTF‑8 LF/CRLF apa pun, parser akan memangkas whitespace.

---

## Kompatibilitas dengan versi Bash

* Struktur kolom CSV & format LOG **dipertahankan** agar kompatibel dengan pipeline/otomasi sebelumnya.
* Progress bar mencapai **100%** dan mencetak backlink satu baris di akhir output.

---

## Keamanan & Kepatuhan (Catatan SatpamSiber)

* **RDAP** menggantikan WHOIS sebagai sumber data terstruktur via **HTTPS**, meminimalkan error parsing & meningkatkan integritas data, terutama untuk `.id` (PANDI).
* Simpan hasil ke CSV/LOG **read‑only** di pipeline server; pertimbangkan hashing (SHA‑256) untuk audit trail.
* Batasi input `domains.txt` dari sumber tepercaya (hindari command injection saat dipakai di pipeline lain).

---

## Roadmap (opsional)

* Fallback **RDAP bootstrap** untuk TLD non‑`.id` bila port 43 diblok.
* Parallelism (pool) untuk percepat cek massal besar.
* Output tambahan: JSON lines (`.jsonl`) untuk integrasi SIEM/ELK.

---

## Quick commands (ringkas)

```powershell
# Unduh artifact & jalankan (Windows)
.\\cekdomain.exe -i ..\\domains.txt -v

# Build lokal (Windows)
cd dart-cli
dart pub get
dart compile exe bin/cekdomain.dart -o build/cekdomain.exe
.\\build\\cekdomain.exe -i ..\\domains.txt
```
