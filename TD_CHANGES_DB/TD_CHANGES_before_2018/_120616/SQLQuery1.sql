USE [TD5R1]
GO
/****** Object:  StoredProcedure [dbo].[SetDriverRemoteStatus]    Script Date: 12.06.2016 7:02:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[ApplyRClientCoords] 
	-- Add the parameters for the stored procedure here
	(@rclient_id int, @lat varchar(50), @lon varchar(50))
AS
BEGIN 
	SET @rclient_id=ISNULL(@rclient_id,0);
	SET @lat=ISNULL(@lat,'');
	SET @lon=ISNULL(@lon,'');
	IF (@rclient_id>0 and @lat<>'' and @lon<>'') begin
		UPDATE Zakaz SET rclient_lat=@lat, rclient_lon=@lon 
		WHERE rclient_id=@rclient_id and Zavershyon=0 and Arhivnyi=0;

		UPDATE REMOTE_CLIENTS SET last_lat=@lat, last_lon=@lon 
		WHERE id=@rclient_id;
	end;
END

