##Integrated Project:Maji Ndogo Part 1##

#2. Dive into the water source: 
-- Once you've identified the right table, write a SQL query to find all the unique types of water sources.
 
 select distinct type_of_water_source
 from water_source;
 
 -- type_of_water_source 1- tap_in_home 2- tap_in_home_broken 3- well 4- shared_tap 5- river -- Let me quickly bring you up to speed on these water source types:

-- 1.River: Open water source with high contamination risk, used by millions in Maji Ndogo. It's the worst water source due to pollution.

-- 2.Well: Draws water from underground, safer than rivers but many are unclean due to aging infrastructure and past corruption.

-- 3.Shared Tap: Public taps shared by communities.--

-- 4.Home Tap: Taps inside homes, serving an average of 6 people per household.

-- 5.Broken Home Tap: Taps installed but non-functional due to issues like burst pipes or faulty water treatment systems.
##3.Unpack the visits to water sources:##
-- We have a table in our database that logs the visits made to different water sources. Can you identify this table?
-- Write an SQL query that retrieves all records from this table where the time_in_queue is more than some crazy time, say 500 min.How would it feel to queue 8 hours for water?

select * from visits 
where
time_in_queue > 500;

-- I am wondering what type of water sources take this long to queue for. We will have to find that information in another table that lists the types of water sources. If I remember correctly, the table has type_of_water_source, and a source_id column.
-- So let's write down a couple of these source_id values from our results, and search for them in the other table.
-- AkKi00881224  
-- AkLu01628224  
-- AkRu05234224  
-- HaRu19601224 
-- HaZa21742224 
-- SoRu36096224  
-- SoRu37635224  
-- SoRu38776224 
-- If we just select the first couple of records of the visits table without a WHERE filter, we can see that some of these rows also have 0 mins queue time. So let's write down one or two of these too.

select * from water_source 
where 
source_id = 'AkKi00881224'
OR
source_id = 'AkLu01628224'
OR
source_id = 'AkRu05234224'
OR 
source_id = 'HaRu19601224'
OR 
source_id = 'HaZa21742224'
OR 
source_id = 'SoRu36096224'
OR 
source_id = 'SoRu37635224';

##4.Assess the quality of water sources:##
-- The quality of our water sources is the whole point of this survey. 
-- We have a table that contains a quality score for each visit made about a water source that was assigned by a Field surveyor.
-- They assigned a score to each source from 1, being terrible, to 10 for agood, clean water source in a home.
-- Shared taps are not rated as high, and the score also depends on how long the queue times are.##

SELECT * FROM water_quality
WHERE
    subjective_quality_score = 10
AND 
   visit_count = 2;

##5. Investigate pollution issues:##
-- Did you notice that we recorded contamination/pollution data for all of the well sources? 
-- Find the right table and print the first few rows.
-- Find the right table and print the first few rows.

select * from well_pollution 
limit 10;

-- Scientists recorded water quality for all wells, classifying them as **Clean**, **Contaminated: Biological**, or **Contaminated: Chemical** based on test results. 
-- Wells contaminated with biological or chemical pollutants are unsafe for drinking. Each test has a source ID linking it to a specific location in Maji Ndogo. 
-- Biological contamination is measured in **CFU/mL** (0 = clean, >0.01 = contaminated). The data needs to be checked for accuracy, as errors could lead to illness.
#write a query that checks if the results is Clean but the biological column is > 0.01.#

select * from well_pollution 
where biological > 0.01
limit 50;

-- If we compare the results of this query to the entire table,
-- it seems like we have some inconsistencies in how the well statuses are
-- recorded. Specifically, it seems that some data input personnel 
-- might have mistaken the description field for determining the cleanliness of the water

## To find these descriptions, search for the word Clean with additional characters after it. 
-- As this is what separates incorrect descriptions from the records that should have "Clean".

select * from well_pollution 
Where description like 'clean_%';

-- The query should return 38 wrong descriptions.
-- 20:27:54	select * from well_pollution  where description like 'clean_%' LIMIT 0, 1000	38 row(s) returned	0.032 sec / 0.000 sec

## Now we need to fix these descriptions so that we don’t encounter this issue again in the future.
-- Looking at the results we can see two different descriptions that we need to fix:
-- 1. All records that mistakenly have Clean Bacteria: E. coli should updated to Bacteria: E. coli
-- 2. All records that mistakenly have Clean Bacteria: Giardia Lamblia should updated to Bacteria: Giardia Lamblia
-- The second issue we need to fix is in our results column.
-- We need to update the results column from Clean to Contaminated: Biological 
-- where the biological column has a value greater than 0.01.
select * from well_pollution
WHERE 
pollutant_ppm > 0.01
AND 
description LIKE 'Clean_%';

-- Case 1a: Update descriptions that mistakenly mention
-- Clean Bacteria: E. coli` to `Bacteria: E. coli`
-- Case 1b: Update the descriptions that mistakenly mention
-- Clean Bacteria: Giardia Lamblia` to `Bacteria: Giardia Lamblia
-- Case 2: Update the `result` to `Contaminated: Biological` where `biological` is greater than 0.01 plus current results is `Clean` 

set
   sql_safe_updates = 0;
-- Case 1a
update well_pollution
SET 
description = 'Bacteria: E. coli'
WHERE 
description = 'Clean Bacteria: E. coli' ;
-- Case 1b
update well_pollution
SET 
description = 'Bacteria: Giardia Lamblia'
WHERE 
description = 'Clean Bacteria: Giardia Lamblia';
-- Case 2
update well_pollution
SET 
results = 'Contaminated: Biological'
WHERE
biological > 0.01 AND results = 'Clean';

-- Run a query to make sure we fixed the errors
SELECT
*
FROM
well_pollution
WHERE
description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);


 


