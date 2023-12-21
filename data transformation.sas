/*Code for data transformation*/

libname project "/home/u63191991/Handson Pro/project 2";

/* Derive age groups variable in patient_demographics dataset */
data project.patient_demographics;
set project.patient_demographics;
if age < 30 then age_group = "18-29";
else if age < 40 then age_group = "30-39";
else if age < 50 then age_group = "40-49";
else if age < 60 then age_group = "50-59";
else if age < 70 then age_group = "60-69";
else age_group = "70+";
run;

/* Calculate treatment duration in treatment_details dataset */
data project.treatment_details;
set project.treatment_details;
start_date1 = input(start_date, mmddyy10.);
end_date1 = input (end_date,mmddyy10.);
duration = end_date - start_date + 1;
drop start_date1 end_date1;
run;

/* Categorize response variable into binary outcomes in treatment_details dataset */
data project.treatment_details;
    set project.treatment_details;
    length response_binary $12; 
    if response = "Complete Response" then response_binary = "Favorable";
    else response_binary = "Unfavorable";
run;

/* Categorize tumor stage into early and late stages in tumor_characteristics dataset */
data project.tumor_characteristics;
set project.tumor_characteristics;
if stage = "IA" or stage = "IB" or stage = "IIA" or stage = "IIB" then stage_group = "Early";
else stage_group = "Late";
run;

/* Merge patient_demographics and treatment_details datasets by patient_id */
data merged_data;
merge project.patient_demographics project.treatment_details;
by patient_id;
run;

/* Create a subset of patients with lung cancer from tumor_characteristics dataset */
data lung_cancer_patients;
set project.tumor_characteristics;
if tumor_type = "Lung Cancer";
run;

libname project "/home/u63191991/Handson Pro/project 2";

/* Print patient_demographics dataset */
proc print data=project.patient_demographics;
title "Patient Demographics Dataset";
run;

/* Print treatment_details dataset after calculating treatment duration */
proc print data=project.treatment_details;
title "Treatment Details Dataset with Duration";
run;

/* Print treatment_details dataset after categorizing response variable */
proc print data=project.treatment_details;
title "Treatment Details Dataset with Binary Response";
run;

/* Print tumor_characteristics dataset after categorizing tumor stage */
proc print data=project.tumor_characteristics;
title "Tumor Characteristics Dataset with Stage Group";
run;

/* Print the merged dataset of patient_demographics and treatment_details */
proc print data=merged_data;
title "Merged Patient Demographics and Treatment Details";
run;

/* Print the subset of patients with lung cancer */
proc print data=lung_cancer_patients;
title "Subset of Lung Cancer Patients";
run;

