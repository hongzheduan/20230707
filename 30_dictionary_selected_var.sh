#!/bin/bash

cd /opt/notebooks
MYDIRPRO=/Work/hd48/pipeline_AnalyticData
RAW_DIR=$MYDIRPRO/prep_data/raw
DOCS_DIR=$MYDIRPRO/docs

### read in dictionary_20230606.tsv
dx download file-GVzgV90J0Z64yY15xPY3qFVK

function transpose_space {
    awk 'BEGIN{FS=" "}
              {for (i = 1;i <= NF; i++) col[i]=col[i] " " $i}
           END{
                for (i = 1;i <= NF; i++) {
                    sub(/^ /,"",col[i]);
                    print col[i]
                    }
              }'
}

SELECTED_FIELD="34 52 40007 1807 3526 40000 40001 191 2946 1845 845 6138 22020 22021 22189 3456 2887 3456 20117 21022 21003 53 54 21000 31 24010 24012 24014 21001 50 21002 2306 971 981 1011 6164 4080 4079 102 130920 131060 1160 1200 20533 42020 131286 131294 131036 130838 131042 131022 42018 2976 4056 3581 20007 40006 40013 40011 40008 22160 2966 3627 3894 42000 30760 30780 30870 30010 30000 30080 30630 30790 30030 30020 30050 30060 30750 30740 30700 30620 30650 30600 6155 6671 41270 41280 41271 41281 20110 20107 20199 20003 20446 25000 25003 25004 25005 25006 25007 25008 25009 25010 25011 25012 25019 25020 25025 25886 25887 25781"

echo $SELECTED_FIELD | transpose_space > field_trans.csv
awk 'BEGIN{OFS="\t"}NR==FNR{a[$1]++;next;}($1 in a){print}' field_trans.csv FS="\t" dictionary_20230606.tsv > dictionary_20230606_selected_no_head.tsv
cat dictionary_20230606.tsv | head -1 > dictionary_20230606_selected_head.tsv
cat dictionary_20230606_selected_head.tsv dictionary_20230606_selected_no_head.tsv > dictionary_20230606_selected.tsv

dx upload dictionary_20230606_selected.tsv --path $DOCS_DIR/dictionary_20230606_selected.tsv
dx upload dictionary_20230606_selected.tsv --path /AnalyticFiles/dictionary/dictionary_20230606_selected.tsv
