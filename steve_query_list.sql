@d:\mysql\plsql\steve_taxon_lineage_file_proc

@d:\mysql\dml_data\steve_taxon_lineage_dml

select l.taxon_level,h.taxon_name,count(*)
from   taxon_hierarchy h,taxon_lineages l
where  l.taxon_level = h.taxon_level
group by l.taxon_level,h.taxon_name
order by l.taxon_level;

select min(taxon_level),max(taxon_level),UPPER(name),count(*)
from taxon_lineages where taxon_level <> 27 group by UPPER(name) having count(*) > 1;

exec taxon_lineage_file('dir_mysql','lineages.txt')

@d:\mysql\table_ddls\steve_taxonomy_hierarchy_ddl
@d:\mysql\table_ddls\steve_taxonomy_lineages_ddl
@d:\mysql\plsql\steve_taxon_lineage_file_proc
@d:\mysql\plsql\steve_taxon_lineage_range_proc
@d:\mysql\plsql\steve_taxon_gen_lineage_dml_proc
@d:\mysql\dml_data\steve_taxon_hierarchy_dml
exec taxon_lineage_dml('d:\mysql','lineage_dml.txt',1)

exec taxon_lineage_auto_dml('d:\mysql','lineage_auto_dml.sql')

exec taxon_lineage_range ('d:\mysql','lineage_chordates.TXT','CHORDATA',16)


=IF(D1="",CONCATENATE("INSERT INTO taxon_lineages VALUES (26,'",B1,"'           , 0,'",B1," ",C1,"'          ,'",A1,"');"),CONCATENATE("INSERT INTO taxon_lineages VALUES (27,'",B1," ",C1,"'     , 0,'",D1,"'               ,'",A1,"');"))

=IF(D1="",CONCATENATE("INSERT INTO taxon_lineages VALUES (26,'",TRIM(B1),"'",REPT(" ",32-LEN(TRIM(B1)))," , 0,'",TRIM(B1)," ",C1,"'",REPT(" ",38-(LEN(TRIM(B1))+LEN(C1)+1)),",'",TRIM(A1),"');"),CONCATENATE("INSERT INTO taxon_lineages VALUES (27,'",TRIM(B1)," ",C1,"'",REPT(" ",33-(LEN(TRIM(B1))+LEN(C1)+1)),", 0,'(",D1,")'",REPT(" ",36-LEN(D1)),",'",TRIM(A1),"');"))

UPDATE taxon_lineages
SET    name = 'Charadriiformes'
WHERE  name = 'CHARADRIIFORMES';

UPDATE taxon_lineages
SET    parent = 'Charadriiformes'
WHERE  parent = 'CHARADRIIFORMES';

UPDATE taxon_lineages
SET    parent = 'ACCIPITRIFORMES'
WHERE  parent IN ('FALCONIFORMES','CATHARTIFORMES');

DELETE FROM taxon_lineages WHERE name = 'CATHARTIFORMES';

INSERT INTO taxon_lineages VALUES (21,'CRYPTODIRA'                  , 0,'Trionychoidea'                    ,'');
UPDATE taxon_lineages
SET    parent = 'Trionychoidea'
WHERE  name IN ('Carettochelyidae','Dermatemydidae','Kinosternidae','Trionychidae)
 




