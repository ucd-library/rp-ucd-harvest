#!/bin/sh
pw=`cat fin_pass.pw`
/Users/jtyzzer/Oracle/instantclient_19_8/sqlplus -S agexpert_app/$pw@'(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(COMMUNITY=TCP.ucdavis.edu)(PROTOCOL=TCP)(Host=fis-dss.ucdavis.edu)(Port=1521)))(CONNECT_DATA=(SID=dsprod)(GLOBAL_NAME=fis_ds_prod.ucdavis.edu)))' <<EOF
SET MARKUP CSV ON QUOTE ON
SET FEEDBACK OFF
SELECT
     awd.cgprpsl_nbr AS "CG_Prpsl_Nbr"
    , COALESCE(per.PRNCPL_NM, c.PRNCPL_NM) AS "PI_ID"
    , awd.CGAWD_PROJ_TTL AS "Award_Title"
    , awd.CGAWD_TOT_AMT "Grant_Amount"
    , awd.CG_AGENCY_FULL_NM AS "Agency"
    , awd.CG_AGENCY_NBR AS "Agency_Nbr"
    , REGEXP_REPLACE(awd.ROOT_AWARD_NBR, '[ \t\r\n\f]+','-') "Grantor_Award_ID"
    , awd.CGAWD_BEG_DT AS "Start_Date"
    , awd.CGAWD_END_DT AS "End_Date"
    , COALESCE(per.PERSON_NM,c.PRSN_NM) AS "PI_Name"
FROM FINANCE.AWARD awd
JOIN FINANCE.CG_AWD_PRJDR_T pi
    ON pi.CGPRPSL_NBR = awd.CGPRPSL_NBR
LEFT OUTER JOIN FINANCE.RICE_UC_KRIM_PERSON_MV per
    ON per.PRNCPL_ID = pi.PERSON_UNVL_ID
LEFT OUTER JOIN FINANCE.RICE_KRIM_ENTITY_CACHE_T c
    ON c.PRNCPL_ID = pi.PERSON_UNVL_ID
WHERE awd.FISCAL_YEAR = 9999
    AND awd.FISCAL_PERIOD = '--'
    AND pi.CGAWD_PRMPRJDR_IND = 'Y'
    AND pi.ROW_ACTV_IND = 'Y'
    AND COALESCE(per.PRNCPL_NM, c.PRNCPL_NM) IN ('amoghimi', 'benthem', 'bougis', 'chmkim', 'daccache', 'dafrank', 'danhung', 'dcs', 'ergoman', 'fkhorsan', 'fzjenkin', 'gangsun', 'gmb', 'ikisekka', 'irdonisg', 'jcgib', 'jdemoura', 'jdfbayo', 'jkmason', 'jmearles', 'jrmerz', 'jsmullin', 'jsvander', 'jzfan', 'kkorn', 'mahamed', 'mgrismer', 'mleite', 'nnitin', 'npan', 'palarbi', 'pourreza', 'quinn', 'ramram', 'rhcastro', 'rhzhang', 'rkukreja', 'sbsen', 'sjmccorm', 'spgentry', 'sshong', 'tjeoh', 'vensberg', 'ylhsieh', 'ytakamur', 'zlpan')
ORDER BY "PI_ID";

DISCONNECT
QUIT
