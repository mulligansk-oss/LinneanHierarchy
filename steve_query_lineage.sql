set lines 145 pages 500
SELECT l.taxon_level
      ,substr(LPAD (' ', 2 * (LEVEL)) || l.name ,1,80) scientific_name
      ,substr(decode(h.taxon_name,'SPECIES','"'||l.common_name||'"'),1,35) common_name
FROM taxon_lineages l
    ,taxon_hierarchy h
WHERE l.taxon_level = h.taxon_level
START WITH l.parent IS NULL
CONNECT BY PRIOR l.name = l.parent;
