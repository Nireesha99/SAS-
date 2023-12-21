/*Data cleaning and Quality assurance*/

libname project "/home/u63191991/Handson Pro/project 2";

1.Handling missing values

/* Impute missing age values with median age in patient_demographics dataset */
data project.patient_demographics;
set project.patient_demographics;
if missing(age) then age =median(age);
run;

/* Exclude observations with missing treatment_type in treatment_project.details dataset */
data project.treatment_details;
set project.treatment_details;
if missing (treatment_type) then delete;
run;


2.identifying data Inconsistencies;

/* Check for invalid values in gender variable in patient_demographics dataset */

proc freq data=project.patient_demographics;
tables gender;
run;

/* Check for typos in tumor_type variable in tumor_characteristics dataset */
proc freq data= project.tumor_characteristics;
tables tumor_type;
run;

3.Rectifying Data Inconsistencies;

/* Replace invalid gender values with 'U' (Unknown) in patient_demographics dataset */
data project.tumor_characteristics;
set project.tumor_characteristics;
if tumor_type= "Lung Cnacner" then tumor_type = "Lung cancer";
if tumor_type= "BreastCan cer" then tumor_type= "Breast Cancer";
run;

/* 4.Standardizing Data Formats*/

data project.patient_demographics;
set project.patient_demographics;
race = propcase(race);
ethnicity = propcase(ethnicity);
run;

/* Standardize treatment_type format in treatment_details dataset */

data project.treatment_details;
set project.treatment_details;
treatment_type = propcase (treatment_type);
run;

/* Standardize tumor_type format in tumor_characteristics dataset */
data project.tumor_characteristics;
set project.tumor_characteristics;
tumor_type = propcase(tumor_type);
run;