/*
Produce a timestamp for 1 a.m. on the 31st of August 2012
*/
SELECT 
    '2012-08-31 01:00:00'::CURRENT_TIMESTAMP;

/*
Subtract timestamps from each other
Find the result of subtracting the timestamp '2012-07-30 01:00:00' from the timestamp '2012-08-31 01:00:00'
*/
SELECT 
    '2012-08-31 01:00:00'::timestamp 
		- '2012-07-30 01:00:00'::timestamp AS interval; 

/*
Generate a list of all the dates in October 2012
Produce a list of all the dates in October 2012. They can be output as a timestamp (with time set to midnight) or a date.
*/
SELECT 
	generate_series(timestamp '2012-10-01', 
					timestamp '2012-10-31', 
					interval '1 day') as ts;

/*
Get the day of the month from a timestamp
Get the day of the month from the timestamp '2012-08-31' as an integer.
*/
SELECT 
	extract(DAY FROM '2012-08-31'::timestamp);  

/*
Work out the number of seconds between timestamps
Work out the number of seconds between the timestamps '2012-08-31 01:00:00' and '2012-09-02 00:00:00'
*/
SELECT 
	ROUND(extract(EPOCH FROM ('2012-09-02 00:00:00'::timestamp 
						- '2012-08-31 01:00:00'::timestamp)), 0);

/*
Work out the number of days in each month of 2012
For each month of the year in 2012, output the number of days in that month. 
Format the output as an integer column containing the month of the year, 
and a second column containing an interval data type.
*/
SELECT 	
	extract(month FROM cal.month) AS month,
	(cal.month + interval '1 month') - cal.month AS length
FROM(
	SELECT 
  		generate_series(timestamp '2012-01-01', 
						timestamp '2012-12-01', 
						interval '1 month') AS month
	)AS cal
ORDER BY month;

/*
Work out the number of days remaining in the month
For any given timestamp, work out the number of days remaining in the month. 
The current day should count as a whole day, regardless of the time. 
Use '2012-02-11 01:00:00' as an example timestamp for the purposes of making the answer. 
Format the output as a single interval value.
*/
SELECT 
	(date_trunc('month',ts.testts) + interval '1 month') 
		- date_trunc('day', ts.testts) AS remaining
FROM (
	SELECT 
  		timestamp '2012-02-11 01:00:00' AS testts) AS ts;

/*
Work out the end time of bookings
Return a list of the start and end time of the last 10 bookings (ordered by the time at which they end, 
followed by the time at which they start) in the system.
*/
SELECT 
	starttime, 
	starttime + slots*(interval '30 minutes') AS endtime
FROM 
	cd.bookings
ORDER BY 
	endtime desc, 
	starttime desc
LIMIT 10;

/*
Return a count of bookings for each month
Return a count of bookings for each month, sorted by month
*/
SELECT
	date_trunc('month', starttime) AS month, 
	count(*)
FROM 
	cd.bookings
GROUP BY 
	month
ORDER BY 
	month; 

/*
Work out the utilisation percentage for each facility by month 
Work out the utilisation percentage for each facility by month, sorted by name and month, 
rounded to 1 decimal place. Opening time is 8am, closing time is 8.30pm. You can treat every 
month as a full month, regardless of if there were some dates the club was not open.
*/

SELECT 
	name, 
	month, 
	round((100*slots)/
		cast(
			25*(cast((month + interval '1 month') AS date)
			- cast (month AS date)) AS numeric),1) AS utilisation
FROM (
	SELECT 
  		facs.name AS name, 
  		date_trunc('month', starttime) AS month, 
  		sum(slots) AS slots
	FROM 
  		cd.bookings bks
	INNER JOIN 
  		cd.facilities facs ON bks.facid = facs.facid
	GROUP BY 
  		facs.facid, 
  		month
	) AS inn
ORDER BY 
	name, 
	month   