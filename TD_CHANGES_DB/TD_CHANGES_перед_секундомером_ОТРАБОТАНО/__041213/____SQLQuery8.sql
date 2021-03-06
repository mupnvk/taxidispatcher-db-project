USE [TD5R1]
GO
/****** Object:  StoredProcedure [dbo].[SetWideBroadcasts]    Script Date: 12/04/2013 04:01:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SetWideBroadcasts] 
	-- Add the parameters for the stored procedure here
	(@set_sectors int, @sectors_bcasts varchar(5000) OUT)
AS
BEGIN 
	SET @sectors_bcasts='';
	IF (ISNULL(@set_sectors,0)=1)
	BEGIN
		SELECT @sectors_bcasts=ISNULL(dbo.GetJSONSectorsStatus(),'');
		UPDATE Objekt_vyborki_otchyotnosti 
		SET sectors_wbroadcast=@sectors_bcasts,
		has_sect_wbroadcast=1;
	END
	ELSE
	BEGIN
		UPDATE Objekt_vyborki_otchyotnosti 
		SET has_sect_wbroadcast=0;
	END;
END


