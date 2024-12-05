
select 
a.pidm_key, a.term_code_key, a.COLL_CODE, a.DISCIPLINE, a.majr_desc1, a.uopi_status, b.IRSV, b.IRSM, cast(b.IRSM as decimal)+cast(b.IRSV as decimal) SATT
into #temp
from ENR a WITH (NOLOCK) 
left join ADM b on a.pidm_key = b.pidm_key and a.term_code_key = b.term_code_key
where report = '1'
and a.styp_code = 'n'
and (a.term_code_key >= '201381')
and a.term_desc like ('%fall%')
and (a.UOPI_status in ('not UOPI','integrated accelerator') or a.UOPI_Status is null)

update #temp set IRSV = null where IRSM is null
update #temp set IRSM = null where IRSV is null; -- remove the ; to run as is - leave it to get the average numbers


-- selecting the average by discipline
/*
with AVGS AS (
select TERM_CODE_KEY, DISCIPLINE, round(avg(SATT),0) AS SCS
from #temp
GROUP BY TERM_CODE_KEY, DISCIPLINE
)

select TERM_CODE_KEY, DISCIPLINE, cast(SCS AS INT)
from AVGS
WHERE TERM_CODE_KEY = '202X81'
GROUP BY TERM_CODE_KEY, DISCIPLINE, SCS
*/


-- selecting the overall average of the term
/*

with AVGS AS (
select TERM_CODE_KEY, round(avg(SATT),0) AS SCS
from #temp
GROUP BY TERM_CODE_KEY 
)

select TERM_CODE_KEY,cast(SCS AS INT)
from AVGS
WHERE TERM_CODE_KEY = '202X81'
GROUP BY TERM_CODE_KEY, SCS

*/

select *
from #temp

drop table #temp
