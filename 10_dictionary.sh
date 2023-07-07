#!/bin/bash

cd /opt/notebooks
MYDIRPRO=/Work/hd48/pipeline_AnalyticData
RAW_DIR=$MYDIRPRO/prep_data/raw
DOCS_DIR=$MYDIRPRO/docs

dx download /Showcase\ metadata/field.tsv
dx download file-GVGj33QJXZBBK788FzgkpxKZ ##pheno_AD-Infect_all_001_v20230419_FN_raw_participant.csv
dx download file-GVVF7Y0JJB8YbkqFY8P4g3x7 ##pheno_AD-Infect_all_002_v20230419_FN_raw_participant.csv
dx download file-GVVFJ7jJK62Y6VYkxY8F3KF5 ##pheno_AD-Infect_all_003_v20230419_FN_raw_participant.csv
dx download file-GVVFXvjJ016z157gYvJq60vf ##pheno_AD-Infect_all_004_v20230419_FN_raw_participant.csv
dx download file-GVVFj08Jb2Kx8JXzBq9zk3qj ##pheno_AD-Infect_all_005_v20230419_FN_raw_participant.csv
dx download file-GVVFvqjJX2532VkqKxq9g2z9 ##pheno_AD-Infect_all_006_v20230419_FN_raw_participant.csv
dx download file-GVVGFVQJ239Z3P5088xKK7GQ ##pheno_AD-Infect_all_007_v20230419_FN_raw_participant.csv
dx download file-GVVJ5QjJf7V3bkqFY8P4gQVK ##pheno_AD-Infect_all_008_v20230419_FN_raw_participant.csv
dx download file-GVVJBxQJ135XKvqKQk3z6qYV ##pheno_AD-Infect_all_009_v20230419_FN_raw_participant.csv
dx download file-GVVJQPjJxvyqvXg0Vb1gFv4z ##pheno_AD-Infect_all_010_v20230419_FN_raw_participant.csv
dx download file-GVVJbB0JBJK7GqKkyKvvfVZb ##pheno_AD-Infect_all_011_v20230419_FN_raw_participant.csv
dx download file-GVVJq5jJ6Z2fZ5y3JFX0pbp6 ##pheno_AD-Infect_all_012_v20230419_FN_raw_participant.csv
dx download file-GVVJzPQJ7X443P5088xKKZv2 ##pheno_AD-Infect_all_013_v20230419_FN_raw_participant.csv
dx download file-GVzb9F8Jz453Q3fz0y6Y5JJJ ##pheno_AD-Infect_all_014_v20230419_FN_raw_participant.csv
dx download file-GVzbPxQJZBpFG8yg6kf1p8gQ ##pheno_AD-Infect_all_015_v20230419_FN_raw_participant.csv

for FILE_SEQUENCE in {1..15};do
  if [ "$FILE_SEQUENCE" -le 9 ]; then
    FILE_NAME="pheno_AD-Infect_all_00${FILE_SEQUENCE}_v20230419_FN_raw_participant"
  else
    FILE_NAME="pheno_AD-Infect_all_0${FILE_SEQUENCE}_v20230419_FN_raw_participant"
  fi;

  cat ${FILE_NAME}.csv |
  head -1 |
  awk 'BEGIN{FS=","}{for (i=1;i<=NF;i++) col[i]=col[i] " " $i}END{for (i=1;i<=NF;i++) {sub(/^ /,"",col[i]);print col[i]}}' |
  awk 'BEGIN{OFS="\t"}{$(NF+1)=NR;print}' |
  awk 'BEGIN{FS=OFS="\t"}{split($1,a,"_");print a[1],a[2],a[3],$2}' |
  awk -v fn="${FILE_SEQUENCE}" 'BEGIN{FS=OFS="\t"}{printf("%s\t%s\n",$0,fn)}' |
  sed 's/p//g' | sed 's/i//g' | sed 's/a//g' | sed 's/ed/eid/g' >> dictional_13_3.tab
done;

awk 'BEGIN{OFS="\t";}NR==FNR{a[$1]=$2;next}{$(NF+1)=a[$1];print}' FS="\t" field.tsv FS="\t" dictional_13_3.tab |
awk 'BEGIN{FS=OFS="\t";printf("%s\t%s\t%s\t%s\t%s\t%s\n","field_id","instance","array","column","cohort","description")}{print}'>final.tsv

dx upload final.tsv --path $DOCS_DIR/dictionary.tsv
dx upload final.tsv --path /AnalyticFiles/dictionary/dictionary_20230606.tsv
