#!/usr/bin/env bash
#
# pipeline.sh — Download a year of NOAA Storm Events, convert to GeoParquet.
#
# Usage:   ./pipeline.sh [YEAR]
# Example: ./pipeline.sh 2024
#
# Requires: bash, curl, gunzip, ogr2ogr (GDAL >= 3.5)

set -euo pipefail

# -----------------------------------------------------------------------------
# Config
# -----------------------------------------------------------------------------

# Year to pull. Override by passing as the first argument.
YEAR="${1:-2024}"

BASE_URL="https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles"

# -----------------------------------------------------------------------------
# Step 0: Dynamic File Discovery
# -----------------------------------------------------------------------------
# NOAA updates their files periodically, changing the 'c{CREATED_DATE}' suffix.
# This block automatically finds the most recent file for the target YEAR.

echo "Finding latest file for year ${YEAR} at NOAA..."
LATEST_FILE=$(curl -s "${BASE_URL}/" | grep -oE "StormEvents_details-ftp_v1.0_d${YEAR}_c[0-9]+\.csv\.gz" | sort -V | tail -n 1)

if [ -z "$LATEST_FILE" ]; then
    echo "Error: Could not find a 'details' file for year ${YEAR}."
    echo "Check the directory manually: ${BASE_URL}"
    exit 1
fi

FILE_NAME="$LATEST_FILE"
URL="${BASE_URL}/${FILE_NAME}"
echo "Found: ${FILE_NAME}"

RAW_DIR="data/raw"
PROCESSED_DIR="data/processed"
RAW_GZ="${RAW_DIR}/${FILE_NAME}"
RAW_CSV="${RAW_DIR}/${FILE_NAME%.gz}"
OUT_PARQUET="${PROCESSED_DIR}/storms_${YEAR}.parquet"

# -----------------------------------------------------------------------------
# Step 1: Set up directories
# -----------------------------------------------------------------------------

echo "[1/4] Setting up directories"
mkdir -p "$RAW_DIR" "$PROCESSED_DIR"

# -----------------------------------------------------------------------------
# Step 2: Download the raw file
# -----------------------------------------------------------------------------

echo "[2/4] Downloading ${FILE_NAME}"
if [ ! -f "$RAW_GZ" ]; then
    curl -L -o "$RAW_GZ" --fail "$URL"
else
    echo "File already exists, skipping download."
fi

# -----------------------------------------------------------------------------
# Step 3: Decompress
# -----------------------------------------------------------------------------

echo "[3/4] Decompressing"
if [ ! -f "$RAW_CSV" ]; then
    gunzip -k "$RAW_GZ"
else
    echo "File already decompressed, skipping."
fi

# -----------------------------------------------------------------------------
# Step 4: Convert CSV to GeoParquet
# -----------------------------------------------------------------------------

echo "[4/4] Converting to GeoParquet"
# ogr2ogr Parquet driver handles overwrite.
ogr2ogr -f Parquet \
    -oo X_POSSIBLE_NAMES=BEGIN_LON \
    -oo Y_POSSIBLE_NAMES=BEGIN_LAT \
    -a_srs EPSG:4326 \
    "$OUT_PARQUET" \
    "$RAW_CSV" \
    -overwrite

echo "Done. Output: ${OUT_PARQUET}"
echo "Open it in DuckDB:"
echo "  duckdb -c \"SELECT COUNT(*) FROM read_parquet('${OUT_PARQUET}');\""
