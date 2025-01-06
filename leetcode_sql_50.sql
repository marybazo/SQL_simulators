/*
Solved task to Top 50 SQL questions on leetcode.
https://leetcode.com/studyplan/top-sql-50/
*/

-- 1757. Recyclable and Low Fat Products
select
    product_id
from
    products
where 
    low_fats = 'Y' and recyclable = 'Y';

-- 584. Find Customer Referee
select 
    c."name"
from 
    customer c
where 
    coalesce(c.referee_id, 0) <> 2;

-- 595. Big Countries
select 
    name,
    population,
    area
from
    world
where 
    area >= 3000000
    or population >= 25000000;

-- 1148. Article Views I
select distinct 
    author_id as id
from 
    views
where 
    author_id = viewer_id
order by 
    author_id;

-- 1683. Invalid Tweets
select 
    tweet_id
from 
    tweets
where 
    length(content) > 15;

-- 1378. Replace Employee ID With The Unique Identifier
select 
    eu.unique_id, 
    e.name
from 
    employees e
Left join 
    employeeUNI eu ON e.id = eu.id;

-- 1068. Product Sales Analysis I
select 
    product_name, year, price
from
    sales s
inner join 
    product p on s.product_id = p.product_id;

-- 1581. Customer Who Visited but Did Not Make Any Transactions
select 
    v.customer_id, 
    count(v.visit_id) as count_no_trans
from
    visits v
left join 
    transactions t on v.visit_id = t.visit_id
where 
    t.visit_id is null
group by 
    v.customer_id;

-- 197. Rising Temperature
select 
    w1.id
from 
    Weather w1
left join 
    Weather w2 on w1.recordDate = w2.recordDate + INTERVAL '1 day'
WHERE 
    w1.temperature > w2.temperature;

-- 1661. Average Time of Process per Machine
select
    tmp.machine_id,
    round(tmp.processing_time::numeric, 3) as processing_time
from
    (select
        a1.machine_id,
        avg(a2.timestamp - a1.timestamp) as processing_time
    from 
        activity a1
    left join 
        activity a2 on a1.machine_id = a2.machine_id
                    and a1.process_id = a2.process_id
                    and a2.activity_type = 'end'
                    and a1.activity_type <> a2.activity_type
    group by
        a1.machine_id) as tmp;

-- 577. Employee Bonus
select
    e.name,
    b.bonus
from
    employee e
left join 
    bonus b on e.empId = b.empId
where
    coalesce(b.bonus, 0) < 1000;

-- 1280. Students and Examinations
select 
    s.student_id,
    s.student_name,
    sj.subject_name,
    coalesce(exams.attended_exams, 0) as attended_exams
from 
    students s
cross join subjects sj
left join (
    select
        e.student_id,
        e.subject_name,
        count(e.subject_name) as attended_exams
    from 
        examinations e 
    group by
        e.student_id,
        e.subject_name) as exams on exams.student_id = s.student_id
                                    and sj.subject_name = exams.subject_name
ORDER BY 
    s.student_id, 
    sj.subject_name;

-- 570. Managers with at Least 5 Direct Reports
select 
    a.name as name 
from 
    employee a 
left join 
    employee b on a.id = b.managerId
group by 
    a.name,a.id 
having 
    count(b.id) >= 5;

-- 1934. Confirmation Rate
select
    s.user_id,
    coalesce(case when tmp.action_amount = 0 or tmp.confirmed = 0 then 0
    else round(tmp.confirmed/tmp.action_amount::numeric, 2)
    end, 0) as confirmation_rate
from 
    signups s
left join (
    select 
        c.user_id,
        SUM(case when c.action = 'confirmed' then 1 ELSE 0 end) as confirmed, 
        COUNT(*) as action_amount
    from 
        confirmations c 
    group by 
        c.user_id) as tmp on s.user_id = tmp.user_id;

-- 620. Not Boring Movies
select 
    c.id,
    c.movie,
    c.description,
    c.rating
from
    cinema c
where
    c.description != 'boring' 
    and c.id % 2 = 1 
order by
    c.rating desc;

-- 1251. Average Selling Price
select
    p.product_id,
    coalesce(round(sum(p.price * us.units) / sum(us.units)::numeric, 2), 0) as average_price
from
    prices p
left join 
    unitsSold us on p.product_id = us.product_id
        and us.purchase_date between p.start_date and p.end_date
group by
    p.product_id;

-- 1075. Project Employees I
select 
    p.project_id,
    round(avg(e.experience_years),2) as average_years
from
    employee e
inner join
    project p on e.employee_id = p.employee_id
group by
    p.project_id;

-- 1633. Percentage of Users Attended a Contest
select 
    r.contest_id as contest_id,
    round(count(r.user_id)/(select count(*) from users):: numeric * 100, 2) as percentage
from
    register r
group by
    r.contest_id
order by
    percentage desc,
    contest_id;

--1211. Queries Quality and Percentage
select
    q.query_name,
    round(sum(q.rating / q.position::numeric) / count(q.query_name), 2) as quality,
    round(
        sum(case when q.rating < 3 then 1 else 0 end)
        /count(q.query_name)::numeric * 100, 2) as poor_query_percentage
from 
    queries q
group by
    q.query_name
order by
    q.query_name;

-- 1193. Monthly Transactions I
select 
    to_char(trans_date, 'YYYY-mm') as month,
    country,
    count(*) as trans_count,
    sum(case when state = 'approved' then 1 ELSE 0 end) as approved_count,
    sum(amount) as trans_total_amount,
    sum(case when state = 'approved' then amount ELSE 0 end) as approved_total_amount
from 
    transactions
group by 
    to_char(trans_date, 'YYYY-mm'), 
    country
order by
    month;

-- 1174. Immediate Food Delivery II
with FirstOrders as (
    select 
        customer_id,
        MIN(order_date) AS first_order_date
    from 
        delivery
    group by 
        customer_id
),
FirstOrderDetails as (
    select 
        f.customer_id,
        d.delivery_id,
        d.order_date,
        d.customer_pref_delivery_date
    from 
        firstOrders f
    inner join 
        delivery d on f.customer_id = d.customer_id 
            and f.first_order_date = d.order_date
)
select 
    round(
        100.0 * sum(case when order_date = customer_pref_delivery_date then 1 ELSE 0 end) 
        / COUNT(*), 
        2
    ) as immediate_percentage
from 
    FirstOrderDetails;

-- 550. Game Play Analysis IV
with firstLogin as (
    select 
        player_id,
        MIN(event_date) as first_login_date
    from 
        activity
    group by 
        player_id
), consecutiveLogin as (
    select 
        f.player_id
    from 
        firstLogin f
    inner join 
        activity a on f.player_id = a.player_id 
            and a.event_date = f.first_login_date + interval '1 day'
), totalPlayers as (
    select 
        count(DISTINCT player_id) AS total_players
    from 
        activity
)
select 
    round(
        (select count(DISTINCT player_id) from consecutiveLogin) 
        / 
        (select total_players from totalPlayers)::numeric, 
        2
    ) AS fraction;

-- 2356. Number of Unique Subjects Taught by Each Teacher
select 
    t.teacher_id,
    count(DISTINCT t.subject_id) as cnt
from 
    teacher t
group by 
    teacher_id;

-- 1141. User Activity for the Past 30 Days I
select 
    activity_date as day,
    count(DISTINCT user_id) as active_users
from 
    activity
where 
    activity_date between '2019-06-28'::DATE and '2019-07-27'::DATE
group by 
    activity_date
order by 
    activity_date;

-- 1070. Product Sales Analysis III
with first_year_sales as (
    select 
        s.product_id,
        min(s.year) as first_year
    from 
        sales s
    group by  
        s.product_id
)
select 
    s.product_id,
    f.first_year AS first_year,
    s.quantity,
    s.price
from 
    first_year_sales f
inner join 
    sales s on f.product_id = s.product_id 
        and f.first_year = s.year;

-- 596. Classes More Than 5 Students
select 
    c.class
from 
    courses c
group by 
    c.class
having 
    count(c.student) >= 5;

-- 1729. Find Followers Count
select 
    f.user_id,
    count(f.follower_id) as followers_count
from 
    followers f
group by 
    f.user_id
order by 
    f.user_id;

-- 619. Biggest Single Number
select
    max(tmp.num) as num
from(
    select 
        mn.num AS num
    from 
        myNumbers mn
    group by  
        mn.num
    having 
        count(num) = 1
    UNION ALL
    select 
        null) as tmp;

-- 1045. Customers Who Bought All Products
select 
    c.customer_id
from 
    customer c
inner join 
    product p on c.product_key = p.product_key
group by 
    c.customer_id
having 
    count(DISTINCT c.product_key) = (select count(*) from product);

-- 1731. The Number of Employees Which Report to Each Employee
select 
    e.employee_id as employee_id,
    e.name as "name",
    count(r.employee_id) as reports_count,
    round(avg(r.age)) as average_age
from 
    employees e
left join 
    employees r on e.employee_id = r.reports_to
where 
    r.employee_id is not null
group by 
    e.employee_id, e.name
order by
    e.employee_id;

-- 1789. Primary Department for Each Employee
select 
    e.employee_id,
    e.department_id
from 
    employee e
where 
    primary_flag = 'Y'
    or (
        primary_flag = 'N' 
        and employee_id not in (
            select 
                r.employee_id 
            from 
                employee r 
            where 
                r.primary_flag = 'Y'
        )
    );

-- 610. Triangle Judgement
select 
    x, 
    y, 
    z,
    case when x + y > z and x + z > y and y + z > x then 'Yes'
    else 'No'
    end as triangle
from 
    triangle;

-- 180. Consecutive Numbers
select 
    DISTINCT l1.num as ConsecutiveNums
from 
    logs l1
inner join 
    logs l2 on l1.id = l2.id - 1
inner join 
    logs l3 on l1.id = l3.id - 2
where 
    l1.num = l2.num and l1.num = l3.num;

-- 1164. Product Price at a Given Date
select 
    p.product_id,
    coalesce(
        (select 
            pr.new_price 
         from 
            products pr
         where 
            p.product_id = pr.product_id and pr.change_date <= '2019-08-16'
         order by 
            change_date desc
         limit 1),
        10
    ) as price
from 
    (select DISTINCT product_id from products) p;

-- 1204. Last Person to Fit in the Bus
with cumulative_weight as (
    select 
        q.person_name,
        q.weight,
        q.turn,
        sum(q.weight) over (order by q.turn) as total_weight
    from 
        queue q
)
select 
    cw.person_name
from 
    cumulative_weight cw
where 
    cw.total_weight <= 1000
order by 
    cw.turn desc
limit 1;

-- 1907. Count Salary Categories
select 
    'Low Salary' as category,
    count(*) as accounts_count
from 
    accounts
where 
    income < 20000
union all
select 
    'Average Salary',
    count(*)
from 
    accounts
where 
    income BETWEEN 20000 and 50000
union all
select 
    'High Salary', 
    count(*) 
from 
    accounts
where 
    income > 50000;

-- 1978. Employees Whose Manager Left the Company
select 
    e.employee_id
from 
    employees e
left join
    employees m on e.manager_id = m.employee_id
where 
    e.salary < 30000 
    and m.employee_id is null
    and e.manager_id is not null
order by
    e.employee_id;

-- 626. Exchange Seats
select 
    case 
        when mod(s.id, 2) = 1 and s.id + 1 <= (select max(s1.id) from seat s1) then s.id + 1
        when mod(s.id, 2) = 0 then s.id - 1
        else s.id
    end as id,
    s.student
from 
    seat s
order by
    id;

-- 1341. Movie Rating
with user_rank as (
    select
        mr.user_id,
        u.name as user_name, 
        count(mr.rating) as rating_amount,
        rank() over (order by count(mr.rating) desc) as rank_user
    from 
        movieRating mr
    inner join
        users u on mr.user_id = u.user_id
    group by
        mr.user_id,
        u.name
    order by
        rating_amount desc
), user_rated_most as(
    select 
        user_id,
        user_name as results
    from 
        user_rank
    where 
        rank_user = 1
    order by
        user_name
    limit 1
), movie_rating as (
    select 
        m.title as movie_name,
        AVG(mr.rating) as avg_rating
    from 
        movies m
    inner join 
        movieRating mr on m.movie_id = mr.movie_id
    where 
        mr.created_at between '2020-02-01' and '2020-02-29'
    group by 
        m.title
), top_movie as (
    select 
        movie_name as results 
    from 
        movie_rating
    where 
        avg_rating = (select max(avg_rating) from movie_rating)
    order by 
        movie_name
    limit 1
)
select results from user_rated_most
union all
select results from top_movie;

-- 1321. Restaurant Growth
with total_per_day as (
    select 
        visited_on, 
        sum(amount) as total_amount
    from 
        customer
    group by 
        visited_on
)
select 
    tpd.visited_on, 
    sum(tpd.total_amount) over visited_on_row as amount,     
    round(avg(tpd.total_amount) over visited_on_row, 2) as average_amount
from 
    total_per_day tpd
window 
    visited_on_row as (order by tpd.visited_on rows between 6 preceding and current row)
order by
    tpd.visited_on
offset 6;

-- 602. Friend Requests II: Who Has the Most Friends
with id_list as (
    select 
        requester_id as id 
    from 
        requestAccepted
    union all
    select 
        accepter_id as id 
    from 
        requestAccepted
)
select 
    id, 
    count(id) as num 
from 
    id_list
group by 
    id
order by 
    num desc 
limit 1;

-- 585. Investments in 2016
with not_unique_tiv_2015 as(
    select
        i.tiv_2015
    from 
        insurance i
    group by
        i.tiv_2015
    having
        count(i.tiv_2015) > 1
), unique_location as ( 
    select 
        i.lat || '-' || i.lon as location_uniq
    from 
        insurance i
    group by
        i.lat || '-' || i.lon
    having
        count(i.lat || '-' || i.lon) = 1

)select
    round(sum(tiv_2016::numeric), 2) as tiv_2016
from
    insurance i
where 
    i.tiv_2015 in (select tiv_2015 from not_unique_tiv_2015)
    and i.lat || '-' || i.lon in (select location_uniq from unique_location);

-- 185. Department Top Three Salaries
select 
    s_rank.department,
    s_rank.employee,
    s_rank.salary    
from 
    (select
        d.name as department,
        e.name as employee,
        e.salary, 
        dense_rank() over (partition by e.departmentId order by e.salary desc) as salary_rank
    from
        employee e
    inner join
        department d on e.departmentId = d.id
    ) as s_rank
where
    s_rank.salary_rank <= 3;

-- 1667. Fix Names in a Table
select
    u.user_id,
    upper(substring(u.name from 1 for 1)) ||
        lower(substring(u.name from 2 )) as name
from
    users u
order by
    user_id;

-- 1527. Patients With a Condition
select
    p.patient_id,
    p.patient_name,
    p.conditions
from
    patients p
where 
    p.conditions like '% DIAB1%'
    or  p.conditions like 'DIAB1%';

-- 196. Delete Duplicate Emails
delete from person
where id not in (
    select 
        min(p.id)
    from 
        person p
    group by 
        p.email);

-- 176. Second Highest Salary
select 
    max(e.salary) as SecondHighestSalary
from 
    employee e
where 
    e.salary < (select max(salary) from employee);

-- 1484. Group Sold Products By The Date
select
    a.sell_date,
    count(distinct a.product) as num_sold,
    string_agg(distinct product, ',' order by product) as products
from
    activities a
group by
    a.sell_date
order by
    sell_date;

-- 1327. List the Products Ordered in a Period
select 
    p.product_name,
    sum(o.unit) AS unit
from 
    products p
inner join 
    orders o on p.product_id = o.product_id
where 
    o.order_date between '2020-02-01' and '2020-02-29'
group by
    p.product_name
having 
    SUM(o.unit) >= 100
order by
    product_name;

-- 1517. Find Users With Valid E-Mails
select 
    u.user_id,
    u.name,
    u.mail
from 
    users u
where 
    u.mail ~ '^[a-zA-Z][a-zA-Z0-9._-]*@leetcode\.com$';