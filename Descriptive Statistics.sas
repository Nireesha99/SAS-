/*Descriptive Statistics*/

libname project "/home/u63191991/Handson Pro/project 2";

/* Generate descriptive statistics for patient age in patient_demographics dataset */
proc means data= project.patient_demographics;
var age;
run;

/* Generate descriptive statistics for treatment duration by treatment type in treatment_details dataset */
proc means data= project.treatment_details;
class treatment_type;
var duration;
run;

/* Generate descriptive statistics for tumor grade by tumor type in tumor_characteristics dataset */
proc means data= project.tumor_characteristics;
class tumor_type;
var grade;
run;

/* Summarize patient demographics by gender and age group */
proc tabulate data=project.patient_demographics;
class gender age_group;
tables gender, age_group;
run;

/* Summarize treatment outcomes by treatment type and response */
proc tabulate data=project.treatment_details;
class treatment_type response;
tables treatment_type, response;
run;

/* Summarize tumor characteristics by tumor type, stage, and grade */
proc tabulate data=project.tumor_characteristics;
class tumor_type stage grade;
tables tumor_type, stage, grade;
run;

/* Create a histogram of patient age in patient_demographics dataset */
proc sgplot data=project.patient_demographics;
histogram age;
run;

/* Create a box plot of treatment duration by treatment type in treatment_details dataset */
proc sgplot data=project.treatment_details;
vbox duration / group=treatment_type;
run;

/* Create a bar chart of tumor grade distribution by tumor type in tumor_characteristics dataset */
proc sgplot data=project.tumor_characteristics;
vbar grade / group=tumor_type;
run;

/* Sequence observations by patient age in patient_demographics dataset */
proc print data=project.patient_demographics;
by age;
run;

/* Group observations by gender and summarize age in patient_demographics dataset */
proc means data= project.patient_demographics;
class gender;
var age;
run;

/* Identify observations with missing values in treatment_details dataset */
proc print data=project.treatment_details;
where missing(treatment_type) or missing(start_date) or missing(end_date) or missing(response);
run;

/* Customize report appearance with titles and column headers */
proc print data=project.patient_demographics;
title "Patient Demographics Report";
label age="Patient Age" gender="Gender" race="Race" ethnicity="Ethnicity";
run;

/* Format data values with appropriate formats */
proc print data=project.treatment_details;
format start_date end_date mmddyy10.;
run;

/* Create an HTML report with customized styles */
ods html style=journal;
proc print data=project.tumor_characteristics;
title "Tumor Characteristics Report";
run;
ods html close;

/* Examine data errors using PROC FREQ */
proc freq data=project.treatment_details;
tables treatment_type start_date end_date response / missing;
run;

/* Assign and modify variable attributes */
data project.tumor_characteristics;
set project.tumor_characteristics;
label tumor_type="Tumor Type" stage="Tumor Stage" grade="Tumor Grade";
format stage grade $2.;
run;

/* Read a dataset and create a new variable */
data project.patient_demographics;
set project.patient_demographics;
age_group = ifn(age < 30, "18-29", ifn(age < 40, "30-39", ifn(age < 50, "40-49", ifn(age < 60, "50-59", ifn(age < 70, "60-69", "70+"))));
run;

/* Process data conditionally based on treatment type */
data project.treatment_details;
set project.treatment_details;
if treatment_type = "Chemotherapy" then duration = end_date - start_date + 1;
else if treatment_type = "Immunotherapy" then duration = 2 * (end_date - start_date) + 1;
else if treatment_type = "Targeted Therapy" then duration = 3 * (end_date - start_date) + 1;
run;

/* Concatenate patient_demographics and treatment_details datasets vertically */
data combined_data;
set project.patient_demographics project.treatment_details;
run;

/* Merge patient_demographics and tumor_characteristics datasets by patient_id */
data merged_data;
merge project.patient_demographics project.tumor_characteristics;
by patient_id;
run;


/* Generate a summary report of patient demographics using PROC REPORT */
proc report data=project.patient_demographics;
    column gender race ethnicity age;
    define gender;
    define race;
    define ethnicity;
    define age;
run;

/* Generate a summary report of treatment outcomes using PROC TABULATE */
proc tabulate data=project.treatment_details;
class treatment_type response;
tables treatment_type, response;
run;

/* Generate a bar chart of patient age distribution */
proc sgplot data=project.patient_demographics;
vbar age;
run;










