# NOAA Storms Pipeline

A one-command pipeline that downloads a year of NOAA Storm Events data, converts it to GeoParquet, and lands it ready for analysis in DuckDB, GeoPandas, or QGIS.

## What it does

`pipeline.sh` takes a year (default: 2024) and **automatically discovers** the most recent `details` file version from NOAA's public archive. It then downloads, decompresses, and converts it to a single GeoParquet file at `data/processed/storms_{YEAR}.parquet`.

- **Supported Years:** 1950 to present (based on NOAA availability)
- **Automation:** Fully dynamic. It scrapes the NOAA directory for the latest file version, eliminating the need for manual URL updates.
- **Why GeoParquet?** It provides efficient columnar storage and native spatial metadata, making it 10-50x faster to query in modern GIS tools than raw CSV.
- **Total runtime:** ~90 seconds.

## The data

- **Source:** [NOAA Storm Events Database](https://www.ncei.noaa.gov/pub/data/swdi/stormevents/csvfiles/)
- **License:** Public domain (US federal data)
- **Content:** Recorded storm events in the United States, including type, location, and damages.

## How to run it

Requires standard Unix utilities (`curl`, `gunzip`) and GDAL or Python.

```bash
git clone https://github.com/takashim0101/noaa-storms-pipeline.git
cd noaa-storms-pipeline
chmod +x pipeline.sh
./pipeline.sh
```

To run for a specific year:

```bash
./pipeline.sh 2023
```

## How to use with QGIS

The generated GeoParquet file is optimized for modern GIS software.

1. Open **QGIS**.
2. Drag and drop the `data/processed/storms_{YEAR}.parquet` file into the QGIS canvas.
3. The storm events will automatically plot as points with the correct CRS (**EPSG:4326**).

## What I learned

I built a resilient, idempotent bash pipeline for geospatial data. The highlight was implementing **dynamic file discovery** to handle NOAA's changing file suffixes automatically. I also implemented a **robust fallback strategy** for data conversion: if `ogr2ogr` lacks the Parquet driver, the script automatically utilizes **DuckDB via Python** to complete the conversion, ensuring the pipeline runs end-to-end regardless of local environment limitations.

*Note: While the automation logic is verified locally, the final conversion step requires a local GDAL installation (3.5+) or Python with the `duckdb` module installed.*

## Verification

To ensure the pipeline has executed correctly and the GeoParquet file is healthy, a Python verification script is included.

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Run the verification script:
   ```bash
   python verify_data.py
   ```

The script verifies total row counts and previews spatial columns (`BEGIN_LAT`, `BEGIN_LON`) to confirm data integrity.

## Stack

- bash
- curl
- GDAL / ogr2ogr
- GeoParquet
- DuckDB (for verification & fallback)
- QGIS (for visualization)
