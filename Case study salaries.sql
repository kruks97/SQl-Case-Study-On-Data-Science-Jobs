/* you are compensation analyst employed by a multinational corporation.
 Your assignement is to pinpoint countries who give fully remote work, for 
 title 'manager' paying salaries exceeding $90000 USD */

select distinct company_location from ds_jobs.salaries
where salary_in_usd > 90000 and 
job_title like '%manager%' and
remote_ratio= 100;

/* As a remote work advocate working for a progressive HR tech startup who place their freshers'
clients in large tech firms. You are tasked with identifying top 5 country having greatest count of 
large (company size) number of comapnies. */

select company_location, count(*) as 'count_of_large' from ds_jobs.salaries
where company_size= 'l' and experience_level= 'EN'
group by company_location
order by count_of_large desc limit 5;

/* Picture yourself AS a data scientist Working for a workforce management platform.
 Your objective is to calculate the percentage of employees. Who enjoy fully remote roles
 WITH salaries Exceeding $100,000 USD, Shedding light ON the attractiveness of high-paying 
 remote positions IN today's job market.*/
 
set @total= (select count(*) from ds_jobs.salaries where salary_in_usd>100000 );
set @count= (select count(*) from ds_jobs.salaries where salary_in_usd>100000 and remote_ratio =100 );
set @percent=((select @count)/ (select @total))*100;
select @percent as percent;

SELECT 
    (COUNT(CASE WHEN remote_ratio = 100 THEN 1 END) / COUNT(*)) * 100 AS percent
FROM 
    ds_jobs.salaries
WHERE 
    salary_in_usd > 100000;

/* Imagine you're a data analyst Working for a global recruitment agency. 
Your Task is to identify the Locations where entry-level average salaries exceed
 the average salary for that job title IN market for entry level, helping your agency guide 
 candidates towards lucrative opportunities. */
 
SELECT company_locatiON, t.job_title, average_per_country, average FROM 
(
	SELECT company_locatiON,job_title,AVG(salary_IN_usd) AS average_per_country FROM  ds_jobs.salaries WHERE experience_level = 'EN' 
	GROUP BY  company_locatiON, job_title
) AS t 
INNER JOIN 
( 
	 SELECT job_title,AVG(salary_IN_usd) AS average FROM ds_jobs.salaries  WHERE experience_level = 'EN'  GROUP BY job_title
) AS p 
ON  t.job_title = p.job_title WHERE average_per_country> average;
	
/* You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries.
 Your job is to Find out for each job title which. Country pays the maximum average salary. This helps you 
 to place your candidates IN those countries. */
 
 select * from
(select *, dense_rank() over (partition by job_title order by average desc) as'num' from
 (select  job_title, company_location, avg(salary_in_usd) as 'average'
 from ds_jobs.salaries
 group by job_title, company_location)t) k
 where num=1;
 
 
/* AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary 
trends across different company Locations. Your goal is to Pinpoint Locations WHERE the average salary Has consistently 
Increased over the Past few years (Countries WHERE data is available for 3 years Only(present year and past two years)
 providing Insights into Locations experiencing Sustained salary growth. */
 
 with Short as 
 (
				  select * from ds_jobs.salaries 
				 where company_location in
				 (select company_location from
				 (select company_location, avg(salary_in_usd), count(distinct work_year) as 'cnt' 
				from ds_jobs.salaries
				 where work_year>=(year(current_date())-2)
				 group by company_location
				 having cnt =3)t)
       )
select company_location,
max(CASE WHEN work_year=2022 THEN average END) AS avg_salary_2022,
max(CASE WHEN work_year=2023 THEN average END) AS avg_salary_2023,
max(CASE WHEN work_year=2024 THEN average END)as avg_salary_2024
from
( select company_location, work_year, avg(salary_in_usd) as 'average' from short
 group by company_location, work_year)q group by company_location
 having avg_salary_2024>avg_salary_2023 and avg_salary_2023> avg_salary_2022;
 
 /* Picture yourself AS a workforce strategist employed by a global HR tech startup. 
 Your Mission is to Determine the percentage of fully remote work for each experience level IN 2021
 and compare it WITH the corresponding figures for 2024, Highlighting any significant Increases or decreases 
 IN remote work Adoption over the years. */
 
select* from
((select a.experience_level,total,count, (count/total)*100 as 'percent_21' from
(select experience_level,count(*) as 'total' from ds_jobs.salaries
where work_year= 2021 
group by experience_level)a
inner join
(select experience_level,count(*) as 'count' from ds_jobs.salaries
where work_year= 2021 and remote_ratio=100
group by experience_level)b
on a.experience_level=b.experience_level))t
inner join
(select a.experience_level,total,count, (count/total)*100 as 'percent_24' from
(select experience_level,count(*) as 'total' from ds_jobs.salaries
where work_year= 2024 
group by experience_level)a
inner join
(select experience_level,count(*) as 'count' from ds_jobs.salaries
where work_year= 2024 and remote_ratio=100
group by experience_level)b
on a.experience_level=b.experience_level)m
on t.experience_level=m.experience_level;

/* AS a Compensation specialist at a Fortune 500 company, you're tasked WITH analyzing salary trends over time.
 Your objective is to calculate the average salary increase percentage for each experience level and job title 
 between the years 2023 and 2024, helping the company stay competitive IN the talent market. */
 
select a.experience_level,a.job_title, avg_23, avg_24, ((avg_24-avg_23)/avg_23)*100 as 'change' from
	 (select experience_level, job_title, avg(salary_in_usd) as 'avg_23' from ds_jobs.salaries
	 where work_year= 2023
	 group by experience_level,job_title)a
inner join
	 (select experience_level, job_title, avg(salary_in_usd) as 'avg_24' from ds_jobs.salaries
	 where work_year= 2024
	 group by experience_level,job_title) b
on a.experience_level=b.experience_level and
a.job_title=b.job_title ;




