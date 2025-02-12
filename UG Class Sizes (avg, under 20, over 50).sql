WITH TempCRN AS (
    select distinct CRN_KEY
    from REG WITH (NOLOCK)
    where report = '1'
    and LEVL_CODE in ('ug', 'uu')
    and season = 'fall' and year = '2024'

)
, SectionData AS (
select actual_enrollment, crn_key, SUBJ_CODE, left(CRSE_NUMBER,3) as CRS_NUM, season+' '+year as term, DEPT_CODE, DEPT_DESC, DEPT_DESC_OVERRIDE, COLL_CODE, COLL_CODE_OVERRIDE, DISCIPLINE, CREDIT_HOURS,
       case
           when  actual_enrollment >=2 and actual_enrollment < 10 then '1. 2-9'
            when actual_enrollment >=10 and actual_enrollment < 20 then '2. 10-19'
            when actual_enrollment >=20 and actual_enrollment < 30 then '3. 20-29'
            when actual_enrollment >=30 and actual_enrollment < 40 then '4. 30-39'
            when actual_enrollment >=40 and actual_enrollment < 50 then '5. 40-49'
            when actual_enrollment >=50 and actual_enrollment < 100 then '6. 50-99'
            when actual_enrollment >= 100 then '7. 100' END AS Class_Size,
     case
         when actual_enrollment < 20 then 1 else 0 END as under_20,
     case
         when actual_enrollment > 49 then 1 else 0 END as over_50
from SECT_SUM WITH (NOLOCK)
where actual_enrollment > 1
  and coll_code <> 'lw'
  and (coll_code <> 'dt' or (coll_code = 'dt' and dept_code = 'DHYG'))
  and (coll_code not in ('sp','ph') or (coll_code in ('sp','ph') and dept_code = 'SLPA'))
  and schd_code_meet1 in ('1', '5', '6','7')
  and season = 'fall' and year = '2024'
 and right(term_code_key,2) in ('52','81','84')
 UNION --- add Pharm 101
 select actual_enrollment, crn_key, SUBJ_CODE, left(CRSE_NUMBER,3) as CRS_NUM, season+' '+year as term, DEPT_CODE, DEPT_DESC, DEPT_DESC_OVERRIDE, COLL_CODE, COLL_CODE_OVERRIDE, DISCIPLINE, CREDIT_HOURS,
       case
           when  actual_enrollment >=2 and actual_enrollment < 10 then '1. 2-9'
            when actual_enrollment >=10 and actual_enrollment < 20 then '2. 10-19'
            when actual_enrollment >=20 and actual_enrollment < 30 then '3. 20-29'
            when actual_enrollment >=30 and actual_enrollment < 40 then '4. 30-39'
            when actual_enrollment >=40 and actual_enrollment < 50 then '5. 40-49'
            when actual_enrollment >=50 and actual_enrollment < 100 then '6. 50-99'
            when actual_enrollment >= 100 then '7. 100' END AS Class_Size,
     case
         when actual_enrollment < 20 then 1 else 0 END as under_20,
     case
         when actual_enrollment > 49 then 1 else 0 END as over_50
from SECT_SUM WITH (NOLOCK)
where actual_enrollment > 1
and coll_code in ('sp','ph')
and dept_code <> 'SLPA'
and subj_code = 'PRAC' and crse_number = '101'and title in ('Pharmacy Orientation')
and season = 'Fall' and year = '2024'
    )
, CleanedData AS (
    select actual_enrollment, crn_key, SUBJ_CODE, CRS_NUM, term, DEPT_CODE, DEPT_DESC, DEPT_DESC_OVERRIDE, COLL_CODE, COLL_CODE_OVERRIDE, DISCIPLINE, CREDIT_HOURS,Class_Size, under_20, over_50,
        case
            when CRS_NUM >= '200' and CRN_KEY not in (select CRN_KEY from TempCRN) then 0
            when dept_code in ('copx') and CREDIT_HOURS = 0 then 0 else 1 END AS SECOUT
    from SectionData WITH (NOLOCK)
)

, PERCT AS (SELECT term,
                   round(avg(actual_enrollment), 0) AS TOTAL,
                   sum(under_20)                    AS UND20,
                   sum(over_50)                     AS OV50,
                   count(CRN_KEY)                   AS CLS
            from CleanedData WITH (NOLOCK)
            where SECOUT = 1
            group by term)

SELECT term, cast(TOTAL AS INT) AS AvgEnr, format((cast(UND20 AS decimal)/ NULLIF(cast(CLS as decimal),0)) *100, '0.#') AS perc20,
       format((cast(OV50 AS decimal)/ NULLIF(cast(CLS as decimal),0)) *100, '0.#') AS perc50
    FROM PERCT WITH (NOLOCK)
GROUP BY term, UND20, OV50, CLS, TOTAL;

WITH TempCRN AS (
    select distinct CRN_KEY
    from REG WITH (NOLOCK)
    where report = '1'
    and LEVL_CODE in ('ug', 'uu')
    and season = 'fall' and year = '2024'

)
, SectionData AS (
select actual_enrollment, crn_key, SUBJ_CODE, left(CRSE_NUMBER,3) as CRS_NUM, season+' '+year as term, DEPT_CODE, DEPT_DESC, DEPT_DESC_OVERRIDE, COLL_CODE, COLL_CODE_OVERRIDE, DISCIPLINE, CREDIT_HOURS,
       case
           when  actual_enrollment >=2 and actual_enrollment < 10 then '1. 2-9'
            when actual_enrollment >=10 and actual_enrollment < 20 then '2. 10-19'
            when actual_enrollment >=20 and actual_enrollment < 30 then '3. 20-29'
            when actual_enrollment >=30 and actual_enrollment < 40 then '4. 30-39'
            when actual_enrollment >=40 and actual_enrollment < 50 then '5. 40-49'
            when actual_enrollment >=50 and actual_enrollment < 100 then '6. 50-99'
            when actual_enrollment >= 100 then '7. 100' END AS Class_Size,
     case
         when actual_enrollment < 20 then 1 else 0 END as under_20,
     case
         when actual_enrollment > 49 then 1 else 0 END as over_50
from SECT_SUM WITH (NOLOCK)
where actual_enrollment > 1
  and coll_code <> 'lw'
  and (coll_code <> 'dt' or (coll_code = 'dt' and dept_code = 'DHYG'))
  and (coll_code not in ('sp','ph') or (coll_code in ('sp','ph') and dept_code = 'SLPA'))
  and schd_code_meet1 in ('1', '5', '6','7')
  and season = 'fall' and year = '2024'
 and right(term_code_key,2) in ('52','81','84')
 UNION --- add Pharm 101
 select actual_enrollment, crn_key, SUBJ_CODE, left(CRSE_NUMBER,3) as CRS_NUM, season+' '+year as term, DEPT_CODE, DEPT_DESC, DEPT_DESC_OVERRIDE, COLL_CODE, COLL_CODE_OVERRIDE, DISCIPLINE, CREDIT_HOURS,
       case
           when  actual_enrollment >=2 and actual_enrollment < 10 then '1. 2-9'
            when actual_enrollment >=10 and actual_enrollment < 20 then '2. 10-19'
            when actual_enrollment >=20 and actual_enrollment < 30 then '3. 20-29'
            when actual_enrollment >=30 and actual_enrollment < 40 then '4. 30-39'
            when actual_enrollment >=40 and actual_enrollment < 50 then '5. 40-49'
            when actual_enrollment >=50 and actual_enrollment < 100 then '6. 50-99'
            when actual_enrollment >= 100 then '7. 100' END AS Class_Size,
     case
         when actual_enrollment < 20 then 1 else 0 END as under_20,
     case
         when actual_enrollment > 49 then 1 else 0 END as over_50
from SECT_SUM WITH (NOLOCK)
where actual_enrollment > 1
and coll_code in ('sp','ph')
and dept_code <> 'SLPA'
and subj_code = 'PRAC' and crse_number = '101'and title in ('Pharmacy Orientation')
and season = 'Fall' and year = '2024'
    )
, CleanedData AS (
    select actual_enrollment, crn_key, SUBJ_CODE, CRS_NUM, term, DEPT_CODE, DEPT_DESC, DEPT_DESC_OVERRIDE, COLL_CODE, COLL_CODE_OVERRIDE,
           case
               when DISCIPLINE in ('PACS/Other', 'CORE/Other') then 'CORE/PACS/Other' else DISCIPLINE END AS DISC,
        CREDIT_HOURS,Class_Size, under_20, over_50,
        case
            when CRS_NUM >= '200' and CRN_KEY not in (select CRN_KEY from TempCRN) then 0
            when dept_code in ('copx') and CREDIT_HOURS = 0 then 0 else 1 END AS SECOUT
    from SectionData WITH (NOLOCK)
)

, PERCT AS (SELECT term, DISC,
                   round(avg(actual_enrollment), 0) AS TOTAL,
                   sum(under_20)                    AS UND20,
                   sum(over_50)                     AS OV50,
                   count(CRN_KEY)                   AS CLS
            from CleanedData WITH (NOLOCK)
            where SECOUT = 1
            group by term, DISC)

SELECT term, DISC,cast(TOTAL AS INT) AS AvgEnr, format((cast(UND20 AS decimal)/ NULLIF(cast(CLS as decimal),0)) *100, '0.#') AS perc20,
       format((cast(OV50 AS decimal)/ NULLIF(cast(CLS as decimal),0)) *100, '0.#') AS perc50
    FROM PERCT WITH (NOLOCK)
GROUP BY term, DISC, UND20, OV50, CLS, TOTAL
ORDER BY
case DISC
	when 'COP - Humanities' then 1
	when 'COP - Natural Sciences' then 2
	when 'COP - Social Sciences' then 3
	when 'COP - Exploratory'then 4
	when 'ESB' then 5
	when 'BC' then 6
	when 'SOECS' then 7
	when 'COM'then 8
	when 'SHS' then 9
	when 'SOH' then 10
	when 'SOP'then 11
	when 'DEN' then 12
	when 'LAW'then 13
	when 'UW'then 14
	when 'CORE/PACS/Other' then 15
	when 'UNC' then 16
	END;
