USE [TD5R1]
GO
/****** Object:  UserDefinedFunction [dbo].[GetJSONSectorList]    Script Date: 08.09.2018 14:51:17 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER FUNCTION [dbo].[GetJSONSectorList] ()
RETURNS varchar(max)
AS
BEGIN
	declare @res varchar(max);
	DECLARE @CURSOR cursor;
	DECLARE @sector_id int, @sector_count int,
		@sector_name varchar(255), @counter int;
   
	SET @res='{"command":"s_lst","s_cnt":"';
	SET @counter = 0;
	
	SELECT @sector_count=COUNT(*)  
	FROM Sektor_raboty ws JOIN Spravochnik dict 
	ON ws.BOLD_ID=dict.BOLD_ID;
	
	IF (@sector_count>0)
	BEGIN
	
	SET @res=@res+CAST(@sector_count as varchar(20))+'"';
	
	SET @CURSOR  = CURSOR SCROLL
	FOR
	SELECT ws.BOLD_ID, dict.Naimenovanie  
	FROM Sektor_raboty ws JOIN Spravochnik dict 
	ON ws.BOLD_ID=dict.BOLD_ID;
	/*Открываем курсор*/
	OPEN @CURSOR
	/*Выбираем первую строку*/
	FETCH NEXT FROM @CURSOR INTO @sector_id, @sector_name
	/*Выполняем в цикле перебор строк*/
	WHILE @@FETCH_STATUS = 0
	BEGIN

        SET @res=@res+',"id'+
			CAST(@counter as varchar(20))+'":"'+
			CAST(@sector_id as varchar(20))+'","nm'+
			CAST(@counter as varchar(20))+'":"'+
			REPLACE(REPLACE(@sector_name,'"',' '),'''',' ')+'"'+
			dbo.GetSectorAreaCoords(@sector_id, @counter);
        SET @counter=@counter+1;
		/*Выбираем следующую строку*/
		FETCH NEXT FROM @CURSOR INTO @sector_id, @sector_name
	END
	CLOSE @CURSOR
	
	SET @res=@res+',"msg_end":"ok"}';
	
	END
	ELSE
	BEGIN
		SET @res=@res+'0","msg_end":"ok"}';	
	END;

	RETURN(@res)
END
