USE [TD5R1]
GO
/****** Object:  Trigger [dbo].[AFTER_ORDER_COMPLETE]    Script Date: 10.11.2018 1:19:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER TRIGGER [dbo].[AFTER_ORDER_COMPLETE] 
   ON  [dbo].[Zakaz] 
   AFTER UPDATE
AS 
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @db_version INT, @min_debet decimal(28,10), 
	@use_dr_bcounter int, @every_order_pay decimal(28,10),
	@dr_dpay decimal(28,10), @all_dr_dpay decimal(28,10), 
	@fix_ord_dpay smallint, @dr_fix_ord_dpay smallint,
	@use_fordbroadcast_priority smallint, 
	@no_percent_before_summ decimal(28,10),
	@no_percent_before_payment decimal(28,10),
	@prize_reward_summ decimal(28,10),
	@use_drivers_rating smallint,
	@base_referral_cashback decimal(18, 5),
	--@base_referral_bonus decimal(18, 5),
	@base_ref_bonus_interval int; 
	--@referral_rbonus_expire int;
	
	SELECT TOP 1 @db_version=ISNULL(db_version,3),
	@min_debet=ISNULL(MIN_DEBET,0),
	@use_dr_bcounter=ISNULL(use_dr_balance_counter,0),
	@every_order_pay=Kolich_vyd_benzina,
	@fix_ord_dpay=fix_order_pay_with_daily_pay,
	@all_dr_dpay=day_payment,
	@use_fordbroadcast_priority = use_fordbroadcast_priority,
	@no_percent_before_summ = no_percent_before_summ,
	@no_percent_before_payment = no_percent_before_payment,
	@prize_reward_summ = prize_reward_summ,
	@use_drivers_rating = use_drivers_rating,
	@base_referral_cashback = base_referral_cashback,
	--@base_referral_bonus = base_referral_bonus,
	@base_ref_bonus_interval = base_ref_bonus_interval
	--@referral_rbonus_expire = referral_rbonus_expire
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';
	
	DECLARE @nOldValue int, @completeNewValue int, 
		@completeOldValue INT, @NewSyncValue INT,
		@summValue decimal(28,10), @newDrId int, @dr_num int,
		@taxSumm decimal(28,10), @priseNum int,
		@bonusUse decimal(28,10),
		@driver_rating_diff decimal(18, 5),
		@driver_rating_expire_date datetime,
		@driver_rating_bonus_code varchar(255),
		@referral_driver_id int,
		@referral_set_date datetime,
		@expire_date datetime;
		
	SELECT @nOldValue=b.BOLD_ID, 
	@completeNewValue=a.Zavershyon,
	@completeOldValue=b.Zavershyon,
	@summValue=a.Uslovn_stoim,
	@newDrId=a.vypolnyaetsya_voditelem,
	@dr_num=a.Pozyvnoi_ustan,
	@priseNum = a.Nomer_skidki,
	@bonusUse = a.bonus_use,
	@driver_rating_diff = a.driver_rating_diff,
	@driver_rating_expire_date = a.driver_rating_expire_date,
	@driver_rating_bonus_code = a.driver_rating_bonus_code
	FROM inserted a, deleted b

	IF (@summValue IS NULL)
	BEGIN
		UPDATE Zakaz SET Uslovn_stoim=0 WHERE BOLD_ID=@nOldValue;
	END
	
	SET @summValue=ISNULL(@summValue,0);

	IF ((@db_version>=5) AND (@completeNewValue=1) AND (@completeNewValue<>@completeOldValue) 
		AND (@newDrId>0) and (@summValue > 0) )
	BEGIN
		EXEC CalcBonusSumm @nOldValue, 1, @bonusUse = @bonusUse OUTPUT;
	END;

	IF((@db_version>=5) AND (@use_dr_bcounter=1))
	BEGIN

	IF ((@completeNewValue=1) AND (@completeNewValue<>@completeOldValue) 
		AND (@newDrId>0) and (@summValue>0) )
	BEGIN
	 
		SELECT @dr_fix_ord_dpay=fix_order_pay_with_daily_pay,
			@dr_dpay=day_payment, @referral_driver_id = ISNULL(referral_driver_id, 0),
			@referral_set_date = referral_set_date
		FROM Voditelj
		WHERE BOLD_ID=@newDrId;

		SET @taxSumm = 0;
		IF @no_percent_before_summ > 0 
			AND @no_percent_before_summ >= @summValue 
			AND @summValue > 0 
			BEGIN
				SET @taxSumm = @no_percent_before_payment;
			END 
		ELSE
			BEGIN
				SET @taxSumm = @summValue*dbo.GetDrTakePercent(@dr_num);
			END

		IF @priseNum > 0 BEGIN
			SET @taxSumm = @taxSumm - @prize_reward_summ;
		END

		IF @bonusUse > 0 BEGIN
			SET @taxSumm = @taxSumm - @bonusUse;
		END;

		IF DATEADD(HOUR, @base_ref_bonus_interval, @referral_set_date) > GETDATE() AND
			@referral_set_date <= GETDATE() AND @referral_driver_id > 0 AND 
			@base_ref_bonus_interval > 0
		BEGIN
			--IF @base_referral_bonus > 0 AND @referral_rbonus_expire > 0 
			--BEGIN
			--	SET @expire_date = DATEADD(MINUTE, @referral_rbonus_expire, GETDATE());
			--	EXEC InsertDriverRating @referral_driver_id, @expire_date, 
			--		'referral', @base_referral_bonus, 1;
			--END;

			IF @base_referral_cashback > 0 BEGIN
				UPDATE Voditelj SET DRIVER_BALANCE = DRIVER_BALANCE + @base_referral_cashback 
				WHERE BOLD_ID = @referral_driver_id AND use_dyn_balance = 1;
			END;
		END;

		IF @driver_rating_diff > 0 AND @use_drivers_rating = 1 AND 
			@driver_rating_expire_date > GETDATE()
		BEGIN
			EXEC InsertDriverRating @newDrId, @driver_rating_expire_date, 
				@driver_rating_bonus_code, @driver_rating_diff, 1;
		END;

		UPDATE Voditelj SET DRIVER_BALANCE=
		DRIVER_BALANCE-@taxSumm 
		WHERE (BOLD_ID=@newDrId) and (use_dyn_balance=1);
		IF (@every_order_pay>0) and not (((@all_dr_dpay>0) OR (@dr_dpay>0)) and ((@fix_ord_dpay=0) or (@dr_fix_ord_dpay=0)))
		BEGIN
			UPDATE Voditelj SET DRIVER_BALANCE=DRIVER_BALANCE-@every_order_pay 
			WHERE (BOLD_ID=@newDrId) and (use_dyn_balance=1);
		END

	END;

	IF (@completeNewValue=1) AND (@completeNewValue<>@completeOldValue) BEGIN
		IF (@use_fordbroadcast_priority = 1)
		BEGIN
		    DELETE FROM DR_ORD_PRIORITY WHERE order_id=@nOldValue;
			--EXEC RefreshDrOrdPriorityBroadcasts;
		END;
		EXEC SetOrdersWideBroadcasts 1, '';
	END;

	END;
	
	
	
END


