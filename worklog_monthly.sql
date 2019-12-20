-- A giant table of worklog hours per day, for each day of the month, selectable by user, year and month
-- https://www.redradishtech.com/display/~jturner/2019/12/19/A+monthly+worklog+report+within+Confluence?moved=true
create schema if not exists queries;
create or replace view queries.worklog_monthly AS
select * from (
	select user_name, email_address, year, month
	, round(sum(sum),2) AS month_total
	,case sum("1") when 0 then 0 else round(sum("1"),2) end AS "1"
	,case sum("2") when 0 then 0 else round(sum("2"),2) end AS "2"
	,case sum("3") when 0 then 0 else round(sum("3"),2) end AS "3"
	,case sum("4") when 0 then 0 else round(sum("4"),2) end AS "4"
	,case sum("5") when 0 then 0 else round(sum("5"),2) end AS "5"
	,case sum("6") when 0 then 0 else round(sum("6"),2) end AS "6"
	,case sum("7") when 0 then 0 else round(sum("7"),2) end AS "7"
	,case sum("8") when 0 then 0 else round(sum("8"),2) end AS "8"
	,case sum("9") when 0 then 0 else round(sum("9"),2) end AS "9"
	,case sum("10") when 0 then 0 else round(sum("10"),2) end AS "10"
	,case sum("11") when 0 then 0 else round(sum("11"),2) end AS "11"
	,case sum("12") when 0 then 0 else round(sum("12"),2) end AS "12"
	,case sum("13") when 0 then 0 else round(sum("13"),2) end AS "13"
	,case sum("14") when 0 then 0 else round(sum("14"),2) end AS "14"
	,case sum("15") when 0 then 0 else round(sum("15"),2) end AS "15"
	,case sum("16") when 0 then 0 else round(sum("16"),2) end AS "16"
	,case sum("17") when 0 then 0 else round(sum("17"),2) end AS "17"
	,case sum("18") when 0 then 0 else round(sum("18"),2) end AS "18"
	,case sum("19") when 0 then 0 else round(sum("19"),2) end AS "19"
	,case sum("20") when 0 then 0 else round(sum("20"),2) end AS "20"
	,case sum("21") when 0 then 0 else round(sum("21"),2) end AS "21"
	,case sum("22") when 0 then 0 else round(sum("22"),2) end AS "22"
	,case sum("23") when 0 then 0 else round(sum("23"),2) end AS "23"
	,case sum("24") when 0 then 0 else round(sum("24"),2) end AS "24"
	,case sum("25") when 0 then 0 else round(sum("25"),2) end AS "25"
	,case sum("26") when 0 then 0 else round(sum("26"),2) end AS "26"
	,case sum("27") when 0 then 0 else round(sum("27"),2) end AS "27"
	,case sum("28") when 0 then 0 else round(sum("28"),2) end AS "28"
	,case sum("29") when 0 then 0 else round(sum("29"),2) end AS "29"
	,case sum("30") when 0 then 0 else round(sum("30"),2) end AS "30"
	,case sum("31") when 0 then 0 else round(sum("31"),2) end AS "31"
	from (
		select user_name, email_address, year, month, day, sum
		, case day when 1 then sum else 0 end AS "1" 
		, case day when 2 then sum else 0 end AS "2" 
		, case day when 3 then sum else 0 end AS "3" 
		, case day when 4 then sum else 0 end AS "4" 
		, case day when 5 then sum else 0 end AS "5" 
		, case day when 6 then sum else 0 end AS "6" 
		, case day when 7 then sum else 0 end AS "7" 
		, case day when 8 then sum else 0 end AS "8" 
		, case day when 9 then sum else 0 end AS "9" 
		, case day when 10 then sum else 0 end AS "10" 
		, case day when 11 then sum else 0 end AS "11" 
		, case day when 12 then sum else 0 end AS "12" 
		, case day when 13 then sum else 0 end AS "13" 
		, case day when 14 then sum else 0 end AS "14" 
		, case day when 15 then sum else 0 end AS "15" 
		, case day when 16 then sum else 0 end AS "16" 
		, case day when 17 then sum else 0 end AS "17" 
		, case day when 18 then sum else 0 end AS "18" 
		, case day when 19 then sum else 0 end AS "19" 
		, case day when 20 then sum else 0 end AS "20" 
		, case day when 21 then sum else 0 end AS "21" 
		, case day when 22 then sum else 0 end AS "22" 
		, case day when 23 then sum else 0 end AS "23" 
		, case day when 24 then sum else 0 end AS "24" 
		, case day when 25 then sum else 0 end AS "25" 
		, case day when 26 then sum else 0 end AS "26" 
		, case day when 27 then sum else 0 end AS "27" 
		, case day when 28 then sum else 0 end AS "28" 
		, case day when 29 then sum else 0 end AS "29" 
		, case day when 30 then sum else 0 end AS "30" 
		, case day when 31 then sum else 0 end AS "31" 
		from (
			select
				user_name
				, email_address
				, extract(year from dte) AS year
				, extract(month from dte) AS month
				, extract(day from dte) AS day
				, sum(coalesce(timeworked,0))/60.0/60 AS sum
			from
				(select generate_series::date AS dte from generate_series('2019-01-01'::date, now()::date, '1 day')) alldays 
				FULL OUTER JOIN cwd_user
				ON (true)
				INNER JOIN app_user
				USING (lower_user_name)
				LEFT JOIN
				public.worklog
				ON 
					worklog.author = app_user.user_key AND
					to_char(dte, 'YYYY-MM-DD') = to_char(worklog.startdate, 'YYYY-MM-DD')
				WHERE cwd_user.active=1 
				-- and email_address ~ '(redradishtech\.com)$'  -- Optionally filter to just workloggable users here.
			group by (user_name, email_address, year, month, day) 
		) y
	) z group by rollup((user_name, email_address), year, month)
) q
order by month_total desc
;
grant select on queries.worklog_monthly to jira_ro;
