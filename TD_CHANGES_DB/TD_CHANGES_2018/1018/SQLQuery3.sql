USE [TD5R1]
GO
/****** Object:  Trigger [dbo].[AFTER_COORD_UPDATE]    Script Date: 29.09.2018 14:54:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[AFTER_COORD_UPDATE] 
   ON  [dbo].[Zakaz] 
   AFTER UPDATE
AS 
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @db_version INT;
	
	SELECT TOP 1 @db_version=ISNULL(db_version,3) 
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';
	
	if(@db_version>=5)
	BEGIN
	
		DECLARE @nOldValue int, @newClLat varchar(50),
			@newClLon varchar(50), @oldClLat varchar(50),
			@oldClLon varchar(50), @newAdrLat varchar(50),
			@newAdrLon varchar(50), @oldAdrLat varchar(50),
			@oldAdrLon varchar(50);

		SELECT @nOldValue=b.BOLD_ID, 
		@newClLat=ISNULL(a.rclient_lat, ''),
		@newClLon=ISNULL(a.rclient_lon, ''),
		@oldClLat=ISNULL(b.rclient_lat, ''),
		@oldClLon=ISNULL(b.rclient_lon, ''),
		@newAdrLat=ISNULL(a.adr_detect_lat, ''),
		@newAdrLon=ISNULL(a.adr_detect_lon, ''),
		@oldAdrLat=ISNULL(b.adr_detect_lat, ''),
		@oldAdrLon=ISNULL(b.adr_detect_lon, '')
		FROM inserted a, deleted b;
	
		IF ((@newClLat <> @oldClLat AND @newClLat <> '') OR 
			(@newClLon <> @oldClLon  AND @newClLon <> '') OR 
			(@newAdrLat <> @oldAdrLat  AND @newAdrLat <> '') OR 
			(@newAdrLon <> @oldAdrLon  AND @newAdrLon <> '') )
		BEGIN
			UPDATE Zakaz 
			SET is_coordinates_upd = 1
			WHERE BOLD_ID=@nOldValue;

			UPDATE Personal
			SET orders_coord_updated = 1;
		END;

	END;
	
END

