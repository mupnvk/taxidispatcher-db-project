USE [TD5R1]
GO
/****** Object:  Trigger [dbo].[AFTER_DRIVER_WORKSTART]    Script Date: 15.12.2018 6:36:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[AFTER_DRIVER_WORKSTART] 
   ON  [dbo].[Voditelj] 
   AFTER UPDATE
AS 
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @db_version INT, @manual_day_sale int, @count int,
		@all_day_payment decimal(28, 10), @pt_offset int;
	
	SET @manual_day_sale = 0;
	SET @count = 0;
	SET @all_day_payment = 0;
	
	SELECT TOP 1 @db_version=ISNULL(db_version,3),
	@manual_day_sale = ISNULL(manual_day_sale,0),
	@all_day_payment = ISNULL(day_payment,0),
	@pt_offset = ISNULL(dayli_pay_time_offset,0) 
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';
	
	if ((@db_version>=5) AND (@manual_day_sale=1))
	BEGIN
	
	DECLARE @nOldValue int, @itsRemoteDr int,
		@dr_num int, @day_payment decimal(28, 10),
		@corruptedNew int, @dr_daily_sale smallint,
		@newDrNum int, @corruptedOld int,
		@newOnLineValue int, @oldOnLineValue int,
		@order_id int, @paymentCount int,
		@oldOrdDate DATETIME, @newOrdDate DATETIME, @bold_id int,
		@dont_restime smallint, @daily_payment_expire smallint;
		
	
	SELECT @nOldValue=b.BOLD_ID, 
	@dr_num=a.Pozyvnoi,
	@day_payment=ISNULL(a.day_payment, 0),
	@corruptedOld=b.Zanyat_drugim_disp,
	@corruptedNew=a.Zanyat_drugim_disp,
	@dr_daily_sale=a.manual_day_sale,
	@newDrNum = a.Pozyvnoi,
	@newOnLineValue = a.V_rabote,
	@oldOnLineValue = b.V_rabote,
	@itsRemoteDr = a.ITS_REMOTE_CLIENT,
	@oldOrdDate = b.Vremya_poslednei_zayavki,
	@newOrdDate = a.Vremya_poslednei_zayavki, -- Get the Old and New values
	@dont_restime = b.dont_reset_time,
	@daily_payment_expire = a.daily_payment_expire
	FROM inserted a, deleted b;

		IF (@newOnLineValue<>@oldOnLineValue) AND (@dont_restime = 1)
		BEGIN
			UPDATE Voditelj 
			SET Vremya_poslednei_zayavki=CURRENT_TIMESTAMP
			WHERE BOLD_ID=@nOldValue;
		END
		
		IF (((@newOnLineValue<>@oldOnLineValue) AND 
			(@newOnLineValue=1)) or 
			((@corruptedNew<>@corruptedOld) AND 
			(@corruptedNew=1)))
		BEGIN
		
				--проверка насройки отчисления по данному водителю
				IF (@dr_daily_sale=1 AND ((@day_payment>0) or (@all_day_payment>0)))
				BEGIN
					--проверка актуальности времени
					--проверка отчислений в эти сутки
					IF (@day_payment<=0) BEGIN
						SET @day_payment=@all_day_payment;
					END
					SET @paymentCount=0;
					DECLARE @edate datetime, @temp_date datetime, @last_14hours_count int;

					SET @daily_payment_expire = -24
					IF @daily_payment_expire > 0 BEGIN
						SET @daily_payment_expire = -@daily_payment_expire
					END

					SET @temp_date = DATEADD(hour, @daily_payment_expire, GETDATE());
					SELECT @last_14hours_count=COUNT(*) FROM Vyruchka_ot_voditelya vv
					WHERE vv.Pozyvnoi=@newDrNum and (vv.Data_postupleniya>@temp_date) and 
					(vv.Data_postupleniya<GETDATE()) and vv.ITS_DAYLY=1;
					--if()
					--set @edate = DATEADD(minute,-@pt_offset,GETDATE());
					IF (@last_14hours_count=0) 
					BEGIN
					set @edate = GETDATE();
					SELECT @paymentCount=COUNT(*) FROM Vyruchka_ot_voditelya vv
					WHERE vv.Pozyvnoi=@newDrNum and CAST(vv.Data_postupleniya as date)=CAST(@edate as DATE)
					and vv.ITS_DAYLY=1;
					--выставление признака необходимости отчисления
					IF (@paymentCount=0 OR @daily_payment_expire > -24) 
					BEGIN
                        DECLARE @uname varchar(255);
						set @uname=SUSER_NAME();
						DECLARE @desc varchar(255);
						set @desc='Водитель '+CAST(@dr_num as varchar(20))+' должен оплатить сутки! '+CAST(@edate as varchar(50));
					    UPDATE Voditelj SET daily_paym_status=1, online_set_uname=@uname,
					    paym_check_date=@edate WHERE BOLD_ID=@nOldValue;
					    IF (@itsRemoteDr=0) BEGIN
							EXEC InsertEvent3 7, -1, @nOldValue, -1, 
								@edate, @desc, '',
								'', @dr_num, '',
								'', 1, @uname, @day_payment, @count = @count OUTPUT;
						END
					END;
					END;
				END;

			    
		
		END;
	
	END;

END
