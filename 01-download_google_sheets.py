#!/usr/bin/env python3 

import requests
import os.path

data_subdirectory = "data"

sheets = { "policy_page_sitelinks-sparql-VALIDATION.csv" : ("1VgmYxt_mnUQX1r04aB_QwjTZFEuWHKOMBSP_oGbqp6U", "602880122"),

           "wiki_level_metadata-20220707.csv" : ( "1uxMQU-KgdfPBSCZVdGChEQH_FR6JaTii0yQ6X9TBq40", "0" ) }


for filename, sheet_data in sheets.items():
    filename = os.path.join(data_subdirectory, filename)
    gsheet_id, gsheet_gid  = sheet_data
    url = f"https://docs.google.com/spreadsheets/d/{gsheet_id}/export?format=csv&id={gsheet_id}&gid={gsheet_gid}"
    rv = requests.get(url)
    csv_text = rv.content.decode('utf-8')
    with open(filename, "w") as f:
        f.write(csv_text)
    print(f"saved sheet: {filename}")

