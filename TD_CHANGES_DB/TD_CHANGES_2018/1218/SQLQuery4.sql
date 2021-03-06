USE [TD5R1]
GO
/****** Object:  UserDefinedFunction [dbo].[GetJSONDriverOrdersBCasts]    Script Date: 04.12.2018 3:09:33 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER FUNCTION [dbo].[GetJSONDriverOrdersBCasts] (@driver_id int)
RETURNS varchar(max)
AS
BEGIN
	declare @res varchar(max);
	DECLARE @CURSOR cursor;
	DECLARE @order_id int, @order_adres varchar(255), @end_sect int,
		@counter int, @prev_price decimal(28,10), @cargo_desc varchar(5000), 
		@end_adres varchar(1000), @client_name varchar(500), 
		@prev_distance decimal(28,10), @prev_date datetime, 
		@rating_bonus decimal(18, 5), @for_all_sectors smallint,
		@company_id int, @show_region_in_addr smallint;

	SET @show_region_in_addr = 0;

	SELECT TOP 1 @show_region_in_addr = show_region_in_addr
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';
   
	SET @res='{"command":"ford"';
	SET @counter = 0;
	
	SET @CURSOR  = CURSOR SCROLL
	FOR
	SELECT ord.BOLD_ID, ((CASE WHEN (@show_region_in_addr = 1 AND ISNULL(ds.name, '') <> '') THEN ('(' + ds.name + ') ') ELSE '' END) + 
	ord.Adres_vyzova_vvodim + (CASE WHEN (ord.is_early = 1) THEN (' (' + CAST(ord.early_date as varchar(50)) + ') ') ELSE '' END)) as Adres_vyzova_vvodim, ord.SECTOR_ID,
	ord.prev_price, ord.cargo_desc, ord.end_adres, ord.client_name, 
	ord.prev_distance, ord.Data_predvariteljnaya, ord.driver_rating_diff,
	ord.for_all_sectors, ISNULL(ds.company_id, 0) as company_id FROM Zakaz ord
	INNER JOIN DR_ORD_PRIORITY dop ON ord.BOLD_ID=dop.order_id 
	LEFT JOIN DISTRICTS ds ON ord.district_id = ds.id
	WHERE ord.Zavershyon=0 AND ord.REMOTE_SET>0 AND ord.REMOTE_SET<8 
	AND dop.priority<=0 AND dop.driver_id=@driver_id;
	--AND dop.priority>=-1
	/*Открываем курсор*/
	OPEN @CURSOR
	/*Выбираем первую строку*/
	FETCH NEXT FROM @CURSOR INTO @order_id, @order_adres, @end_sect, @prev_price, @cargo_desc, @end_adres, @client_name, @prev_distance, @prev_date, @rating_bonus, @for_all_sectors, @company_id
	/*Выполняем в цикле перебор строк*/
	WHILE @@FETCH_STATUS = 0
	BEGIN
        SET @res=@res+',"id'+
			CAST(@counter as varchar(20))+'":"'+
			CAST(@order_id as varchar(20))+'","oad'+
			CAST(@counter as varchar(20))+'":"'+
			REPLACE(REPLACE(@order_adres,'"',' '),'''',' ')+'","oes'+
			CAST(@counter as varchar(20))+'":"'+CAST(@end_sect as varchar(20))+'"';

		IF (@rating_bonus>0)
			BEGIN
			SET @res=@res+',"orb'+
			CAST(@counter as varchar(20))+'":"'+
			convert(varchar,convert(decimal(8,2),@rating_bonus))+'"';
			END;

		IF (@for_all_sectors>0)
			BEGIN
			SET @res=@res+',"fas'+
			CAST(@counter as varchar(20))+'":"1"';
			END;

		IF (@company_id>0)
			BEGIN
			SET @res=@res+',"cmp'+
			CAST(@counter as varchar(20))+'":"' + 
			CAST(@company_id as varchar(20)) + '"';
			END;
        
		IF (@prev_price>0)
			BEGIN
			SET @res=@res+',"oppr'+
			CAST(@counter as varchar(20))+'":"'+
			convert(varchar,convert(decimal(8,2),@prev_price))+'"';
			END;

			IF (@prev_distance>0)
			BEGIN
			SET @res=@res+',"opdn'+
			CAST(@counter as varchar(20))+'":"'+
			convert(varchar,convert(decimal(8,2),@prev_distance))+'"';
			END;

			IF (@cargo_desc<>'')
			BEGIN
			SET @res=@res+',"ocrd'+
			CAST(@counter as varchar(20))+'":"'+
			@cargo_desc+'"';
			END;

			IF (ISNULL(@end_adres,'')<>'')
			BEGIN
			SET @res=@res+',"oena'+
			CAST(@counter as varchar(20))+'":"'+
			REPLACE(REPLACE(ISNULL(@end_adres,''),'"',' '),'''',' ')+'"';
			END;

			IF (ISNULL(@client_name,'')<>'')
			BEGIN
			SET @res=@res+',"ocln'+
			CAST(@counter as varchar(20))+'":"'+
			REPLACE(REPLACE(ISNULL(@client_name,''),'"',' '),'''',' ')+'"';
			END;

			SET @res=@res+',"oprd'+
			CAST(@counter as varchar(20))+'":"'+
			CAST(DATEDIFF(second,{d '1970-01-01'},@prev_date) AS varchar(100))+'"';
		
		SET @counter=@counter+1;
		/*Выбираем следующую строку*/
		FETCH NEXT FROM @CURSOR INTO @order_id, @order_adres, @end_sect, @prev_price, @cargo_desc, @end_adres, @client_name, @prev_distance, @prev_date, @rating_bonus, @for_all_sectors, @company_id
	END
	CLOSE @CURSOR
	
	SET @res=@res+',"ocnt":"'+
		CAST(@counter as varchar(20))+'","msg_end":"ok"}';

	IF @counter = 0 
	BEGIN
		SET @res = '';
	END

	RETURN(@res)
END

