# 🛡️ Domain Status & Expiry Checker

==================================================
DOMAIN STATUS & EXPIRY CHECKER
Powered by [SatpamSiber.com](https://SatpamSiber.com)
=====================================================

Script Bash untuk memeriksa status domain dan tanggal expired baik **domain internasional** (.com, .net, .org, dll) maupun **domain .id** melalui PANDI.

🚀 **Fitur Utama:**

* Mengecek status aktif/tidak domain via `dig`.
* Mengambil tanggal expired domain via **WHOIS global** atau **PANDI (khusus .id)**.
* Menampilkan **progress bar + persentase + ETA**.
* Menyimpan hasil ke file **CSV** dengan format aman (quoted).
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
suarabarito.com
suarabarito.id
example.org
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

## 📂 Output

* **domain-status.csv** → hasil cek domain (dengan kolom `Domain, Status, Expiry Date, Note`)
* **domain-status.log** → log detail proses, lengkap dengan header & footer

Contoh `domain-status.csv`:

```
"Domain","Status","Expiry Date","Note"
"suarabarito.com","Active (203.0.113.10)","2026-03-14T04:00:00Z","✅ OK (330 days left)"
"suarabarito.id","Inactive/No DNS","(Cek manual pandi.id/whois)",""
"expiredexample.com","Inactive/No DNS","2024-05-02T23:59:59Z","❌ Expired"
```

Contoh `domain-status.log`:

```
==================================================
   DOMAIN STATUS & EXPIRY CHECKER - LOG FILE
   Powered by SatpamSiber.com
   Start time : Sun Oct  5 10:15:27 WIB 2025
   Input file : domains.txt
   Output CSV : domain-status.csv
==================================================

🔍 Memproses: suarabarito.com
➡️  Cek via WHOIS: suarabarito.com
Registry Expiry Date: 2026-03-14T04:00:00Z

🔍 Memproses: suarabarito.id
➡️  Cek via PANDI: suarabarito.id
Expired Date: 2026-02-28 23:59:59

==================================================
   END OF LOG
   Finish time : Sun Oct  5 10:16:10 WIB 2025
   Total domain: 52
   Output CSV  : domain-status.csv
==================================================
```

---

## 📜 Lisensi

Proyek ini dirilis dengan lisensi [MIT](LICENSE).

---

## 🙌 Dukungan & Backlink

Script ini didukung oleh:
🔗 [SatpamSiber.com](https://SatpamSiber.com) | [AhliWeb.com](https://AhliWeb.com) | [AhliWeb.co.id](https://AhliWeb.co.id) |
==================================================
