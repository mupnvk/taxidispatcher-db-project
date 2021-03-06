USE [TD5R1]
GO
/****** Object:  UserDefinedFunction [dbo].[GetJSONSectorList]    Script Date: 09/12/2014 17:23:44 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER FUNCTION [dbo].[GetJSONTarifAndOptionsList] ()
RETURNS varchar(1000)
AS
BEGIN
	declare @res varchar(1000);
	DECLARE @CURSOR cursor;
	DECLARE @sid int, @scount int,
		@sname varchar(255), @counter int,
		@timetr decimal(28,10), @tmetrtr decimal(28,10),
		@os_coeff decimal(28,10), @os_comp decimal(28,10);
   
	SET @res='{"command":"to_lst","t_cnt":"';
	SET @counter = 0;
	
	SELECT @scount=COUNT(*)  
	FROM ORDER_TARIF;
	
	IF (@scount>0)
	BEGIN
	
	SET @res=@res+CAST(@scount as varchar(20))+'"';
	
	SET @CURSOR  = CURSOR SCROLL
	FOR
	SELECT ID, TARIF_NAME, TIME_TARIF, TMETER_TARIF  
	FROM ORDER_TARIF;
	/*Открываем курсор*/
	OPEN @CURSOR
	/*Выбираем первую строку*/
	FETCH NEXT FROM @CURSOR INTO @sid, @sname, @timetr, @tmetrtr
	/*Выполняем в цикле перебор строк*/
	WHILE @@FETCH_STATUS = 0
	BEGIN

        SET @res=@res+',"tid'+
			CAST(@counter as varchar(20))+'":"'+
			CAST(@sid as varchar(20))+'","tn'+
			CAST(@counter as varchar(20))+'":"'+
			REPLACE(REPLACE(@sname,'"',' '),'''',' ')+'","tmt'+
			CAST(@counter as varchar(20))+'":"'+
			CAST(@timetr as varchar(20))+'","txt'+
			CAST(@counter as varchar(20))+'":"'+
			CAST(@tmetrtr as varchar(20))+'"';
        SET @counter=@counter+1;
		/*Выбираем следующую строку*/
		FETCH NEXT FROM @CURSOR INTO @sid, @sname, @timetr, @tmetrtr
	END
	CLOSE @CURSOR
	
	END
	ELSE
	BEGIN
		SET @res=@res+'0"';	
	END;
	
	SELECT @scount=COUNT(*)  
	FROM ORDER_OPTION;
	
	SET @res=@res+',"op_cnt":"';
	SET @counter = 0;
	
	IF (@scount>0)
	BEGIN
	
	SET @res=@res+CAST(@scount as varchar(20))+'"';
	
	SET @CURSOR  = CURSOR SCROLL
	FOR
	SELECT ID, OPTION_NAME, OSUMM_COEFF, OS_COMPOSED  
	FROM ORDER_OPTION;
	/*Открываем курсор*/
	OPEN @CURSOR
	/*Выбираем первую строку*/
	FETCH NEXT FROM @CURSOR INTO @sid, @sname, @os_coeff, @os_comp
	/*Выполняем в цикле перебор строк*/
	WHILE @@FETCH_STATUS = 0
	BEGIN

        SET @res=@res+',"oid'+
			CAST(@counter as varchar(20))+'":"'+
			CAST(@sid as varchar(20))+'","on'+
			CAST(@counter as varchar(20))+'":"'+
			REPLACE(REPLACE(@sname,'"',' '),'''',' ')+'","oscf'+
			CAST(@counter as varchar(20))+'":"'+
			CAST(@os_coeff as varchar(20))+'","oscm'+
			CAST(@counter as varchar(20))+'":"'+
			CAST(@os_comp as varchar(20))+'"';
        SET @counter=@counter+1;
		/*Выбираем следующую строку*/
		FETCH NEXT FROM @CURSOR INTO @sid, @sname, @os_coeff, @os_comp
	END
	CLOSE @CURSOR
	
	END
	ELSE
	BEGIN
		SET @res=@res+'0"';	
	END;
	
	SET @res=@res+',"msg_end":"ok"}';

	RETURN(@res)
END
