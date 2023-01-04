import sys
import os
import json


def main():
    country_geojsons_path = "static_data/countries"
    extracts = []
    for filename in os.listdir(country_geojsons_path):
        if filename.endswith(".json"):
            country_geojson_file_path = os.path.join(country_geojsons_path, filename)
            country_code = os.path.splitext(
                os.path.basename(country_geojson_file_path)
            )[0]

            extracts.append(
                {
                    "output": f"data/mid/mapaction/{country_code}.pbf",
                    "output_format": "pbf",
                    "description": country_code,
                    "polygon": {
                        "file_type": "geojson",
                        "file_name": country_geojson_file_path,
                    },
                }
            )

    print(json.dumps({"extracts": extracts}))


if __name__ == "__main__":
    main()
