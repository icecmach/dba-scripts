insert into bg_image_ref
 (doc_id, doc_refnum, bi_reference, bi_reference_type)
values (1, '1GSXhzdr94t', 'test', 1);

declare
  lnDocId     bg_image_ref.doc_id%TYPE;
  lsDocRefNum bg_image_ref.doc_refnum%TYPE;
  lsBiRef     bg_image_ref.bi_reference%TYPE;
  lnBiRefType bg_image_ref.bi_reference_type%TYPE;

  TYPE recBgImageRef is record (doc_id            bg_image_ref.doc_id%TYPE,
                                doc_refnum        bg_image_ref.doc_refnum%TYPE,
                                bi_reference      bg_image_ref.bi_reference%TYPE,
                                bi_reference_type bg_image_ref.bi_reference_type%TYPE);

  TYPE tblBgImageRef is table of recBgImageRef INDEX BY BINARY_INTEGER;
  rBghBillImageRef recBgImageRef;
  tBghBillImageRef tblBgImageRef;
begin
    --
    lnDocId     := 1;
    --
    for x in 1..100000 loop
        --
        for y in 1..10000 loop
            --
            lsDocRefNum := dbms_random.string('A', 20);
            lsBiRef     := dbms_random.string('L', 200);
            lnBiRefType := round(dbms_random.VALUE (1, 2));
            --
            rBghBillImageRef.doc_id            := lnDocId;
            rBghBillImageRef.doc_refnum        := lsDocRefNum;
            rBghBillImageRef.bi_reference      := lsBiRef;
            rBghBillImageRef.bi_reference_type := lnBiRefType;
            --
            tBghBillImageRef(y) := rBghBillImageRef;
            --
        end loop;
        --
    end loop;
    --
end;
/

select round(DBMS_RANDOM.VALUE (1, 2)) from dual;


select mod (2001, 1000) from dual;
