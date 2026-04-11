#!/usr/bin/env bash
# Download NYC TLC trip data from DataTalksClub GitHub releases (same assets as the tag pages).
# Example: ./download_data.sh --color yellow --year 2021
#          ./download_data.sh -c green -y 2020

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: download_data.sh --color <yellow|green> --year <YYYY> [--output-dir <path>]

Downloads monthly CSV.gz files from:
  https://github.com/DataTalksClub/nyc-tlc-data/releases/download/<color>/

Files are saved under <output-dir>/<color>/<year>/ (default output-dir: ./data/raw).
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COLOR=""
YEAR=""
OUTPUT_DIR="${SCRIPT_DIR}/data/raw"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--color)
      COLOR="${2:-}"
      shift 2
      ;;
    -y|--year)
      YEAR="${2:-}"
      shift 2
      ;;
    -o|--output-dir)
      OUTPUT_DIR="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$COLOR" || -z "$YEAR" ]]; then
  echo "Error: --color and --year are required." >&2
  usage >&2
  exit 1
fi

COLOR="$(printf '%s' "$COLOR" | tr '[:upper:]' '[:lower:]')"
case "$COLOR" in
  yellow|green) ;;
  *)
    echo "Error: color must be 'yellow' or 'green' (got: $COLOR)" >&2
    exit 1
    ;;
esac

if ! [[ "$YEAR" =~ ^[0-9]{4}$ ]]; then
  echo "Error: year must be a four-digit number (got: $YEAR)" >&2
  exit 1
fi

BASE_URL="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/${COLOR}"
DEST_DIR="${OUTPUT_DIR}/${COLOR}/${YEAR}"
mkdir -p "$DEST_DIR"

echo "Downloading ${COLOR} taxi data for ${YEAR} into ${DEST_DIR}"

ok=0
for i in $(seq 1 12); do
  printf -v month '%02d' "$i"
  fname="${COLOR}_tripdata_${YEAR}-${month}.csv.gz"
  url="${BASE_URL}/${fname}"
  outpath="${DEST_DIR}/${fname}"

  echo "  -> ${fname}"
  if curl -fsSL --connect-timeout 30 --retry 3 -o "${outpath}.part" "$url"; then
    mv "${outpath}.part" "$outpath"
    ok=$((ok + 1))
  else
    rm -f "${outpath}.part"
    echo "     (not available: ${url})" >&2
  fi
done

if [[ "$ok" -eq 0 ]]; then
  echo "Error: no files were downloaded." >&2
  exit 1
fi

echo "Done. Downloaded ${ok} file(s)."
