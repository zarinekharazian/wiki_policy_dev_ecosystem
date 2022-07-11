BIGSSS project on how wiki language editions evolve policies and influence each other

1.

Run SPARQL query to get the list of policy pages in the Wikidata category
"Wikimedia policy pages and guidelines" (Q4656150):
https://www.wikidata.org/wiki/Q4656150

  Script: 01-sparql_query.txt
  Query: https://w.wiki/5RCg
  Output: generated_data/policy_page_sitelinks-sparql.csv (symlink)

2.

Get the full list of policy pages for each of the policies listed in Wikidata
collected from the query in #1.

  Script: 02-collect_sitelinks_for_all_policy_articles.py 
  Inputs: generated_data/policy_page_sitelinks-sparql.csv (#1)
  Outputs: edge_list.csv policy_page_links.csv

3.

Go through the list of every policy in every wiki and identify (a) the time
that the policy was edited and (b) the order that the policy was created
relative to other policies in the list across and (c) between wikis.

This drops any policy pages (currently just one!) that appear to be missing.
This might need to be fixed in Wikidata.

  Script: 03-identify_policy_order.py
  Inputs: generated_data/policy_page_links.csv
  Outputs: generated_data/policy_page_links-post03.csv

4.

Script: python3 ./04-collect_revisions_json_api_data.py > generated_data/policy_page_revision_payloads.jsonl
Inputs: generated_data/policy_page_links-post03.csv
Outputs: generated_data/policy_page_revision_payloads.jsonl

