libname project "/home/u63191991/Handson Pro/project 2";

proc sql;
Create table patient_demographics (
    patient_id int,
    age int,
    gender char(1),
    race varchar(20),
    ethnicity varchar(20)
);

/* Insert sample data into the patient_demographics table one row at a time */
insert into patient_demographics values (1, 45, 'M', 'White', 'Hispanic');
insert into patient_demographics values (2, 32, 'F', 'Asian', 'Non-Hispanic');
insert into patient_demographics values (3, 67, 'M', 'Black', 'Hispanic');
insert into patient_demographics values (4, 24, 'F', 'White', 'Non-Hispanic');
insert into patient_demographics values (5, 58, 'M', 'Asian', 'Hispanic');
quit;

/* Generate a report of patient demographics */
proc sql;
select * from patient_demographics;
/* Summarize patient age by gender */
select gender, avg(age) as average_age, min(age) as min_age, max(age) as max_age
from patient_demographics
group by gender;
quit;

/* Perform a complex join between patient_demographics and treatment_details tables */

/* Import the CSV data into the treatment_details table */
data work.treatment_details;
    infile datalines dlm=',' dsd truncover;
    length patient_id $5 treatment_type $19 response $30;
    format start_date end_date mmddyy10.;
    input
        patient_id 
        treatment_type
        start_date : mmddyy10.
        end_date : mmddyy10.
        response;
datalines;
00001,Chemotherapy,01/01/2023,03/31/2023,Partial Response
00002,Immunotherapy,02/15/2023,05/15/2023,Complete Response
00003,TargetedTherapy,03/01/2023,06/30/2023,Stable Disease
00004,Chemotherapy,04/10/2023,07/10/2023,Progressive Disease
00005,Immunotherapy,05/20/2023,08/20/2023,Partial Response
00006,Chemotherapy,06/01/2023,09/30/2023,Complete Response
00007,TargetedTherapy,07/15/2023,10/15/2023,Stable Disease
00008,Chemotherapy,08/10/2023,11/10/2023,Progressive Disease
00009,Immunotherapy,09/20/2023,12/20/2023,Partial Response
00010,TargetedTherapy,10/01/2023,01/31/2024,Complete Response
;
run;

proc sql;
    select p.patient_id, p.age, p.gender, t.treatment_type, t.response
    from patient_demographics as p
    inner join work.treatment_details as t
    on p.patient_id = input(t.patient_id, 8.);
quit;

/* 1. Data Retrieval and Filtering */

/*-- Retrieve patient demographics for patients aged 50 or older*/
proc sql;
select * from patient_demographics
where age >= 50;
quit;
/*Filter treatment details for patients who received chemotherapy*/
proc sql;
select * from treatment_details
where treatment_type = 'Chemotherapy';
quit;

/* 2. Data Aggregation and Summarization */
/*Calculate average age and median survival time for each tumor type*/
* Create the tumor_characteristics dataset;

data work.tumor_characteristics;
    length patient_id $5 tumor_type $15 stage $4 survival_time 8;
    infile datalines dlm=','; /* or use a delimiter that matches your data */
    input patient_id $ tumor_type $ stage $ survival_time;
    datalines;
00001,Lung Cancer,IIIA,24
00002,Breast Cancer,IIB,36
00003,Prostate Cancer,IV,48
00004,Colon Cancer,IIIB,24
00005,Melanoma,IA,12
00006,Lung Cancer,IIB,36
00007,Breast Cancer,IIIA,24
00008,Prostate Cancer,IIIB,36
00009,Colon Cancer,IV,48
00010,Melanoma,IIB,24
;
run;

proc sql;
select tc.tumor_type, 
       avg(pd.age) as average_age, 
       median(tc.survival_time) as median_survival_time
from patient_demographics as pd
inner join work.tumor_characteristics as tc
on put(pd.patient_id, $5.) = tc.patient_id /* Convert numeric to character if needed */
group by tc.tumor_type;
quit;

/*Summarize treatment outcomes by treatment type and response*/
proc sql;
select treatment_type, response, count(*) as patient_count
from treatment_details
group by treatment_type, response;
quit;

/* 3. Advanced Data Analysis Tasks */
/*Identify patient subgroups based on age, gender, and tumor stage*/
proc sql;
select 
    /* Create the age_group on the fly */
    case 
        when pd.age < 18 then 'Under 18'
        when pd.age between 18 and 35 then '18-35'
        when pd.age between 36 and 65 then '36-65'
        else 'Over 65'
    end as age_group,
    pd.gender,
    tc.stage as tumor_stage, /* Assuming the column is named 'stage' in tumor_characteristics */
    count(*) as patient_count
from 
    patient_demographics as pd
inner join 
    tumor_characteristics as tc
    /* Convert the patient_id in tumor_characteristics to numeric if it's character */
    on pd.patient_id = input(tc.patient_id, best.)
group by 
    1, 2, 3; /* Group by the first three selected columns */
quit;

/*Analyze treatment outcomes by calculating response rates for each treatment type*/

proc sql;
select treatment_type,
round(sum(case when response = 'Complete Response' then 1 else 0 end) / count(*) * 100, 2) as response_rate
from treatment_details
group by treatment_type;
quit;

/*Estimate survival rates based on tumor type and treatment response*/
proc sql;
select 
    tc.tumor_type, 
    td.response,
    avg(case 
          when pd.survival_status = 'Alive' then 1 
          else 0 
        end) as survival_rate
from 
    patient_demographics as pd
inner join 
    tumor_characteristics as tc
    on pd.patient_id = tc.patient_id
inner join 
    treatment_details as td
    on pd.patient_id = td.patient_id
group by 
    tc.tumor_type, 
    td.response;
quit;

/* 4. Integration of SQL with SAS Programming */

proc sql;
connect to oracle as ora (user=username password=password path=database_path);

/* Retrieve data from Oracle and ensure survival_time is included */
create table patient_data as
select * from connection to ora
(select patient_id, /* other columns */, survival_time from patient_demographics);
quit;

/* Make sure treatment_details dataset is appropriately prepared */
proc sort data=treatment_details;
by patient_id;
run;

/* Sort the patient_data by patient_id to prepare for merging */
proc sort data=patient_data;
by patient_id;
run;

/* Merge the datasets on patient_id */
data merged_data;
merge patient_data(in=a) treatment_details(in=b);
by patient_id;
if a and b; /* Ensures only matching records are kept */
run;

/* Check if survival_time is present in the merged_data */
proc contents data=merged_data;
run;

/* Proceed with analysis if survival_time is present */
proc means data=merged_data;
class treatment_type response;
var survival_time;
run;

