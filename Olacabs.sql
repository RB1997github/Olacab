create database case4sql;
set sql_safe_updates = 0;

use case4sql;
select * from data;
ALTER TABLE data
ADD COLUMN NewPickupDate DATE,
ADD COLUMN NewPickupTime TIME,
ADD COLUMN NewPickupDatetime DATETIME,
ADD COLUMN NewConfirmedAt DATETIME;

UPDATE data
SET NewPickupDate = STR_TO_DATE(pickup_date, '%d-%m-%Y'),
    NewPickupTime = STR_TO_DATE(pickup_time, '%H:%i:%s'),
    NewPickupDatetime = STR_TO_DATE(pickup_datetime, '%d-%m-%Y %H:%i:%s'),
    NewConfirmedAt = STR_TO_DATE(Confirmed_at, '%d-%m-%Y %H:%i:%s');
    
ALTER TABLE data
DROP COLUMN pickup_date,
DROP COLUMN pickup_time,
DROP COLUMN pickup_datetime,
DROP COLUMN Confirmed_at;

select * from data;

-------------------------------------------------------------------------
/*Find hour of 'pickup' and 'confirmed_at' time, and make a column of 
weekday as "Sun,Mon, etc"next to pickup_datetime											
-- Add columns for the hour and weekday
ALTER TABLE data
ADD COLUMN PickupHour INT,
ADD COLUMN ConfirmedHour INT,
ADD COLUMN Weekday CHAR(3);

-- Update the new columns with the hour and weekday values
UPDATE data
SET PickupHour = HOUR(NewPickupTime),
    ConfirmedHour = HOUR(NewConfirmedAt),
    Weekday = CONCAT(LEFT(DAYNAME(NewPickupDatetime), 3), ',');
*/


select newpickuptime, newconformedat, booking_id
from data 

---------------------------------------------------------------------
/*2-->Make a table with count of bookings with 
booking_type = p2p catgorized by booking mode as 'phone', 'online','app',etc
*/
/*Create a new table to store the result*/

create table Bookcnt (
booking_mode varchar(255),
Count int);

/*Insert counts in the new table*/

insert into Bookcnt (booking_mode, count)
SELECT Booking_mode, Count(*) as Cnt 
FROM data
WHERE booking_type = "p2p"
Group by Booking_mode;


/*Find top 5 drop zones in terms of average revenue				
*/
select 'Drop area', avg(fare) as Revenue
from data 
group by 'drop area'
order by 2 desc
limit 5; 

/*Find all unique driver numbers grouped by top 5 pickzones	*/				

select count(distinct Driver_number) as unq, PickupArea
from data
group by pickuparea
order by unq desc
limit 5;

/*Make a hourwise table of bookings for week between Nov01-Nov-07 
and highlight the hours with more than average no.of bookings day wise*/


/*Part 1 – Hour-wise no. of bookings*/
Select Hour(newPickuptime), Count(*)
FROM data
WHERE newpickupdate between 2013-11-01 and 2013-11-7
Group By Hour(newPickuptime);

/*Part 2 – Avge Daily Bookings*/
Select Avg(Bookings) as AvgDayWiseBookings
From (Select newPickupdate, Count(*) as Bookings
FROM data
WHERE newPickupdate between 2013-11-01 and 2013-11-7
Group By newPickupdate);

/*Combined*/
Select Hour(newpickuptime), Count(*)
FROM data
WHERE newPickupdate between 2013-11-01 and 2013-11-7
Group By Hour(newpickuptime)
HAVING Count(*) >
(Select Avg(Bookings) as AvgDayWiseBookings
From (Select newPickupdate, Count(*) as Bookings
FROM data
WHERE newPickupdate between 2013-11-01 and 2013-11-7
Group By newpickupdate)
);







