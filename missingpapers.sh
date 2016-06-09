#!/bin/bash

# nb - this requires jq - https://stedolan.github.io/jq/

# all repositories will be hardcoded
# 
# nora
# soton
# open

# rm working/*

# all dates currently 2015-16 only, may make this adjustable for final version
# commented out to avoid spamming the same request at repos

# curl "http://nora.nerc.ac.uk/cgi/search/archive/advanced/export_nora_JSON.js?screen=Search&dataset=archive&_action_export=1&output=JSON&exp=0%7C1%7C-date%2Fcreators_name%2Ftitle%7Carchive%7C-%7Cdate%3Adate%3AALL%3AEQ%3A2015-2016%7Ctype%3Atype%3AANY%3AEQ%3Aarticle%7C-%7Ceprint_status%3Aeprint_status%3AANY%3AEQ%3Aarchive%7Cmetadata_visibility%3Ametadata_visibility%3AANY%3AEQ%3Ashow&n=" > working/json-nora

# curl "http://eprints.soton.ac.uk/cgi/search/archive/advanced/export_eps_JSON.js?screen=Search&dataset=archive&_action_export=1&output=JSON&exp=0%7C1%7Ccontributors_name%2F-date%2Ftitle%7Carchive%7C-%7Cdate%3Adate%3AALL%3AEQ%3A2015-2016%7Ctype%3Atype%3AANY%3AEQ%3Aarticle%7C-%7Ceprint_status%3Aeprint_status%3AANY%3AEQ%3Aarchive%7Cmetadata_visibility%3Ametadata_visibility%3AANY%3AEQ%3Ashow&n=" > working/json-soton

# curl "http://oro.open.ac.uk/cgi/search/archive/advanced/export_oro_JSON.js?screen=Search&dataset=archive&_action_export=1&output=JSON&exp=0%7C1%7C-date%2Fcreators_name%2Ftitle%7Carchive%7C-%7Cdate%3Adate%3AALL%3AEQ%3A2015-2016%7Ctype%3Atype%3AANY%3AEQ%3Aarticle%7C-%7Ceprint_status%3Aeprint_status%3AANY%3AEQ%3Aarchive%7Cmetadata_visibility%3Ametadata_visibility%3AANY%3AEQ%3Ashow&n=" > working/json-open

# now get the bits we care about - this cuts the size massively! - and tidy out DOI prefixes while we're at it (eprints is permissive over doi:xxx, DOI:xxx, etc)

jq '.[] | {eprintid, uri, doi: .id_number, status: .full_text_status}' working/json-nora | sed s'/doi://g' | sed 's/DOI: //g' > working/json-nora-trimmed
jq '.[] | {eprintid, uri, doi: .id_number, status: .full_text_status}' working/json-soton | sed s'/doi://g' | sed 's/DOI: //g' > working/json-soton-trimmed
jq '.[] | {eprintid, uri, doi, status: .full_text_status}' working/json-open | sed s'/doi://g' | sed 's/DOI: //g' > working/json-open-trimmed

# nb OU uses 'doi' not 'id_number'

# oneline versions for later

jq -c '.' working/json-nora-trimmed > working/json-nora-trimmed-oneline
jq -c '.' working/json-soton-trimmed > working/json-soton-trimmed-oneline
jq -c '.' working/json-open-trimmed > working/json-open-trimmed-oneline

# now quickly find any duplicates

jq -r '.doi' working/json-nora-trimmed | sort | grep -v null | uniq -d > working/nora-doi-dups
jq -r '.doi' working/json-soton-trimmed | sort | grep -v null | uniq -d > working/soton-doi-dups
jq -r '.doi' working/json-open-trimmed | sort | grep -v null | uniq -d > working/open-doi-dups

# make a little DOI duplicates report

echo "NORA DOI duplicates" > nora-dup-report
echo "" >> nora-dup-report
echo "These repository entries have the same DOI and may thus be about the same paper:" >> nora-dup-report
echo "" >> nora-dup-report

for i in `cat working/nora-doi-dups`; do
echo "doi:"$i":" >> nora-dup-report ;
echo `grep "$i" working/json-nora-trimmed-oneline | cut -d , -f 2 | sed 's/"uri":"//g' | sed 's/"//g'` >> nora-dup-report ;
echo "" >> nora-dup-report ;
done

# and soton

echo "Southampton DOI duplicates" > soton-dup-report
echo "" >> soton-dup-report
echo "These repository entries have the same DOI and may thus be about the same paper:" >> soton-dup-report
echo "" >> soton-dup-report

for i in `cat working/soton-doi-dups`; do
echo "doi:"$i":" >> soton-dup-report ;
echo `grep "$i" working/json-soton-trimmed-oneline | cut -d , -f 2 | sed 's/"uri":"//g' | sed 's/"//g'` >> soton-dup-report ;
echo "" >> soton-dup-report ;
done

# and open

echo "Open University DOI duplicates" > open-dup-report
echo "" >> open-dup-report
echo "These repository entries have the same DOI and may thus be about the same paper:" >> open-dup-report
echo "" >> open-dup-report

for i in `cat working/open-doi-dups`; do
echo "doi:"$i":" >> open-dup-report ;
echo `grep "$i" working/json-open-trimmed-oneline | cut -d , -f 2 | sed 's/"uri":"//g' | sed 's/"//g'` >> open-dup-report ;
echo "" >> open-dup-report ;
done

# now build a master list of DOIs, omitting nulls

rm working/doilist
jq -r '.doi' working/json-nora-trimmed | sort | uniq >> working/doilist
jq -r '.doi' working/json-soton-trimmed | sort | uniq >> working/doilist
jq -r '.doi' working/json-open-trimmed | sort | uniq >> working/doilist

cat working/doilist | grep -v "^null" | sort | uniq > working/master-dois
cat working/doilist | grep -v "^null" | sort | uniq -d > working/duplicate-dois

# now build the report

echo -e "# This report outlines papers which overlap between multiple repositories" > logfile.tsv # resetting logfile here
echo -e DOI"\t"NORA"\t"Open"\t"Southampton"\t" >> logfile.tsv

for i in `cat working/duplicate-dois` ; 
do grep $i working/json-nora-trimmed-oneline > working/nora-placeholder ;
grep $i working/json-open-trimmed-oneline > working/open-placeholder ;
grep $i working/json-soton-trimmed-oneline > working/soton-placeholder ;
echo -e $i"\t"`jq '. | {status}' working/nora-placeholder`"\t"`jq '. | {status}' working/open-placeholder`"\t"`jq '. | {status}' working/soton-placeholder` | sed "s/{ //g" | sed "s/ }//g" | sed "s/\"//g" | sed "s/status: //g" >> logfile.tsv ;
done
