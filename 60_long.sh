#!/bin/bash

cd /opt/notebooks
MYDIRPRO_READ=/mnt/project/Work/hd48/pipeline_AnalyticData ## when read
MYDIRPRO=Work/hd48/pipeline_AnalyticData ## when write
RAW_DIR_READ=$MYDIRPRO_READ/prep_data/raw
RAW_DIR=$MYDIRPRO/prep_data/raw
DOCS_DIR=$MYDIRPRO/docs
# SAVE_DIR=AnalyticFiles/20230620 ## when write to final directory
SAVE_DIR=AnalyticFiles/20230707 ## when write to final directory

dx download -f $RAW_DIR/*.csv

# Prepare long
cat mortality_ukb.csv |
cut -d',' -f1-46,52-  |
head -1 |
awk 'BEGIN{FS=OFS=","}NR==1{print "instance",$0,"age","BMI","visit_date","center","climb","walk","walk_for_pleasure","DIY","light_heavy_DIY","DBP","SBP","height","weight","pulserate","weightchange","HDL","LDL","RBC","WBC","platelet","HCT","ApolipoproteinA","lipoproteinA","HGB","MCH","MCHC","HbA1C","glucose","Creatinine","ALT","AST","albumin","qualification_array","highestedu","edu1","edu2","edu3","VitA","VitB","VitC","VitD","VitE","VitB9","MultiVit","antibiotics","Sleepless","sleep_duration","benzodiazepine","zdrug","amitriptyline","tetracycline_all","antibiotics_all"}' > long_ukb_head.csv

cat mortality_ukb.csv |
cut -d',' -f1-46,52-  |
awk 'BEGIN{OFS=","}
    NR>1{for (i=0;i<=3;i++)
        {
            printf("%s,%s\n", i,$0)
        }
    }' > mortality_ukb_wave.csv

awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," age.csv FS="," mortality_ukb_wave.csv |  #age
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," BMI.csv FS="," - |  #BMI
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," date.csv FS="," - |  #visit date
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3;next}{$(NF+1)=a[$2];print}' FS="," center.csv FS="," - |  #center
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," climb.csv FS="," - |  #climb
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," walk.csv FS="," - |  #walk
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," walk_for_pleasure.csv FS="," - |  #walk_for_pleasure
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," DIY.csv FS="," - |  #DIY
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," light_heavy_DIY.csv FS="," - |  #light_heavy_DIY
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," DBP.csv FS="," - |  #DBP
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," SBP.csv FS="," - |  #SBP
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," height.csv FS="," - |  #Height
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," weight.csv FS="," - |  #weight
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," pulserate_long.csv FS="," - |  #pulse rate
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," weightchange.csv FS="," - |  #weightchange
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," hdl.csv FS="," - |  #hdl
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," ldl.csv FS="," - |  #ldl
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," rbc.csv FS="," - |  #rbc
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," wbc.csv FS="," - |  #wbc
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," plt.csv FS="," - |  # plt
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," hct.csv FS="," - |  # hct
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," apolipA.csv FS="," - |  # apolipoprotein A
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," lipoproteinA.csv FS="," - |  # lipoproteinA
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," hgb.csv FS="," - |  # HGB
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," mch.csv FS="," - |  # MCH
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," mchc.csv FS="," - |  # MCHC
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," a1c.csv FS="," - |  # HbA1C
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," glucose.csv FS="," - |  # glucose
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," Creatinine.csv FS="," - |  # Creatinine
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," alt.csv FS="," - |  # alt
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," ast.csv FS="," - |  # ast
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," albumin.csv FS="," - |  # Albumin
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4OFS$5OFS$6OFS$7OFS$8;next}{$(NF+1)=a[$2,$1];print}' FS="," highedu_long.csv FS="," - |  # high edu
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$2]=$3OFS$4OFS$5OFS$6OFS$7OFS$8OFS$9;next}{$(NF+1)=a[$2,$1];print}' FS="," vitamin_2.csv FS="," - |  # vitamins
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," antibiotics.csv FS="," - |  # antibiotics
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," Sleepless.csv FS="," - |  # sleepless
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," sleep_duration_long.csv FS="," - |  # sleep_duration
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," benzodiazepine2.csv FS="," - |  # benzodiazepine
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," zdrug2.csv FS="," - |  # zdrug
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," amitriptyline2.csv FS="," - |  # amitriptyline
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," tetracycline_all_2.csv FS="," - |  # tetracycline_all
awk 'BEGIN{OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$2,$1];print}' FS="," antibiotics_all2.csv FS="," - |
sed 's/NA//g' > long_ukb_nohead.csv

cat long_ukb_head.csv long_ukb_nohead.csv > long_ukb.csv

dx upload long_ukb.csv --path $RAW_DIR/long_ukb.csv

# wrap up
dx upload long_ukb.csv --path $SAVE_DIR/long_ukb.csv
dx upload wide_ukb.csv --path $SAVE_DIR/wide_ukb.csv
dx upload mortality_ukb.csv --path $SAVE_DIR/mortality_ukb.csv

git clone https://github.com/hongzheduan/20230707
dx upload /opt/notebooks/20230707/*.sh --path AnalyticFiles/20230707/program
