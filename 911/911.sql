USE 911calls;

select * from calls;

-- remove safe update mode
SET SQL_SAFE_UPDATES = 0;

-- check data type of a column
SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE table_name = 'calls' AND COLUMN_NAME = 'timeStamp';

-- change column names
alter table calls rename column zip to zipcode;
alter table calls rename column twp to township;
alter table calls rename column addr to address;
alter table calls rename column `desc` to description;

alter table calls drop column e;

-- check for null values
select * from calls where concat(lat,lng, description,zipcode,
							title,timeStamp, township, address,e) is null;
                            
-- convert timeStamp and zipcode data type
alter table calls modify zipcode INTEGER;
update calls set timeStamp = str_to_date(timeStamp, '%Y-%m-%d %T');
alter table calls modify column timeStamp datetime;

-- fill na values
update calls set zipcode='0' where zipcode = '';

-- add day, month, year columns + insert values accordingly
alter table calls add column day varchar(50),
add column month varchar(50),
add column year int,
add column hour_col int;

update calls
set day = dayname(timeStamp);
update calls
set month = monthname(timeStamp);
update calls
set year = extract(year from timeStamp);
update calls
set hour_col = extract(hour from timeStamp);

-- add new fields
alter table calls add column reason varchar(30),
add column sub_reason varchar(30);

update calls set reason = substring_index(title, ':', 1);
update calls set sub_reason = substring_index(title, ':', -1);

-- top 5 zipcode has highest 911 calls
select zipcode, count(title) from calls 
where zipcode <> 0
group by zipcode, title 
order by count(title) desc
limit 5;

-- get township names had the most calls in years list 
select township, count(title) from calls
where township <> '' OR township <> ' '
group by township, title
order by count(title) desc 
limit 5;

-- most common reason of 911 calls
select reason, count(reason) from calls
group by reason 
order by count(reason) desc
limit 1;

-- most common reason of 911 calls
select sub_reason, count(sub_reason) from calls
group by sub_reason 
order by count(sub_reason) desc
limit 1;

-- remove/trim the extras in DISABLED VEHICLE - and VEHICLE ACCIDENT -
UPDATE calls 
SET sub_reason = replace(sub_reason, 'DISABLED VEHICLE - ', 'DISABLED VEHICLE');
UPDATE calls 
SET sub_reason = replace(sub_reason, 'VEHICLE ACCIDENT -', 'VEHICLE ACCIDENT');

--  top 10 common sub reasons
select sub_reason, count(sub_reason) from calls
group by sub_reason
order by count(sub_reason) desc
limit 5;

-- find percentage of top 5 sub reasons people call for emergency
select 
  sub_reason, 
  count(sub_reason), 
  count(sub_reason)/(select count(*) from calls) * 100.0 as percentage
from calls
group by sub_reason
order by count(sub_reason) desc
limit 5;

-- SELECT sub_reason, 100 * COUNT(*) / total AS percentage
-- FROM calls
-- CROSS JOIN (
--     SELECT COUNT(*) AS total
--     FROM calls
-- )
-- GROUP BY sub_reason
-- ORDER BY percentage DESC
-- LIMIT 5


-- towns with highest number of fire alarm/ EMS/traffic
select township, count(reason) from calls
where reason = 'Fire'
group by township 
order by count(reason) desc
limit 3;

select township, count(reason) from calls
where reason = 'EMS'
group by township 
order by count(reason) desc
limit 3;

select township, count(reason) from calls
where reason = 'Traffic'
group by township 
order by count(reason) desc
limit 3;

-- which year has the highest calls
select year, count(reason) from calls
group by year
order by count(reason) desc
limit 1;

-- which month of the year has the highest calls
select month, year, count(reason) from calls
group by month, year
order by count(reason) desc
limit 1;

-- which day has the highest calls
select day, count(reason) from calls
group by day
order by count(reason) desc
limit 1;

-- which specific date where the most emergency calls were made
select day, month, year, count(reason) from calls
group by day, month, year
order by count(reason) desc
limit 1;

-- get percentage of incidents by day, month, year






-- What time of the day happen to get the most calls
select time, count(time) from calls 
where time between 00 and 23 
group by time 
limit 1;

-- During the above time window, what is the common reasons people call 911






