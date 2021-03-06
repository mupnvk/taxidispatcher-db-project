USE [TD5R1]
GO
/****** Object:  StoredProcedure [dbo].[AutoSetFromPretendents]    Script Date: 22.03.2019 2:02:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








ALTER PROCEDURE [dbo].[AutoSetFromPretendents] 
	-- Add the parameters for the stored procedure here
	(@order_id int, @delta_time_param int, @count int OUT,
		@sort_with_accept int, @manual_before int)
AS
BEGIN 
	DECLARE @order_dr_num int, 
	@last_status_time datetime, 
	@driver_id int, @accept_count int,
	@dr_count int, @rating_pretendent_sorting smallint,
	@use_rating_levels smallint;

	SELECT TOP 1 
	@rating_pretendent_sorting = rating_pretendent_sorting,
	@use_rating_levels = use_rating_levels 
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';
	
	SET @count = 0;
	SET @last_status_time = NULL;
	SET @order_dr_num = 0;
	SET @dr_count = 0;

	SELECT @order_dr_num=REMOTE_DRNUM,
	@last_status_time=LAST_STATUS_TIME
	FROM Zakaz
	WHERE (Zakaz.BOLD_ID=@order_id);
	
	IF ((DATEDIFF(SECOND, @last_status_time, 
		CURRENT_TIMESTAMP)>=@delta_time_param)
		AND (@last_status_time IS NOT NULL) 
		AND (@order_dr_num>0) 
		AND (@last_status_time<CURRENT_TIMESTAMP))
	BEGIN
	
	--PRINT '111';
	SET @accept_count = 0;

	IF @rating_pretendent_sorting = 1 BEGIN

		IF @use_rating_levels = 1 BEGIN
			SELECT TOP 1 @driver_id=oa.DRIVER_ID 
			FROM ORDER_ACCEPTING oa INNER JOIN Voditelj dr ON oa.DRIVER_ID = dr.BOLD_ID
			WHERE oa.ORDER_ID=@order_id
			ORDER BY dbo.GetDriverRatingLevel(oa.DRIVER_ID) DESC, 
			dr.Vremya_poslednei_zayavki ASC;

			SET @accept_count = @@ROWCOUNT;
		END
		ELSE BEGIN
			SELECT TOP 1 @driver_id=oa.DRIVER_ID 
			FROM ORDER_ACCEPTING oa 
			WHERE oa.ORDER_ID=@order_id
			ORDER BY dbo.GetDriverRating(oa.DRIVER_ID) DESC, oa.ACCEPT_DATE ASC;

			SET @accept_count = @@ROWCOUNT;
		END;
	END
	ELSE BEGIN
		if (@sort_with_accept>0) BEGIN
			SELECT @accept_count=COUNT(*) FROM
			ORDER_ACCEPTING WHERE ORDER_ID=@order_id
			AND DRIVER_NUM=@order_dr_num;
	
			SELECT TOP 1 @driver_id=oa.DRIVER_ID 
			FROM ORDER_ACCEPTING oa 
			WHERE oa.ORDER_ID=@order_id AND 
			oa.DRIVER_NUM=@order_dr_num
			ORDER BY oa.ACCEPT_DATE DESC;
		END;
	END;
	
	--SELECT TOP 1 @driver_id=dr.BOLD_ID 
	--FROM Voditelj dr 
	--WHERE dr.Pozyvnoi=@order_dr_num;
	
	SET @dr_count = @accept_count;
	
	if (@accept_count=0)
	BEGIN
		SELECT @accept_count=COUNT(*) 
		FROM ORDER_ACCEPTING
		WHERE ORDER_ID=@order_id;
		
		if (@accept_count>0)
		BEGIN
		  if (@sort_with_accept>0)
		  begin
			
			if(@manual_before=0)
			BEGIN
			
			SELECT TOP 1 @driver_id=oa.DRIVER_ID
			FROM ORDER_ACCEPTING oa JOIN Voditelj dr
			ON oa.DRIVER_ID=dr.BOLD_ID
			WHERE oa.ORDER_ID=@order_id
			AND oa.IS_MANUAL=0
			ORDER BY dr.Vremya_poslednei_zayavki ASC;
			
			SET @dr_count=@@ROWCOUNT;
			
			if (@dr_count=0)
			BEGIN
			
			SELECT TOP 1 @driver_id=oa.DRIVER_ID
			FROM ORDER_ACCEPTING oa 
			WHERE oa.ORDER_ID=@order_id 
			AND oa.IS_MANUAL>0
			ORDER BY oa.ACCEPT_DATE ASC;
			
			SET @dr_count=@@ROWCOUNT;
			
			END;
			
			END
			else
			BEGIN
			
			SELECT TOP 1 @driver_id=oa.DRIVER_ID 
			FROM ORDER_ACCEPTING oa 
			WHERE oa.ORDER_ID=@order_id 
			AND oa.IS_MANUAL>0
			ORDER BY oa.ACCEPT_DATE ASC;
			
			SET @dr_count=@@ROWCOUNT;
			
			if (@dr_count=0)
			BEGIN
			SELECT TOP 1 @driver_id=oa.DRIVER_ID
			FROM ORDER_ACCEPTING oa JOIN Voditelj dr
			ON oa.DRIVER_ID=dr.BOLD_ID
			WHERE oa.ORDER_ID=@order_id
			AND oa.IS_MANUAL=0
			ORDER BY dr.Vremya_poslednei_zayavki ASC;
			
			SET @dr_count=@@ROWCOUNT;
			
			END;
			
			END;
		  end
		  else
			begin
			
			SELECT TOP 1 @driver_id=oa.DRIVER_ID 
			FROM ORDER_ACCEPTING oa JOIN Voditelj dr
			ON oa.DRIVER_ID=dr.BOLD_ID
			WHERE oa.ORDER_ID=@order_id
			ORDER BY dr.Vremya_poslednei_zayavki ASC;

			SET @dr_count=@@ROWCOUNT;
			
			end;
		END;
		
	END;
	
	if ((@accept_count>0) AND (@driver_id>0) 
		AND (@dr_count>0))
	BEGIN
		EXEC SetDriverFromPretendents @order_id, 
		@driver_id, @count = @count OUTPUT;
	END
	ELSE
	BEGIN
		EXEC ClearOrderAcceptByDrId @order_id,
		@driver_id, @accept_count;
	END;
	
	
	END;
END












