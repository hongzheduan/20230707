#!/bin/bash

cd /opt/notebooks

MYDIRPRO_READ=/mnt/project/Work/hd48/pipeline_AnalyticData ## when read
MYDIRPRO=Work/hd48/pipeline_AnalyticData ## when write
RAW_DIR_READ=$MYDIRPRO_READ/prep_data/raw
RAW_DIR=$MYDIRPRO/prep_data/raw
DOCS_DIR=$MYDIRPRO/docs

git clone https://github.com/hongzheduan/scripts

### read in all source data
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

### read in dictionary_20230606.tsv
dx download file-GVzgV90J0Z64yY15xPY3qFVK

awk 'BEGIN{FS=OFS=","}{print $1,$1}' pheno_AD-Infect_all_001_v20230419_FN_raw_participant.csv > id.csv

function readvar {
    cat id.csv | sed 's/,$/,NA/g' > ${DS_NAME}.csv
    for TARGET in ${TARGET_FIELDS};do
      N_TARGET=$(awk -v target="$TARGET" 'BEGIN{FS=OFS="\t"}$1==target{printf("%s_%s\n", $5,$4)}' dictionary_20230606.tsv | wc -l)
      if [ $N_TARGET == 0 ]; then
          echo field $TARGET has 0 records
          continue
          fi;
      for EACH_TARGET in $(eval echo "{1..$N_TARGET}");do
          COHORT_N=$(awk -v target="$TARGET" 'BEGIN{FS=OFS="\t"}$1==target{printf("%s_%s\n", $5,$4)}' dictionary_20230606.tsv | head -${EACH_TARGET} | tail -1 | awk '{split($1,a,"_"); print a[1]}')
          COLUMN_N=$(awk -v target="$TARGET" 'BEGIN{FS=OFS="\t"}$1==target{printf("%s_%s\n", $5,$4)}' dictionary_20230606.tsv | head -${EACH_TARGET} | tail -1 | awk '{split($1,a,"_"); print a[2]}')
          echo field $TARGET has $N_TARGET records, working on cohort number ${COHORT_N} and column number ${COLUMN_N}
          if [ "$COHORT_N" -le 9 ]; then
              ANALYRIC_FILE_NAME="pheno_AD-Infect_all_00${COHORT_N}_v20230419_FN_raw_participant"
          else
              ANALYRIC_FILE_NAME="pheno_AD-Infect_all_0${COHORT_N}_v20230419_FN_raw_participant"
          fi;
          awk -v var="$COLUMN_N" 'BEGIN{FS=OFS=","}{print $1,$var}' ${ANALYRIC_FILE_NAME}.csv |
          sed 's/,$/,NA/g' |
          awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$2;next}{$(NF+1)=a[$1];print}' FS="," - FS="," ${DS_NAME}.csv > ${DS_NAME}2.csv
          cat ${DS_NAME}2.csv > ${DS_NAME}.csv
       done;
    done;
    rm ${DS_NAME}2.csv
}
# function isnum(n) { return n ~ /^[+-]?[0-9]+[.]?[0-9]*$/ }

function maxvar {
  awk 'BEGIN{FS=OFS=","; maxnum=-10000}
       NR>1{for (i = 3; i <= NF; i++)
              {if ($i > maxnum) maxnum=$i}
            $(NF+1) = maxnum
            print
            maxnum=-10000}'
}

function widetolong {
  awk 'BEGIN{FS=OFS=","}
      NR>1{for (i = 3; i <= NF; i++)
              {
                  printf("%s,%s,%s\n", $1,i-3,$i)
              }
          }'
}
function widetolong23 {
  awk 'BEGIN{FS=OFS=","}
      NR>1{for (i = 3; i <= NF; i++)
              {
                  printf("%s,%s,%s\n", $1,i-1,$i)
              }
          }'
}
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
function widemeantolong {
    awk 'BEGIN{FS=OFS=","}
        NR>1{for (i = 3; i <= NF; i=i+2)
                {
                    if ($i != "NA")
                        {hrsum=$i;hrnum=1}
                    if ($(i+1) != "NA")
                        {hrsum=hrsum+$(i+1); hrnum=hrnum+1}
                    if ($i != "NA" || $(i+1) != "NA")
                        {printf("%s,%s,%s\n", $1,(i-3)/2,hrsum/hrnum)}
                    else
                        {printf("%s,%s,%s\n", $1,(i-3)/2,"NA")}
                    hrnum=0;hrsum=0
                }
            }
        '
}
function longmultitolongeach {
    awk 'BEGIN{FS=OFS=","}
        NR>1 {for (i = 3;i <= NF; i++)
        {
            {printf("%s,%s,%s\n", $1,$2,$i)}
        }
    }'
}
function transpose {
    awk 'BEGIN{FS=","}
              {for (i = 1;i <= NF; i++) col[i]=col[i] " " $i}
           END{
                for (i = 1;i <= NF; i++) {
                    sub(/^ /,"",col[i]);
                    print col[i]
                    }
              }'
}
## year of birth
TARGET_FIELDS="34";DS_NAME="yearbirth";readvar
dx upload ${DS_NAME}.csv --path $RAW_DIR/${DS_NAME}.csv

# ### month of birth
TARGET_FIELDS="52";DS_NAME="monthbirth";readvar
dx upload ${DS_NAME}.csv --path $RAW_DIR/${DS_NAME}.csv

### age of death
TARGET_FIELDS="40007";DS_NAME="deathage";readvar
cat deathage.csv | sed 's/NA/-10000/g' | maxvar | sed 's/-10000/NA/g' | cut -d',' -f1,2,5 |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","AgeDeath")}{print}'> ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

# ### Age of Death of father
TARGET_FIELDS="1807";DS_NAME="deathage_father";readvar
cat ${DS_NAME}.csv |
sed 's/NA/-10000/g' | maxvar |
sed 's/-10000/NA/g' | sed 's/-1/NA/g' | sed 's/-3/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","deathage_father")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv


# ### Age of Death of mother
TARGET_FIELDS="3526";DS_NAME="deathage_mother";readvar
cat ${DS_NAME}.csv |
sed 's/NA/-10000/g' | maxvar |
sed 's/-10000/NA/g' | sed 's/-1/NA/g' | sed 's/-3/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","deathage_mother")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

# ### Date of Death
# ## This info is also used to create last follow-up date!
TARGET_FIELDS="40000";DS_NAME="deathdate";readvar
cat ${DS_NAME}.csv |
sed 's/NA/-10000/g' | maxvar |
sed 's/-10000/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","deathage_mother")}{print}'> ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

## Cause of Death
TARGET_FIELDS="40001";DS_NAME="deathcause";readvar
cat ${DS_NAME}.csv |
sed 's/NA/-10000/g' | maxvar | sed 's/-10000/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","deathcause")}{print}'> ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv


## last follow-up date, last update is 2017-05-01
TARGET_FIELDS="191";DS_NAME="lastfudate";readvar
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," $RAW_DIR_READ/deathdate.csv FS="," lastfudate.csv |
sed 's/NA/-10000/g' | maxvar | sed 's/-10000/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
sed 's/NA/2017-05-01/g' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","lastfudate")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Age at assessment for father
## 0: initial assessment (2006-2010); 1: first repeat assessment (2012-2013); 2: imaging visit (2014+); 3: first repeat imaging visit (2019+)
TARGET_FIELDS="2946";DS_NAME="age_father";readvar
cat ${DS_NAME}.csv | widetolong |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","age_father")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### last follow up for father
# 0: initial assessment (2006-2010); 1: first repeat assessment (2012-2013); 2: imaging visit (2014+); 3: first repeat imaging visit (2019+)
TARGET_FIELDS="2946";DS_NAME="lastfuage_father";readvar
cat ${DS_NAME}.csv |
sed 's/NA/-10000/g' | maxvar |
sed 's/-10000/NA/g' | sed 's/-1/NA/g' | sed 's/-3/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","lastfuage_father")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### father's age at recruitment of participants
TARGET_FIELDS="2946";DS_NAME="ltmort_father";readvar
cat $DS_NAME.csv |
minvar |
sed 's/-1/NA/g' | sed 's/-3/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","ltmort_father")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Age at assessment for mother
TARGET_FIELDS="1845";DS_NAME="age_mother";readvar
cat ${DS_NAME}.csv | widetolong |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","age_mother")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### last follow up for mother
##0: initial assessment (2006-2010); 1: first repeat assessment (2012-2013); 2: imaging visit (2014+); 3: first repeat imaging visit (2019+)
TARGET_FIELDS="1845";DS_NAME="lastfuage_mother";readvar
cat ${DS_NAME}.csv |
sed 's/NA/-10000/g' | maxvar |
sed 's/-10000/NA/g' | sed 's/-1/NA/g' | sed 's/-3/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","lastfuage_mother")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### mother's age at recruitment of participants
TARGET_FIELDS="1845";DS_NAME="ltmort_mother";readvar
cat $DS_NAME.csv |
minvar |
sed 's/-1/NA/g' | sed 's/-3/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","ltmort_mother")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv


### Age completed full time education
TARGET_FIELDS="845";DS_NAME="fulleduage";readvar
cat $DS_NAME.csv |
sed 's/NA/-10000/g' | maxvar |
sed 's/-10000/NA/g' | sed 's/-1/NA/g' | sed 's/-3/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","fulleduage")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### college degree
TARGET_FIELDS="6138";DS_NAME="highedu";readvar

lvl.100305 <- c(-7,-3,1,2,3,4,5,6)
lbl.100305 <- c("None of the above","Prefer not to answer","College or University degree","A levels/AS levels or equivalent (hd: required for college entrance)","O levels/GCSEs or equivalent (hd:US high school diploma)","CSEs or equivalent (hd: predecessor of A/O level)","NVQ or HND or HNC or equivalent","Other professional qualifications eg: nursing, teaching")

awk 'BEGIN{FS=OFS=","}{split($3,a,"\|");split($4,b,"\|");split($5,c,"\|");split($6,d,"\|");print $1,$2,a[1],a[2],a[3],a[4],a[5],a[6],b[1],b[2],b[3],b[4],b[5],b[6],c[1],c[2],c[3],c[4],c[5],c[6],d[1],d[2],d[3],d[4],d[5],d[6]}' highedu.csv |
sed 's/-7/NA/g' |
sed 's/-3/NA/g' |
sed 's/,,/,NA,/g' |
sed 's/,,/,NA,/g' |
sed 's/,$/,NA/g' |
minvar |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","highestedu")}{print}' > highedu2.csv

awk 'BEGIN{FS=OFS=","}{split($3,a,"\|");split($4,b,"\|");split($5,c,"\|");split($6,d,"\|");print $1,a[1],a[2],a[3],a[4],a[5],a[6],b[1],b[2],b[3],b[4],b[5],b[6],c[1],c[2],c[3],c[4],c[5],c[6],d[1],d[2],d[3],d[4],d[5],d[6]}' highedu.csv |
sed 's/-3/NA/g' |
sed 's/,,/,NA,/g' |
sed 's/,,/,NA,/g' |
sed 's/,$/,NA/g' |
awk 'BEGIN{FS=OFS=","}
    NR>1{print $0,$2"|"$3"|"$4"|"$5"|"$6"|"$7"|"$8"|"$9"|"$10"|"$11"|"$12"|"$13"|"$14"|"$15"|"$16"|"$17"|"$18"|"$19"|"$20"|"$21"|"$22"|"$23"|"$24"|"$25}' |
awk 'BEGIN{FS=OFS=","}
    {if ($NF ~ /1/) print $0,"1";
      else if ($NF ~ /5/) print $0,"5";
      else if ($NF ~ /6/) print $0,"6";
      else if ($NF ~ /2/) print $0,"2";
      else if ($NF ~ /3/) print $0,"3";
      else if ($NF ~ /4/) print $0,"4";
      else if ($NF ~ /7/) print $0,"-7";
      else print $0,"NA"
    }' |
awk 'BEGIN{FS=OFS=","}
    {if ($26 ~ /1/) print $0,"1";
      else if ($26 ~ /5|6|2|3|4|7/) print $0,"0";
      else print $0,"NA"
    }' |
awk 'BEGIN{FS=OFS=","}
    {if ($26 ~ /1|2|5|6/) print $0,"1";
      else if ($26 ~ /3|4|7/) print $0,"0";
      else print $0,"NA"
    }' |
awk 'BEGIN{FS=OFS=","}
    {if ($26 ~ /1/) print $0,"2";
      else if ($26 ~ /2|5|6/) print $0,"1";
      else if ($26 ~ /4|3|7/) print $0,"0"
      else print $0,"NA"
    }' |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$26,$27,$28,$29,$30}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s,%s,%s,%s\n","eid","eid","qualification_array","highestedu","edu1","edu2","edu3")}{print}' > highedu_wide.csv

dx upload highedu_wide.csv --path $RAW_DIR/highedu_wide.csv

awk 'BEGIN{FS=OFS=","}{split($3,a,"\|");split($4,b,"\|");split($5,c,"\|");split($6,d,"\|");print $1,a[1],a[2],a[3],a[4],a[5],a[6],b[1],b[2],b[3],b[4],b[5],b[6],c[1],c[2],c[3],c[4],c[5],c[6],d[1],d[2],d[3],d[4],d[5],d[6]}' highedu.csv |
sed 's/-3/NA/g' |
sed 's/,,/,NA,/g' |
sed 's/,,/,NA,/g' |
sed 's/,$/,NA/g' |
awk 'BEGIN{FS=OFS=","}
    NR>1{print $1,"0",$2,$3,$4,$5,$6,$7,$2"|"$3"|"$4"|"$5"|"$6"|"$7}
    NR>1{print $1,"1",$8,$9,$10,$11,$12,$13,$8"|"$9"|"$10"|"$11"|"$12"|"$13}
    NR>1{print $1,"2",$14,$15,$16,$17,$18,$19,$14"|"$15"|"$16"|"$17"|"$18"|"$19}
    NR>1{print $1,"3",$20,$21,$22,$23,$24,$25,$20"|"$21"|"$22"|"$23"|"$24"|"$25}
    ' |
awk 'BEGIN{FS=OFS=","}
    {if ($NF ~ /1/) print $0,"1";
      else if ($NF ~ /5/) print $0,"5";
      else if ($NF ~ /6/) print $0,"6";
      else if ($NF ~ /2/) print $0,"2";
      else if ($NF ~ /3/) print $0,"3";
      else if ($NF ~ /4/) print $0,"4";
      else if ($NF ~ /7/) print $0,"-7";
      else print $0,"NA"
    }' |
awk 'BEGIN{FS=OFS=","}
    {if ($9 ~ /1/) print $0,"1";
        else if ($9 ~ /5|6|2|3|4|7/) print $0,"0";
        else print  $0,"NA"
    }' |
awk 'BEGIN{FS=OFS=","}
    {if ($9 ~ /1|2|5|6/) print $0,"1";
        else if ($9 ~ /3|4|7/) print $0,"0";
        else print  $0,"NA"
    }' |
awk 'BEGIN{FS=OFS=","}
    {if ($9 ~ /1/) print $0,"2";
        else if ($9 ~ /2|5|6/) print $0,"1";
        else if ($9 ~ /4|3|7/) print $0,"0"
        else print  $0,"NA"
    }' |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$2,$9,$10,$11,$12,$13}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s,%s,%s,%s,%s\n","eid","eid","instance","qualification_array","highestedu","edu1","edu2","edu3")}{print}' > highedu_long.csv

dx upload highedu_long.csv --path $RAW_DIR/highedu_long.csv


### used in genetic PC
TARGET_FIELDS="22020";DS_NAME="UsedInGeneticPC";readvar
# cat $DS_NAME.csv |
# awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","UsedInGeneticPC")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}.csv --path $RAW_DIR/${DS_NAME}.csv

## genetic kinship to other participants
TARGET_FIELDS="22021";DS_NAME="GeneticKinshipToOther";readvar
cat $DS_NAME.csv |
sed 's/-1/NA/g'  > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Townsend deprivation index
TARGET_FIELDS="22189";DS_NAME="TownsendIndex";readvar
# cat $DS_NAME.csv |
# awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","TownsendIndex")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}.csv --path $RAW_DIR/${DS_NAME}.csv

### Number of cigarettes currently smoked daily (current cigarette smokers)
TARGET_FIELDS="3456";DS_NAME="cignum";readvar
cat $DS_NAME.csv |
sed 's/-3/NA/g' |
sed 's/-10/NA/g' |
sed 's/-1/NA/g' |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","cignum")}{print}' > ${DS_NAME}_2.csv

dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}_long.csv

### Ever smoked
cat $DS_NAME.csv |
sed 's/NA/-10000/g' | maxvar | sed 's/-10000/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","eversmoke")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Alcohol drinker status
### lvl.0090 <- c(-3,0,1,2)
### lbl.0090 <- c("Prefer not to answer","Never","Previous","Current")
TARGET_FIELDS="20117";DS_NAME="drinker";readvar

cat $DS_NAME.csv |
sed 's/-3/NA/g' |
sed 's/NA/-10000/g' | maxvar | sed 's/-10000/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","drinker")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv


### Age at recruitment
TARGET_FIELDS="21022";DS_NAME="recruitage";readvar
cat $DS_NAME.csv |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","recruitage")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Age when attended assessment centre
### 0: initial assessment (2006-2010); 1: first repeat assessment (2012-2013); 2: imaging visit (2014+); 3: first repeat imaging visit (2019+)
TARGET_FIELDS="21003";DS_NAME="age";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","age")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv


### Date of attending assessment centre
TARGET_FIELDS="53";DS_NAME="date";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","date")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv


### UK Biobank assessment centre (code 10)
## 0: initial assessment (2006-2010); 1: first repeat assessment (2012-2013); 2: imaging visit (2014+); 3: first repeat imaging visit (2019+)
TARGET_FIELDS="54";DS_NAME="center";readvar
cat $DS_NAME.csv > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

# ### Ethnic background
# ### lvl.1001 <- c(-3,-1,1,2,3,4,5,6,1001,1002,1003,2001,2002,2003,2004,3001,3002,3003,3004,4001,4002,4003)
# ### lbl.1001 <- c("Prefer not to answer","Do not know","White","Mixed","Asian or Asian British","Black or Black British","Chinese","Other ethnic group","British","Irish","Any other white background","White and Black Caribbean","White and Black African","White and Asian","Any other mixed background", "Indian", "Pakistani","Bangladeshi","Any other Asian background","Caribbean","African","Any other Black background")

TARGET_FIELDS="21000";DS_NAME="race";readvar
cat $DS_NAME.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$3}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Sex
TARGET_FIELDS="31";DS_NAME="sex";readvar
dx upload ${DS_NAME}.csv --path $RAW_DIR/${DS_NAME}.csv

### Inverse distance to the nearest road
TARGET_FIELDS="24010";DS_NAME="Inverse_distance_nearest_road";readvar
dx upload ${DS_NAME}.csv --path $RAW_DIR/${DS_NAME}.csv


### Inverse distance to the nearest major road
TARGET_FIELDS="24012";DS_NAME="Inverse_dist_nearest_major_road";readvar
dx upload ${DS_NAME}.csv --path $RAW_DIR/${DS_NAME}.csv

### Close to major road
TARGET_FIELDS="24014";DS_NAME="Close_to_major_road";readvar
dx upload ${DS_NAME}.csv --path $RAW_DIR/${DS_NAME}.csv

### Body mass index (BMI: kg/m2)
## 0: initial assessment (2006-2010); 1: first repeat assessment (2012-2013); 2: imaging visit (2014+); 3: first repeat imaging visit (2019+)
TARGET_FIELDS="21001";DS_NAME="BMI";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","BMI")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_.csv --path $RAW_DIR/${DS_NAME}.csv

### Standing height (cm, changed to m)
# 0: initial assessment (2006-2010); 1: first repeat assessment (2012-2013); 2: imaging visit (2014+); 3: first repeat imaging visit (2019+)
TARGET_FIELDS="50";DS_NAME="height";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}
          {if ($NF!~/NA/)
              print $1,$1,$2,$NF/100
           else
              print $1,$1,$2,"NA"}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","height")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_.csv --path $RAW_DIR/${DS_NAME}.csv

### Weight (kg)
# 0: initial assessment (2006-2010); 1: first repeat assessment (2012-2013); 2: imaging visit (2014+); 3: first repeat imaging visit (2019+)
TARGET_FIELDS="21002";DS_NAME="weight";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","weight")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### weight loss (0	No - weigh about the same, 2	Yes - gained weight, 3	Yes - lost weight)
TARGET_FIELDS="2306";DS_NAME="weightchange";readvar
cat $DS_NAME.csv |
widetolong |
sed 's/-3/NA/g' |
sed 's/-1/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","weightchange")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Frequency of stair climbing in last 4 weeks
TARGET_FIELDS="943";DS_NAME="climb";readvar
cat climb.csv |
widetolong |
sed 's/-3/NA/g' |
sed 's/-1/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","climb")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Frequency of walking for pleasure in last 4 weeks
TARGET_FIELDS="971";DS_NAME="walk";readvar
cat $DS_NAME.csv |
widetolong |
sed 's/-3/NA/g' |
sed 's/-1/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","walk")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv


# ### Duration walking for pleasure (field 981 is still not available)
TARGET_FIELDS="981";DS_NAME="walktime";readvar
# cut -d$'\t' -f1,826-829 $MYDIRPRO/ukb669128.tab > $MYDIRPRO_Z/prep_data/raw/walktime.tab
# awk -f $MYDIR/widetolong $MYDIRPRO_Z/prep_data/raw/walktime.tab |
# awk 'BEGIN{FS=OFS="\t"}($NF!=-1 && $NF!=-3){print}' > $MYDIRPRO_Z/prep_data/raw/walktime2.tab

### Frequency of light DIY in last 4 weeks
TARGET_FIELDS="1011";DS_NAME="DIY";readvar
cat $DS_NAME.csv |
widetolong |
sed 's/-3/NA/g' |
sed 's/-1/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","DIY")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### field 6164: physical activity in last 4 weeks (for light DIY and heavy DIY)
TARGET_FIELDS="6164";DS_NAME="physical_activity";readvar
cat $DS_NAME.csv |
widetolong |
sed 's/-3/NA/g' |
sed 's/-7/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=","}$4~/1/{print $1,$2,$3,1}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","walk_for_pleasure")}{print}' > walk_for_pleasure.csv
dx upload walk_for_pleasure.csv --path $RAW_DIR/walk_for_pleasure.csv

cat $DS_NAME.csv |
widetolong |
sed 's/-3/NA/g' |
# sed 's/-1/NA/g' |
sed 's/-7/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=","}$4~/4|5/{print $1,$2,$3,1}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","light_heavy_DIY")}{print}' > light_heavy_DIY.csv
dx upload light_heavy_DIY.csv --path $RAW_DIR/light_heavy_DIY.csv

### Systolic blood pressure
TARGET_FIELDS="4080";DS_NAME="SBP";readvar
cat $DS_NAME.csv |
widemeantolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","SBP")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Diastolic blood pressure
TARGET_FIELDS="4079";DS_NAME="DBP";readvar
cat $DS_NAME.csv |
widemeantolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","SBP")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

###  Pulse rate, automated reading
TARGET_FIELDS="102";DS_NAME="pulserate";readvar
widemeantolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","pulserate")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}_long.csv


### sleep disorders
TARGET_FIELDS="130920";DS_NAME="nonorganicsleepdisorders";readvar
cat $DS_NAME.csv |
sed 's/1900-01-01/NA/g' |
sed 's/1901-01-01/NA/g' |
sed 's/1902-02-02/NA/g' |
sed 's/1903-03-03/NA/g' |
sed 's/2037-07-07/NA/g' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

TARGET_FIELDS="131060";DS_NAME="sleepdisorders";readvar
cat $DS_NAME.csv |
sed 's/1900-01-01/NA/g' |
sed 's/1901-01-01/NA/g' |
sed 's/1902-02-02/NA/g' |
sed 's/1903-03-03/NA/g' |
sed 's/2037-07-07/NA/g' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv


### Sleep duration
TARGET_FIELDS="1160";DS_NAME="sleep_duration";readvar
cat $DS_NAME.csv |
widetolong |
sed 's/-1/NA/g' |
sed 's/-3/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","sleep_duration")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}_long.csv

### Sleeplessness / insomnia
TARGET_FIELDS="1200";DS_NAME="Sleepless";readvar
cat $DS_NAME.csv |
widetolong |
sed 's/-3/NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","sleepless")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Trouble falling asleep (no instance, age can't be determined)
# TARGET_FIELDS="20533";DS_NAME="trouble_fall_asleep";readvar
# cat $DS_NAME.csv |
# widetolong |
# awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
# awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","trouble_fall_asleep")}{print}' > ${DS_NAME}_2.csv
# dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}_long.csv

### Date of alzheimer's disease report
TARGET_FIELDS="42020";DS_NAME="alzonset";readvar
cat $DS_NAME.csv |
sed 's/1900-01-01/NA/g' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Date I10 first reported (essential (primary) hypertension)
TARGET_FIELDS="131286";DS_NAME="hypertension_I10";readvar
cat $DS_NAME.csv |
sed 's/1900-01-01/NA/g' |
sed 's/1901-01-01/NA/g' |
sed 's/1902-02-02/NA/g' |
sed 's/1903-03-03/NA/g' |
sed 's/2037-07-07/NA/g' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Date I15 first reported (secondary hypertension),
TARGET_FIELDS="131294";DS_NAME="hypertension_I15";readvar
cat $DS_NAME.csv |
sed 's/1900-01-01/NA/g' |
sed 's/1901-01-01/NA/g' |
sed 's/1902-02-02/NA/g' |
sed 's/1903-03-03/NA/g' |
sed 's/2037-07-07/NA/g' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

# ### Date of G30 first reported (AD)
TARGET_FIELDS="131036";DS_NAME="alzheimer_G30";readvar
cat $DS_NAME.csv |
sed 's/1900-01-01/NA/g' |
sed 's/1901-01-01/NA/g' |
sed 's/1902-02-02/NA/g' |
sed 's/1903-03-03/NA/g' |
sed 's/2037-07-07/NA/g' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

# ### Date of F00 first reported (dementia in AD)
cat $DS_NAME.csv |
sed 's/1900-01-01/NA/g' |
sed 's/1901-01-01/NA/g' |
sed 's/1902-02-02/NA/g' |
sed 's/1903-03-03/NA/g' |
sed 's/2037-07-07/NA/g' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Date F01 first reported (vascular dementia)
TARGET_FIELDS="130838";DS_NAME="VascularDementia_F01";readvar
cat $DS_NAME.csv |
sed 's/1900-01-01/NA/g' |
sed 's/1901-01-01/NA/g' |
sed 's/1902-02-02/NA/g' |
sed 's/1903-03-03/NA/g' |
sed 's/2037-07-07/NA/g' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv


### Date G35 first reported (multiple sclerosis)
TARGET_FIELDS="131042";DS_NAME="MultipleSclerosis_G35";readvar
cat $DS_NAME.csv |
sed 's/1900-01-01/NA/g' |
sed 's/1901-01-01/NA/g' |
sed 's/1902-02-02/NA/g' |
sed 's/1903-03-03/NA/g' |
sed 's/2037-07-07/NA/g' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv


### Date G20 first reported (parkinson's disease)
TARGET_FIELDS="131022";DS_NAME="Parkinson_G20";readvar
cat $DS_NAME.csv |
sed 's/1900-01-01/NA/g' |
sed 's/1901-01-01/NA/g' |
sed 's/1902-02-02/NA/g' |
sed 's/1903-03-03/NA/g' |
sed 's/2037-07-07/NA/g' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv


### Date of all cause dementia report
TARGET_FIELDS="42018";DS_NAME="AllCauseDementia";readvar
cat $DS_NAME.csv |
sed 's/1900-01-01/NA/g' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv



# ### Age diabetes diagnosed
TARGET_FIELDS="2976";DS_NAME="diabetes_age";readvar
cat $DS_NAME.csv |
sed 's/-1/NA/g' |
sed 's/-3/NA/g' |
minvar |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","diabetes_age")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv


### Age stroke diagnosed
TARGET_FIELDS="4056";DS_NAME="stroke_age";readvar
cat $DS_NAME.csv |
sed 's/-1/NA/g' |
sed 's/-3/NA/g' |
minvar |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","stroke_age")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### menopause diagnosed
TARGET_FIELDS="3581";DS_NAME="menopause_age";readvar
cat $DS_NAME.csv |
sed 's/-1/NA/g' |
sed 's/-3/NA/g' |
minvar |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","menopause_age")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Interpolated Age of participant when cancer first diagnosed
TARGET_FIELDS="20007";DS_NAME="cancer";readvar
cat $DS_NAME.csv |
sed 's/-3/NA/g' |
sed 's/-1/NA/g' |
minvar |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","cancer")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Type of cancer: ICD10
TARGET_FIELDS="40006";DS_NAME="cancer_ICD10";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","seq","cancer_ICD10")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}_long.csv


# ### Type of cancer: ICD9
TARGET_FIELDS="40013";DS_NAME="cancer_ICD9";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","seq","cancer_ICD9")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}_long.csv

### Histology of cancer tumour
TARGET_FIELDS="40011";DS_NAME="cancer_histology";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","seq","cancer_histology")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}_long.csv

### Age at cancer diagnosis
TARGET_FIELDS="40008";DS_NAME="cancer_age";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}$3!~/NA/{print}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","seq","cancer_age")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}_long.csv

awk 'BEGIN{FS=OFS=","}NR==FNR{a[$1,$2]=$3;next}{$(NF+1)=a[$1,$2];print}' $RAW_DIR_READ/cancer_ICD9_long.csv $RAW_DIR_READ/cancer_age_long.csv |
awk 'BEGIN{FS=OFS=","}NR==FNR{a[$1,$2]=$3;next}{$(NF+1)=a[$1,$2];print}' $RAW_DIR_READ/cancer_ICD10_long.csv - |
awk 'BEGIN{FS=OFS=","}NR==FNR{a[$1,$2]=$3;next}{$(NF+1)=a[$1,$2];print}' $RAW_DIR_READ/cancer_histology_long.csv - >  cancer_ICD9_ICD10_histology_long.csv
dx upload cancer_ICD9_ICD10_histology_long.csv --path $RAW_DIR/cancer_ICD9_ICD10_histology_long.csv

### Age lung cancer (not mesothelioma) diagnosed by doctor
TARGET_FIELDS="22160";DS_NAME="lungcancer_age";readvar
dx upload ${DS_NAME}.csv --path $RAW_DIR/${DS_NAME}.csv

### version 2 all cancer without skin cancer, isincid_allcancer_butskin2: 1 - if ONLY has non-skin cancer; 0 - no cancer
## mark 1 for skin cancer and glioblastoma: 210-229,235-238,239,172*,173* in ICD9,C43*,C44*,D10-D36,D37-D48 in ICD10,9440,9441 in histology, lung cancer: 162*, 1970,2311,2312,V101 in ICD9, C34*,C78.0,D02.1,D02.2, Z851 in ICD10
awk 'BEGIN{FS=OFS=","}
    {if ($4~/^(172|173|21|22|235|236|237|238|239)/ || $5~/^(C43|C44|D1|D2|D3|D40|D41|D42|D43|D44|D45|D46|D47|D48)/ || $6~/9440|9441/)
    print $0,1
    else
    print $0,0}' $RAW_DIR_READ/cancer_ICD9_ICD10_histology_long.csv > allcancer_but_skin_age_ver2.csv

awk 'BEGIN{FS=OFS=","}{print $1,$2,$3,$NF}' allcancer_but_skin_age_ver2.csv |
awk 'BEGIN{FS=OFS=","}{sum4[$1] += $4};END{for (id in sum4){print id, sum4[id]}}' |
sort |
awk 'BEGIN{FS=OFS=","}$2==0{print $1}' > ID_allcancer_but_skin_age_ver2.csv
awk 'BEGIN{OFS=","}NR==FNR{a[$1]++;next;}($1 in a){print $1,$3}' FS="," ID_allcancer_but_skin_age_ver2.csv FS="," allcancer_but_skin_age_ver2.csv |
sort -k1,1n -k2,2n |
awk 'BEGIN{FS=OFS=","}!a[$1] {a[$1]=$2} $2==a[$1]' |
sort -u |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$2}' > allcancer_but_skin_age_ver2_2.csv
dx upload allcancer_but_skin_age_ver2_2.csv --path $RAW_DIR/allcancer_but_skin_age_ver2_2.csv


### skin cancer
awk 'BEGIN{FS=OFS=","}$NF==1{print $1,$3}' allcancer_but_skin_age_ver2.csv |
sort -k1,1n -k2,2n |
awk 'BEGIN{OFS="\t"}!a[$1] {a[$1]=$2} $2==a[$1]' |
sort -u |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$2}'  > SkinCancerGlioblastoma.csv
dx upload SkinCancerGlioblastoma.csv --path $RAW_DIR/SkinCancerGlioblastoma.csv

# skin or long cancer
awk 'BEGIN{FS=OFS=","}
     $4 ~ /^(172|173|21|22|235|236|237|238|239|162|1970|2311|2312|V101|C43|C44|D1|D2|D3|D40|D41|D42|D43|D44|D45|D46|D47|D48|C34|C780|D021|D022|Z851|9440|9441)/{print $0}' ${RAW_DIR_READ}/cancer_ICD9_ICD10_histology_long.csv |
cut -d',' -f1,3 |
awk 'BEGIN{FS=OFS=","}!a[$1] {a[$1]=$2} $2==a[$1]' |
sort -u |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$2}' > skinlungcancer.csv
dx upload skinlungcancer.csv --path $RAW_DIR/skinlungcancer.csv
### Get earliest age onset of all cancer minus skin cancer, glioblastoma, and lung cancer

## remove skin cancer and glioblastoma: 210-229,235-238,239,172*,173* in ICD9,C43*,C44*,D10-D36,D37-D48 in ICD10,9440,9441 in histology,
## remove lung cancer: 162*, 1970,2311,2312,V101 in ICD9, C34*,C78.0,D02.1,D02.2, Z851 in ICD10

awk 'BEGIN{FS=OFS=","}
     $4 !~ /^(172|173|21|22|235|236|237|238|239)/{print $0}' ${RAW_DIR_READ}/cancer_ICD9_ICD10_histology_long.csv |
awk 'BEGIN{FS=OFS=","}
    $4 !~ /^(162|1970|2311|2312|V101)/{print $0}' |
awk 'BEGIN{FS=OFS=","}
    $5 !~ /^(C43|C44|D1|D2|D3|D40|D41|D42|D43|D44|D45|D46|D47|D48)/{print $0}' |
awk 'BEGIN{FS=OFS=","}
    $5 !~ /^(C34|C780|D021|D022|Z851)/{print $0}' |
awk 'BEGIN{FS=OFS=","}
    $6 !~ /9440|9441/{print $0}' |
awk 'BEGIN{FS=OFS=","}{print $1,$3}' > allcancer_but_skin_glioblastoma_lung_age.csv
cat allcancer_but_skin_glioblastoma_lung_age.csv | sort -u | sed 's/ $/,NA/g' > allcancer_but_skin_glioblastoma_lung_age_2.csv

# ## find the smallest age onset for all cancer minus skin cancer, glioblastoma, and lung cancer.
SUBJECTLIST=$(awk 'BEGIN{FS=","}NR>1{print $1}' allcancer_but_skin_glioblastoma_lung_age_2.csv | sed 's/ //g' | sort -u | transpose)
for eachid in ${SUBJECTLIST};do
  EACHLINE=$(awk -v eachid="$eachid" 'BEGIN{FS=OFS=","}$1==eachid{print $2}' allcancer_but_skin_glioblastoma_lung_age_2.csv | transpose)
#   echo "$eachid $EACHLINE"
  echo "$eachid,$EACHLINE" >> allcancer_but_skin_glioblastoma_lung_age_wide.csv
done;
dx upload allcancer_but_skin_glioblastoma_lung_age_wide.csv --path $RAW_DIR/allcancer_but_skin_glioblastoma_lung_age_wide.csv

sed 's/ /,/g' allcancer_but_skin_glioblastoma_lung_age_wide.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
minvar |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","allcancer_but_skin_lung_age")}{print}' > allcancer_but_skin_glioblastoma_lung_min_age.csv

dx upload allcancer_but_skin_glioblastoma_lung_min_age.csv --path $RAW_DIR/allcancer_but_skin_glioblastoma_lung_min_age.csv


### version 2 all cancer without skin/lung cancer, isincid_allcancer_butskinlung2: 1 - if ONLY has non skin/lung cancer; 0 - no cancer
# ## mark 1 for skin cancer and glioblastoma: 210-229,235-238,239,172*,173* in ICD9,C43*,C44*,D10-D36,D37-D48 in ICD10,9440,9441 in histology, lung cancer: 162*, 1970,2311,2312,V101 in ICD9, C34*,C78.0,D02.1,D02.2, Z851 in ICD10
awk 'BEGIN{FS=OFS=","}
    {if ($4~/^(172|173|21|22|235|236|237|238|239|162|1970|2311|2312|V101)/ || $5~/^(C43|C44|D1|D2|D3|D40|D41|D42|D43|D44|D45|D46|D47|D48|C34|C780|D021|D022|Z851)/ || $6~/9440|9441/)
    print $0,1
    else
    print $0,0}' ${RAW_DIR_READ}/cancer_ICD9_ICD10_histology_long.csv > allcancer_but_skin_lung_age_ver2.csv
awk 'BEGIN{FS=OFS=","}{print $1,$2,$3,$NF}' allcancer_but_skin_lung_age_ver2.csv |
awk 'BEGIN{FS=OFS=","}{sum4[$1] += $4};END{for (id in sum4){print id, sum4[id]}}' |
sort |
awk 'BEGIN{FS=OFS=","}$2==0{print $1}' > ID_allcancer_but_skin_lung_age_ver2.csv
awk 'BEGIN{OFS=","}NR==FNR{a[$1]++;next;}($1 in a){print $1,$3}' FS="," ID_allcancer_but_skin_lung_age_ver2.csv FS="," allcancer_but_skin_lung_age_ver2.csv |
sort -k1,1n -k2,2n |
awk 'BEGIN{FS=OFS=","}!a[$1] {a[$1]=$2} $2==a[$1]' |
sort -u |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' > allcancer_but_skin_lung_ver2.csv
dx upload allcancer_but_skin_lung_ver2.csv --path $RAW_DIR/allcancer_but_skin_lung_ver2.csv

### melanoma
awk 'BEGIN{FS=OFS=","}$4~/^172/ || $5~/^(C43|D03)/ || $6~/8720|8721|8722|8723|8730|8740|8741|8742|8743|8744|8745|8746|8761|8770|8771|8772|8773|8774/{print $1,$3}' ${RAW_DIR_READ}/cancer_ICD9_ICD10_histology_long.csv > melanoma_age.csv

awk 'BEGIN{FS=OFS="\t"}$4~/^172/ || $5~/^(C43|D03)/ || $6~/8720|8721|8722|8723|8730|8740|8741|8742|8743|8744|8745|8746|8761|8770|8771|8772|8773|8774/{print $1,$3}' ${MYDIRPRO_Z}/prep_data/raw/cancer_ICD9_ICD10_histology_long.tab > ${MYDIRPRO_Z}/prep_data/raw/melanoma_age.tab

SUBJECTLIST=$(awk 'BEGIN{FS=","}{print $1}' melanoma_age.csv | sed 's/ //g' | sort -u | transpose)
for eachid in ${SUBJECTLIST};do
  EACHLINE=$(awk -v eachid="$eachid" 'BEGIN{FS=OFS=","}$1==eachid{print $2}' melanoma_age.csv | transpose)
  echo "$eachid,$EACHLINE" >> melanoma_age_wide.csv
done;
sed 's/ /,/g' melanoma_age_wide.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
minvar |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","melanoma_age")}{print}' > melanoma_min_age.csv
dx upload melanoma_min_age.csv --path $RAW_DIR/melanoma_min_age.csv


### Age high blood pressure diagnosed
TARGET_FIELDS="2966";DS_NAME="hbp";readvar
cat $DS_NAME.csv |
sed 's/-1/NA/g' |
sed 's/-3/NA/g' |
minvar |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","hbp")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Age angina diagnosed
TARGET_FIELDS="3627";DS_NAME="angina";readvar
cat $DS_NAME.csv |
sed 's/-1/NA/g' |
sed 's/-3/NA/g' |
minvar |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","angina")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv


# ### Age heart attack diagnosed
TARGET_FIELDS="3894";DS_NAME="heartattack";readvar
cat $DS_NAME.csv |
sed 's/-1/NA/g' |
sed 's/-3/NA/g' |
minvar |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","heartattack")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv


# ### Date of myocardial infarction
TARGET_FIELDS="42000";DS_NAME="MI";readvar
cat $DS_NAME.csv |
sed 's/1900-01-01/NA/g' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv


### HDL cholesterol (mmol/l)
TARGET_FIELDS="30760";DS_NAME="hdl";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","HDL")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### LDL direct (mmol/l)
TARGET_FIELDS="30780";DS_NAME="ldl";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","LDL")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Triglycerides (mmol/l)
TARGET_FIELDS="30870";DS_NAME="tc";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","TC")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Red blood cell (erythrocyte) count
TARGET_FIELDS="30010";DS_NAME="rbc";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","RBC")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### White blood cell (leukocyte) count
TARGET_FIELDS="30000";DS_NAME="wbc";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","WBC")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Platelet count
TARGET_FIELDS="30080";DS_NAME="plt";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","platelet")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Apolipoprotein A
TARGET_FIELDS="30630";DS_NAME="apolipA";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","apolipA")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### lipoprotein A
TARGET_FIELDS="30790";DS_NAME="lipoproteinA";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","lipoproteinA")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Haematocrit percentage
TARGET_FIELDS="30030";DS_NAME="hct";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","HCT")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Haemoglobin concentration
TARGET_FIELDS="30020";DS_NAME="hgb";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","HGB")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Mean corpuscular haemoglobin
TARGET_FIELDS="30050";DS_NAME="mch";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","MCH")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Mean corpuscular haemoglobin concentration
TARGET_FIELDS="30060";DS_NAME="mchc";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","MCHC")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Glycated haemoglobin (HbA1c)
TARGET_FIELDS="30750";DS_NAME="a1c";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","HbA1C")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Glucose
TARGET_FIELDS="30740";DS_NAME="glucose";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","glucose")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Creatinine
TARGET_FIELDS="30700";DS_NAME="Creatinine";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","Creatinine")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Alanine aminotransferase
TARGET_FIELDS="30620";DS_NAME="alt";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","ALT")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Aspartate aminotransferase
TARGET_FIELDS="30650";DS_NAME="ast";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","AST")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### Albumin
TARGET_FIELDS="30600";DS_NAME="albumin";readvar
cat $DS_NAME.csv |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","albumin")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### vitamin
TARGET_FIELDS="6155";DS_NAME="vitamin";readvar
cat $DS_NAME.csv |
sed 's/-7/NA/g' |
sed 's/-3/NA/g' |
widetolong |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","vitamin")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### antibiotics number of antibiotics taken in last three months
TARGET_FIELDS="6671";DS_NAME="antibiotics";readvar
cat $DS_NAME.csv |
widetolong23 |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","antibiotics")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

### glioblastoma ()
## keep 9440,9441 in cancer_histology_long.tab
awk 'BEGIN{FS=OFS=","}$3 ~ /9440|9441/{print}' ${RAW_DIR_READ}/cancer_histology_long.csv > glioblastoma_long.csv

## combine cancer_age_long.csv glioblastoma_long.csv
awk 'BEGIN{FS=OFS=","}$3 ~ /9440|9441/{print}' ${RAW_DIR_READ}/cancer_histology_long.csv > glioblastoma_long.csv
awk 'BEGIN{FS=OFS=","}NR==FNR{a[$1,$2]=$3;next}{$(NF+1)=a[$1,$2];print}' glioblastoma_long.csv ${RAW_DIR_READ}/cancer_age_long.csv |
awk 'BEGIN{FS=OFS=","}$4 ~ /9440|9441/{print}' > glioblastoma_long2.csv

## find the smallest age onset for glioblastoma.
SUBJECTLIST=$(awk 'BEGIN{FS=","}{print $1}' glioblastoma_long2.csv | sed 's/ //g' | sort -u | transpose)
for eachid in ${SUBJECTLIST};do
  EACHLINE=$(awk -v eachid="$eachid" 'BEGIN{FS=OFS=","}$1==eachid{print $3}' glioblastoma_long2.csv | transpose)
  echo "$eachid,$EACHLINE" >> glioblastoma_age_wide.csv
done;
sed 's/ /,/g' glioblastoma_age_wide.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
minvar |
awk 'BEGIN{FS=OFS=","}{print $1,$2,$NF}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","glioblastoma_age")}{print}' > glioblastoma_min_age.csv
dx upload glioblastoma_min_age.csv --path $RAW_DIR/glioblastoma_min_age.csv

#### ICD 9/10
## Diagnoses - ICD10
TARGET_FIELDS="41270";DS_NAME="all_ICD10";readvar

awk 'BEGIN{FS=OFS=","}{print $1,$3}' all_ICD10.csv |
sed 's/|/,/g' |
widetolong |
sort -t $',' -k1,1n -k2,2n > all_ICD10_long.csv
dx upload all_ICD10_long.csv --path $RAW_DIR/all_ICD10_long.csv

### ICD 10 age
# TARGET_FIELDS="41280";DS_NAME="all_ICD10_age";readvar
# there are 258 variables!
cut -d$',' -f1,94-199 pheno_AD-Infect_all_014_v20230419_FN_raw_participant.csv > p41280_cohort14.csv
cut -d$',' -f1-154 pheno_AD-Infect_all_015_v20230419_FN_raw_participant.csv > p41280_cohort15.csv
awk 'BEGIN{FS=OFS=","}NR==FNR{a[$1]=$0;next}{$(NF+1)=a[$1];print}' p41280_cohort15.csv p41280_cohort14.csv |
cut -d$',' -f1-107,109-261 > all_ICD10_age.csv
dx upload all_ICD10_age.csv --path $RAW_DIR/all_ICD10_age.csv

cat $RAW_DIR/all_ICD10_age.csv |
widetolong |
sed 's/,$/,NA/g' |
sort -t $',' -k1,1n -k2,2n |
awk 'BEGIN{FS=OFS=","}$3!~/NA/{print}' > all_ICD10_age_long.csv
dx upload all_ICD10_age_long.csv --path $RAW_DIR/all_ICD10_age_long.csv

#download all_ICD10_long.csv
dx download file-GX2PB7QJ0Z62kzVBk56Fz4vv
#download all_ICD10_age_long.csv
dx download file-GX1gkX0J0Z6KV1kGgpK36X1x
awk 'BEGIN{FS=OFS=","}$3!~/NA/{print}' all_ICD10_age_long.csv > all_ICD10_age_long_2.csv
awk 'BEGIN{FS=OFS=","}NR==FNR{a[$1,$2]=$3;next}{$(NF+1)=a[$1,$2];print}' all_ICD10_long.csv all_ICD10_age_long_2.csv > all_ICD10_age_code_long.csv

dx upload all_ICD10_age_code_long.csv --path $RAW_DIR/all_ICD10_age_code_long.csv

### ICD 9
TARGET_FIELDS="41271";DS_NAME="all_ICD9";readvar

awk 'BEGIN{FS=OFS=","}{print $1,$3}' all_ICD9.csv |
sed 's/|/,/g' |
awk 'BEGIN{FS=OFS=","}$2!~/NA/{print}' |
widetolong |
sort -t $',' -k1,1n -k2,2n > all_ICD9_long.csv
dx upload all_ICD9_long.csv --path $RAW_DIR/all_ICD9_long.csv

# ## ICD 9 age
# TARGET_FIELDS="41281";DS_NAME="all_ICD9_age";readvar
cut -d$',' -f1,200 pheno_AD-Infect_all_014_v20230419_FN_raw_participant.csv > p41281_cohort14.csv
cut -d$',' -f1,155-200 pheno_AD-Infect_all_015_v20230419_FN_raw_participant.csv > p41281_cohort15.csv
awk 'BEGIN{FS=OFS=","}NR==FNR{a[$1]=$0;next}{$(NF+1)=a[$1];print}' p41281_cohort14.csv p41281_cohort15.csv |
cut -d$',' -f1-47,49 |
widetolong |
sed 's/,$/,NA/g' |
sort -t $',' -k1,1n -k2,2n |
awk 'BEGIN{FS=OFS=","}$3!~/NA/{print}' > all_ICD9_age_long.csv
dx upload all_ICD9_age_long.csv --path $RAW_DIR/all_ICD9_age_long.csv

awk 'BEGIN{FS=OFS=","}NR==FNR{a[$1,$2]=$3;next}{$(NF+1)=a[$1,$2];print}' all_ICD9_long.csv all_ICD9_age_long.csv > all_ICD9_age_code_long.csv
dx upload all_ICD9_age_code_long.csv --path $RAW_DIR/all_ICD9_age_code_long.csv

### ICD 10 based on field 20110- mother
TARGET_FIELDS="20110";DS_NAME="all_ICD10_mother";readvar
cat $DS_NAME.csv |
sed 's/-17/NA/g' |
sed 's/-13/NA/g' |
sed 's/-11/NA/g' |
sed 's/-27/NA/g' |
sed 's/-23/NA/g' |
sed 's/-21/NA/g' |
widetolong |
awk 'BEGIN{FS=OFS=","}{split($3,a,"\|");print $1,$2,a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11]}' |
longmultitolongeach |
sed 's/,$/,NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","all_ICD10_mother")}{print}' > mother_long_1_disease_1_line.csv
dx upload mother_long_1_disease_1_line.csv --path $RAW_DIR/mother_long_1_disease_1_line.csv

# ### ICD 10 based on field 20107- father
TARGET_FIELDS="20107";DS_NAME="all_ICD10_father";readvar
cat $DS_NAME.csv |
sed 's/-17/NA/g' |
sed 's/-13/NA/g' |
sed 's/-11/NA/g' |
sed 's/-27/NA/g' |
sed 's/-23/NA/g' |
sed 's/-21/NA/g' |

widetolong |
awk 'BEGIN{FS=OFS=","}{split($3,a,"\|");print $1,$2,a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10]}' |
longmultitolongeach |
sed 's/,$/,NA/g' |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","all_ICD10_father")}{print}' > father_long_1_disease_1_line.csv
dx upload father_long_1_disease_1_line.csv --path $RAW_DIR/father_long_1_disease_1_line.csv

awk 'BEGIN{FS=OFS=","}
    $4==10{print}' ${RAW_DIR_READ}/mother_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","mother_Ad")}{print}' > mother_Ad_ID.csv
dx upload mother_Ad_ID.csv --path $RAW_DIR/mother_Ad_ID.csv

awk 'BEGIN{FS=OFS=","}
    $4==10{print}' ${RAW_DIR_READ}/father_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","father_Ad")}{print}' > father_Ad_ID.csv
dx upload father_Ad_ID.csv --path $RAW_DIR/father_Ad_ID.csv

awk 'BEGIN{FS=OFS=","}
    $4==12{print}' ${RAW_DIR_READ}/mother_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","mother_SevereDepression")}{print}' > mother_SevereDepression.csv
dx upload mother_SevereDepression.csv --path $RAW_DIR/mother_SevereDepression.csv

awk 'BEGIN{FS=OFS=","}
    $4==11{print}' ${RAW_DIR_READ}/mother_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","mother_Parkinson")}{print}' > mother_Parkinson.csv
dx upload mother_Parkinson.csv --path $RAW_DIR/mother_Parkinson.csv

awk 'BEGIN{FS=OFS=","}
    $4==9{print}' ${RAW_DIR_READ}/mother_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","mother_Diabetes")}{print}' > mother_Diabetes.csv
dx upload mother_Diabetes.csv --path $RAW_DIR/mother_Diabetes.csv

awk 'BEGIN{FS=OFS=","}
    $4==8{print}' ${RAW_DIR_READ}/mother_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","mother_hypertension")}{print}' > mother_hypertension.csv
dx upload mother_hypertension.csv --path $RAW_DIR/mother_hypertension.csv

awk 'BEGIN{FS=OFS=","}
    $4==6{print}' ${RAW_DIR_READ}/mother_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","mother_BronchitisEmphysema")}{print}' > mother_BronchitisEmphysema.csv
dx upload mother_BronchitisEmphysema.csv --path $RAW_DIR/mother_BronchitisEmphysema.csv

awk 'BEGIN{FS=OFS=","}
    $4==5{print}' ${RAW_DIR_READ}/mother_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","mother_BreastCancer")}{print}' > mother_BreastCancer.csv
dx upload mother_BreastCancer.csv --path $RAW_DIR/mother_BreastCancer.csv

awk 'BEGIN{FS=OFS=","}
    $4==4{print}' ${RAW_DIR_READ}/mother_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","mother_BowelCancer")}{print}' > mother_BowelCancer.csv
dx upload mother_BowelCancer.csv --path $RAW_DIR/mother_BowelCancer.csv

awk 'BEGIN{FS=OFS=","}
    $4==3{print}' ${RAW_DIR_READ}/mother_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","mother_LungCancer")}{print}' > mother_LungCancer.csv
dx upload mother_LungCancer.csv --path $RAW_DIR/mother_LungCancer.csv

awk 'BEGIN{FS=OFS=","}
    $4==2{print}' ${RAW_DIR_READ}/mother_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","mother_Stroke")}{print}' > mother_Stroke.csv
dx upload mother_Stroke.csv --path $RAW_DIR/mother_Stroke.csv

awk 'BEGIN{FS=OFS=","}
    $4==1{print}' ${RAW_DIR_READ}/mother_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","mother_HeartDisease")}{print}' > mother_HeartDisease.csv
dx upload mother_HeartDisease.csv --path $RAW_DIR/mother_HeartDisease.csv

awk 'BEGIN{FS=OFS=","}
    $4==13{print}' ${RAW_DIR_READ}/father_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","father_ProstateCancer")}{print}' > father_ProstateCancer.csv
dx upload father_ProstateCancer.csv --path $RAW_DIR/father_ProstateCancer.csv

awk 'BEGIN{FS=OFS=","}
    $4==12{print}' ${RAW_DIR_READ}/father_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","father_SevereDepression")}{print}' > father_SevereDepression.csv
dx upload father_SevereDepression.csv --path $RAW_DIR/father_SevereDepression.csv

awk 'BEGIN{FS=OFS=","}
    $4==11{print}' ${RAW_DIR_READ}/father_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","father_Parkinson")}{print}' > father_Parkinson.csv
dx upload father_Parkinson.csv --path $RAW_DIR/father_Parkinson.csv

awk 'BEGIN{FS=OFS=","}
    $4==9{print}' ${RAW_DIR_READ}/father_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","father_Diabetes")}{print}' > father_Diabetes.csv
dx upload father_Diabetes.csv --path $RAW_DIR/father_Diabetes.csv

awk 'BEGIN{FS=OFS=","}
    $4==8{print}' ${RAW_DIR_READ}/father_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","father_hypertension")}{print}' > father_hypertension.csv
dx upload father_hypertension.csv --path $RAW_DIR/father_hypertension.csv

awk 'BEGIN{FS=OFS=","}
    $4==6{print}' ${RAW_DIR_READ}/father_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","father_BronchitisEmphysema")}{print}' > father_BronchitisEmphysema.csv
dx upload father_BronchitisEmphysema.csv --path $RAW_DIR/father_BronchitisEmphysema.csv

awk 'BEGIN{FS=OFS=","}
    $4==4{print}' ${RAW_DIR_READ}/father_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","father_BowelCancer")}{print}' > father_BowelCancer.csv
dx upload father_BowelCancer.csv --path $RAW_DIR/father_BowelCancer.csv

awk 'BEGIN{FS=OFS=","}
    $4==3{print}' ${RAW_DIR_READ}/father_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","father_LungCancer")}{print}' > father_LungCancer.csv
dx upload father_LungCancer.csv --path $RAW_DIR/father_LungCancer.csv

awk 'BEGIN{FS=OFS=","}
    $4==2{print}' ${RAW_DIR_READ}/father_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","father_Stroke")}{print}' > father_Stroke.csv
dx upload father_Stroke.csv --path $RAW_DIR/father_Stroke.csv

awk 'BEGIN{FS=OFS=","}
    $4==1{print}' ${RAW_DIR_READ}/father_long_1_disease_1_line.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$2,1}' |
sort | uniq |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","father_HeartDisease")}{print}' > father_HeartDisease.csv
dx upload father_HeartDisease.csv --path $RAW_DIR/father_HeartDisease.csv

## Colorectal from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}($4~/^153/||$4~/^1540|1541$/){print}' all_ICD9_age_code_long.csv > icd9_ColorectalCancer.csv
awk 'BEGIN{FS=OFS=","}($4~/^C18/||$4~/^C19/||$4~/^C20/){print}' all_ICD10_age_code_long.csv |
cat  icd9_ColorectalCancer.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","ColorectalCancer_age","code")}{print}' > icd9_10_ColorectalCancer.csv
dx upload icd9_10_ColorectalCancer.csv --path $RAW_DIR/icd9_10_ColorectalCancer.csv

## AD from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}$4~/^3310$/{print}' all_ICD9_age_code_long.csv > icd9_ad.csv
awk 'BEGIN{FS=OFS=","}($4~/^G300/||$4~/^G301/||$4~/^G308/||$4~/^G309/){print}' all_ICD10_age_code_long.csv |
cat  icd9_ad.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","AD_age","code")}{print}' > icd9_10_ad.csv
dx upload icd9_10_ad.csv --path $RAW_DIR/icd9_10_ad.csv


awk 'BEGIN{FS=OFS="\t"}$4~/^3310$/{print}' ${MYDIRPRO_Z}/prep_data/raw/all_ICD9_age_code_long.tab > ${MYDIRPRO_Z}/prep_data/raw/icd9_ad.tab
awk 'BEGIN{FS=OFS="\t"}($4~/^G300/||$4~/^G301/||$4~/^G308/||$4~/^G309/){print}' ${MYDIRPRO_Z}/prep_data/raw/all_ICD10_age_code_long.tab |
cat  ${MYDIRPRO_Z}/prep_data/raw/icd9_ad.tab - > ${MYDIRPRO_Z}/prep_data/raw/icd9_10_ad.tab

## ADRD from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}($4~/^3311/ || $4~/^33182$/ || $4~/^2904/){print}' all_ICD9_age_code_long.csv > icd9_adrd.csv
awk 'BEGIN{FS=OFS=","}($4~/^G310/||$4~/^G3183$/||$4~/^F01/){print}' all_ICD10_age_code_long.csv |
cat  icd9_adrd.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","adrd_age","code")}{print}' > icd9_10_adrd.csv
dx upload icd9_10_adrd.csv --path $RAW_DIR/icd9_10_adrd.csv

## ADrelated from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}($4~/^3310$/ || $4~/^3320$/ || $4~/^33182$/ || $4~/^2904/ || $4~/^340/){print}' all_ICD9_age_code_long.csv > icd9_adrelated.csv
awk 'BEGIN{FS=OFS=","}($4~/^G310/||$4~/^G3183$/||$4~/^F01/){print}' all_ICD10_age_code_long.csv |
cat  icd9_adrelated.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","adrelated_age","code")}{print}' > icd9_10_adrelated.csv
dx upload icd9_10_adrelated.csv --path $RAW_DIR/icd9_10_adrelated.csv

## Other Dementias and neurodegenerative disorders from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}($4~/^290/ || $4~/^2941/ || $4~/^2942/ || $4~/^2948$/ || $4~/^3312$/ || $4~/^3319$/){print}' all_ICD9_age_code_long.csv > icd9_otherdemneuro.csv
awk 'BEGIN{FS=OFS=","}($4~/^G310/||$4~/^G3183$/||$4~/^F01/){print}' all_ICD10_age_code_long.csv |
cat  icd9_otherdemneuro.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","otherdemneuro_age","code")}{print}' > icd9_10_otherdemneuro.csv
dx upload icd9_10_otherdemneuro.csv --path $RAW_DIR/icd9_10_otherdemneuro.csv

# ## ADRD plus from ICD 9/10 code
cat icd9_10_otherdemneuro.csv icd9_10_ad.csv icd9_10_adrd.csv > icd9_10_adrdplus.tab
dx upload icd9_10_adrdplus.csv --path $RAW_DIR/icd9_10_adrdplus.csv

## lung cancer from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}($4~/^162/){print}' all_ICD9_age_code_long.csv > icd9_lungcancer.csv
awk 'BEGIN{FS=OFS=","}($4~/^C34/){print}' all_ICD10_age_code_long.csv |
cat  icd9_lungcancer.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","lungcancer_age","code")}{print}' > icd9_10_lungcancer.csv
dx upload icd9_10_lungcancer.csv --path $RAW_DIR/icd9_10_lungcancer.csv

## colon cancer from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}($4~/^153/){print}' all_ICD9_age_code_long.csv > icd9_coloncancer.csv
awk 'BEGIN{FS=OFS=","}($4~/^C18/){print}' all_ICD10_age_code_long.csv |
cat  icd9_coloncancer.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","coloncancer_age","code")}{print}' > icd9_10_coloncancer.csv
dx upload icd9_10_coloncancer.csv --path $RAW_DIR/icd9_10_coloncancer.csv

## breast cancer from ICD 9/10 code (no 2330 found in ICD 9 code)
awk 'BEGIN{FS=OFS=","}($4~/^174/){print}' all_ICD9_age_code_long.csv > icd9_breastcancer.csv
awk 'BEGIN{FS=OFS=","}($4~/^C50/){print}' all_ICD10_age_code_long.csv |
cat  icd9_breastcancer.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","breastcancer_age","code")}{print}' > icd9_10_breastcancer.csv
dx upload icd9_10_breastcancer.csv --path $RAW_DIR/icd9_10_breastcancer.csv

## prostate cancer from ICD 9/10 code (no 2334 found in ICD 9 code)
awk 'BEGIN{FS=OFS=","}($4~/^185/){print}' all_ICD9_age_code_long.csv > icd9_prostatecancer.csv
awk 'BEGIN{FS=OFS=","}($4~/^C61/){print}' all_ICD10_age_code_long.csv |
cat  icd9_prostatecancer.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","prostatecancer_age","code")}{print}' > icd9_10_prostatecancer.csv
dx upload icd9_10_prostatecancer.csv --path $RAW_DIR/icd9_10_prostatecancer.csv

## gastric cancer from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}($4~/^151/){print}' all_ICD9_age_code_long.csv > icd9_gastriccancer.csv
awk 'BEGIN{FS=OFS=","}($4~/^C16/){print}' all_ICD10_age_code_long.csv |
cat  icd9_gastriccancer.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","gastriccancer_age","code")}{print}' > icd9_10_gastriccancer.csv
dx upload icd9_10_gastriccancer.csv --path $RAW_DIR/icd9_10_gastriccancer.csv

## uterine cancer from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}$4~/^(179|180|181|182)/{print}' all_ICD9_age_code_long.csv > icd9_uterinecancer.csv
awk 'BEGIN{FS=OFS=","}$4~/^(C53|C54|C55)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_uterinecancer.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","uterinecancer_age","code")}{print}' > icd9_10_uterinecancer.csv
dx upload icd9_10_uterinecancer.csv --path $RAW_DIR/icd9_10_uterinecancer.csv

## Parkinson's Disease from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}$4~/^3320/{print}' all_ICD9_age_code_long.csv > icd9_Parkinson.csv
awk 'BEGIN{FS=OFS=","}$4~/^G20/{print}' all_ICD10_age_code_long.csv |
cat  icd9_Parkinson.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","Parkinson_age","code")}{print}' > icd9_10_Parkinson.csv
dx upload icd9_10_Parkinson.csv --path $RAW_DIR/icd9_10_Parkinson.csv

# ## MultipleSclerosis from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}$4~/^340/{print}' all_ICD9_age_code_long.csv > icd9_MS.csv
awk 'BEGIN{FS=OFS=","}$4~/^G35/{print}' all_ICD10_age_code_long.csv |
cat  icd9_MS.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","MultipleSclerosis_age","code")}{print}' > icd9_10_MultipleSclerosis.csv
dx upload icd9_10_MultipleSclerosis.csv --path $RAW_DIR/icd9_10_MultipleSclerosis.csv

# ##VascularDementia from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}$4~/^2904/{print}' all_ICD9_age_code_long.csv > icd9_VascularDementia.csv
awk 'BEGIN{FS=OFS=","}$4~/^F01/{print}' all_ICD10_age_code_long.csv |
cat  icd9_VascularDementia.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","VascularDementia_age","code")}{print}' > icd9_10_VascularDementia.csv
dx upload icd9_10_VascularDementia.csv --path $RAW_DIR/icd9_10_VascularDementia.csv

# ##HerpesZoster from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}$4~/^053/{print}' all_ICD9_age_code_long.csv > icd9_HerpesZoster.csv
awk 'BEGIN{FS=OFS=","}$4~/^B02/{print}' all_ICD10_age_code_long.csv |
cat  icd9_HerpesZoster.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","HerpesZoster_age","code")}{print}' > icd9_10_HerpesZoster.csv
dx upload icd9_10_HerpesZoster.csv --path $RAW_DIR/icd9_10_HerpesZoster.csv

# ##MyocardialInfarction from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}$4~/^410/{print}' all_ICD9_age_code_long.csv > icd9_MyocardialInfarction.csv
awk 'BEGIN{FS=OFS=","}$4~/^(I21|I22)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_MyocardialInfarction.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","MyocardialInfarction_age","code")}{print}' > icd9_10_MyocardialInfarction.csv
dx upload icd9_10_MyocardialInfarction.csv --path $RAW_DIR/icd9_10_MyocardialInfarction.csv

# ##AcuteCoronaryHeartDis from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}$4~/^(410|411|413)/{print}' all_ICD9_age_code_long.csv > icd9_AcuteCoronaryHeartDis.csv
awk 'BEGIN{FS=OFS=","}$4~/^(I20|I21|I22)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_AcuteCoronaryHeartDis.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","AcuteCoronaryHeartDis_age","code")}{print}' > icd9_10_AcuteCoronaryHeartDis.csv
dx upload icd9_10_AcuteCoronaryHeartDis.csv --path $RAW_DIR/icd9_10_AcuteCoronaryHeartDis.csv

# ##CoronaryHeartDis from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}$4~/^(410|411|412|413|414)/{print}' all_ICD9_age_code_long.csv > icd9_CoronaryHeartDis.csv
awk 'BEGIN{FS=OFS=","}$4~/^(I20|I21|I22|I23|I24|I25)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_CoronaryHeartDis.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","CoronaryHeartDis_age","code")}{print}' > icd9_10_CoronaryHeartDis.csv
dx upload icd9_10_CoronaryHeartDis.csv --path $RAW_DIR/icd9_10_CoronaryHeartDis.csv

# ##CerebrovascularDis from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}$4~/^(430|431|432|433|434|435|436|437|438)/{print}' all_ICD9_age_code_long.csv > icd9_CerebrovascularDis.csv
awk 'BEGIN{FS=OFS=","}$4~/^(I6|G45|G46|H340)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_CerebrovascularDis.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","CerebrovascularDis_age","code")}{print}' > icd9_10_CerebrovascularDis.csv
dx upload icd9_10_CerebrovascularDis.csv --path $RAW_DIR/icd9_10_CerebrovascularDis.csv

# ##stroke from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}$4~/^(436|431|4329|433|434|997|4376|438)/{print}' all_ICD9_age_code_long.csv > icd9_stroke.csv
awk 'BEGIN{FS=OFS=","}$4~/^(I61|I629|I63|I64|I691|I692|I693|I694)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_stroke.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","stroke_age","code")}{print}' > icd9_10_stroke.csv
dx upload icd9_10_stroke.csv --path $RAW_DIR/icd9_10_stroke.csv

# ##CHF from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}$4~/^428/{print}' all_ICD9_age_code_long.csv > icd9_CHF.csv
awk 'BEGIN{FS=OFS=","}$4~/^(I099|I110|I130|I132|I255|I420|I425|I426|I427|I428|I429|I43|I50|P29)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_CHF.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","CHF_age","code")}{print}' > icd9_10_CHF.csv
dx upload icd9_10_CHF.csv --path $RAW_DIR/icd9_10_CHF.csv

# ##PeripheralvascularDis from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}$4~/^(0930|4373|440|441|4431|4432|4433|4434|4435|4436|4437|4438|4439|471|5571|5579|V434)/{print}' all_ICD9_age_code_long.csv > icd9_PeripheralvascularDis.csv
awk 'BEGIN{FS=OFS=","}$4~/^(I70|I71|I731|I738|I739|I771|I790|I792|K551|K558|K559|Z958|Z959)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_PeripheralvascularDis.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","PeripheralvascularDisF_age","code")}{print}' > icd9_10_PeripheralvascularDis.csv
dx upload icd9_10_PeripheralvascularDis.csv --path $RAW_DIR/icd9_10_PeripheralvascularDis.csv

# ##CardiovascularDis from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}$4~/^(410|411|412|413|414|430|431|432|433|434|435|436|437|438|0930|440|441|4431|4432|4433|4434|4435|4436|4437|4438|4439|471|5571|5579|V434)/{print}' all_ICD9_age_code_long.csv > icd9_CardiovascularDis.csv
awk 'BEGIN{FS=OFS=","}$4~/^(I20|I21|I22|I23|I24|I25|I6|G45|G46|H340|I099|I110|I130|I132|I420|I425|I426|I427|I428|I429|I43|I50|P29|I70|I71|I731|I738|I739|I771|I790|I792|K551|K558|K559|Z958|Z959)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_CardiovascularDis.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","CardiovascularDis_age","code")}{print}' > icd9_10_CardiovascularDis.csv
dx upload icd9_10_CardiovascularDis.csv --path $RAW_DIR/icd9_10_CardiovascularDis.csv

# ##pneumonia from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}$4~/^48[0-6]/{print}' all_ICD9_age_code_long.csv > icd9_pneumonia.csv
awk 'BEGIN{FS=OFS=","}$4~/^J1[2-8]/{print}' all_ICD10_age_code_long.csv |
cat  icd9_pneumonia.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","pneumonia_age","code")}{print}' > icd9_10_pneumonia.csv
dx upload icd9_10_pneumonia.csv --path $RAW_DIR/icd9_10_pneumonia.csv

# ##influenza from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}$4~/^487/{print}' all_ICD9_age_code_long.csv > icd9_influenza.csv
awk 'BEGIN{FS=OFS=","}$4~/^(J09|J10|J11)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_influenza.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","influenza_age","code")}{print}' > icd9_10_influenza.csv
dx upload icd9_10_influenza.csv --path $RAW_DIR/icd9_10_influenza.csv

# ##fungus from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}$4~/^11[0-8]/{print}' all_ICD9_age_code_long.csv > icd9_fungus.csv
awk 'BEGIN{FS=OFS=","}$4~/B3[5-9]|B4[0-9]/{print}' all_ICD10_age_code_long.csv |
cat  icd9_fungus.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","fungus_age","code")}{print}' > icd9_10_fungus.csv
dx upload icd9_10_fungus.csv --path $RAW_DIR/icd9_10_fungus.csv

# ## breast cancer ver2 requested by Igor
awk 'BEGIN{FS=OFS=","}$4~/^(174|175)/{print}' all_ICD9_age_code_long.csv > icd9_breastcancer_Ver2.csv
awk 'BEGIN{FS=OFS=","}$4~/^(C50)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_breastcancer_Ver2.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","breastcancer_Ver2_age","code")}{print}' > icd9_10_breastcancer_Ver2.csv
dx upload icd9_10_breastcancer_Ver2.csv --path $RAW_DIR/icd9_10_breastcancer_Ver2.csv

# ## colon rectum anus cancer requested by Igor
awk 'BEGIN{FS=OFS=","}$4~/^(153|154)/{print}' all_ICD9_age_code_long.csv > icd9_colonrectumanuscancer.csv
awk 'BEGIN{FS=OFS=","}$4~/^(C18|C19|C20|C21)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_colonrectumanuscancer.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","colonrectumanuscancer_age","code")}{print}' > icd9_10_colonrectumanuscancer.csv
dx upload icd9_10_colonrectumanuscancer.csv --path $RAW_DIR/icd9_10_colonrectumanuscancer.csv

# ## pancreas cancer requested by Igor
awk 'BEGIN{FS=OFS=","}$4~/^(157)/{print}' all_ICD9_age_code_long.csv > icd9_pancreascancer.csv
awk 'BEGIN{FS=OFS=","}$4~/^(C25)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_pancreascancer.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","pancreascancer_age","code")}{print}' > icd9_10_pancreascancer.csv
dx upload icd9_10_pancreascancer.csv --path $RAW_DIR/icd9_10_pancreascancer.csv

# ## trachea bronchus lung cancer requested by Igor
awk 'BEGIN{FS=OFS=","}$4~/^(162)/{print}' all_ICD9_age_code_long.csv > icd9_tracheabronchuslungca.csv
awk 'BEGIN{FS=OFS=","}$4~/^(C33|C34)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_tracheabronchuslungca.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","tracheabronchuslungca_age","code")}{print}' > icd9_10_tracheabronchuslungca.csv
dx upload icd9_10_tracheabronchuslungca.csv --path $RAW_DIR/icd9_10_tracheabronchuslungca.csv

# ## non-solid cancer(leukemias and lymphomas) requested by Igor
awk 'BEGIN{FS=OFS=","}$4~/^(200|201|202|203|204|205|206|207|208)/{print}' all_ICD9_age_code_long.csv > icd9_nonsoidcancer.csv
awk 'BEGIN{FS=OFS=","}$4~/^(C81|C82|C83|C84|C85|C86|C87|C88|C89|C90|C91|C92|C93|C94|C95|C96)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_nonsoidcancer.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","nonsolidcancer_age","code")}{print}' > icd9_10_nonsolidcancer.csv
dx upload icd9_10_nonsolidcancer.csv --path $RAW_DIR/icd9_10_nonsolidcancer.csv

# ## other solid fast progressive cancer  requested by Igor
awk 'BEGIN{FS=OFS=","}$4~/^(150|151|152|155|156|158|159|163|164|165|170|171|172|176|179|182|183|188|189|191|192|194|195|209)/{print}' all_ICD9_age_code_long.csv > icd9_othersoidfastcancer.csv
awk 'BEGIN{FS=OFS=","}$4~/^(C15|C16|C17|C22|C23|C24|C26|C37|C38|C39|C40|C41|C43|C46|C47|C48|C49|C54|C55|C56|C64|C65|C66|C67|C68|C70|C71|C72|C74|C75|C76)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_othersoidfastcancer.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","othersoidfastcancer_age","code")}{print}' > icd9_10_othersolidfastcancer.csv
dx upload icd9_10_othersolidfastcancer.csv --path $RAW_DIR/icd9_10_othersolidfastcancer.csv

# ## other solid slow progressive cancer  requested by Igor
awk 'BEGIN{FS=OFS=","}$4~/^(14|160|161|173|180|181|184|186|187|190|193)/{print}' all_ICD9_age_code_long.csv > icd9_othersolidslowcancer.csv
awk 'BEGIN{FS=OFS=","}$4~/^(C0|C10|C11|C12|C13|C14|C30|C31|C32|C44|C51|C52|C53|C57|C58|C60|C62|C63|C69|C73)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_othersolidslowcancer.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","othersolidslowcancer_age","code")}{print}' > icd9_10_othersolidslowcancer.csv
dx upload icd9_10_othersolidslowcancer.csv --path $RAW_DIR/icd9_10_othersolidslowcancer.csv

# ## secondary malignant cancer requested by Igor
awk 'BEGIN{FS=OFS=","}$4~/^(196|197|198)/{print}' all_ICD9_age_code_long.csv > icd9_secondarycancer.csv
awk 'BEGIN{FS=OFS=","}$4~/^(C77|C78|C79)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_secondarycancer.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","secondarycancer_age","code")}{print}' > icd9_10_secondarycancer.csv
dx upload icd9_10_secondarycancer.csv --path $RAW_DIR/icd9_10_secondarycancer.csv

# ## other nonspecified cancer requested by Igor
awk 'BEGIN{FS=OFS=","}$4~/^(199)/{print}' all_ICD9_age_code_long.csv > icd9_othernonspecifiedcancer.csv
awk 'BEGIN{FS=OFS=","}$4~/^(C80|C45|C97)/{print}' all_ICD10_age_code_long.csv |
cat  icd9_othernonspecifiedcancer.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","othernonspecifiedcancer_age","code")}{print}' > icd9_10_othernonspecifiedcancer.csv
dx upload icd9_10_othernonspecifiedcancer.csv --path $RAW_DIR/icd9_10_othernonspecifiedcancer.csv

# ## burden of infection from ICD 10 code
awk 'BEGIN{FS=OFS=","}($4~/^A/ || $4~/^B/ || $4~/J06|J09|J10|J11|J12|J13|J14|J15|J16|J17|J18|J22/){print}' all_ICD10_age_code_long.csv > icd10_infection.csv
dx upload icd10_infection.csv --path $RAW_DIR/icd10_infection.csv

# ## burden of infection from ICD 10 code without HIV
awk 'BEGIN{FS=OFS=","}($4!~/B20|B21|B22|B23|B24/){print}' all_ICD10_age_code_long.csv > icd10_infection_no_hiv.csv
dx upload icd10_infection_no_hiv.csv --path $RAW_DIR/icd10_infection_no_hiv.csv
#
# ## burden of infection from ICD 10 code - version 2 suggested by Vladimir 5/12/2022
awk 'BEGIN{FS=OFS=","}($4~/^A/ || $4~/^B/ || $4~/J00|J01|J02|J03|J04|J05|J06|J09|J10|J11|J12|J13|J14|J15|J16|J17|J18|J20|J21|J22|I30|I33|I40|K35|K85|L04/){print}' all_ICD10_age_code_long.csv > icd10_infection_burden_v2.csv
dx upload icd10_infection_burden_v2.csv --path $RAW_DIR/icd10_infection_burden_v2.csv

# ## burden of acute infection from ICD 10 code - suggested by Vladimir 5/12/2022
awk 'BEGIN{FS=OFS=","}($$4~/B15|B16|B17|J00|J01|J02|J03|J04|J05|J06|J09|J10|J11|J12|J13|J14|J15|J16|J17|J18|J20|J21|J22|I30|I33|I40|K35|K85|L04/){print}' all_ICD10_age_code_long.csv > icd10_acute_infection.csv
dx upload icd10_acute_infection.csv --path $RAW_DIR/icd10_acute_infection.csv

# ## probable brain trauma from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}($4~/^854/){print}' all_ICD9_age_code_long.csv > icd9_probheadtrauma.csv
awk 'BEGIN{FS=OFS=","}($4~/Z8782|S0/){print}' all_ICD10_age_code_long.csv |
cat  icd9_probheadtrauma.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","probheadtrauma_age","code")}{print}' > icd9_10_probheadtrauma.csv
dx upload icd9_10_probheadtrauma.csv --path $RAW_DIR/icd9_10_probheadtrauma.csv

## antibiotic for the last three month from field 20199 (126 medications)
TARGET_FIELDS="20199";DS_NAME="antibiotic_20199";readvar
cat $DS_NAME.csv |
sed 's/99999/NA/g' |
widetolong23 |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","antibiotic_20199")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/${DS_NAME}.csv

## medication/treatment from field 20003
TARGET_FIELDS="20003";DS_NAME="all_medication_treatment";readvar

cat $DS_NAME.csv |
sed 's/99999/NA/g' |
widetolong |
awk 'BEGIN{FS=OFS=","}
    {split($3,a,"\|");
     for (i=1;i<=48;i++)
         {
             printf("%s,%s,%s\n",$1,$2,a[i])
         }
    }' |
sed 's/,$/,NA/g' |
awk 'BEGIN{FS=OFS=","}$3!~/NA/{print}' |
awk 'BEGIN{FS=OFS=","}{print $1,$0}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","medication_treatment")}{print}' > ${DS_NAME}_2.csv
dx upload ${DS_NAME}_2.csv --path $RAW_DIR/medication_treatment_long.csv

awk 'BEGIN{FS=OFS=","}NR==FNR{a[$1,$3]=$4;next}{$(NF+1)=a[$1,$3];print}' age.csv medication_treatment_long.csv |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$2;next}{$(NF+1)=a[$4];print}' FS="\t" /opt/notebooks/scripts/medication_treatment.tsv FS="," - >  medication_treatment_age_long.csv
sed -i 's/age,$/age,med/' medication_treatment_age_long.csv
dx upload medication_treatment_age_long.csv --path $RAW_DIR/medication_treatment_age_long.csv

awk 'BEGIN{OFS=","}NR==FNR{a[$3]=$3;next;}($3 in a){print $0}' FS="," ${RAW_DIR_READ}/antibiotic_20199.csv FS="," ${RAW_DIR_READ}/medication_treatment_long.csv > antibiotics_20003_long.csv
dx upload antibiotics_20003_long.csv --path $RAW_DIR/antibiotics_20003_long.csv

# awk 'BEGIN{OFS=","}NR==FNR{a[$3]=$3;next;}!($3 in a){print $0}' FS="," ${RAW_DIR_READ}/antibiotics_20003_long.csv FS=","  ${RAW_DIR_READ}/antibiotic_20199.csv > antibiotic_in20199_notin20003.csv

## Long-term/recurrent antibiotics as child or teenager (field 21067 still not available)
# TARGET_FIELDS="21067";DS_NAME="regular_antibiotic";readvar
# awk 'BEGIN{FS=OFS="\t"}{print $1,$12258}' $MYDIRPRO/ukb669128.tab |
# awk 'BEGIN {FS=OFS="\t"}
#     (NR>1 && $2!~/818|121|NA/){print}' > ${MYDIRPRO_Z}/prep_data/raw/regular_antibiotic.tab
#
## Depression 1 from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}($4~/^2961/||$4~/^3004/||$4~/^311/){print}' all_ICD9_age_code_long.csv > icd9_depression1.csv
awk 'BEGIN{FS=OFS=","}($4~/^F32/||$4~/^F33/||$4~/^F341/||$4~/^F412/){print}' all_ICD10_age_code_long.csv |
cat  icd9_depression1.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","depression1_age","code")}{print}' > icd9_10_depression1.csv
dx upload icd9_10_depression1.csv --path $RAW_DIR/icd9_10_depression1.csv

## Depression 2 from ICD 9/10 code
awk 'BEGIN{FS=OFS=","}($4~/^2961/||$4~/^3004/||$4~/^311/||$4~/^2963/||$4~/^2980/||$4~/^3090/||$4~/^3091/){print}' all_ICD9_age_code_long.csv > icd9_depression2.csv
awk 'BEGIN{FS=OFS=","}($4~/^F32/||$4~/^F33/||$4~/^F341/||$4~/^F412/||$4~/^F251/||$4~/^F313/||$4~/^F314/||$4~/^F315/||$4~/^F432/){print}' all_ICD10_age_code_long.csv |
cat  icd9_depression2.csv - |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","depression2_age","code")}{print}' > icd9_10_depression2.csv
dx upload icd9_10_depression2.csv --path $RAW_DIR/icd9_10_depression2.csv

# ## depression 3 according to depression medication
awk 'BEGIN {FS=OFS=","}
    ($6~/^(lithium|camcolit|priadel|liskonum|phasal|litarex|li\-liquid)/){split($6,a," ");print $1,$2,$3,$5,a[1]}' medication_treatment_age_long.csv > depression3_1.csv
awk 'BEGIN{FS=OFS=","}{print $1,$1,1}' depression3_1.csv |
sort -u |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","depression3_ind")}{print}' > depression3_12.csv
dx upload depression3_12.csv --path $RAW_DIR/depression3_12.csv

## depression 3 according to field 20446
TARGET_FIELDS="20446";DS_NAME="sadness";readvar
awk 'BEGIN{FS=OFS=","}$3!~/NA/{print}' sadness.csv |
awk 'BEGIN{FS=OFS=","}NR>1{print}' |
awk 'BEGIN{FS=OFS=","}$3==1{print $1,$1,$3}' |
cat depression3_12.csv - |
sort -u > depression3.csv
dx upload depression3.csv --path $RAW_DIR/depression3.csv

cat /opt/notebooks/scripts/antibiotics2.tab |
sed 's/\t/,/g' > antibiotics2.csv
dx upload antibiotics2.csv --path $RAW_DIR/antibiotics2.csv

## antibiotics_visit1
awk 'BEGIN{FS=OFS=","}$3==0{print}' medication_treatment_age_long.csv |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$1;next;}($4 in a){print $0}' FS="," antibiotics2.csv FS="," - > antibiotics_visit1.csv
awk 'BEGIN{FS=OFS=","}{print $1}' antibiotics_visit1.csv |
sort -u |
awk 'BEGIN{FS=OFS=","}{print $1,$1,1}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","antibiotics_visit1_ind")}{print}' > antibiotics_visit1_2.csv
dx upload antibiotics_visit1_2.csv --path $RAW_DIR/antibiotics_visit1_2.csv

# ## antibiotics
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$1;next;}($4 in a){print $0}' FS="," antibiotics2.csv FS="," medication_treatment_age_long.csv > antibiotics_all.csv
awk 'BEGIN{FS=OFS=","}{print $1,$2,$3,1}' antibiotics_all.csv |
sort -u |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","instance","antibiotics_all_ind")}{print}' > antibiotics_all2.csv
dx upload antibiotics_all2.csv --path $RAW_DIR/antibiotics_all2.csv

 ## tetracycline
 awk 'BEGIN{FS=OFS=","}$6~/achrocidin|achromycin|achrostatin|acobiotic|acromicina|acticlate|actisite|adoxa|akne\-pyodron|ala\-tet|alfaflor|alodox|ambotetra|ambramicina/{print}' medication_treatment_age_long.csv > tetracycline_all1.csv
awk 'BEGIN{FS=OFS=","}$6~/ambra\-sinto|amphocycline|amycycline|anfoterin|aphlomycine|apocyclin|apo\-tetra|arcanacycline|armocyclar|aureciclina|austramycin|avidoxy|beatacycline|berciclina|betafloroto|biotricina|bisolvomycine|boramycin|bristaciclina|brodspec/{print}' medication_treatment_age_long.csv > tetracycline_all2.csv
awk 'BEGIN{FS=OFS=","}$6~/broncho\-tetrabakat|bronco|broncofenil|bronquinflamatoria|bucocilina|calociclina|cervicaletten|chemiciclina|chimotetra|chlortetracycline|chymocyclar|chymocycline|ciclobiotico|clomocycline|colbiocin|colicort|combitrex|cortigrin/{print}' medication_treatment_age_long.csv > tetracycline_all3.csv
awk 'BEGIN{FS=OFS=","}$6~/cortilen|cyclodox|demeclocycline|dermobios|desonix|deteclo|dhatracin|dibaterr|dispatetrin|doryx|doxatet|doxy|doxycycline|doxylar|doxytet|droclina|dumocyclin|duotal|dynacin|economycin|eftapan|eravacycline|eubetal/{print}' medication_treatment_age_long.csv > tetracycline_all4.csv
awk 'BEGIN{FS=OFS=","}$6~/febrectol\-tetracycline|finegosan|florocycline|flumetol|fluorex|forcicline|gammatet|gelcap|gine|gino\-teracin|gt\-250|guayaciclina|helidac|helipak|hexacycline|hortepulmo|hortetracin|hostacyclin|hostacycline/{print}' medication_treatment_age_long.csv > tetracycline_all5.csv
awk 'BEGIN{FS=OFS=","}$6~/hostacycline\-p|hydracycline|hydromycin|ibicyn|iducol|imacol|imex|inacol|infex|istix|kinciclina|latycin|latycyn|laur|lenocin|lymecycline|macrocilin|makatussin|medocycline|miciclin|mictasone|minocin|minocycline|minolira|miociclin|miten|monocetin/{print}' medication_treatment_age_long.csv > tetracycline_all6.csv
awk 'BEGIN{FS=OFS=","}$6~/monodox|morgidox|mucitux|mucorex|myrac|mysteclin|mystecline|mysteclin\-f|mysteclin\-v|nasopomada|neociclina|neumobac|nordox|nor\-tet|novo\-tetra|nu\-tetra|nutridox|nuzyra|nymix\-cyclin|ocudox|ofticlin|omadacycline|oracea|oraxyl|oricyclin|otocusi/{print}' medication_treatment_age_long.csv > tetracycline_all7.csv
awk 'BEGIN{FS=OFS=","}$6~/oxi\-t|oxytetracycline|oxytetramix|panmycin|pantocycline|parenciclina|parenzyme|pavitron|pensulvit|periostat|polcortolon|polycid|pygmal|quimocyclar|quimocyclin|quimotrip|quimpe|rayetetra|reacton|recycline|resteclin|retet|rexamycin|rexamycin\-s|rhinathiol|riostatin|robitet|rotet|rubitracine|sagittacin|sanicel|sarecycline|senociclin|servitet|seysara|sigmamycine/{print}' medication_treatment_age_long.csv > tetracycline_all8.csv
awk 'BEGIN{FS=OFS=","}$6~/sk\-tetracycline|solclin|solfranicol|solodyn|spaciclina|statinclyne|steclin|steclin\-v|sumycin|supramycin|sustamycin|synacthen|talseclin|talsutin|tantum|te\-br|tecyn|tefilin|tehadispers|teline|teraciton|tericin|terrakal|terramycin|terranilo|terranumonyl|tetra/{print}' medication_treatment_age_long.csv > tetracycline_all9.csv
awk 'BEGIN{FS=OFS=","}$6~/tetra\-abiadin|tetrabakat|tetrabid\-organon|tetrabioptal|tetrabiotic|tetrablet|tetracap|tetrachel|tetracina|tetracitro|tetraclin|tetracon|tetracycline|tetracyn|tetrafosammina|tetralan|tetralen|tetralim|tetralution|tetralysal|tetram|tetramax|tetramicin|tetramig|tetramykoin|tetrana|tetrano|tetranovax|tetra\-ozothin|tetrapres|tetraprocyn/{print}' medication_treatment_age_long.csv > tetracycline_all10.csv
awk 'BEGIN{FS=OFS=","}$6~/tetra\-proter|tetrarco|tetraseptine|tetrasulbron|tetraxil|tetrazil|tetrerba|tetrex|tetrex\-f|tetrib|tetrim|tevacycline|topicycline|topitetrina|tracyne/{print}' medication_treatment_age_long.csv > tetracycline_all11.csv
awk 'BEGIN{FS=OFS=","}$6~/traumanase\-cyclin|trecloran|triacycline|tricangine|triclin|trinotrex|triphacycline|tritet|tromicol|ultratussin|urovec|vagmycin|velutrix|venugyl|vibramycin|vibra\-tabs|vitecaf|xerava|ximino|uro\ hubber/{print}' medication_treatment_age_long.csv > tetracycline_all12.csv
cat tetracycline_all1.csv tetracycline_all2.csv tetracycline_all3.csv tetracycline_all4.csv tetracycline_all5.csv tetracycline_all6.csv tetracycline_all7.csv tetracycline_all8.csv tetracycline_all9.csv tetracycline_all10.csv tetracycline_all11.csv tetracycline_all12.csv |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s,%s,%s\n","eid","eid","instance","code","age","med")}{print}' > tetracycline_all.csv
dx upload tetracycline_all.csv --path $RAW_DIR/tetracycline_all.csv

awk 'BEGIN{FS=OFS=","}{print $1,$2,$3,1}' tetracycline_all.csv > tetracycline_all_2.csv
dx upload tetracycline_all_2.csv --path $RAW_DIR/tetracycline_all_2.csv

## tetracycline_visit1
awk 'BEGIN{FS=OFS=","}$3==0{print}' tetracycline_all.csv |
awk 'BEGIN{FS=OFS=","}{print $1}' |
sort -u |
awk 'BEGIN{FS=OFS=","}{print $1,$1,1}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","tetracycline_all_ind")}{print}' > tetracycline_visit1_2.csv
dx upload tetracycline_visit1_2.csv --path $RAW_DIR/tetracycline_visit1_2.csv

# ## tetracycline short list, June 15, 2022 email from SV
awk 'BEGIN{FS=OFS=","}$6~/tetracycline|doxycycline|doxylar|doxatet|doxytet|nordox|cyclodox|oxytetracycline|oxytetramix|terramycin|chlortetracycline|tetrachel|clomocycline|demeclocycline|lymecycline|tetralysal|minocycline|minocin/{print}' medication_treatment_age_long.csv |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s,%s,%s\n","eid","eid","instance","code","age","med")}{print}' > tetracycline_short.csv
dx upload tetracycline_short.csv --path $RAW_DIR/tetracycline_short.csv

# ## speep pill
awk 'BEGIN{FS=OFS=","}$6~/ativan|librium|lexotan|bromazepam|tranxene|dialar|diazemuls|diazepam|stesolid|tensium|lormetazepam|rohypnol|flunitrazepam|hypnotic|noctec|phanodorm|centrax|prazepam|somnite|somnia|almazine|anxon|valium|atensine|admbien|imovane|sleep|temazepam|remifemin|imozop|melatonin|zolpidem|paxane|dormonoct|noctamid|nitrados/{print}' medication_treatment_age_long.csv > sleeppill1.csv
awk 'BEGIN{FS=OFS=","}$6~/noctesed|halcion|alupram|amytal|methyprylone|noludar|chloral|welldorm|chlormethiazole|heminevrin|flurazepam|dalmane|euhypnos|triclofos|zopiclone|rimapam|nitrazepam|mogadon|remnos|normison|seconal|tuinal|stilnoct|amylobarbitone|butobarbitone|butobarbital|soneryl|cyclobarbitone|amobarbital|clomethiazole|butethal|zileze|zaleplon|sonata|secobarbital|somnwell|provigil|oxazepam|acrivastine/{print}' medication_treatment_age_long.csv > sleeppill2.csv
awk 'BEGIN{FS=OFS=","}$6~/aldex\ an|alprazolam|ambien|amitriptyline|anxon|ativan|banophen|belsomra|benadryl|bromazepam|calmday|centrax|chloral\ hydrate|chlordiazepoxide|circadin|clorazepate|dalmane|daridorexant|dayvigo|diazemuls|diazepam|diphedryl|diphenhist|diphenhydramine|doral|doxepin|doxylamine|dytuss|edluar|elavil|endep|estazolam|estorra|eszopiclone/{print}' medication_treatment_age_long.csv > sleeppill3.csv
awk 'BEGIN{FS=OFS=","}$6~/euhypnos|flunitrazepam|flurazepam|halazepam|halcion|imovane|intermezzo|ketazolam|lemborexant|lexomil|lexotan|librium|lorazepam|loreev|lormetazepam|lunesta|lysanxia|medazepam|melatonin|mogadon|nitrazepam|nobrium|noctamid|noctec|nordaz|nordazepam|normison|nuctalon|nytol|quickcaps|oxazepam|paxipam|prazepam|prosom|q-dryl|quazepam|quenalin|quviviq/{print}' medication_treatment_age_long.csv > sleeppill4.csv
awk 'BEGIN{FS=OFS=","}$6~/ramelteon|ramitax|restoril|rohypnol|rozerem|serax|serenid|serepax|seresta|silenor|sinequan|slenyto|sominex|somnote|sonata|stilnoct|stilnox|suvorexant|syncrodin|tafil|tavor|temazepam|tranquil|tranxene|triazolam|twilite|unisom|valium|valu-dryl|vanamine\ pd|vanatrip|welldorm|xanax|xanor|xonvea|zaleplon|zimovane|zolpidem|zolpimist|zopiclone|zzzquil/{print}' medication_treatment_age_long.csv > sleeppill5.csv
awk 'BEGIN{FS=OFS=","}$6~/promethazine|phenergan|alzain|pregabalin|axalid|buspiron|dormagen|lecaent|loprazolam|lyrica|tropium/{print}' medication_treatment_age_long.csv > sleeppill6.csv
cat sleeppill1.csv sleeppill2.csv sleeppill3.csv sleeppill4.csv sleeppill5.csv sleeppill6.csv |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s,%s,%s\n","eid","eid","instance","code","age","med")}{print}' > sleeppill.csv
dx upload sleeppill.csv --path $RAW_DIR/sleeppill.csv

awk 'BEGIN{FS=OFS="\t"}{print $1,$2,$3,1}' sleeppill.csv |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","sleeppill_ind")}{print}' > sleeppill2.csv
dx upload sleeppill2.csv --path $RAW_DIR/sleeppill2.csv

# ## Benzodiazepine
awk 'BEGIN{FS=OFS=","}$6~/temazepam|restoril|ativan|lorazepam|Loreev|estazolam|prosom|nuctalon|flurazepam|dalmane|halcion|doral|nitrazepam|diazepam|alprazolam|bromazepam|chlordiazepoxide|clorazepate|flunitrazepam|halazepam|ketazolam|lormetazepam|medazepam|nordazepam|oxazepam|prazepam|normison|euhypnos|tavor|estazolam/{print}' medication_treatment_age_long.csv > benzodiazepine1.csv
awk 'BEGIN{FS=OFS=","}$6~/triazolam|quazepam|mogadon|valium|diazemuls|xanax|xanor|tafil|lexotan|lexomil|librium|tranxene|rohypnol|paxipam|anxon|noctamid|nobrium|nordaz|calmday|serax|serenid|serepax|seresta|centrax|lysanxia/{print}' medication_treatment_age_long.csv > benzodiazepine2.csv
cat benzodiazepine1.csv benzodiazepine2.csv |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s,%s,%s\n","eid","eid","instance","code","age","med")}{print}' > benzodiazepine.csv
awk 'BEGIN{FS=OFS=","}NR>1{print $1,$2,$3,1}' benzodiazepine.csv |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","benzodiazepine_ind")}{print}' > benzodiazepine2.csv
dx upload benzodiazepine2.csv --path $RAW_DIR/benzodiazepine2.csv

## Z-drugs
awk 'BEGIN{FS=OFS=","}$6~/zolpimist|zolpidem|intermezzo|ambien|lunesta|eszopiclone|estorra|sonata|zaleplon|stilnoct|stilnox|edluar|zopiclone|zimovane|imovane/{print}' medication_treatment_age_long.csv |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s,%s,%s\n","eid","eid","instance","code","age","med")}{print}' > zdrug.csv
awk 'BEGIN{FS=OFS=","}NR>1{print $1,$2,$3,1}' zdrug.csv |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","zdrug_ind")}{print}' > zdrug2.csv
dx upload zdrug2.csv --path $RAW_DIR/zdrug2.csv

# ## amitriptyline
awk 'BEGIN{FS=OFS=","}$6~/amitriptyline/{print}' medication_treatment_age_long.csv |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s,%s,%s\n","eid","eid","instance","code","age","med")}{print}' > amitriptyline.csv
awk 'BEGIN{FS=OFS=","}NR>1{print $1,$2,$3,1}' amitriptyline.csv |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","instance","amitriptyline_ind")}{print}' > amitriptyline2.csv
dx upload amitriptyline2.csv --path $RAW_DIR/amitriptyline2.csv

## 'MRI' sheet line 2-17
TARGET_FIELDS="25000 25003 25004 25005 25006 25007 25008 25009 25010 25011 25012 25019 25020 25025 25886 25887";DS_NAME="MRI_2_17";readvar
cut -d',' -f1-14,16-35 MRI_2_17.csv |
awk 'BEGIN{FS=OFS=","}NR>1{print 2,3,$0}' |
awk 'BEGIN{FS=OFS=","}
            {for (i = 1;i <= NF; i=i+2){printf "%s%s",$i,((i+2)>NF ? ORS: OFS)}}
            {for (j = 2;j <= NF; j=j+2){printf "%s%s",$j,((j+2)>NF ? ORS: OFS)}}' |
sort -k2,2 -k1,1 |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n","instance","eid","VolScaling","VolVentCerSpinal_fluid_norm","VolVentCerSpinal_fluid","VolBrain_grey_norm","VolBrain_grey","VolBrain_white_norm","VolBrain_white","VolBrain_norm","VolBrain","VolThal_left","VolThal_right","VolHipp_left","VolHipp_right","Vol_brain_stem_4ventricle","VolHipp_grey_left","VolHipp_grey_right")}{print}' > MRI_2_17_final.csv
dx upload MRI_2_17_final.csv --path $RAW_DIR/MRI_2_17_final.csv

## 'MRI' sheet line 18: WMH
TARGET_FIELDS="25781";DS_NAME="MRI_18";readvar
awk 'BEGIN{FS=OFS=","}NR>1{print 2,3,$0}' MRI_18.csv |
awk 'BEGIN{FS=OFS=","}
    {for (i = 1;i <= NF; i=i+2){printf "%s%s",$i,((i+2)>NF ? ORS: OFS)}}
    {for (j = 2;j <= NF; j=j+2){printf "%s%s",$j,((j+2)>NF ? ORS: OFS)}}' |
sort -k2,2 -k1,1 |
sed -e "1 s/^/Wave,EID,WMH\n/" > MRI_18_final.csv
dx upload MRI_18_final.csv --path $RAW_DIR/MRI_18_final.csv

### ALS
awk 'BEGIN{FS=OFS=","}($4~/G122/){print}' all_ICD10_age_code_long.csv |
awk 'BEGIN{FS=OFS=","}{print $1,$1,$3,$4}' |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s\n","eid","eid","ALS_age","code")}{print}' > ALS.csv
dx upload ALS.csv --path $RAW_DIR/ALS.csv

# CHD, combine angina, heartattack and MI
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3;next}{$(NF+1)=a[$1];print}' FS="," yearbirth.csv FS="," id.csv |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3;next}{$(NF+1)=a[$1];print}' FS="," monthbirth.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3;next}{$(NF+1)=a[$1];print}' FS="," MI.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3;next}{$(NF+1)=a[$1];print}' FS="," angina.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3;next}{$(NF+1)=a[$1];print}' FS="," heartattack.csv FS="," - |
awk 'BEGIN{FS=OFS=","}{
        if ($5!~/NA/)
            {split($5,a,"-");$(NF+1)=(a[1]*365.25+a[2]*30.4167+a[3]-$3*365.25-$4*30.4167-15)/365.25;print}
        else
            {print $0,"NA"}
        }' |
cut -d',' -f1-2,6-8 |
minvar |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s\n","eid","eid","CHD")}{print $1,$2,$NF}' > CHD.csv
dx upload CHD.csv --path $RAW_DIR/CHD.csv
