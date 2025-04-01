declare
begin
    for x in 1..10000 loop
        INSERT INTO bg_image_ref (
            doc_id,
            doc_refnum,
            bi_reference,
            bi_reference_type
        ) VALUES (
            1,
            dbms_random.string('A', 20),
            dbms_random.string('L', 200),
            round(dbms_random.VALUE (1, 2))
        );
        --
        if (mod(x, 2000) = 0) then
            commit;
        end if;
        --
    end loop;
end;
/
