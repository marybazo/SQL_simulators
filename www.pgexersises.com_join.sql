/*
Retrieve the start times of members' bookings
How can you produce a list of the start times for bookings by members named 'David Farrell'?
*/
SELECT
	b.starttime
FROM
	cd.bookings as b
INNER JOIN
	cd.members  as m
	ON b.memid = m.memid
	AND m.surname = 'Farrell'
	AND m.firstname = 'David'

/*
Work out the start times of bookings for tennis courts
How can you produce a list of the start times for bookings for tennis courts, 
for the date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time.
*/
SELECT
	b.starttime as start,
	f.name
FROM
	cd.bookings as b
INNER JOIN
	cd.facilities  as f
	ON b.facid = f.facid
	AND f.name LIKE 'Tennis%'
	AND b.starttime::DATE = '2012-09-21'
ORDER BY
	start
	
/*
Produce a list of all members who have recommended another member
How can you output a list of all members who have recommended another member? 
Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname).
*/
SELECT DISTINCT
	m_name.firstname as f_name,
	m_name.surname as s_name
FROM
	cd.members as m
JOIN cd.members as m_name
	ON m.recommendedby = m_name.memid
ORDER BY
	s_name,
	f_name
	
/*
Produce a list of all members, along with their recommender
How can you output a list of all members, including the individual who recommended them (if any)? 
Ensure that results are ordered by (surname, firstname).
*/
SELECT
	m.firstname as f_name,
	m.surname as s_name,
	m_name.firstname ,
	m_name.surname 
FROM
	cd.members as m
LEFT JOIN cd.members as m_name
	ON m.recommendedby = m_name.memid
ORDER BY
	s_name,
	f_name

/*
Produce a list of all members who have used a tennis court
How can you produce a list of all members who have used a tennis court? 
Include in your output the name of the court, and the name of the member formatted as a single column. 
Ensure no duplicate data, and order by the member name followed by the facility name.
*/
SELECT DISTINCT
	concat(m.firstname, ' ', m.surname) as member,
	f.name as facility
FROM
	cd.bookings as b
JOIN cd.members as m
	ON b.memid = m.memid
JOIN cd.facilities as f
	ON b.facid = f.facid
	AND f.name LIKE 'Tennis%'
ORDER BY
	member, facility

/*
Produce a list of costly bookings
How can you produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) 
more than $30? Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), 
and the guest user is always ID 0. Include in your output the name of the facility, the name of the member formatted 
as a single column, and the cost. Order by descending cost, and do not use any subqueries.
*/
SELECT
	concat(m.firstname, ' ', m.surname) as member,
	f.name as facility,
	CASE 
		WHEN m.memid = 0
		THEN f.guestcost * b.slots
		ELSE f.membercost * b.slots
	END AS cost	
FROM 
    cd.bookings as b
JOIN cd.members as m
	ON b.memid = m.memid
JOIN cd.facilities as f
	ON b.facid = f.facid
WHERE
	b.starttime::DATE = '2012-09-14'
	AND CASE 
            WHEN m.memid = 0 
            THEN f.guestcost * b.slots 
            ELSE f.membercost * b.slots 
        END > 30
ORDER BY 
    cost DESC

/*
Produce a list of all members, along with their recommender, using no joins.
How can you output a list of all members, including the individual who recommended them (if any), 
without using any joins? Ensure that there are no duplicates in the list, and that each 
firstname + surname pairing is formatted as a column and ordered.
*/
SELECT DISTINCT
	concat(m.firstname, ' ', m.surname) as member,
	(SELECT 
		concat(m2.firstname, ' ', m2.surname)
	FROM 
		cd.members as m2
	WHERE m2.memid = m.recommendedby) as recommender
FROM 
	cd.members as m
ORDER BY
	member

/*
Produce a list of costly bookings, using a subquery
The Produce a list of costly bookings exercise contained some messy logic: 
we had to calculate the booking cost in both the WHERE clause and the CASE statement. 
Try to simplify this calculation using subqueries. 

For reference, the question was:
How can you produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) more than $30? 
Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), 
and the guest user is always ID 0. Include in your output the name of the facility, the name of the member 
formatted as a single column, and the cost. Order by descending cost.
*/
SELECT 
	g.member,
	g.facility,
	g.cost
FROM
	(SELECT
	  concat(m.firstname, ' ', m.surname) as member,
	  f.name as facility,
	  b.slots * CASE 
		  WHEN m.memid = 0
		  THEN f.guestcost 
		  ELSE f.membercost
	  END AS cost	
  FROM 
	  cd.bookings as b
  JOIN cd.members as m
	  ON b.memid = m.memid
  JOIN cd.facilities as f
	  ON b.facid = f.facid
  WHERE
	  b.starttime::DATE = '2012-09-14'
) as g
WHERE 
    g.cost > 30
ORDER BY 
    g.cost DESC