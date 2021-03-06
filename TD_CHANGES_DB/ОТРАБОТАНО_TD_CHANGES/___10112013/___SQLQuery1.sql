ALTER FUNCTION [dbo].[GetJSONDriverSettings]  ( @driver_id int)
RETURNS varchar(500)
AS
BEGIN
	declare @en_moving int;
	DECLARE @curr_mver INT, @min_mver int, @mand_upd int, 
		@addit_rparams varchar(500);
	
	SELECT TOP 1 @curr_mver=ISNULL(curr_mob_version,2102),
	@min_mver=ISNULL(min_mob_version,2102),
	@mand_upd=ISNULL(mandatory_update,0),
	@addit_rparams=ISNULL(addit_rem_params,'') 
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';
   
	SET @en_moving=0;
   
	select @en_moving=ISNULL(EN_MOVING,0)   
	from Voditelj where BOLD_ID=@driver_id;   

	RETURN('{"command":"sets","en_moving":"'+
		CAST(@en_moving as varchar(20))+'","curr_mver":"'+
		CAST(@curr_mver as varchar(20))+'","min_mver":"'+
		CAST(@min_mver as varchar(20))+'","mand_upd":"'+
		CAST(@mand_upd as varchar(20))+'",'+@addit_rparams+
		'"msg_end":"ok"}')
END
