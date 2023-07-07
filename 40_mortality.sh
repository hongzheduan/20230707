#!/bin/bash

cd /opt/notebooks
MYDIRPRO_READ=/mnt/project/Work/hd48/pipeline_AnalyticData ## when read
MYDIRPRO=Work/hd48/pipeline_AnalyticData ## when write
RAW_DIR_READ=$MYDIRPRO_READ/prep_data/raw
RAW_DIR=$MYDIRPRO/prep_data/raw
DOCS_DIR=$MYDIRPRO/docs

### create mortality file

dx download -f $RAW_DIR/*.csv

awk 'BEGIN{FS=OFS=","}
     $4!~/NA/ && NR>1{if ($4~/1/) $5=1
                else $5=0
              if ($4~/2/) $6=1
                else $6=0
              if ($4~/3/) $7=1
                else $7=0
              if ($4~/4/) $8=1
                else $8=0
              if ($4~/5/) $9=1
                else $9=0
              if ($4~/6/) $10=1
                else $10=0
              if ($4~/7/) $11=1
                else $11=0
              print }' vitamin.csv |
sort |
cut -d',' -f1,3,5-11 |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s,%s,%s,%s,%s,%s\n","eid","instance","VitA","VitB","VitC","VitD","VitE","VitB9","MultiVit")}{print}'> vitamin_2.csv
dx upload vitamin_2.csv --path $RAW_DIR/vitamin_2.csv

/*Infection*/
awk 'BEGIN{FS=OFS=","}{print $0,1}' icd10_infection.csv |
awk 'BEGIN{FS=OFS=","}{sum5[$1] += $5};END{for (id in sum5){print id, sum5[id]}}' |
sort |
awk 'BEGIN{FS=OFS=",";printf("%s,%s\n","eid","count_infection1")}{print}'  > icd10_infection_2.csv

awk 'BEGIN{FS=OFS=","}{print $0,1}' antibiotics.csv |
awk 'BEGIN{FS=OFS=","}{sum5[$1] += $5};END{for (id in sum5){print id, sum5[id]}}' |
sort |
awk 'BEGIN{FS=OFS=",";printf("%s,%s\n","eid","count_infection2")}{print}'  > antibiotics2_2.csv

awk 'BEGIN{FS=OFS=","}{print $0,1}' icd10_infection_no_hiv.csv |
awk 'BEGIN{FS=OFS=","}{sum5[$1] += $5};END{for (id in sum5){print id, sum5[id]}}' |
sort |
awk 'BEGIN{FS=OFS=",";printf("%s,%s\n","eid","count_infection3")}{print}'  > icd10_infection_nohiv_2.csv

awk 'BEGIN{FS=OFS=","}$4!~/NA/{print}' antibiotic_20199.csv |
awk 'BEGIN{FS=OFS=","}{print $0,1}' |
awk 'BEGIN{FS=OFS=","}{sum5[$1] += $5};END{for (id in sum5){print id, sum5[id]}}' |
sort |
awk 'BEGIN{FS=OFS=",";printf("%s,%s\n","eid","count_infection4")}{print}'  > antibiotic_20199_2.csv

awk 'BEGIN{FS=OFS=","}$4!~/NA/{print}' antibiotics_20003_long.csv |
awk 'BEGIN{FS=OFS=","}{print $0,1}' |
awk 'BEGIN{FS=OFS=","}{sum5[$1] += $5};END{for (id in sum5){print id, sum5[id]}}' |
sort |
awk 'BEGIN{FS=OFS=",";printf("%s,%s\n","eid","count_infection5")}{print}'  > antibiotics_20003_2.csv

awk 'BEGIN{FS=OFS=","}$4!~/NA/{print}' antibiotics_20003_long.csv |
awk 'BEGIN{FS=OFS=","}{print $0,1}' icd10_acute_infection.csv |
awk 'BEGIN{FS=OFS=","}{sum5[$1] += $5};END{for (id in sum5){print id, sum5[id]}}' |
sort |
awk 'BEGIN{FS=OFS=",";printf("%s,%s\n","eid","count_acute_infection")}{print}'  > icd10_acute_infection_2.csv

awk 'BEGIN{FS=OFS=","}{print $0,1}' icd10_infection_burden_v2.csv |
awk 'BEGIN{FS=OFS=","}{sum5[$1] += $5};END{for (id in sum5){print id, sum5[id]}}' |
sort |
awk 'BEGIN{FS=OFS=",";printf("%s,%s\n","eid","count_infection_burden_v2")}{print}'  > icd10_infection_burden_v2_2.csv

dx upload icd10_infection_2.csv --path $RAW_DIR/icd10_infection_2.csv
dx upload antibiotics2_2.csv --path $RAW_DIR/antibiotics2_2.csv
dx upload icd10_infection_nohiv_2.csv --path $RAW_DIR/icd10_infection_nohiv_2.csv
dx upload antibiotic_20199_2.csv --path $RAW_DIR/antibiotic_20199_2.csv
dx upload antibiotics_20003_2.csv --path $RAW_DIR/antibiotics_20003_2.csv
dx upload icd10_acute_infection_2.csv --path $RAW_DIR/icd10_acute_infection_2.csv
dx upload icd10_infection_burden_v2_2.csv --path $RAW_DIR/icd10_infection_burden_v2_2.csv

# Take away people withdrawn from study
dx download file-GVjX9k0J0Z6PpxVKyPq9Pqyk
cat w82705_2023-04-25.csv |
sed 's/\r//g' |
awk 'BEGIN{FS=OFS=","}{print $1,1}' |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]++;next;}!($1 in a){print}' FS="," - FS="," sex.csv |
awk 'BEGIN{FS=OFS=","}{if ($3==0)
                        print $1,$2,2
                    if ($3==1)
                        print $1,$2,1}' > id.csv
dx upload id.csv --path $RAW_DIR/id.csv

# Prepare mortality data


cat id.csv |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," sex.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," race.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," deathcause.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," deathage.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," yearbirth.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," monthbirth.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," eversmoke.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," lastfudate.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," recruitage.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," drinker.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$2; next}{$(NF+1)=a[$1];print}' FS="," icd10_infection_2.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$2; next}{$(NF+1)=a[$1];print}' FS="," antibiotics2_2.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$2; next}{$(NF+1)=a[$1];print}' FS="," icd10_infection_nohiv_2.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$2; next}{$(NF+1)=a[$1];print}' FS="," antibiotic_20199_2.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$2; next}{$(NF+1)=a[$1];print}' FS="," antibiotics_20003_2.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$2; next}{$(NF+1)=a[$1];print}' FS="," icd10_acute_infection_2.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$2; next}{$(NF+1)=a[$1];print}' FS="," icd10_infection_burden_v2_2.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," deathage_father.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," lastfuage_father.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," ltmort_father.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," deathage_mother.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," lastfuage_mother.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," ltmort_mother.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," father_Ad_ID.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," father_BowelCancer.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," father_BronchitisEmphysema.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," father_Diabetes.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," father_HeartDisease.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," father_hypertension.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," father_LungCancer.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," father_Parkinson.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," father_ProstateCancer.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," father_SevereDepression.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," father_Stroke.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," mother_Ad_ID.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," mother_BowelCancer.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," mother_BronchitisEmphysema.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," mother_Diabetes.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," mother_HeartDisease.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," mother_hypertension.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," mother_LungCancer.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," mother_Parkinson.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," mother_BreastCancer.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," mother_SevereDepression.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," mother_Stroke.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," depression3.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," antibiotics_visit1_2.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," tetracycline_visit1_2.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," Inverse_distance_nearest_road.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," Inverse_dist_nearest_major_road.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," Close_to_major_road.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," menopause_age.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," UsedInGeneticPC.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," TownsendIndex.csv FS="," - |
awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3; next}{$(NF+1)=a[$1];print}' FS="," GeneticKinshipToOther.csv FS="," - |
awk 'BEGIN{FS=OFS=",";printf("%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n","EID","EID","Sex","Race","DeathCause","AgeDeath","BirthCohort","BirthMonth","IsSmoker","lastfudate","LTmort","IsDrinker","count_infection1","count_infection2","count_infection3","count_infection4","count_infection5","count_acute_infection","count_infection_burden_v2","AgeDeath_father","lastfuage_father","LTmort_father","AgeDeath_mother","lastfuage_mother","LTmort_mother","IsIncid_ADdementia_father","IsIncid_BowelCancer_father","IsIncid_COPD_father","IsIncid_Diabetes_father","IsIncid_HeartDisease_father","IsIncid_hypertension_father","IsIncid_LungCancer_father","IsIncid_Parkinson_father","IsIncid_ProstateCancer_father","IsIncid_SevereDepression_father","IsIncid_Stroke_father","IsIncid_ADdementia_mother","IsIncid_BowelCancer_mother","IsIncid_COPD_mother","IsIncid_Diabetes_mother","IsIncid_HeartDisease_mother","IsIncid_hypertension_mother","IsIncid_LungCancer_mother","IsIncid_Parkinson_mother","IsIncid_BreastCancer_mother","IsIncid_SevereDepression_mother","IsIncid_Stroke_mother","depression3","antibiotics_visit1","tetracycline_visit1","Inverse_distance_nearest_road","Inverse_dist_nearest_major_road","Close_to_major_road","menopause_age","Genetic_PC_indicator","Townsend_Deprivation_Index","Genetic_kinship_to_other")}{print}' > mortality0.csv

sed 's/NA//g' mortality0.csv > mortality1.csv
dx upload mortality1.csv --path $RAW_DIR/mortality1.csv

awk 'BEGIN{FS=OFS=","}NR==1{print $0,"qualification_array","highestedu","edu1","edu2","edu3"}' mortality1.csv > mortality_head.csv

awk 'BEGIN{OFS=","}NR==FNR{a[$1]=$3OFS$4OFS$5OFS$6OFS$7; next}{$(NF+1)=a[$1];print}' FS="," highedu_wide.csv FS="," mortality1.csv |
tail -n+2 |
sort > mortality_nohead.csv
cat mortality_head.csv mortality_nohead.csv > mortality.csv
dx upload mortality.csv --path $RAW_DIR/mortality.csv

awk 'BEGIN{FS=OFS=","}NR==1{print $0,"LSmort","IsDead","RaceWBO","IsDead_father","LSmort_father","IsDead_mother","LSmort_mother","count_infection","burden_infection1","burden_infection2","burden_infections_ver2","burden_acute_infection","IsIncid_cancer_father","IsIncid_cancer_mother"}' mortality.csv > mortality2_head.csv

awk 'BEGIN{FS=OFS=","}
          {split($10,a,"-"); print $0,(a[1]*365.25+a[2]*30.4167+a[3]-$7*365.25-$8*30.4167-15)/365.25}' mortality.csv |  #LSmort
awk 'BEGIN{FS=OFS=","}{if ($6>0) $(NF+1)=1;else $(NF+1)=0;print}' | #IsDead
awk 'BEGIN{FS=OFS=","}{if ($4~/^1/) $(NF+1)=1;else if ($4~/^4/) $(NF+1)=2;else if ($4!~/^$/) $(NF+1)=3;print}' | #RaceWBO
awk 'BEGIN{FS=OFS=","}
     $20>0{print $0,1,$20}
     $20~/^$/{print $0,0,$21}' | #IsDead_father LSmort_father
awk 'BEGIN{FS=OFS=","}
     $23>0{print $0,1,$23}
     $23~/^$/{print $0,0,$24}' | #IsDead_mother LSmort_mother
awk 'BEGIN{FS=OFS=","; maxnum=-10000}
     NR>1{for (i = 14; i <= 17; i++)
            {if ($i > maxnum) maxnum=$i}
          $(NF+1) = maxnum
          print
          maxnum=-10000}'  | #count_infection
awk 'BEGIN{FS=OFS=","}
     $13>=1{print $0,1}
     $13~/^$/{print $0,0}' | #burden_infection1
awk 'BEGIN{FS=OFS=","}
     $(NF-1)>=1{print $0,1}
     $(NF-1)~/^$/{print $0,0}' | #burden_infection2
awk 'BEGIN{FS=OFS=","}
     $19>=1{print $0,1}
     $19~/^$/{print $0,0}' | #burden_infection_ver2
awk 'BEGIN{FS=OFS=","}
     $18>=1{print $0,1}
     $18~/^$/{print $0,0}' | #burden_acute_infection
awk 'BEGIN{FS=OFS=","}
     $26!~/^$/{print}
     $26~/^$/{$26=0;print}' |  #set IsIncid_ADdementia_father
awk 'BEGIN{FS=OFS=","}
     $27!~/^$/{print}
     $27~/^$/{$27=0;print}' |  #set IsIncid_BowelCancer_father
awk 'BEGIN{FS=OFS=","}
     $28!~/^$/{print}
     $28~/^$/{$28=0;print}' |  #set IsIncid_COPD_father
awk 'BEGIN{FS=OFS=","}
     $29!~/^$/{print}
     $29~/^$/{$29=0;print}' |  #set IsIncid_Diabetes_father
awk 'BEGIN{FS=OFS=","}
     $30!~/^$/{print}
     $30~/^$/{$30=0;print}' |  #set IsIncid_HeartDisease_father
awk 'BEGIN{FS=OFS=","}
     $31!~/^$/{print}
     $31~/^$/{$31=0;print}' |  #set IsIncid_hypertension_father
awk 'BEGIN{FS=OFS=","}
     $32!~/^$/{print}
     $32~/^$/{$32=0;print}' |  #set IsIncid_LungCancer_father
awk 'BEGIN{FS=OFS=","}
     $33!~/^$/{print}
     $33~/^$/{$33=0;print}' |  #set IsIncid_Parkinson_father
awk 'BEGIN{FS=OFS=","}
     $34!~/^$/{print}
     $34~/^$/{$34=0;print}' |  #set IsIncid_ProstateCancer_father
awk 'BEGIN{FS=OFS=","}
     $35!~/^$/{print}
     $35~/^$/{$35=0;print}' |  #set IsIncid_SevereDepression_father
awk 'BEGIN{FS=OFS=","}
     $36!~/^$/{print}
     $36~/^$/{$36=0;print}' |  #set IsIncid_Stroke_father
awk 'BEGIN{FS=OFS=","}
     $37!~/^$/{print}
     $37~/^$/{$37=0;print}' |  #set IsIncid_ADdementia_mother
awk 'BEGIN{FS=OFS=","}
     $38!~/^$/{print}
     $38~/^$/{$38=0;print}' |  #set IsIncid_BowelCancer_mother
awk 'BEGIN{FS=OFS=","}
     $39!~/^$/{print}
     $39~/^$/{$39=0;print}' |  #set IsIncid_COPD_mother
awk 'BEGIN{FS=OFS=","}
     $40!~/^$/{print}
     $40~/^$/{$40=0;print}' |  #set IsIncid_Diabetes_mother
awk 'BEGIN{FS=OFS=","}
     $41!~/^$/{print}
     $41~/^$/{$41=0;print}' |  #set IsIncid_HeartDisease_mother
awk 'BEGIN{FS=OFS=","}
     $42!~/^$/{print}
     $42~/^$/{$42=0;print}' |  #set IsIncid_hypertension_mother
awk 'BEGIN{FS=OFS=","}
     $43!~/^$/{print}
     $43~/^$/{$43=0;print}' |  #set IsIncid_LungCancer_mother
awk 'BEGIN{FS=OFS=","}
     $44!~/^$/{print}
     $44~/^$/{$44=0;print}' |  #set IsIncid_Parkinson_mother
awk 'BEGIN{FS=OFS=","}
     $45!~/^$/{print}
     $45~/^$/{$45=0;print}' |  #set IsIncid_BreastCancer_mother
awk 'BEGIN{FS=OFS=","}
     $46!~/^$/{print}
     $46~/^$/{$46=0;print}' |  #set IsIncid_SevereDepression_mother
awk 'BEGIN{FS=OFS=","}
     $47!~/^$/{print}
     $47~/^$/{$47=0;print}' |  #set IsIncid_Stroke_mother
awk 'BEGIN{FS=OFS=","}{
    if ($27>=$32 && $27>=$34)
        print $0,$27
    else if ($32>=$27 && $32>=$34)
        print $0,$32
    else if ($34>=$27 && $34>=$32)
        print $0,$34
    }' |  # IsIncid_cancer_father
awk 'BEGIN{FS=OFS=","}{
    if ($38>=$43 && $38>=$45)
        print $0,$38
    else if ($43>=$38 && $43>=$45)
        print $0,$43
    else if ($45>=$38 && $45>=$43)
        print $0,$45
    }' |  # IsIncid_cancer_mother
awk 'BEGIN{FS=OFS=","}
     $50!~/^$/{print}
     $50~/^$/{$50=0;print}' |  #set tetracycline_visit1
awk 'BEGIN{FS=OFS=","}
     $49!~/^$/{print}
     $49~/^$/{$49=0;print}' |  #set antibiotics_visit1   and depression3 for $48 below
awk 'BEGIN{FS=OFS=","}
     $48!~/^$/{print}
     $48~/^$/{$48=0;print}' > mortality2_nohead.csv

cat mortality2_head.csv mortality2_nohead.csv > mortality2.csv
dx upload mortality2.csv --path $RAW_DIR/mortality2.csv

cut -d',' -f1-4,65,7-8,11,63,64,9,12,5,54-62,71-74,49-50,20,66-67,22,23,67-68,25,48,51-53,26-47,75-76 mortality2.csv |
sed 's/EID,EID/FID,EID/g' |
sed 's/NA//g' > mortality_ukb.csv

dx upload mortality_ukb.csv --path $RAW_DIR/mortality_ukb.csv
