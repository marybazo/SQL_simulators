/*
Count the number of facilities
For our first foray into aggregates, we're going to stick to something simple. 
We want to know how many facilities exist - simply produce a total count.
*/
SELECT 
    COUNT(*)
FROM 
    cd.facilities

/*
Count the number of expensive facilities
Produce a count of the number of facilities that have a cost to guests of 10 or more.
*/
SELECT 
    COUNT(*)
FROM 
    cd.facilities AS f
WHERE 
    f.guestcost > 9

/*
Count the number of recommendations each member makes.
Produce a count of the number of recommendations each member has made. 
Order by member ID.
*/
SELECT 
	m.recommendedby as recom,
	COUNT(m.memid)
FROM 
    cd.members AS m
WHERE 
    m.recommendedby IS NOT NULL
GROUP BY 
    m.recommendedby 
ORDER BY 
    recom

/*
List the total slots booked per facility
Produce a list of the total number of slots booked per facility. 
For now, just produce an output table consisting of facility id and slots, sorted by facility id.
*/
SELECT 
	f.facid as facid,
	SUM(b.slots) as total_slots
FROM 
    cd.facilities AS f 
JOIN cd.bookings AS b
    ON f.facid = b.facid
GROUP BY 
    f.facid
ORDER BY 
    facid

/*
List the total slots booked per facility in a given month
Produce a list of the total number of slots booked per facility in the month of September 2012. 
Produce an output table consisting of facility id and slots, sorted by the number of slots.
*/
SELECT 
	f.facid as facid,
	SUM(b.slots) as total_slots
FROM 
    cd.facilities AS f 
JOIN cd.bookings AS b
    ON f.facid = b.facid
WHERE 
    b.starttime BETWEEN '2012-09-01' AND '2012-10-01'
GROUP BY 
    f.facid
ORDER BY 
    total_slots

/*
List the total slots booked per facility per month
Produce a list of the total number of slots booked per facility per month in the year of 2012. 
Produce an output table consisting of facility id and slots, sorted by the id and month.
*/
SELECT 
	f.facid as facid,
	EXTRACT(MONTH FROM b.starttime) as month,
	SUM(b.slots) as total_slots
FROM 
    cd.facilities AS f 
JOIN cd.bookings AS b
    ON f.facid = b.facid
WHERE 
    EXTRACT(YEAR FROM b.starttime) = 2012
GROUP BY 
    f.facid, 
    EXTRACT(MONTH FROM b.starttime)
ORDER BY 
    facid, 
    month

/*
Find the count of members who have made at least one booking
Find the total number of members (including guests) who have made at least one booking.
*/
SELECT 
	COUNT(DISTINCT b.memid)
FROM 
    cd.bookings as b

/*
List facilities with more than 1000 slots booked
Produce a list of facilities with more than 1000 slots booked. 
Produce an output table consisting of facility id and slots, sorted by facility id.
*/
SELECT 
	f.facid as facid,
	SUM(b.slots) as total_slots
FROM 
    cd.facilities AS f 
JOIN cd.bookings AS b 
    ON f.facid = b.facid
GROUP BY 
    f.facid
HAVING 
    SUM(b.slots) > 1000
ORDER BY 
    facid

/*
Find the total revenue of each facility
Produce a list of facilities along with their total revenue. 
The output table should consist of facility name and revenue, sorted by revenue. 
Remember that there's a different cost for guests and members!
*/
SELECT
	f.name,
	SUM(b.slots *   
        CASE WHEN b.memid = 0 
            THEN f.guestcost
            ELSE f.membercost
        END) AS revenue
FROM 
    cd.facilities AS f
JOIN cd.bookings AS b 
    ON f.facid = b.facid
GROUP BY 
    f.name
ORDER BY 
    revenue

/*
Find facilities with a total revenue less than 1000
Produce a list of facilities with a total revenue less than 1000. 
Produce an output table consisting of facility name and revenue, sorted by revenue. 
Remember that there's a different cost for guests and members!
*/
SELECT
	f.name,
	SUM(b.slots * CASE WHEN b.memid = 0 
		THEN f.guestcost
		ELSE f.membercost
		END) AS revenue
FROM cd.facilities AS f
JOIN cd.bookings AS b ON f.facid = b.facid
GROUP BY f.name
HAVING 	SUM(b.slots * CASE WHEN b.memid = 0 
		THEN f.guestcost
		ELSE f.membercost
		END) < 1000 
ORDER BY revenue

/*
Output the facility id that has the highest number of slots booked
Output the facility id that has the highest number of slots booked. 
For bonus points, try a version without a LIMIT clause. This version will probably look messy!
*/
WITH fac_slots AS(
    SELECT
	    b.facid,
	    SUM(b.slots) AS slots
    FROM 
        cd.bookings AS b 
	GROUP BY 
        b.facid
)
SELECT 
    fs.facid, 
    fs.slots
FROM 
    fac_slots AS fs
WHERE 
    fs.slots = (
        SELECT 
            MAX(slots) 
        FROM 
            fac_slots)

/*
List the total slots booked per facility per month, part 2
Produce a list of the total number of slots booked per facility per month in the year of 2012. 
In this version, include output rows containing totals for all months per facility, 
and a total for all months for all facilities. The output table should consist of facility id, 
month and slots, sorted by the id and month. When calculating the aggregated values for all months and all facids, 
return null values in the month and facid columns.
*/
-- v1
WITH fac_slots AS(
	SELECT
		b.facid as id,
  		EXTRACT(MONTH FROM b.starttime) AS month,
		b.slots AS slots
	FROM 
        cd.bookings AS 
  	WHERE 
        EXTRACT(YEAR FROM b.starttime) = 2012
 )
SELECT 
    fs.id, 
    fs.month, 
    sum(fs.slots)
FROM 
    fac_slots AS fs
GROUP BY 
    fs.id, 
    fs.month 
UNION ALL
SELECT 
    fs.id, 
    NULL, 
    sum(fs.slots)
FROM 
    fac_slots AS fs
GROUP BY 
    fs.id 
UNION ALL
SELECT 
    NULL, 
    NULL, 
    sum(fs.slots)
FROM 
    fac_slots AS fs
ORDER BY 
    id, 
    month
-- v2
SELECT
	b.facid,
  	EXTRACT(MONTH FROM b.starttime) AS month,
	SUM(b.slots) AS slots
FROM 
    cd.bookings AS b 
WHERE 
    EXTRACT(YEAR FROM b.starttime) = 2012
GROUP BY 
    rollup(b.facid, EXTRACT(MONTH FROM b.starttime))
ORDER BY 
    facid, 
    month
/*
List the total hours booked per named facility
Produce a list of the total number of hours booked per facility, 
remembering that a slot lasts half an hour. 
The output table should consist of the facility id, name, and hours booked, 
sorted by facility id. Try formatting the hours to two decimal places.
*/	
SELECT 
    f.facid, 
    f.name, 
    round(sum(b.slots)/2::DECIMAL,2) AS hours
FROM 
    cd.bookings as b 
JOIN cd.facilities as f 
	ON b.facid = f.facid
GROUP BY 
    f.facid, 
    f.name
ORDER BY 
    f.facid

/*
List each member's first booking after September 1st 2012
Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID.
*/
SELECT 
    m.surname, 
    m.firstname, 
    m.memid, 
    min(b.starttime)
FROM cd.members as m 
JOIN cd.bookings as b 
	ON m.memid = b.memid 
    AND b.starttime::DATE >= '2012-09-01'
GROUP BY 
    m.surname, 
    m.firstname, 
    m.memid
ORDER BY 
    memid

/*
Produce a list of member names, with each row containing the total member count
Produce a list of member names, with each row containing the total member count. 
Order by join date, and include guest members
*/
SELECT
	mc.count,
	m.firstname,
	m.surname
FROM cd.members as m, 
    (SELECT 
        COUNT(*) as count 
    FROM 
        cd.members) as mc
ORDER BY 
    m.joindate

/*
Produce a numbered list of members
Produce a monotonically increasing numbered list of members (including guests), 
ordered by their date of joining. Remember that member IDs are not guaranteed to be sequential.
*/
SELECT
	row_number() over(ORDER BY m.joindate) AS row_number,
	m.firstname,
	m.surname
FROM 
    cd.members as m

/*
Output the facility id that has the highest number of slots booked, again
Output the facility id that has the highest number of slots booked. 
Ensure that in the event of a tie, all tieing results get output.
*/
--v1
SELECT 
    b.facid, 
    sum(b.slots) as slots
FROM 
    cd.bookings as b
GROUP BY 
    b.facid
ORDER BY 
    slots DESC
LIMIT 1
--v2
SELECT r.facid, r.slots
FROM
    (SELECT 
        b.facid, 
        sum(b.slots) as slots,
        rank() over(ORDER BY sum(slots) DESC) as rank
    FROM 
        cd.bookings as b
    GROUP BY 
        b.facid) as r
WHERE r.rank = 1
	
/*
Rank members by (rounded) hours used
Produce a list of members (including guests), along with the number of hours they've booked in facilities, 
rounded to the nearest ten hours. Rank them by this rounded figure, producing output of first name, surname, 
rounded hours, rank. Sort by rank, surname, and first name.
*/
SELECT 
    m.firstname, 
    m.surname,
	((sum(b.slots)+10)/20)*10 as hours,
	rank() over(ORDER BY ((sum(b.slots)+10)/20)*10 DESC) as rank
FROM 
    cd.members as m
JOIN cd.bookings as b
	ON m.memid = b.memid
GROUP BY 
    m.memid
ORDER BY 
    rank,  
    m.surname, 
    m.firstname

/*
Find the top three revenue generating facilities
Produce a list of the top three revenue generating facilities (including ties). 
Output facility name and rank, sorted by rank and facility name.
*/
SELECT f.name,
	rank() over (ORDER BY 
				 sum(b.slots * CASE when b.memid = 0
                                    then f.guestcost
                                    else f.membercost
				  end) DESC) AS rank
FROM 
    d.facilities as f
JOIN cd.bookings as b 
    ON f.facid = b.facid
GROUP BY 
    f.facid
LIMIT 3

/*
Classify facilities by value
Classify facilities into equally sized groups of high, average, and low based on their revenue. 
Order by classification and facility name.
*/
WITH revenue as (
    SELECT 
        f.name,
	    ntile(3) over(ORDER BY sum(b.slots * CASE when b.memid = 0
                                                    then f.guestcost
                                                    else f.membercost
		end) DESC) AS cost
FROM 
    cd.facilities as f 
JOIN cd.bookings as b 
    ON f.facid = b.facid
GROUP BY 
    f.facid
)
SELECT
	r.name,
	case 
		when r.cost = 1 then 'high'
		when r.cost = 2 then 'average'
		else 'low' end as revenue
FROM 
    revenue as r
ORDER BY 
    r.cost, 
    r.name

/*
Calculate the payback time for each facility
Based on the 3 complete months of data so far, calculate the amount of time each 
facility will take to repay its cost of ownership. Remember to take into account 
ongoing monthly maintenance. Output facility name and payback time in months, 
order by facility name. Don't worry about differences in month lengths, we're only 
looking for a rough value here!
*/
WITH revenue_by_month as (
    SELECT 
	    f.name, 
        f.facid,
	    f.initialoutlay as init_cost, 
        f.monthlymaintenance as month_cost,
	    sum(b.slots * 
            CASE when b.memid = 0 
            then f.guestcost
		    else f.membercost 
            end)/3 AS avg_revenue
FROM 
    cd.facilities as f
JOIN cd.bookings as b
	ON f.facid = b.facid
GROUP BY 
    f.facid
ORDER BY 
    name)
SELECT
	rm.name,
	init_cost/(avg_revenue - month_cost) as month
FROM revenue_by_month as rm

/*
Calculate a rolling average of total revenue
For each day in August 2012, calculate a rolling average of total revenue 
over the previous 15 days. Output should contain date and revenue columns, 
sorted by the date. Remember to account for the possibility of a day having zero revenue. 
This one's a bit tough, so don't be afraid to check out the hint!
*/
SELECT date_gen.date,
	(SELECT sum(b.slots * case
			when memid = 0 then f.guestcost
			else f.membercost end) AS rev
	FROM cd.bookings b
	JOIN cd.facilities f ON b.facid = f.facid
	WHERE b.starttime > date_gen.date - interval '14 days'
		AND b.starttime < date_gen.date + interval '1 day'
	)/15 AS revenue
FROM
	(SELECT cast(generate_series(timestamp '2012-08-01',
			'2012-08-31','1 day') as date) as date
	) AS date_gen
ORDER BY date_gen.date