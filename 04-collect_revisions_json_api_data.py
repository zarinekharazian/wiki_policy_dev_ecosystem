#!/usr/bin/env python3

import pandas as pd
import requests
import json

df = pd.read_csv('generated_data/policy_page_links-post03.csv')

for lang, title in df[['lang', 'title']].itertuples(index=False):
    base_url = 'https://' + lang + '.wikipedia.org/w/api.php'

    params = {'action' : 'query',
              'titles' : title,
              'format' : 'json',
              'prop' : 'revisions',
              'rvslots' : 'main',
              'rvprop' : 'ids|timestamp|user|userid|sha1|flags|content',
              'rvlimit' : 'max' }

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
        else:
            break


