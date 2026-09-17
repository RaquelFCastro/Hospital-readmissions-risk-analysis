-- create database
create database hospital_readmissions;
use hospital_readmissions;

-- create the diabetic_data_raw table
create table diabetic_data_raw (
    encounter_id INT NOT NULL,
    patient_nbr INT NOT NULL,
    race VARCHAR(50),
    gender VARCHAR(20),
    age VARCHAR(20),
    weight VARCHAR(20),
    admission_type_id INT,
    discharge_disposition_id INT,
    admission_source_id INT,
    time_in_hospital INT,
    payer_code VARCHAR(10),
    medical_specialty VARCHAR(100),
    num_lab_procedures INT,
    num_procedures INT,
    num_medications INT,
    number_outpatient INT,
    number_emergency INT,
    number_inpatient INT,
    diag_1 VARCHAR(20),
    diag_2 VARCHAR(20),
    diag_3 VARCHAR(20),
    number_diagnoses INT,
    max_glu_serum VARCHAR(20),
    A1Cresult VARCHAR(20),
    metformin VARCHAR(20),
    repaglinide VARCHAR(20),
    nateglinide VARCHAR(20),
    chlorpropamide VARCHAR(20),
    glimepiride VARCHAR(20),
    acetohexamide VARCHAR(20),
    glipizide VARCHAR(20),
    glyburide VARCHAR(20),
    tolbutamide VARCHAR(20),
    pioglitazone VARCHAR(20),
    rosiglitazone VARCHAR(20),
    acarbose VARCHAR(20),
    miglitol VARCHAR(20),
    troglitazone VARCHAR(20),
    tolazamide VARCHAR(20),
    examide VARCHAR(20),
    citoglipton VARCHAR(20),
    insulin VARCHAR(20),
    `glyburide-metformin` VARCHAR(20),
    `glipizide-metformin` VARCHAR(20),
    `glimepiride-pioglitazone` VARCHAR(20),
    `metformin-rosiglitazone` VARCHAR(20),
    `metformin-pioglitazone` VARCHAR(20),
    `change` VARCHAR(10),
    diabetesMed VARCHAR(10),
    readmitted VARCHAR(20)
);

-- check table
DESCRIBE diabetic_data_raw;
SELECT COUNT(*) FROM diabetic_data_raw;

-- create the IDS_mapping tables
create table admission_type_raw(
admission_type_id int primary key,
description varchar(255)
);

insert into admission_type_raw (admission_type_id, description) values
(1, "Emergency"),
(2, "Urgent"),
(3, "Elective"),
(4, "Newborn"),
(5, "Not available"),
(6, null),
(7, "Truma Center"),
(8, "Not Mapped");

create table discharge_disposition_raw(
discharge_disposition_id int primary key,
description varchar (255)
);

insert into discharge_disposition_raw (discharge_disposition_id, description) values
(1, "Discharged to home"),
(2, "Discharged/transferred to another short term hospital"),
(3, "Discharged/transferred to SNF"),
(4, "Discharged/transferred to ICF"),
(5, "Discharged/transferred to another type of inpatient care institution"),
(6, "Discharged/transferred to home with home health service"),
(7, "Left AMA"),
(8, "Discharged/transferred to home under care of Home IV provider"),
(9, "Admited as an inpatient to this hospital"),
(10, "Neonate discharged to another hospital for neonatal aftercare"),
(11, "Expired"),
(12, "Still patient or expected to return for outpatient services"),
(13, "Hospice / home"),
(14, "Hopice / medical facility"),
(15, "Discharged/transferred within this institution to Medicare approved swing bed"),
(16, "Dichargeds/transferred/referred another institution for outpatient services"),
(17, "Discharged/transferred/referred to this institution for outpatient services"),
(18, null),
(19, "Expired at home. Medicaid only, hospice."),
(20, "Expired in a medical facility. Medicaid only, hospice."),
(21, "Expired, place unkown. Medicaid only, hospice."),
(22, "Discharged/transferred to another rehab fac including rehab units of a hospital."),
(23, "Discharged/transferred to a long term care hospital."),
(24, "Discharged/transferred to a nursing facility certified under Medicaid but not certifiedd under Medicare."),
(25, "Not mapped"),
(26, "Unknown/Invalid"),
(30, "Discharged/transferred to another Type of Health Care Institution not Defined Elsewhere"),
(27, "Discharged/transferred to a federal health care facility."),
(28, "Discharged/transferred/referred to a psychiatric hospital of psychiatric distintc part unit of a hospital"),
(29, "Discharged/transferred to a Critical Access Hospital (CAH).");

create table admission_source_raw (
admission_source_id int primary key,
description varchar (255)
);

insert into admission_source_raw (admission_source_id, description) values 
(1, "Physical Referral"),
(2, "Clinic Referral"),
(3, "HMO Referral"),
(4, "Transfer from hospital"),
(5, "Transfer from a Skilled Nursing Facility (SNF"),
(6, "Transfer from another health care facility"),
(7, "Emergency Room"),
(8, "Court/Law Enforcement"),
(9, "Not Available"),
(10,"Transfer from critical access hospital"),
(11, "Normal Delivery"),
(12, "Premature Delivery"),
(13, "Sick Baby"),
(14, "Extramural Birth"),
(15, "Not Available"),
(17, null),
(18, "Transfer From Another Home Health Agency"),
(19, "Readmission to Same Home Health Agency"),
(20, "Not Mapped"),
(21, "Unknown/Invalid"),
(22, "Transfer from hospital inpt/same fac reslt in a sep claim"),
(23, "Born inside this hospital"),
(24, "Born outside this hospital"),
(25, "Transfer from Ambulatory Surgery Center"),
(26, "Transfer from Hospice");

-- Step1 cleaning
-- data cleaning handling the ?
update diabetic_data_raw
set race = nullif (race, '?'),
	weight = nullif (weight, '?'),
	payer_code = nullif (payer_code, '?'),
	medical_specialty = nullif (medical_specialty, '?'),
	diag_1 = nullif (diag_1, '?'),
	diag_2 = nullif (diag_2, '?'),
	diag_3 = nullif (diag_3, '?');

-- quantify the amount of missing data
SELECT
    ROUND(
        SUM(weight IS NULL)
        / COUNT(*) * 100,
        1
    ) AS pct_missing_weight,

    ROUND(
        SUM(payer_code IS NULL)
        / COUNT(*) * 100,
        1
    ) AS pct_missing_payer_code,

    ROUND(
        SUM(race IS NULL)
        / COUNT(*) * 100,
        1
    ) AS pct_missing_race,

    ROUND(
        SUM(medical_specialty IS NULL)
        / COUNT(*) * 100,
        1
    ) AS pct_missing_medical_specialty

	FROM diabetic_data_raw;
	
-- handling duplicant patient counters
select 
	patient_nbr,
	COUNT(*) as encounter_count
from diabetic_data_raw
group by patient_nbr
having count(*) > 1
order by encounter_count desc 
limit 10;

-- keep only the first encounter 
create table diabetic_data_dedup as 
select t.*
from diabetic_data_raw as t
inner join (select 
	patient_nbr,
	min(encounter_id) as first_encounter
from diabetic_data_raw
group by patient_nbr) as first_enc
on t.patient_nbr = first_enc.patient_nbr
and t.encounter_id = first_enc.first_encounter;

select count(*) from diabetic_data_dedup

-- remove patients that will no longer be returning
select 
	discharge_disposition_id,
	count(*) as encounter_count
from diabetic_data_raw
group by discharge_disposition_id
order by encounter_count desc;

-- correction of error from discharge_disposition_raw table
update discharge_disposition_raw
set `14`= 'Hospice / medical facility'
where `14` = 'Hopice / medical facility';

select * from discharge_disposition_raw
where description like '%hospice%' or description like '%expired%' or description like '%deceased%' or description like '%Hopice%';

-- 11, 13, 14, 19, 20, 21 are diluting the data
delete from diabetic_data_dedup
where discharge_disposition_id in (11, 13, 14, 19, 20, 21);

-- remove brackets from column age
alter table diabetic_data_dedup 
add column age_midpoint INT;

update diabetic_data_dedup
set age_midpoint = case
	when age = '[0-10)' then 5
	when age = '[10-20)' then 15
	when age = '[20-30)' then 25
	when age = '[30-40)' then 35
	when age = '[40-50)' then 45
	when age = '[50-60)' then 55
	when age = '[60-70)' then 65
	when age = '[70-80)' then 75
	when age = '[80-90)' then 85
	when age = '[90-100)' then 95
end;

-- Step 2 exploratory analysis
-- overall readmission (being <30 days) breakdown
select 
	readmitted,
	count(*) as encounter_count,
	round(count(*)
	/ (select count(*) from diabetic_data_dedup) * 100,
	1
	) as pct_of_total
	from diabetic_data_dedup
	group by readmitted
	order by encounter_count desc;

-- readmission by age and age_midpoint 
select
	age,
	age_midpoint,
	count(*) as total_encounters,
	sum(readmitted = '<30') as readmitted_under_30,
	round(sum(readmitted = '<30') / count(*) * 100, 1) as readmission_rate_pct
from diabetic_data_dedup
group by age, age_midpoint 
order by age_midpoint;

-- readmission by way of admition_type
select 
	map.description as admission_type,
	count(*) as total_encouters,
	round(sum(d.readmitted = '<30') / count(*) * 100, 1) as readmission_rate_pct
from diabetic_data_dedup as d
join admission_type_raw as map
on d.admission_type_id = map.admission_type_id
group by map.description
order by readmission_rate_pct desc
;

-- readmission by admition_source
select 
	map.description as admission_source,
	count(*) as total_encouters,
	round(sum(d.readmitted = '<30') / count(*) * 100, 1) as readmission_rate_pct
from diabetic_data_dedup as d
join admission_source_raw as map
on d.admission_source_id = map.admission_source_id
group by map.description
order by readmission_rate_pct desc
;

-- readmission by discharge_disposition
select 
	map.description as discharge_disposition,
	count(*) as total_encouters,
	round(sum(d.readmitted = '<30') / count(*) * 100, 1) as readmission_rate_pct
from diabetic_data_dedup as d
join discharge_disposition_raw as map
on d.discharge_disposition_id = map.discharge_disposition_id
group by map.description
order by readmission_rate_pct desc
;

-- risk of readmission for multiple factors
with patient_risk_base as (
	select 
		encounter_id,
		patient_nbr,
		age_midpoint,
		time_in_hospital,
		num_medications,
		num_lab_procedures,
		number_diagnoses,
		number_inpatient,
		number_emergency,
		number_outpatient,
		diag_1,
		readmitted,
		case when readmitted = '<30' then 1 else 0 end as is_readmitted_30
	from diabetic_data_dedup
)
select * from patient_risk_base
limit 20
;

-- medication load by age group
with patient_risk_base as (
	select 
		encounter_id,
		age_midpoint,
		num_medications,
		readmitted,
		case when readmitted = '<30' then 1 else 0 end as is_readmitted_30
	from diabetic_data_dedup
)
select 
	encounter_id,
	age_midpoint,
	num_medications,
	rank() over(partition by age_midpoint order by num_medications desc) as med_rank_age_group
from patient_risk_base 
order by age_midpoint, med_rank_age_group 
limit 300
;

-- population level segmentation by number_inpatient
with patient_risk_base as (
	select 
		encounter_id,
		number_inpatient,
		readmitted,
		case when readmitted = '<30' then 1 else 0 end as is_readmitted_30
	from diabetic_data_dedup
)
select 
	encounter_id,
	number_inpatient,
	ntile(4) over (order by number_inpatient desc) as risk_quartile
from patient_risk_base
;

-- medication and diagnoses burden
select 
	encounter_id,
	num_medications,
	number_diagnoses,
	case 
		when num_medications <= 10 then 'Low'
		when num_medications between 11 and 20 then 'Medium'
		else 'High'
	end as medication_burden_tier,
	case
		when number_diagnoses <=5 then 'Low Complexity'
		when number_diagnoses between 6 and 9 then 'Moderate Complexity'
		else 'High Complexity'
	end as diagnoses_complexity_tier
from diabetic_data_dedup
;

-- -- Finding 1: Top diagnoses categories driving readmissions above hospital average
-- diag_1 notes
-- 390-459: Diseases of the circulatory system
-- 460-519: Diseases of the respiratory system
-- 520-579: Diseases of the digestive system
-- 580-629: Diseases of the genitourinary system
-- 800-999: Injury and poisoning
with diag_categorize as (
	select
		encounter_id,
		readmitted,
		case 
			when diag_1 like '250%' then 'Diabetes'
			when cast(left(diag_1, 3) as unsigned) between 390 and 459 then 'Circulatory'
			when cast(left(diag_1, 3) as unsigned) between 460 and 519 then 'Respiratory'
			when cast(left(diag_1, 3) as unsigned) between 520 and 579 then 'Digestive'
			when cast(left(diag_1, 3) as unsigned) between 580 and 629 then 'Genitourinaty'
			when cast(left(diag_1, 3) as unsigned) between 800 and 999 then 'Injury'
			else 'Other'
		end as diagnoses_category,
		case
			when readmitted = '<30' then 1 else 0 end as is_readmitted_30
		from diabetic_data_dedup
		where diag_1 is not null
)
select
	diagnoses_category,
	count(*) as total_encounters,
	round(avg(is_readmitted_30) * 100, 1) as readmission_rate_pct
from diag_categorize
group by diagnoses_category
having avg(is_readmitted_30)> (
	select avg(is_readmitted_30) from diag_categorize
)
order by readmission_rate_pct desc
;
		
-- Finding 2: Does a medication change at discharge affect readmission
select 
	`change`,
	count(*) as total_encounters,
	round(sum(readmitted = '<30') / count(*) * 100, 1) as readmission_rate_pct
from diabetic_data_dedup
group by `change` 
;

-- Finding 3: Discharge disposition impact
select 
	map.description as discharge_disposition,
	count(*) as total_encounters,
	round(sum(d.readmitted = '<30') / count(*) * 100, 1) as readmission_rate_pct
from diabetic_data_dedup as d
join discharge_disposition_raw as map
on d.discharge_disposition_id = map.discharge_disposition_id
group by map.description
having count(*) > 100
order by readmission_rate_pct desc 
limit 10
;

-- Finding 4: A1C testing and readmission
select
	A1Cresult,
	count(*) as total_encounters,
	round(sum(readmitted = '<30') / count(*) * 100, 1) as readmission_rate_pct
from diabetic_data_dedup
group by A1Cresult
;
