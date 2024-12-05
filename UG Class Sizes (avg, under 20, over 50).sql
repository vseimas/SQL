--CLASS SECTIONS & SUBSECTIONS (UNDERGRADUATE CLASS SIZE)
--New Method: GR level courses with no UG level student enrollment were removed. Applied music sections were also removed. DHYG courses were added. Will not match anything prior to 2018-19.
--To update just the current year data, set year = '20xx'.


--Get all courses with UG level student enrollment
select distinct CRN_KEY
into #temp
from REG
where report = '1'
and levl_code in ('UG', 'UU')
and season = 'Fall' and year = '2023'

--Get class sections and enrollment
select actual_enrollment, season+' '+year term, crn_key, SUBJ_CODE, CRSE_NUMBER, DEPT_CODE, DEPT_CODE_OVERRIDE, DEPT_DESC, DEPT_DESC_OVERRIDE, COLL_CODE, COLL_CODE_OVERRIDE, DISCIPLINE, CREDIT_HOURS
into #sections
from SECT_SUM
where actual_enrollment > 1 
  and coll_code <> 'lw'
  and (coll_code <> 'dt' or (coll_code = 'dt' and dept_code = 'DHYG'))
  and (coll_code not in ('sp','ph') or (coll_code in ('sp','ph') and dept_code = 'SLPA'))
  and schd_code_meet1 in ('1', '5', '6','7')
and season = 'Fall' and year = '2023'
and right(term_code_key,2) in ('52','81','84')
union --Add Pharm 101
select actual_enrollment, season+' '+year term, crn_key, SUBJ_CODE, CRSE_NUMBER, DEPT_CODE, DEPT_CODE_OVERRIDE, DEPT_DESC, DEPT_DESC_OVERRIDE, COLL_CODE, COLL_CODE_OVERRIDE, DISCIPLINE, CREDIT_HOURS
from SECT_SUM
where actual_enrollment > 1
and coll_code in ('sp','ph')
and dept_code <> 'SLPA'
and subj_code = 'PRAC' and crse_number = '101'and title in ('Pharmacy Orientation')
and season = 'Fall' and year = '2023'


--Apply College/Department Overrides
update #sections set DEPT_CODE = DEPT_CODE_OVERRIDE where DEPT_CODE_OVERRIDE is not null
update #sections set DEPT_DESC = DEPT_DESC_OVERRIDE where DEPT_CODE_OVERRIDE is not null
update #sections set COLL_CODE = COLL_CODE_OVERRIDE where COLL_CODE_OVERRIDE is not null


--Remove letters from CRSE_NUMBER so you can filter out GR level courses
update #sections set CRSE_NUMBER = left(CRSE_NUMBER,3)

----Check that CRSE_NUMBER has no letters
--select distinct CRSE_NUMBER
--from #sections
--order by CRSE_NUMBER

--Remove all GR level courses with no UG student enrollment
delete from #sections where CRSE_NUMBER >= 200 and CRN_KEY not in (select CRN_KEY from #temp)

--Remove Pre-Dental Orientation with no credit hours
delete from #sections where dept_code in ('copx') and CREDIT_HOURS = 0

--Create class size bands (CDS/US News Check)
alter table #sections add class_size varchar(250)
go

update #sections set class_size = '1. 2-9' where actual_enrollment >=2 and actual_enrollment < 10
update #sections set class_size = '2. 10-19' where actual_enrollment >=10 and actual_enrollment < 20
update #sections set class_size = '3. 20-29' where actual_enrollment >=20 and actual_enrollment < 30
update #sections set class_size = '4. 30-39' where actual_enrollment >=30 and actual_enrollment < 40
update #sections set class_size = '5. 40-49' where actual_enrollment >=40 and actual_enrollment < 50
update #sections set class_size = '6. 50-99' where actual_enrollment >=50 and actual_enrollment < 100
update #sections set class_size = '7. 100' where actual_enrollment >= 100


--Update discipline so CORE/PACS/Other are categorized together
update #sections set DISCIPLINE = 'CORE/PACS/Other' where DISCIPLINE in ('PACS/Other', 'CORE/Other')


--Create US News/President's Metrics
alter table #sections add 
	under_20 varchar(250),
	over_50 varchar(250)
go

update #sections set under_20 = '0'
update #sections set under_20 = '1' where actual_enrollment < 20

update #sections set over_50 = '0'
update #sections set over_50 = '1' where actual_enrollment > 49


----Data to Pivot
select * from #sections 

drop table #sections
drop table #temp







