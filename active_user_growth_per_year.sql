-- Show Jira user license growth over time. Depends on active_users.sql
-- E.g.:
-- ┌──────┬───────────┬──────────────┐
-- │ year │ new_users │ total_active │
-- ├──────┼───────────┼──────────────┤
-- │ 2009 │         1 │            1 │
-- │ 2014 │        83 │           84 │
-- │ 2015 │        47 │          131 │
-- │ 2016 │        74 │          205 │
-- │ 2017 │       167 │          372 │
-- │ 2018 │       125 │          497 │
-- │ 2019 │        74 │          571 │
-- │ 2020 │        83 │          654 │   <-- 654 equals the licensed users 'signed up currently' on /admin/license.action
-- └──────┴───────────┴──────────────┘
-- (8 rows)
select year, new_users, sum(new_users) over (order by year) AS total_active
from (
	select 
		to_char(created_date, 'YYYY') AS year
		, count(*) AS new_users
	from queries.active_users
	group by 1
	order by 1 asc
) x;
