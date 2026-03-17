DROP TABLE taxon_lineages
;
CREATE TABLE taxon_lineages
	(taxon_level	NUMBER(2)	NOT NULL
	,parent		VARCHAR2(40)		
	,precedence	NUMBER(2)
	,name		VARCHAR2(40)	NOT NULL
	,common_name	VARCHAR2(40)
)
 STORAGE (INITIAL 16M NEXT 1M PCTINCREASE 0) PCTFREE 5
 TABLESPACE DATA_LARGE
 NOLOGGING
;
