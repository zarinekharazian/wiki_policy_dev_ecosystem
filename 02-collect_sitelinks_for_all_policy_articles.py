#!/usr/bin/env python3

import requests
from bs4 import BeautifulSoup
import pandas as pd
import re

query = pd.read_csv('data/policy_page_sitelinks-sparql.csv')
url_list = query.item.apply(lambda x: ('https://www.wikidata.org/wiki/'+x.split('/')[-1]))

# merge in data from manual validation
val_data = pd.read_csv("data/policy_page_sitelinks-sparql-VALIDATION.csv")[["item", "include", "concern"]]

# print(val_data["include"].value_counts())
# print(val_data["concern"].value_counts())
val_data["concern"] = val_data["concern"] == True

# drop the stuff we've decided to drop
query = pd.merge(query, val_data, on="item")
query = query[query["include"]]
query = query.drop(columns="include")

# url = 'https://www.wikidata.org/wiki/Q4616152'
df_list = []
qlink_list = []
for url in url_list:
  print(url)
  data = requests.get(url)
  soup = BeautifulSoup(data.content, "html.parser")
  sitelinks = soup.find_all("div", {"class": "wikibase-sitelinklistview"})[0].find_all("li")
  df = pd.DataFrame([[item.find_next("a").get("hreflang"),item.find_next("a").get("title"),
                      item.find_next("a").get("href")]
                    for item in sitelinks],
                    columns=("hreflang",'title',"href"))
  qlink_list+=[url.split('/')[-1]]*df.shape[0]
  df_list.append(df)

df_all=pd.concat(df_list)
df_all['QID']=qlink_list

## add qids to the query frame
query = query.assign(QID = query["item"].apply(lambda x: re.sub(r'.*/', '', x)))

df_all = pd.merge(df_all, query[["QID", "itemLabel"]], on=["QID"])
df_all = df_all.rename(columns = {"hreflang" : "lang_href", "title" : "page_title", "href" : "url", "QID": "QID", "itemLabel" : "policy_name_en"})

df_all['lang'] = df_all['url'].apply(lambda x: x.split('/')[2].split('.')[0] )

df_all = df_all[["lang", "QID", "url", "lang_href", "policy_name_en"]]

## output the edge list and the full list of policy information
df_all[['lang', 'QID', 'policy_name_en']].to_csv('data/edge_list.csv', index=False)

df_all.to_csv('data/policy_page_links.csv', index=False)

