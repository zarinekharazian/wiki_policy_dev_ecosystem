#!/usr/bin/env python3

import pandas as pd
import requests
import json

df = pd.read_csv('generated_data/policy_page_links-post03.csv')

for row in df[['lang', 'title']].iterrows():
    lang = row[1]['lang']
    base_url = 'https://' + lang + '.wikipedia.org/w/api.php'

    title = row[1]['title']

    params = {'titles' : title,
              'format' : 'json',
              'action' : 'query',
              'prop' : 'revisions',
              'rvprop' : 'ids|timestamp|user|userid|sha1|flags|content',
              'rvlimit' : 500 }

    while True:
        r = requests.get(base_url, params=params)
        
        data = r.json()
        final_data =  {'lang' : lang,
                       'title' : title,
                        'url' : r.url,
                        'payload' : data }

        # print out the final data
        print(json.dumps(final_data))

        if 'continue' in data:
            params.update(data['continue'])
            print(data)
        else:
            break


