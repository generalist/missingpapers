#!/bin/bash

# nb - this requires jquery

# rm working/*

# find all DOIs

# all repositories will be hardcoded
# 
# nora
# soton

# all dates currently 2016 only

curl "http://nora.nerc.ac.uk/cgi/search/archive/advanced/export_nora_JSON.js?screen=Search&dataset=archive&_action_export=1&output=JSON&exp=0%7C1%7C-date%2Fcreators_name%2Ftitle%7Carchive%7C-%7Cdate%3Adate%3AALL%3AEQ%3A2016-%7Ctype%3Atype%3AANY%3AEQ%3Aarticle%7C-%7Ceprint_status%3Aeprint_status%3AANY%3AEQ%3Aarchive%7Cmetadata_visibility%3Ametadata_visibility%3AANY%3AEQ%3Ashow&n=" > working/json-nora

curl "http://eprints.soton.ac.uk/cgi/search/archive/advanced/export_eps_JSON.js?screen=Search&dataset=archive&_action_export=1&output=JSON&exp=0%7C1%7Ccontributors_name%2F-date%2Ftitle%7Carchive%7C-%7Cdate%3Adate%3AALL%3AEQ%3A2016-%7Ctype%3Atype%3AANY%3AEQ%3Aarticle%7C-%7Ceprint_status%3Aeprint_status%3AANY%3AEQ%3Aarchive%7Cmetadata_visibility%3Ametadata_visibility%3AANY%3AEQ%3Ashow&n=" > working/json-soton

