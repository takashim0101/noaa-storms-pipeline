# Developer Notes: NOAA Storms Pipeline Journey

This document records the technical challenges encountered and the solutions implemented during the development of the NOAA Storms Pipeline (Portfolio Project 1).

## 1. Dynamic File Discovery (The URL Problem)
**Challenge:** The NOAA dataset files change names periodically based on a `CREATED_DATE` suffix (e.g., `_c20260421`). Hardcoding this date meant the script would break or download outdated data in the future.
**Solution:** I implemented a "Dynamic File Discovery" step using `curl` and `grep` to scrape the NOAA public directory. The script now automatically finds the most recent file version for any requested year (`sort -V | tail -n 1`), making the pipeline truly zero-maintenance and future-proof.

## 2. Environment Dependencies (The GDAL/ogr2ogr Problem)
**Challenge:** The original specification relied on `ogr2ogr` for CSV to GeoParquet conversion. However, my local Windows environment lacked a GDAL installation compiled with the Parquet driver (`ERROR 1: Unable to find driver 'Parquet'`).
**Solution:** Instead of failing, I implemented a robust **Fallback Strategy**. 
- The script first attempts the `ogr2ogr` conversion.
- If it fails, it gracefully falls back to using **DuckDB via Python**.

## 3. Intelligent Path Resolution (The Python/venv Problem)
**Challenge:** When running the bash script (`pipeline.sh`) via Git Bash on Windows, the script couldn't find the `duckdb` module because it was looking at the system Python instead of the active virtual environment (`venv`).
**Solution:** I wrote a custom Python discovery block. The bash script now determines its own absolute path (`SCRIPT_DIR`), navigates up one level, and explicitly targets the Python executable inside the virtual environment (`$VENV_DIR/Scripts/python.exe`). This ensures the script works consistently across different terminals (PowerShell, Git Bash) and operating systems (Windows/Unix).

## 4. Quality Assurance (The Verification Step)
**Challenge:** How do I prove the output is valid without requiring the user to manually open QGIS?
**Solution:** I built a dedicated `verify_data.py` script. It uses DuckDB to read the generated Parquet file, count the rows, and preview the spatial columns (`BEGIN_LAT`, `BEGIN_LON`). This provides instant feedback and proves the data is analysis-ready.

---
**Conclusion:** What started as a simple download script evolved into an intelligent, resilient, and fully automated data pipeline capable of handling dynamic URLs and local environment limitations.