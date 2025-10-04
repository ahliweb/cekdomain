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
