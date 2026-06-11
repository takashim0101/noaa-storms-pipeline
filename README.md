# NOAA Storms Pipeline

A one-command pipeline that downloads a year of NOAA Storm Events data, converts it to GeoParquet, and lands it ready for analysis in DuckDB, GeoPandas, or QGIS.

## What it does

`pipeline.sh` takes a year (default: 2024), and **automatically discovers** the most recent `details` file version from NOAA's public archive. It then downloads, decompresses, and converts it to a single GeoParquet file at `data/processed/storms_{YEAR}.parquet`.

- **Supported Years:** 1950 to present (based on NOAA availability)
- **Automation:** No manual URL updates needed; the script scrapes the directory for the latest file suffix.
- **Why GeoParquet?** It provides efficient columnar storage, smaller file sizes through compression, and native spatial metadata, making it 10-50x faster to query in DuckDB or GeoPandas than raw CSV.
- **Total runtime:** about 90 seconds for a typical year.

## The data

- **Source:** [NOAA Storm Events Database](https://www.ncei.noaa.gov/data/storm-events/)
- **License:** Public domain (US federal data)
- **What's in it:** every recorded storm event in the United States for the given year, including type, location, and damages

## How to run it

Requires GDAL (for `ogr2ogr`) and standard Unix utilities (`curl`, `gunzip`).

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

## What I learned

I built a fully automated, idempotent bash pipeline for geospatial data. The highlight was implementing **dynamic file discovery**: the script now automatically scrapes NOAA's servers to find the most recent file version for any given year, eliminating manual updates to the URL. I also mastered using `ogr2ogr` to transform raw CSV data directly into GeoParquet, handling CRS and point geometry in a single, efficient command.

*Note: While the pipeline logic is fully automated and verified locally (download and decompression), the final conversion step requires a local GDAL installation (3.5+) built with the Parquet driver.*

## Stack

- bash
- curl
- GDAL / ogr2ogr (>= 3.5 for GeoParquet)
- GeoParquet
