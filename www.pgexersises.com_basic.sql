--Retrieve everything from a table
SELECT
    *
FROM
    cd.facilities
/*
Retrieve specific columns from a table
You want to print out a list of all of the facilities and their cost to members. 
How would you retrieve a list of only facility names and costs?
*/
SELECT 
    f.name, 
    f.membercost 
FROM 
    cd.facilities as f

/*
Control which rows are retrieved
How can you produce a list of facilities that charge a fee to members?
*/
SELECT 
    f.name
FROM 
    cd.facilities as f
WHERE 
	f.membercost > 0

/*
Control which rows are retrieved - part 2 
How can you produce a list of facilities that charge a fee to members, 
and that fee is less than 1/50th of the monthly maintenance cost? 
Return the facid, facility name, member cost, and monthly maintenance of the facilities in question.
*/
SELECT 
	f.facid,
    f.name,
	f.membercost,
	f.monthlymaintenance
FROM 
    cd.facilities as f
WHERE 
	f.membercost < f.monthlymaintenance/50
	AND f.membercost > 0

/*
Basic string searches
How can you produce a list of all facilities with the word 'Tennis' in their name?
*/
SELECT 
	*
FROM 
    cd.facilities as f
WHERE 
	f.name LIKE '%Tennis%'

/*
Matching against multiple possible values
How can you retrieve the details of facilities with ID 1 and 5? Try to do it without using the OR operator.
*/
SELECT 
	*
FROM 
    cd.facilities as f
WHERE 
	f.facid IN (1,5)

/*
Classify results into buckets
How can you produce a list of facilities, with each labelled as 'cheap' or 'expensive' depending on 
if their monthly maintenance cost is more than $100? Return the name and monthly 
maintenance of the facilities in question.
*/
SELECT 
	f.name,
	CASE
		WHEN f.monthlymaintenance > 100
		THEN 'expensive'
		ELSE 'cheap'
		END AS cost
FROM 
    cd.facilities as f

/*
Working with dates
How can you produce a list of members who joined after the start of September 2012? 
Return the memid, surname, firstname, and joindate of the members in question.
*/
SELECT 
	m.memid,
	m.surname,
	m.firstname,
	m.joindate
FROM 
    cd.members as m
WHERE 
	(EXTRACT(YEAR FROM m.joindate) = 2012 
	AND EXTRACT(MONTH FROM m.joindate) >= 9)
	OR EXTRACT(YEAR FROM m.joindate) > 2012 

/*
Removing duplicates, and ordering results
How can you produce an ordered list of the first 10 surnames in the members table? 
The list must not contain duplicates.
*/
SELECT 
	DISTINCT m.surname
FROM 
    cd.members as m
ORDER BY
	m.surname
LIMIT 10

/*
Combining results from multiple queries
You, for some reason, want a combined list of all surnames and all facility names. 
Yes, this is a contrived example :-). Produce that list!
*/
SELECT 
	m.name
FROM 
    cd.facilities as m
UNION 
SELECT 
	m.surname
FROM 
    cd.members as m

/*
Simple aggregation
You'd like to get the signup date of your last member. How can you retrieve this information?
*/
SELECT
	max(m.joindate) as latest
FROM
	cd.members as m

/*
More aggregation 
You'd like to get the first and last name of the last member(s) who signed up - not just the date. 
How can you do that?
*/
SELECT
	m.firstname,
	m.surname,
	m.joindate as latest
FROM
	cd.members as m
WHERE m.joindate = (
					SELECT
						max(m.joindate) as latest
					FROM
						cd.members as m) 