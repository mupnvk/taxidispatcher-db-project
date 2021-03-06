USE [TD5R1]
GO
/****** Object:  UserDefinedFunction [dbo].[GetJSONWaitTimesList]    Script Date: 31.03.2019 1:48:31 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[GetJSONWaitTimesList] ()
RETURNS varchar(max)
AS
BEGIN
	declare @res varchar(max);
	DECLARE @CURSOR cursor;
	DECLARE @wid int, @tval smallint, @wcount int,
		@sector_name varchar(255), @counter int, @for_all smallint, 
		@scompany_id int;
   
	SET @res='"wc":"';
	SET @counter = 0;
	
	SELECT @wcount=COUNT(*)  
	FROM WAIT_TIMES;

	IF (@wcount>0)
	BEGIN
	
	SET @res=@res+CAST(@wcount as varchar(20))+'",';
	
	SET @CURSOR  = CURSOR SCROLL
	FOR
	SELECT wt.id, wt.tval  
	FROM WAIT_TIMES wt;
	/*Открываем курсор*/
	OPEN @CURSOR
	/*Выбираем первую строку*/
	FETCH NEXT FROM @CURSOR INTO @wid, @tval
	/*Выполняем в цикле перебор строк*/
	WHILE @@FETCH_STATUS = 0
	BEGIN

        SET @res=@res+'"id'+
			CAST(@counter as varchar(20))+'":"'+
			CAST(@wid as varchar(20));

		SET @res=@res + '","tv'+
			CAST(@counter as varchar(20))+'":"'+
			CAST(@tval as varchar(20)) + '",';

        SET @counter=@counter+1;
		/*Выбираем следующую строку*/
		FETCH NEXT FROM @CURSOR INTO @wid, @tval
	END
	CLOSE @CURSOR
	
	END
	ELSE
	BEGIN
		SET @res=@res+'0",';	
	END;

	RETURN(@res)
END

