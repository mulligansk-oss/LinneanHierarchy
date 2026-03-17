CREATE OR REPLACE PROCEDURE taxon_lineage_auto_dml (pp_output_dir       IN     VARCHAR2
                                                   ,pp_treefile         IN     VARCHAR2
                                                   ,pp_level_multiply   IN     NUMBER := 1 
                                               )
IS
 
    CURSOR c_tree IS
        SELECT l.taxon_level
              ,l.parent
              ,l.precedence
              ,l.name
              ,l.common_name
        FROM   taxon_lineages l
        ORDER BY l.taxon_level,l.parent,l.precedence,l.name;
 
    i                    NUMBER(3);
    v_tree               UTL_FILE.FILE_TYPE; 
    l_maxlen_h           NUMBER(2);
    l_text_expansion     VARCHAR2(50);
    l_alignment_pad      VARCHAR2(50);
    l_corner             VARCHAR2(1) := CHR(3);
    l_line               VARCHAR2(1) := CHR(6);
    l_parent_level       taxon_hierarchy.taxon_level%TYPE;
    l_start_level        taxon_hierarchy.taxon_level%TYPE;
    l_parent_len		 NUMBER(3);
    l_name_len			 NUMBER(3);

BEGIN
 
    v_tree := UTL_FILE.FOPEN (pp_output_dir
                             ,pp_treefile
                             ,'w');

    UTL_FILE.PUT_LINE(v_tree,'TRUNCATE TABLE taxon_lineages;');


	SELECT MAX(LENGTH(untrim(parent,'''',''''''))) INTO l_parent_len FROM taxon_lineages;
	SELECT MAX(LENGTH(untrim(name  ,'''',''''''))) INTO l_name_len   FROM taxon_lineages;

	l_parent_len := l_parent_len + 2;
	l_name_len   := l_name_len   + 2;

    FOR r_tree in c_tree LOOP
 
        l_alignment_pad := '';
        IF LENGTH(r_tree.common_name) >0 THEN
            FOR i IN 1 .. LENGTH(r_tree.common_name) LOOP

                IF SUBSTR(r_tree.common_name,i,1) = ''''
                    THEN l_alignment_pad := l_alignment_pad||'''''';
                    ELSE l_alignment_pad := l_alignment_pad||SUBSTR(r_tree.common_name,i,1);
                END IF;

            END LOOP;
        END IF;
            UTL_FILE.PUT_LINE( v_tree , 'INSERT INTO taxon_lineages VALUES ('||
               LPAD(r_tree.taxon_level,2)                                 || ',''' ||
               RPAD(untrim(r_tree.parent,'''','''''') ||'''',l_parent_len)|| ','   ||
               LPAD(r_tree.precedence,2)                                  || ',''' ||
               RPAD(untrim(r_tree.name  ,'''','''''') ||'''',l_name_len)  || ',''' ||
               untrim(r_tree.common_name,'''','''''') ||''');' );
 
    END LOOP;

 
    UTL_FILE.FFLUSH(v_tree);
    UTL_FILE.FCLOSE(v_tree);



END;
 
/
