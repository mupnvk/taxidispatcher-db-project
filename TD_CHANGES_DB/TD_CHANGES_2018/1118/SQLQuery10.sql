USE [TD5R1]
GO
/****** Object:  UserDefinedFunction [dbo].[GetDrIDByNum]    Script Date: 23.11.2018 3:24:57 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER FUNCTION [dbo].[GetSetManualAddrChange]  ()
RETURNS smallint
AS
BEGIN
	DECLARE @set_manual_addr_change int;

	SELECT TOP 1 @set_manual_addr_change=ISNULL(set_manual_addr_change,0) 
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';

	SET @set_manual_addr_change=ISNULL(@set_manual_addr_change,0)

	RETURN(@set_manual_addr_change)
END