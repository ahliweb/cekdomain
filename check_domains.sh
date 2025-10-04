#!/bin/bash
# ==========================================================
#   DOMAIN STATUS & EXPIRY CHECKER
#   (Progress Bar + WHOIS + PANDI + CSV Output + Logging)
#
#   Powered by SatpamSiber.com
# ==========================================================
# Fungsi:
# - Mengecek status domain (.com, .id, .xyz, .top, .online, .site, dll)
# - Menampilkan apakah domain aktif atau tidak (cek DNS via dig)
# - Mengambil tanggal expired (WHOIS global atau PANDI untuk .id family)
# - Menampilkan progress bar + persentase + ETA (selalu finish 100%)
# - Menyimpan hasil ke file CSV (quoted, anti-terpotong)
# - Menyimpan log proses ke file LOG (dengan header & footer)
# - Auto install dependency (whois, dig, curl, grep, coreutils/date) bila belum ada
# - Highlight otomatis: ❌ Expired | ⚠️ Expiring Soon (≤30 hari) | ✅ OK
#
# Usage:
#   ./check_domains.sh        # mode normal
#   ./check_domains.sh -v     # verbose mode (tampilkan cuplikan WHOIS/PANDI)
# ==========================================================

set -u

INPUT_FILE="domains.txt"
OUTPUT_FILE="domain-status.csv"
LOG_FILE="domain-status.log"

VERBOSE=false
if [[ "${1:-}" == "-v" ]]; then
  VERBOSE=true
fi

# Reset log file + tulis header
{
  echo "=================================================="
  echo "   DOMAIN STATUS & EXPIRY CHECKER - LOG FILE"
  echo "   Powered by SatpamSiber.com"
  echo "   Start time : $(date)"
  echo "   Input file : $INPUT_FILE"
  echo "   Output CSV : $OUTPUT_FILE"
  echo "=================================================="
} > "$LOG_FILE"

# --------------------------
# Helper Functions
# --------------------------
logv() {
  echo -e "$@" >> "$LOG_FILE"
  if [[ "$VERBOSE" == true ]]; then
    echo -e "$@"
  fi
}

fmt_duration() {
  local T=$1
  local H=$((T/3600))
  local M=$(((T%3600)/60))
  local S=$((T%60))
  if (( H > 0 )); then
    printf "%02d:%02d:%02d" "$H" "$M" "$S"
  else
    printf "%02d:%02d" "$M" "$S"
  fi
}

print_progress() {
  local current=$1
  local total=$2
  local elapsed=$3
  local avg=0
  if (( current > 0 )); then
    avg=$(( elapsed / current ))
  fi
  local remaining=$(( (total - current) * avg ))
  local percent=$(( current * 100 / total ))
  (( percent > 100 )) && percent=100
  local width=30
  local filled=$(( percent * width / 100 ))
  local bar=""
  for ((i=0;i<filled;i++)); do bar+="#"; done
  for ((i=filled;i<width;i++)); do bar+="-"; done
  printf "\r[%s] %3d%%  %d/%d  ETA %s" "$bar" "$percent" "$current" "$total" "$(fmt_duration $remaining)"
}

ensure_tools() {
  local tools=("whois" "dig" "curl" "grep" "date")
  for tool in "${tools[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      echo "⚠️  $tool belum ada. Install dulu..." | tee -a "$LOG_FILE"
      sudo apt-get update -y
      case "$tool" in
        whois) sudo apt-get install -y whois ;;
        dig) sudo apt-get install -y dnsutils ;;
        curl) sudo apt-get install -y curl ;;
        grep) sudo apt-get install -y grep ;;
        date) sudo apt-get install -y coreutils ;;
      esac
    fi
  done
}

# Parser WHOIS (standar)
extract_expiry_whois() {
  grep -iE 'Registry Expiry Date|Expiry Date|Expiration Date|paid-till|expire' \
    | head -n 1 \
    | sed -E 's/.*:[[:space:]]*//; s/\r$//'
}

# Parser WHOIS (spesial TLD/registrar), mis. .top menggunakan field Registrar Registration Expiration Date
extract_expiry_special() {
  grep -iE 'Registrar Registration Expiration Date|Domain Expiration Date|Expiry|Expires On' \
    | head -n 1 \
    | sed -E 's/.*:[[:space:]]*//; s/\r$//'
}

# Parser PANDI (.id family)
extract_expiry_pandi() {
  awk '/Expired Date/ {print}' \
    | head -n 1 \
    | sed -E 's/.*Expired Date: *//; s/<.*$//; s/\r$//'
}

# Hitung sisa hari dari string tanggal yang bisa dipahami `date -d`
days_left() {
  local expiry_date="$1"
  if exp_epoch=$(date -d "$expiry_date" +%s 2>/dev/null); then
    :
  else
    echo ""
    return
  fi
  local now_epoch=$(date +%s)
  local diff_days=$(( (exp_epoch - now_epoch) / 86400 ))
  echo "$diff_days"
}

# Escape CSV -> quote semua kolom dan escape tanda kutip
csv_escape() {
  local s="$1"
  s="${s//\"/\"\"}"
  echo "\"$s\""
}

# --------------------------
# Main
# --------------------------
if [[ ! -f "$INPUT_FILE" ]]; then
  echo "❌ File $INPUT_FILE tidak ditemukan." | tee -a "$LOG_FILE"
  exit 1
fi

ensure_tools

TMP_INPUT="$(mktemp)"
tr -d '\r' < "$INPUT_FILE" > "$TMP_INPUT"

total=$(grep -cve '^\s*$' "$TMP_INPUT")
if (( total == 0 )); then
  echo "❌ $INPUT_FILE kosong." | tee -a "$LOG_FILE"
  rm -f "$TMP_INPUT"
  exit 1
fi

# Info awal di layar
echo "=================================================="
echo "   DOMAIN STATUS & EXPIRY CHECKER"
echo "   Powered by SatpamSiber.com"
echo "=================================================="
echo "📌 Fungsi Script:"
echo "- Mengecek status aktif/tidak domain"
echo "- Mengambil tanggal expired WHOIS/PANDI"
echo "- Output CSV: $OUTPUT_FILE"
echo "- Output Log: $LOG_FILE"
echo "--------------------------------------------------"
echo "📊 Jumlah domain yang akan dicek: $total"
echo "=================================================="

# Header CSV (quoted)
echo '"Domain","Status","Expiry Date","Note"' > "$OUTPUT_FILE"

start_ts=$(date +%s)
count=0

while IFS= read -r domain; do
  [[ -z "$domain" ]] && continue
  count=$((count+1))

  now_ts=$(date +%s)
  elapsed=$(( now_ts - start_ts ))
  print_progress "$count" "$total" "$elapsed"

  logv "\n🔍 Memproses: $domain"

  # Cek DNS
  ip=$(dig +short "$domain")
  if [[ -z "$ip" ]]; then
    status="Inactive/No DNS"
  else
    first_ip=$(echo "$ip" | head -n 1)
    status="Active ($first_ip)"
  fi

  expiry="Unknown"
  note=""

  # .id family (termasuk .co.id, .or.id, .ac.id, dll) → cukup cek suffix .id
  if [[ "$domain" == *.id ]]; then
    logv "➡️  Cek via PANDI: $domain"
    pandi_html=$(curl -s "https://pandi.id/whois?domain=$domain")
    logv "$(echo "$pandi_html" | grep -i 'Expired' | head -n 3)"
    e=$(echo "$pandi_html" | extract_expiry_pandi)
    [[ -n "$e" ]] && expiry="$e" || expiry="(Cek manual pandi.id/whois)"
  else
    logv "➡️  Cek via WHOIS: $domain"
    whois_raw=$(whois "$domain" 2>/dev/null)
    logv "$(echo "$whois_raw" | grep -iE 'Expiry|Expiration|paid|expire' | head -n 5)"

    # Parser standar
    e=$(echo "$whois_raw" | extract_expiry_whois)
    # Fallback parser spesial (untuk .top, .xyz, .online, .site, dll)
    if [[ -z "$e" ]]; then
      e=$(echo "$whois_raw" | extract_expiry_special)
    fi

    [[ -n "$e" ]] && expiry="$e" || expiry="Unknown"
  fi

  # Tentukan note highlight
  if [[ "$expiry" != "Unknown" && "$expiry" != "(Cek manual pandi.id/whois)" ]]; then
    dleft=$(days_left "$expiry")
    if [[ -n "$dleft" ]]; then
      if (( dleft < 0 )); then
        note="❌ Expired"
      elif (( dleft <= 30 )); then
        note="⚠️ Expiring Soon ($dleft days)"
      else
        note="✅ OK ($dleft days left)"
      fi
    fi
  fi

  # Tulis CSV (quoted)
  d_q=$(csv_escape "$domain")
  s_q=$(csv_escape "$status")
  e_q=$(csv_escape "$expiry")
  n_q=$(csv_escape "$note")
  printf "%s,%s,%s,%s\n" "$d_q" "$s_q" "$e_q" "$n_q" >> "$OUTPUT_FILE"

  # throttle ringan (hindari rate-limit registrar WHOIS)
  sleep 0.3

  # Update progress
  now_ts=$(date +%s)
  elapsed=$(( now_ts - start_ts ))
  print_progress "$count" "$total" "$elapsed"

done < "$TMP_INPUT"

rm -f "$TMP_INPUT"

# Pastikan progress 100%
print_progress "$total" "$total" "$elapsed"
echo ""

# Footer log
{
  echo ""
  echo "=================================================="
  echo "   END OF LOG"
  echo "   Finish time : $(date)"
  echo "   Total domain: $total"
  echo "   Output CSV  : $OUTPUT_FILE"
  echo "=================================================="
} >> "$LOG_FILE"

# Footer info di layar
echo "=================================================="
echo "✅ Selesai! Hasil ada di $OUTPUT_FILE"
echo "📄 Log detail proses ada di $LOG_FILE"
echo "--------------------------------------------------"
echo "🔗 Yuk join komunitas: https://SatpamSiber.com    " 
echo "🔗 https://AhliWeb.com | https://AhliWeb.co.id    "
echo "=================================================="
