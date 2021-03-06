USE [TD5R1]
GO
/****** Object:  StoredProcedure [dbo].[AddNewOrderNum]    Script Date: 15.07.2018 11:16:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[CalcBonusSumm] 
	-- Add the parameters for the stored procedure here
	(@order_id int, @decPhoneBalance smallint, @bonusUse decimal(28,10) OUTPUT)
AS
BEGIN   
	DECLARE @nOldValue int, @completeNewValue int, 
		@completeOldValue INT, @NewSyncValue INT,
		@summValue decimal(28,10), @newDrId int, 
		@bonusSumm decimal(28,10),
		@bonusAll decimal(28,10),
		@orderPhone varchar(255),
		@first_trip_bonus decimal(28,10),
		@trip_bonus decimal(28,10),
		@percent_bonus_min_summ decimal(28,10),
		@bonus_percent decimal(28,10),
		@phoneOrderCount int, @db_version int;

	SET @decPhoneBalance = ISNULL(@decPhoneBalance, 0);

	SELECT TOP 1 
	@first_trip_bonus = first_trip_bonus,
	@trip_bonus = trip_bonus,
	@percent_bonus_min_summ = percent_bonus_min_summ,
	@bonus_percent = bonus_percent
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';

	SELECT 
	@summValue=Uslovn_stoim,
	@newDrId=vypolnyaetsya_voditelem,
	@orderPhone = Telefon_klienta,
	@bonusUse = bonus_use
	FROM Zakaz
	WHERE BOLD_ID = @nOldValue

	SET @bonusUse = ISNULL(@bonusUse,0);

	IF (@bonusUse < 0) BEGIN 
		SET @bonusUse = 0;
	END;

	SET @bonusSumm = 0;

	IF ( (@summValue>0) AND @orderPhone<>'' AND @newDrId > 0 AND 
		((@bonus_percent > 0 AND @percent_bonus_min_summ > 0) OR @first_trip_bonus > 0 OR @trip_bonus > 0) AND 
		(@summValue > 0) )
	BEGIN
		SELECT COUNT(BOLD_ID)
		FROM Sootvetstvie_parametrov_zakaza sp
		WHERE sp.Telefon_klienta = @orderPhone;

		IF @@ROWCOUNT = 1 BEGIN

			SELECT @phoneOrderCount = sp.Summarn_chislo_vyzovov, 
			@bonusAll = sp.bonus_summ
			FROM Sootvetstvie_parametrov_zakaza sp
			WHERE sp.Telefon_klienta = @orderPhone;

			IF @bonusUse > @bonusAll BEGIN
				SET @bonusUse = @bonusAll;
				UPDATE Zakaz SET bonus_use = @bonusUse
				WHERE BOLD_ID = @nOldValue;
			END;

			IF @bonus_percent > 0 AND @percent_bonus_min_summ <= @summValue AND 
				@percent_bonus_min_summ > 0 AND @bonus_percent < 1 BEGIN
				SET @bonusSumm = @summValue * @bonus_percent;
			END
			ELSE BEGIN
				IF @phoneOrderCount = 1 BEGIN
					SET @bonusSumm = @first_trip_bonus;
				END
				ELSE BEGIN
					SET @bonusSumm = @trip_bonus;
				END;
			END;

			UPDATE Zakaz SET bonus_add = @bonusSumm, 
			bonus_all = @bonusAll + @bonusSumm - @bonusUse
			WHERE BOLD_ID = @nOldValue;

			IF @decPhoneBalance = 1 BEGIN
				UPDATE Sootvetstvie_parametrov_zakaza
				SET bonus_summ = bonus_summ + @bonusSumm - @bonusUse
				WHERE Telefon_klienta = @orderPhone;
			END;
		END;
     
    END;
    return
END

