
select year, id, STYP_CODE, ft_pt, ethnic_code, total_credit_hours, majr_desc1, level, degc_code, program_code, state1, REGION
into #temp
from enr WITH (NOLOCK)	
where year in ('2022', '2023', '2024') and season = 'fall'
and report = 1														

alter table #temp add
	FTE float,
	Resident varchar(255),
	Online varchar (255)

update #temp set FTE = total_credit_hours/15 where ft_pt = 'PT' and level = 'ug'
update #temp set FTE = total_credit_hours/12 where ft_pt = 'PT' and level = 'gr'
update #temp set FTE = total_credit_hours/18 where ft_pt = 'PT' and level = 'pr'
update #temp set FTE = 1 where ft_pt = 'FT' or degc_code in ('DDS', 'IDS')  --DDS/IDS students have always been full-time, but if there happen to be any that are PT, count them 1.0 FTE

--!! 11/27/23 -- IR can identify online students if the entire program is 100% online, or if a program code is entered on the student's record in Banner
--see these notes: "\Documentation and Procedures\Z Code Repository\Programs, Disciplines, Majors, Degrees\Online Academic Programs (offered 100% online, no residency component) 10.03.23.xlsx"

update #temp set Resident = 'Resident' where ethnic_code <> 'F'
update #temp set Resident = 'Non-Resident' where ethnic_code = 'F'
update #temp set Resident = 'Non-Resident' where program_code in ('MSL-ONLI', 'LLM-ONLI') and STATE1 <> 'CA'
update #temp set Resident = 'Non-Resident' where DEGC_CODE in ('DHSC', 'DMSC') and STATE1 <> 'CA'
update #temp set Resident = 'Non-Resident' where majr_desc1 in ('Cybersecurity') and STATE1 <> 'CA'

UPDATE #temp
SET Online = 
    CASE 
        when LEVEL = 'gr' AND (DEGC_CODE IN ('DHSC', 'DMSC') OR majr_desc1 IN ('Cybersecurity') OR program_code IN ('MSL-ONLI', 'LLM-ONLI'))
        then 'Online'
        else 'In-Seat'
	 END

update #temp set level = 'GR (Moodys)' where level in ('GR','PR');

select year, count(id) as students, styp_code, ft_pt, ETHNIC_CODE, sum(TOTAL_CREDIT_HOURS) as Total_Credit_Hours, MAJR_DESC1, level, DEGC_CODE, Program_Code, state1, region, sum(fte) as FTES, resident, online
from #temp
group by year, styp_code, ft_pt, ETHNIC_CODE, TOTAL_CREDIT_HOURS, MAJR_DESC1, level, DEGC_CODE, Program_Code, state1, region, fte, resident, online



drop table #temp



--in prior years FTE was calculated this way for Law/Dental--
--update #temp set FTE = 1 where ft_pt = 'FT' or degc_code in ('JD','DDS', 'MSL','LLM','JSD','AEGD','MSD')
--Beginning in fall 2023, the decision was made to update this and only count DDS as 1.0 for FT/PT. The law programs should use the regular formula. 

