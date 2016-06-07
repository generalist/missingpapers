#!/bin/bash

# nb - this requires jquery

# rm working/*

# find all DOIs

# all repositories will be hardcoded
# 
# nora
# soton

# all dates currently 2016 only

# curl "http://nora.nerc.ac.uk/cgi/search/archive/advanced/export_nora_JSON.js?screen=Search&dataset=archive&_action_export=1&output=JSON&exp=0%7C1%7C-date%2Fcreators_name%2Ftitle%7Carchive%7C-%7Cdate%3Adate%3AALL%3AEQ%3A2016-%7Ctype%3Atype%3AANY%3AEQ%3Aarticle%7C-%7Ceprint_status%3Aeprint_status%3AANY%3AEQ%3Aarchive%7Cmetadata_visibility%3Ametadata_visibility%3AANY%3AEQ%3Ashow&n=" > working/json-nora

# curl "http://eprints.soton.ac.uk/cgi/search/archive/advanced/export_eps_JSON.js?screen=Search&dataset=archive&_action_export=1&output=JSON&exp=0%7C1%7Ccontributors_name%2F-date%2Ftitle%7Carchive%7C-%7Cdate%3Adate%3AALL%3AEQ%3A2016-%7Ctype%3Atype%3AANY%3AEQ%3Aarticle%7C-%7Ceprint_status%3Aeprint_status%3AANY%3AEQ%3Aarchive%7Cmetadata_visibility%3Ametadata_visibility%3AANY%3AEQ%3Ashow&n=" > working/json-soton

# now get the bits we care about - this cuts the size massively! - and tidy out DOI prefixes while we're at it

jq '.[] | {eprintid, uri, doi: .id_number, status: .full_text_status}' working/json-nora | sed s'/doi://g' | sed 's/DOI: //g' > working/json-nora-trimmed
jq '.[] | {eprintid, uri, doi: .id_number, status: .full_text_status}' working/json-soton | sed s'/doi://g' | sed 's/DOI: //g' > working/json-soton-trimmed

# oneline versions for later

jq -c '.' working/json-nora-trimmed > working/json-nora-trimmed-oneline
jq -c '.' working/json-soton-trimmed > working/json-soton-trimmed-oneline


# now quickly find any duplicates

jq -r '.doi' working/json-nora-trimmed | sort | grep -v null | uniq -d > working/nora-doi-dups
jq -r '.doi' working/json-soton-trimmed | sort | grep -v null | uniq -d > working/soton-doi-dups

# make a little DOI duplicates report

echo "Southampton DOI duplicates" > soton-dup-report
echo "" >> soton-dup-report
echo "These repository entries have the same DOI and may thus be about the same paper:" >> soton-dup-report
echo "" >> soton-dup-report

for i in `cat working/soton-doi-dups`; do
echo "doi:"$i":" >> soton-dup-report ;
echo `grep "$i" working/json-soton-trimmed-oneline | cut -d , -f 2 | sed 's/"uri":"//g' | sed 's/"//g'` >> soton-dup-report ;
echo "" >> soton-dup-report ;
done


