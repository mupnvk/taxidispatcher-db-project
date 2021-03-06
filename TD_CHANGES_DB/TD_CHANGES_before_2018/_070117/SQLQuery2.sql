USE [TD5R1]
GO
/****** Object:  Trigger [dbo].[AFTER_DRIVER_ASSIGN]    Script Date: 07.01.2017 16:25:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER TRIGGER [dbo].[AFTER_DRIVER_ASSIGN] 
   ON  [dbo].[Zakaz] 
   AFTER UPDATE
AS 
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @db_version INT,
	@clsms_offlinedr_assign smallint;
	
	SELECT TOP 1 @db_version=ISNULL(db_version,3),
	@clsms_offlinedr_assign = clsms_offlinedr_assign
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';
	
	IF((@db_version>=5))
	BEGIN

	DECLARE @nOldValue int, @newDrId int, @oldDrId int;
		
	SELECT @nOldValue=b.BOLD_ID, 
	@newDrId=a.vypolnyaetsya_voditelem,
	@oldDrId=b.vypolnyaetsya_voditelem
	FROM inserted a, deleted b;
	
	IF((@newDrId<>@oldDrId) and (@newDrId>0))
	BEGIN
	
		UPDATE Zakaz SET dr_assign_date=GETDATE() WHERE BOLD_ID=@nOldValue;
		
		SELECT COUNT(*) FROM Voditelj v WHERE v.BOLD_ID=@newDrId AND v.ITS_REMOTE_CLIENT<>1
		IF (@@ROWCOUNT>0) AND (@clsms_offlinedr_assign=1) BEGIN
			UPDATE Zakaz SET CLIENT_SMS_SEND_STATE=1
			WHERE BOLD_ID=@nOldValue;
		END;
	END;

	END;
	
	
	
END


