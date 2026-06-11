import duckdb
import os

# 確認するファイルのパス
parquet_file = 'data/processed/storms_2024.parquet'

if not os.path.exists(parquet_file):
    print(f"Error: {parquet_file} not found. Run ./pipeline.sh first!")
else:
    print(f"Checking {parquet_file}...")
    conn = duckdb.connect()
    try:
        # 1. 件数を取得
        count = conn.execute(f"SELECT count(*) FROM '{parquet_file}'").fetchone()[0]
        print(f"✅ Success! Total rows: {count:,}")

        # 2. 緯度経度が入っているかプレビュー
        print("\n--- Spatial Data Preview ---")
        df = conn.execute(f"SELECT EVENT_TYPE, BEGIN_LAT, BEGIN_LON FROM '{parquet_file}' LIMIT 5").df()
        print(df)
        
        print("\n[VERIFIED] The data is ready for analysis in QGIS/PostGIS!")
    except Exception as e:
        print(f"❌ Error reading file: {e}")
