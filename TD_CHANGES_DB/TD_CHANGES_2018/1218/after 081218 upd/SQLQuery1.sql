USE [TD5R1]
GO
/****** Object:  StoredProcedure [dbo].[AssignDriverOnOrder]    Script Date: 12.12.2018 3:58:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






ALTER PROCEDURE [dbo].[AssignDriverOnOrder] 
	-- Add the parameters for the stored procedure here
	(@order_id int, @driver_id int, @user_id int, @count int OUT)
AS
BEGIN 
	DECLARE @prev_dr_id int, 
	@on_launch int, @driverNum int,
	@min_debet decimal(28, 10);
	
	SET @count = 0;

	SELECT TOP 1 @min_debet=ISNULL(MIN_DEBET,0) 
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';

	SELECT @prev_dr_id=Zakaz.vypolnyaetsya_voditelem 
	FROM Zakaz
	WHERE Zakaz.BOLD_ID=@order_id;
	
	SELECT TOP 1 @driverNum=Pozyvnoi 
	FROM Voditelj 
	WHERE BOLD_ID=@driver_id AND ITS_REMOTE_CLIENT = 1 AND 
	Na_pereryve = 0 AND (DRIVER_BALANCE > @min_debet OR use_dyn_balance <> 1) AND 
	V_rabote = 1;
	
	if (@@ROWCOUNT>0)
	begin
	
	UPDATE Zakaz 
	SET REMOTE_SET=8,
	vypolnyaetsya_voditelem=@driver_id,
	Pozyvnoi_ustan=@driverNum,
	REMOTE_INCOURSE=0, REMOTE_ACCEPTED=0,
	Priority_counter=0, REMOTE_DRNUM=@driverNum,
	REMOTE_SYNC=1, Individ_order=1, 
	otpravlyaetsya = @user_id, adr_manual_set = 1
	WHERE BOLD_ID=@order_id AND Adres_vyzova_vvodim <> ''
	AND Telefon_klienta <> '';

	--adr_manual_set=1
	SET @count = @@ROWCOUNT;
	
	IF @count > 0 BEGIN
		UPDATE Voditelj
		SET Na_pereryve=0,
		Zanyat_drugim_disp=1
		WHERE BOLD_ID=@driver_id;

		IF @prev_dr_id > 0 BEGIN
			EXEC CheckDriverBusy @prev_dr_id;
		END;
	END;
	
	end
	
	
	
END










