set serverout on size 1000000

Create Or Replace
Procedure Transpose (
          Myowner       In Varchar2,
          Oldtable      In Varchar2,
          Newtable      In Varchar2,
          Clausula      In Varchar2, 
          Xcol_Dim      In Varchar2,
          Ycol_Dim      In Varchar2,
          Cell_Value    In Varchar2      )  Is
          --
          Cur           Integer        := Dbms_Sql.Open_Cursor;
          Load_Cur      Integer        := Dbms_Sql.Open_Cursor;
          V_Rc          Integer;
          V_Retval      Varchar2(44);
          V_Sql         Varchar2(1000) := '';
          Ycol_Title    Varchar2(33);
          Ycol_Val      Varchar2(22);
          V_Cell_Attr   Varchar2(22)   := 'Number(12,2) ';
/*******************************************************************/
        /* Parse_Stmt: Parses The Passed Sql Statement, Checks For Errors  */
/*******************************************************************/
        Function Parse_Stmt( Cur In Number, V_Sql In Varchar2 ) Return Integer Is
        Begin
          Dbms_Sql.Parse( Cur, V_Sql, Dbms_Sql.V7);
          Return Sqlcode;
        Exception
          When Others Then
           Raise;
          Return Sqlcode ;
        End Parse_Stmt;
/*******************************************************************/
        /* Quotes:  Place Quotes Around A Specific Character Value */
/*******************************************************************/
        Function Quotes(V_Value In Varchar2) Return Varchar2 Is
        Begin
          Return '''' || Upper(V_Value) || '''';
        End Quotes;
/*******************************************************************/
        /* Column_Format: Put All Attributes Of A Column Into A Format */
        /*  Result := Column_Format('Char',3,3,0) */
        /*  Result Returns: Char(3) */
        /*  Result := Column_Format('Number',22,11,2) */
        /*  Result Returns: Number(11,2) */
/*******************************************************************/
        Function Column_Format( Col_Type  In Char,
                                Precision In Char,
                                Maxs      In Char,
                                Scale     In Char)  Return Varchar2 Is
        Begin
          V_Retval  := Upper( Col_Type );       /* Default Is Return As Is */
          If V_Retval In ( 'VARCHAR2', 'CHAR' ) Then
             V_Retval := Col_Type || '(' || Maxs || ')';
          End If;
          If V_Retval In ( 'NUMBER', 'LONG' ) Then
             V_Retval := Col_Type || '(' || Precision || ',' || Scale ||')';
          End If;
          If V_Retval In ( 'DATE' ) Then
             V_Retval := Col_Type ;
          End If;
          Return V_Retval;
        End Column_Format;
/*******************************************************************/
        /* Get_Attr: Obtain Column Attributes To Create Table Columns, Etc.*/
/*******************************************************************/
        Function Get_Attr( Col_Name In Varchar2 ) Return Varchar2 Is
          V_Type      Varchar2(33);
          V_Max       Varchar2(03);
          V_Precision Varchar2(03);
          V_Scale     Varchar2(03);
        Begin
          V_Sql  := 'Select Data_Type, Data_Precision,Char_Col_Decl_Length, Data_Scale ';
          V_Sql  := V_Sql || ' From User_Tab_Columns ';
          V_Sql  := V_Sql || ' Where Table_Name  = ' ||Quotes(Trim(Upper(Oldtable)));
          V_Sql  := V_Sql || '  And  Column_Name = ' ||Quotes(Trim(Upper(Col_Name  )));
          V_Rc   := Parse_Stmt( Cur, V_Sql );
          Dbms_Sql.Define_Column( Cur, 1, V_Type     ,22);
          Dbms_Sql.Define_Column( Cur, 2, V_Precision, 3);
          Dbms_Sql.Define_Column( Cur, 3, V_Max      , 3);
          Dbms_Sql.Define_Column( Cur, 4, V_Scale    , 3);
          V_Rc  := Dbms_Sql.Execute( Cur );
        Loop
          If Dbms_Sql.Fetch_Rows( Cur ) = 0 Then
             Exit;
          End If;
          Dbms_Sql.Column_Value( Cur, 1, V_Type      );
          Dbms_Sql.Column_Value( Cur, 2, V_Precision );
          Dbms_Sql.Column_Value( Cur, 3, V_Max       );
          Dbms_Sql.Column_Value( Cur, 4, V_Scale     );
          V_Retval := Column_Format( V_Type, V_Precision, V_Max,V_Scale);
        End Loop;
          Return V_Retval;
        Exception
          When Others Then
               Raise;
          Return ' ';
        End Get_Attr;
/*******************************************************************/
        /* Drop_Table:  Remove Newtable, If It Exists */
/*******************************************************************/
        Function Drop_Table Return Number Is
        Begin
          Dbms_Sql.Parse( Cur, 'Drop Table ' || Newtable, Dbms_Sql.V7);
          Return Sqlcode;
        Exception
          When Others Then
             If Sqlcode != -942 Then
                Raise;
             End If;
          Return Sqlcode ;
        End Drop_Table;
/*******************************************************************/
        /* Create_Table:  Create Newtable, With List Of X-Column Values */
/*******************************************************************/
        Function Create_Table(Clausula In Varchar2) Return Number Is
        Begin
          V_Sql  := 'Create Table ' || Newtable ;
          V_Sql  := V_Sql ||' As Select Distinct '|| Xcol_Dim ;
          V_Sql  := V_Sql ||' From ' ||  Oldtable ;
          V_Sql  := V_Sql ||Clausula;
          Dbms_Output.Put_Line (V_sql);
          Return Parse_Stmt( Cur, V_Sql );
        End Create_Table;
/*******************************************************************/
        /* Alter_Table:  Append All Distinct Ycol_Dim Values Into Columns*/
/*******************************************************************/
        Function Alter_Table(Clausula In Varchar2)  Return Number Is
        Begin
          V_Cell_Attr := Get_Attr( Cell_Value ); /* Get Cell Column Value Attribute */
          V_Sql := 'Select Distinct '|| Ycol_Dim ||' From ';
          V_Sql :=  V_Sql ||  Oldtable ;
          V_Sql :=  V_Sql ||Clausula;
          V_Rc  := Parse_Stmt( Cur, V_Sql );
          Dbms_Sql.Define_Column( Cur, 1, Ycol_Val, 22);
          V_Rc  := Dbms_Sql.Execute( Cur );
        Loop
          If Dbms_Sql.Fetch_Rows( Cur ) = 0 Then
             Exit;
          End If;
          Dbms_Sql.Column_Value( Cur, 1, Ycol_Val);
          Ycol_Title := Ycol_Dim || '_' || Trim(Ycol_Val);
          V_Sql      := 'Alter Table ' || Newtable || ' Add ';
          V_Sql      := V_Sql || '( '  || Ycol_Title || ' ' ||V_Cell_Attr || ' ) ';
          V_Rc       := Parse_Stmt( Load_Cur, V_Sql );
        End Loop;
          Return 0;
        End Alter_Table;
/*******************************************************************/
        /* Update_Table: Populate Each Intersection, With Cell Columns */
/*******************************************************************/
        Function Update_Table(Clausula In Varchar2) Return Number  Is
        Begin
          V_Sql := 'Select Distinct '|| Ycol_Dim ||' From ' || Oldtable ;
          V_Sql :=  V_Sql ||Clausula;
          V_Rc  := Parse_Stmt( Cur, V_Sql );
          Dbms_Sql.Define_Column( Cur, 1, Ycol_Val, 22);
          V_Rc  := Dbms_Sql.Execute( Cur );
        Loop
          If Dbms_Sql.Fetch_Rows( Cur ) = 0 Then
             Exit;
          End If;
          Dbms_Sql.Column_Value( Cur, 1, Ycol_Val);
          Ycol_Title := Ycol_Dim || '_' || Trim(Ycol_Val);
          V_Sql      := 'Update '  || Newtable   || ' T1 Set ' ||Ycol_Title || ' = ';
          V_Sql      := V_Sql || ' (Select Sum(' || Cell_Value || ')From '  || Oldtable || ' T2';
          V_Sql      := V_Sql || '   Where T1.'  || Xcol_Dim   || '=T2.'    || Xcol_Dim ;
          V_Sql      := V_Sql || '      And    ' || Ycol_Dim   || '= '|| Quotes(Ycol_Val) || ')';
          V_Rc       := Parse_Stmt( Load_Cur, V_Sql );
          V_Rc       := Dbms_Sql.Execute( Load_Cur );
        End Loop;
          Return 0;
        Exception
          When Others Then
            Raise;
            Return 32;
        End Update_Table;
  Begin
    Begin
      V_Rc  := Drop_Table ;                  /* Drop Out Table, If Exists       */
      V_Rc  := Create_Table(Clausula);                 /* Load Distinct X Rows Now*/
      V_Rc  := Alter_Table(Clausula);                  /* Add Y Dimension Columns*/
      V_Rc  := Update_Table(Clausula);       /* Populate Y Columns From Source  */
      Dbms_Sql.Close_Cursor( Cur );
      Dbms_Sql.Close_Cursor( Load_Cur );
    End;
  End Transpose;
/

/*


Exec Transpose ('USUARIO', 'FICHA_COMPENSACAO', 'testenr', ' Where  Dt_Vcto between '||''''||'01-mar-12'||''''||' and '||''''||'20-mar-12'||'''', 'DT_EMIS','DT_VCTO','VL_DOCU');


*/
