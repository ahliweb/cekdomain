# 📑 Changelog

Semua perubahan penting pada proyek **cekdomain** akan didokumentasikan di file ini.

---

## [v1.0.0] - 2025-10-04

### Added

* Script `check_domains.sh` untuk pengecekan domain.
* Dukungan domain internasional (WHOIS).
* Dukungan domain `.id` melalui PANDI.
* Output **CSV** dengan kolom: `Domain, Status, Expiry Date, Note`.
* Output **LOG** dengan header dan footer.
* Progress bar dengan persentase dan ETA.
* Auto-install dependency (`whois`, `dig`, `curl`, `grep`).

### Improved

* Format CSV sekarang **quoted** agar tidak terpotong.
* LOG file lebih rapi dengan **header** dan **footer**.

### Notes

* Highlight otomatis:

  * ❌ Expired
  * ⚠️ Expiring Soon (≤30 hari)
  * ✅ OK
* Script ini didukung oleh:

  * [SatpamSiber.com](https://SatpamSiber.com)
  * [AhliWeb.com](https://AhliWeb.com)
  * [AhliWeb.co.id](https://AhliWeb.co.id)

---

## [Unreleased]

* Export hasil ke Excel (`.xlsx`).
* Mode cepat tanpa delay.
* Notifikasi Telegram/Email untuk domain yang akan expired.
