USE [TD5R1]
GO
/****** Object:  StoredProcedure [dbo].[SetOrdersWideBroadcasts]    Script Date: 31.08.2018 19:43:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SetOrdersWideBroadcasts] 
	-- Add the parameters for the stored procedure here
	(@set_owbcast int, @forders_bcasts varchar(5000) OUT)
AS
BEGIN 

	DECLARE @db_version INT, @use_fordbroadcast_priority int, 
		@use_drivers_rating smallint;
	
	SELECT TOP 1 @db_version=ISNULL(db_version,3),
	@use_fordbroadcast_priority = ISNULL(use_fordbroadcast_priority,0),
	@use_drivers_rating = use_drivers_rating 
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';

	IF @use_drivers_rating = 1 BEGIN
		EXEC RecalcCurrentOrderRatingBonuses;
	END;

	SET @forders_bcasts='';
	IF (ISNULL(@set_owbcast,0)=1)
	BEGIN
		IF @use_fordbroadcast_priority <> 1
		BEGIN
			SELECT @forders_bcasts=ISNULL(dbo.GetJSONOrdersBCasts(),'');
			UPDATE Objekt_vyborki_otchyotnosti 
			SET forders_wbroadcast=@forders_bcasts,
			has_ford_wbroadcast=1;
		END
		ELSE
		BEGIN
			EXEC RefreshDrOrdPriorityBroadcasts;
		END
	END
	ELSE
	BEGIN
		UPDATE Objekt_vyborki_otchyotnosti
		SET has_ford_wbroadcast=0;
	END;
END
