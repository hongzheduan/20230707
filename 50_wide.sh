#!/bin/bash

cd /opt/notebooks
MYDIRPRO_READ=/mnt/project/Work/hd48/pipeline_AnalyticData ## when read
MYDIRPRO=Work/hd48/pipeline_AnalyticData ## when write
RAW_DIR_READ=$MYDIRPRO_READ/prep_data/raw
RAW_DIR=$MYDIRPRO/prep_data/raw
DOCS_DIR=$MYDIRPRO/docs

### create mortality file

dx download -f $RAW_DIR/*.csv

# Prepare disease datasets and wide

function minvar {
  awk 'BEGIN{FS=OFS=","; minnum = "NA"}
        NR>1 {for (i = 3; i <= NF; i++)
            {
                if ($i < minnum)
                minnum=$i
            }
            $(NF+1) = minnum
            print
            minnum = "NA"
            }'
}
# for having date of onset, sequence is NF:dateonset;NF+1:AgeOnset;NF+2:IsIncid,NF+3:LSincid,NF+4:Duration
function adddisease {
    awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," $1.csv FS="," wide.csv |
    awk 'BEGIN{FS=OFS=","}
        NR>1{
            if ($NF !~ /NA/ && $NF !~ /^$/)
                {split($NF,a,"-");ageonset=(a[1]*365.25+a[2]*30.4167+a[3]-$6*365.25-$7*30.4167-15)/365.25;print $0,ageonset,1,ageonset,$15-ageonset}
            else
                {print $0,"NA",0,$15,"NA"}
            }' |
    sed 's/NA//g' > ${1}_2_nohead.csv
    OLD_HEAD=$(cat wide.csv | head -1)
    echo "$OLD_HEAD,OnsetDate_$2,AgeOnset_$2,IsIncid_$2,LSincid_$2,Duration_$2" > $1_2_head.csv
    cat $1_2_head.csv ${1}_2_nohead.csv > wide.csv
#     head -200
}
# for having age of onset, sequence is NF:AgeOnset;NF+1:IsIncid,NF+2:LSincid,NF+3:Duration
function adddisease2 {
    awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," $1.csv FS="," wide.csv |
    awk 'BEGIN{FS=OFS=","}
        NR>1{
            if ($NF !~ /NA/ && $NF !~ /^$/)
                {split($NF,a,"-");print $0,1,$NF,$15-$NF}
            else
                {print $0,0,$15,"NA"}
            }' |
    sed 's/NA//g' > ${1}_2_nohead.csv
    OLD_HEAD=$(cat wide.csv | head -1)
    echo "$OLD_HEAD,AgeOnset_$2,IsIncid_$2,LSincid_$2,Duration_$2" > $1_2_head.csv
    cat $1_2_head.csv ${1}_2_nohead.csv > wide.csv
#     head -200
}
# for allcancer but skin/lung, need to remove respective disease from no cancer group
function adddisease3 {
    awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," $1.csv FS="," wide.csv |
    awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," $3.csv FS="," - |
    awk 'BEGIN{FS=OFS=","}
        NR>1{
            if ($NF !~ /^$/ && $(NF-1) !~ /^$/)
                {$NF="NA";print $0,"NA","NA"}
            else if ($(NF-1) !~ /NA/ && $(NF-1) !~ /^$/)
                {$NF=1;split($NF,a,"-");print $0,$NF,$15-$(NF-1)}
            else
                {$NF=0;print $0,$15,"NA"}
            }' |
    sed 's/NA//g' > ${1}_2_nohead.csv
    OLD_HEAD=$(cat wide.csv | head -1)
    echo "$OLD_HEAD,AgeOnset_$2,IsIncid_$2,LSincid_$2,Duration_$2" > $1_2_head.csv
    cat $1_2_head.csv ${1}_2_nohead.csv > wide.csv
#     head -200
}
cut -d',' -f1-10,48-54 mortality_ukb.csv > mortality_ukb_sim.csv
cat mortality_ukb_sim.csv > wide.csv
adddisease "alzonset" "Alzheimer"
adddisease "MI" "MI"
adddisease "icd9_10_ad" "AD_ICD"
adddisease "G30" "AD_G30"
adddisease "icd9_10_adrd" "ADRD"
adddisease "icd9_10_adrdplus" "ADRDplus"
adddisease "icd9_10_adrelated" "ADrelated"
adddisease "AllCauseDementia" "AllCauseDementia"
adddisease "icd9_10_coloncancer" "ColonCancer"
adddisease "icd9_10_breastcancer" "BreastCancer"
adddisease "icd9_10_prostatecancer" "ProstateCancer"
adddisease "icd9_10_probheadtrauma" "Probheadtrauma"
adddisease "icd9_10_uterinecancer" "UterineCancer"
adddisease "icd9_10_gastriccancer" "GastricCancer"
adddisease "icd9_10_ColorectalCancer" "ColorectalCancer"
adddisease "icd9_10_depression2" "depression2"
adddisease "icd9_10_depression1" "depression1"
adddisease "icd9_10_pancreascancer" "PancreasCa"
adddisease "icd9_10_othernonspecifiedcancer" "OtherNonspecifiedCa"
adddisease "icd9_10_secondarycancer" "SecondaryCancer"
adddisease "icd9_10_othersolidslowcancer" "OtherSolidSlowCa"
adddisease "icd9_10_othersolidfastcancer" "OtherSoidFastCa"
adddisease "icd9_10_nonsolidcancer" "NonSolidCa"
adddisease "icd9_10_tracheabronchuslungca" "TracheaBronchusLungCa"
adddisease "icd9_10_colonrectumanuscancer" "ColonRectumAnusCa"
adddisease "icd9_10_breastcancer_Ver2" "BreastCancer_ver2"
adddisease "icd9_10_CardiovascularDis" "CardiovascularDis"
adddisease "icd9_10_CHF" "CHF"
adddisease "icd9_10_stroke" "stroke_ICD"
adddisease "icd9_10_MyocardialInfarction" "MI_ICD"
adddisease "icd9_10_CoronaryHeartDis" "CHD_ICD"
adddisease "icd9_10_VascularDementia" "VascularDementia"
adddisease "VascularDementia_F01" "VascularDementia2"
adddisease "icd9_10_MultipleSclerosis" "MultipleSclerosis"
adddisease "icd9_10_lungcancer" "LungCancer"
adddisease "MultipleSclerosis_G35" "MultipleSclerosis2"
adddisease "icd9_10_Parkinson" "ParkinsonDisease"
adddisease "Parkinson_G20" "ParkinsonDisease2"
adddisease "ALS" "ALS"
adddisease "hypertension_I15" "hypertension_I15"
adddisease "hypertension_I10" "hypertension_I10"

adddisease2 "angina" "angina"
adddisease2 "cancer" "cancer"
adddisease2 "diabetes_age" "diabetes"
adddisease2 "heartattack" "heartattack"
adddisease2 "stroke_age" "stroke"
adddisease2 "hbp" "hypertension"
adddisease2 "glioblastoma_min_age" "glioblastoma"
adddisease2 "melanoma_min_age" "melanoma"
adddisease2 "SkinCancerGlioblastoma" "SkinCancerGlioblastoma"
adddisease2 "CHD" "CHD"

adddisease3 "allcancer_but_skin_lung_ver2" "AllCancerButSkinLung2" "skinlungcancer"
adddisease3 "allcancer_but_skin_age_ver2_2" "AllCancerButSkin2" "SkinCancerGlioblastoma"

cat wide.csv > wide_ukb.csv
dx upload wide_ukb.csv --path $RAW_DIR/wide_ukb.csv
