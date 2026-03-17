CREATE OR REPLACE PROCEDURE taxon_lineage_range (pp_output_dir IN     VARCHAR2
                                                ,pp_treefile   IN     VARCHAR2
                                                ,pp_start      IN     VARCHAR2 := 'LIFE' 
                                                ,pp_maxlevel   IN     NUMBER   := 27 
                                                )
IS
 
    CURSOR c_tree IS
        SELECT h.taxon_name
              ,l.taxon_level
              ,l.parent
              ,l.name
              ,substr(LPAD (' ', 2 * (LEVEL)) || l.name ,1,80) scientific_name
              ,substr(decode(h.taxon_name,'SPECIES'    ,'"'||l.common_name||'"'
                                         ,'SUB-SPECIES','  ('||l.common_name||')',l.common_name),1,44) common_name
        FROM   taxon_lineages l
              ,taxon_hierarchy h
        WHERE  l.taxon_level = h.taxon_level
        AND    l.taxon_level <= pp_maxlevel
        START WITH UPPER(l.name) = UPPER(pp_start)
        CONNECT BY PRIOR UPPER(l.name) = UPPER(l.parent)
        ORDER SIBLINGS BY l.precedence,l.name;
 
    CURSOR c_parent_level (cp_parent VARCHAR2) IS
        SELECT pl.taxon_level
        FROM   taxon_lineages  pl
        WHERE  UPPER(pl.name) = UPPER(cp_parent);

    CURSOR c_children (cp_current VARCHAR2) IS
        SELECT count(*) - 1
        FROM   taxon_lineages
        WHERE LEVEL <= 2
        START WITH UPPER(name) = UPPER(cp_current)
        CONNECT BY PRIOR UPPER(name) = UPPER(parent);

    l_found              BOOLEAN := FALSE;
    v_errlist            UTL_FILE.FILE_TYPE;
    v_tree               UTL_FILE.FILE_TYPE; 
    l_maxlen_h           NUMBER(2);
    l_maxlen_l           NUMBER(2);
    l_max_level          NUMBER(2);
    l_space_padding_len  NUMBER(2);
    l_line_padding_len   NUMBER(2);
    l_alignment_pad      NUMBER(3);
    l_corner             VARCHAR2(1) := CHR(3);
    l_line               VARCHAR2(1) := CHR(6);
    l_parent_level       taxon_hierarchy.taxon_level%TYPE;
    l_start_level        taxon_hierarchy.taxon_level%TYPE;

BEGIN
 
    v_tree := UTL_FILE.FOPEN (upper(pp_output_dir)
                             ,pp_treefile
                             ,'w');

    SELECT max(length(taxon_name))
    INTO   l_maxlen_h
    FROM   taxon_hierarchy;

    SELECT max(length(name)),max(taxon_level)
    INTO   l_maxlen_l,l_max_level
    FROM   taxon_lineages;

    UTL_FILE.PUT_LINE(v_tree,'Descent Tree for all '||pp_start);
    UTL_FILE.PUT_LINE(v_tree,' ');

    FOR r_tree in c_tree LOOP
 
       /* find taxon_level of parent to decide position of l_corner and length of l_line */
        OPEN c_parent_level(r_tree.parent);
        FETCH c_parent_level INTO l_parent_level;
        IF c_parent_level%NOTFOUND THEN
            l_parent_level := 0;
        END IF;
        CLOSE c_parent_level;

        IF UPPER(r_tree.name) = UPPER(pp_start) THEN
            l_start_level := r_tree.taxon_level;
        END IF;

        l_space_padding_len := (l_parent_level - l_start_level) * 2;
        l_line_padding_len  := (r_tree.taxon_level - l_parent_level - 1) * 2;
        l_alignment_pad     := l_maxlen_l + ((l_max_level - r_tree.taxon_level) * 2);

        IF UPPER(r_tree.name) = UPPER(pp_start) THEN
            UTL_FILE.PUT_LINE(v_tree,lpad(r_tree.taxon_level,2,' ') ||' - '||
                                     rpad(r_tree.taxon_name,l_maxlen_h+1,' ')||':'||
                                     r_tree.name 
                                     --  ||' '||r_tree.common_name
                              );
        ELSE
            UTL_FILE.PUT_LINE(v_tree,lpad(r_tree.taxon_level,2,' ') ||' - '||
                                     rpad(r_tree.taxon_name,l_maxlen_h+1,' ')||':'||
                                     lpad(' ',l_space_padding_len) ||
                                     l_corner || l_line         ||
                                     lpad(l_line,l_line_padding_len,l_line)||
                                     RPAD(r_tree.name,l_alignment_pad,' ') ||' - '||
                                     r_tree.common_name
                              );
        END IF;
 
    END LOOP;

 
    UTL_FILE.FFLUSH(v_tree);
    UTL_FILE.FCLOSE(v_tree);



END;
 
/
