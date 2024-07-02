BIGSSS project on how wiki language editions evolve policies and influence each other

1.

Run SPARQL query to get the list of policy pages in the Wikidata category
"Wikimedia policy pages and guidelines" (Q4656150):
https://www.wikidata.org/wiki/Q4656150

  Script: 01-sparql_query.txt
  Query: https://w.wiki/5RCg
  Output: data/policy_page_sitelinks-sparql.csv (symlink)

Download the csv from https://w.wiki/5RCg, rename it 'policy_page_sitelinks-sparql.csv' and put it in the data folder. 

2. Open policy_page_sitelinks-sparql.csv. Add columns called `include` and `category`, and `type`. For each policy, put include=TRUE if you want the policy to be included in the next step, and put the category of policy it is (e.g., enforcement, behavioral, etc.). In `type', put either policy or guideline.

3. 

Get the full list of policy pages for each of the policies listed in Wikidata
collected from the query in #1.

  Script: 02-collect_sitelinks_for_all_policy_articles.py 
  Inputs: data/policy_page_sitelinks-sparql-VALIDATION-ZARINE.csv (#1)
  Outputs: edge_list.csv policy_page_links.csv

4. 

Go through the list of every policy in every wiki and identify (a) the time
that the policy was edited and (b) the order that the policy was created
relative to other policies in the list across and (c) between wikis.

This drops any policy pages (currently just one!) that appear to be missing.
This might need to be fixed in Wikidata.

  Script: 03-identify_policy_order.py
  Inputs: data/policy_page_links.csv
  Outputs: data/policy_page_links-post03.csv

5. 

Script: python3 ./04-collect_revisions_json_api_data.py > data/policy_page_revision_payloads.jsonl
Inputs: data/policy_page_links-post03.csv
Outputs: data/policy_page_revision_payloads.jsonl

