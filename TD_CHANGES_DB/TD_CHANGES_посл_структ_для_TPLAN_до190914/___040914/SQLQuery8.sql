USE [TD5R1]
GO
/****** Object:  Trigger [dbo].[AFTER_ORDER_FIXTIMESET]    Script Date: 09/04/2014 18:38:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER TRIGGER [dbo].[AFTER_ORDER_FIXTIMESET] 
   ON  [dbo].[Zakaz] 
   AFTER UPDATE
AS 
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @db_version INT, 
	@recalc_on_timeset smallint,
	@ftime_tariff decimal(28,10),
	@tax_tariff decimal(28,10);
	
	SET @recalc_on_timeset=0;
	
	SELECT TOP 1 @db_version=ISNULL(db_version,3),
	@recalc_on_timeset=ISNULL(recalc_on_timeset,0) 
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';
	
	IF((@db_version>=5) AND (@recalc_on_timeset=1))
	BEGIN
	
		DECLARE @oldfixed_time int, @newfixed_time int,
			@oldtm_distance int, @newtm_distance int, 
			@newOrderId INT, @dr_id int;
			
		SELECT @oldfixed_time=b.fixed_time, 
		@newfixed_time=a.fixed_time,
		@oldtm_distance=b.tm_distance,
		@newtm_distance=a.tm_distance,
		@newOrderId=a.BOLD_ID,
		@dr_id=a.vypolnyaetsya_voditelem
		FROM inserted a, deleted b
		
		SELECT @ftime_tariff = dbo.GetDrTimeTariff(@dr_id);
		SELECT @tax_tariff = dbo.GetDrTaxTariff(@dr_id);

		IF ((@oldfixed_time<>@newfixed_time) AND (@ftime_tariff>0) AND (@newfixed_time>0))
		BEGIN
			UPDATE Zakaz SET fixed_summ=@newfixed_time*@ftime_tariff 
			WHERE BOLD_ID=@newOrderId;
		END;
		
		IF ((@oldtm_distance<>@newtm_distance) AND (@tax_tariff>0) AND (@newtm_distance>0))
		BEGIN
			UPDATE Zakaz SET tm_summ=@newtm_distance*@tax_tariff
			WHERE BOLD_ID=@newOrderId;
		END;

	END;
	
	
	
END



