USE [TD5R1]
GO
/****** Object:  StoredProcedure [dbo].[InsertNewDriverIncome]    Script Date: 19.12.2018 12:50:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[InsertNewDriverIncome] 
	-- Add the parameters for the stored procedure here
	(@bold_id int OUT, @its_dayly smallint, @summ decimal(28,10), @idt datetime, @dr_num int, @count int OUT)
AS
BEGIN 
    DECLARE @last_ct datetime, @curr_dt datetime;
    DECLARE @last_ts int, @bold_ts int, @daily_count int, @daily_expire smallint;   

	--SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	
	SET @bold_id = -1;
	SET @its_dayly = ISNULL(@its_dayly,0);
	SET @summ = ISNULL(@summ,0);
	SET @idt = ISNULL(@idt, GETDATE());
	SET @dr_num = ISNULL(@dr_num, 0);
	SET @count=0;
	
	SELECT @daily_expire = daily_payment_expire FROM Voditelj 
	WHERE Pozyvnoi = @dr_num
	
	SET @daily_count=0; 
	SELECT @daily_count=COUNT(*) FROM Vyruchka_ot_voditelya vv
	WHERE vv.Pozyvnoi=@dr_num and CAST(vv.Data_postupleniya as date)=CAST(@idt as DATE)
	and vv.ITS_DAYLY=1;
	
	IF(NOT ((@its_dayly=1) AND (@daily_count>0)) OR (@its_dayly=1 AND @daily_expire > 0 AND @daily_expire < 24))
	BEGIN
	
	BEGIN TRAN
	
	SELECT TOP 1 @bold_id=BOLD_ID FROM BOLD_ID;
    
    UPDATE [BOLD_ID] set [BOLD_ID] = [BOLD_ID]+1;
    
    INSERT INTO BOLD_XFILES 
    (BOLD_ID, BOLD_TYPE, BOLD_TIME_STAMP, 
    EXTERNAL_ID) 
	VALUES (@bold_id, 1, 0, '{'+CONVERT(varchar(36),NEWID())+'}') 
    
    INSERT INTO BOLD_OBJECT(BOLD_ID, BOLD_TYPE,
    [READ_ONLY]) VALUES(@bold_id, 1, 0);
    
    INSERT INTO Prihod (BOLD_ID, BOLD_TYPE, sostavlyaet_prihod, 
		Summa_pozicii, Data_prihoda, Opisanie, otnos_k_operac_prih) 
		VALUES (@bold_id, 1, -1, 0, @idt, '-', -1);
    
    INSERT INTO Vyruchka_ot_voditelya(BOLD_ID, BOLD_TYPE, Summa, 
    kem_prinositsya, Data_postupleniya, Pozyvnoi, ITS_DAYLY) 
	VALUES (@bold_id, 1, @summ, 
	-1, @idt, @dr_num, @its_dayly);
	
	SET @count=@@ROWCOUNT;
	
	SELECT TOP 1 @last_ts=LastTimestamp, 
	@last_ct=LastClockTime FROM BOLD_LASTCLOCK;
	
	UPDATE [BOLD_TIMESTAMP] 
	SET [BOLD_TIME_STAMP] = [BOLD_TIME_STAMP]+1;		
    
    SELECT TOP 1 @bold_ts=BOLD_TIME_STAMP 
    FROM BOLD_TIMESTAMP;
    
    SET @curr_dt = GETDATE();
    
    INSERT INTO BOLD_CLOCKLOG (LastTimestamp, 
    ThisTimestamp, LastClockTime, 
	ThisClockTime) VALUES (@last_ts, @bold_ts, 
	@last_ct, @curr_dt);
	
	UPDATE BOLD_LASTCLOCK SET LastTimestamp = @bold_ts, 
	LastClockTime = @curr_dt;
	
	UPDATE BOLD_XFILES
	SET BOLD_TIME_STAMP = @bold_ts
	WHERE BOLD_ID = @bold_id;
      
    COMMIT TRAN
    
    END;
     
    --SET @ord_num=@new_ord_num;
    --return
END
GO

/****** Object:  StoredProcedure [dbo].[AssignDriverOnOrder]    Script Date: 19.12.2018 12:54:36 ******/
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
GO

/****** Object:  StoredProcedure [dbo].[GetJSONDriverStatus]    Script Date: 19.12.2018 12:55:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[GetJSONDriverStatus] 
	-- Add the parameters for the stored procedure here
	(@driver_id int, @show_phone int, @res varchar(8000) OUT)
AS
BEGIN 

	DECLARE @CURSOR cursor;
	DECLARE @sector_id int, @dr_count int,
		@sector_name varchar(255), @counter int,
		@order_id int, @order_data varchar(255),
		@order_count int, @on_launch int, @busy int,
		@dr_status varchar(255), @rsync int, 
		@waiting int, @order_sort_dr_assign smallint,
		@tarif_id int, @opt_comb varchar(255), @tplan_id int, 
		@prev_price decimal(28,10), @cargo_desc varchar(5000), 
		@end_adres varchar(1000), @client_name varchar(500), 
		@prev_distance decimal(28,10), @prev_date datetime,
		@on_place smallint, @bonus_use decimal(28,10),
		@show_region_in_addr smallint, @is_early smallint;
	DECLARE @last_order_time datetime;
	DECLARE @position int;
	
	SET @last_order_time=GETDATE();
   
	SET @res='{"command":"driver_status","did":"';
	SET @dr_count = 0;
	SET @counter = 0;
	
	DECLARE @send_wait_info smallint;
	
	SELECT TOP 1 @send_wait_info=ISNULL(send_wait_info,0),
	@order_sort_dr_assign=ISNULL(order_sort_dr_assign,0),
	@show_region_in_addr = show_region_in_addr
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';
	
	SET @send_wait_info = ISNULL(@send_wait_info,0);
	
	SELECT @dr_count=COUNT(*) FROM
	Voditelj WHERE BOLD_ID=@driver_id;
	
	IF (@dr_count>0)
	BEGIN
	
	--UPDATE Voditelj SET V_rabote=1 
	--WHERE BOLD_ID=@driver_id;
	
	--UPDATE Voditelj SET REMOTE_STATUS=1
	--WHERE REMOTE_STATUS<=0;
	
	EXEC CheckDriverBusy @driver_id;
	
	SELECT @busy=Zanyat_drugim_disp, @on_launch=Na_pereryve,
	@last_order_time=Vremya_poslednei_zayavki 
	FROM Voditelj 
	WHERE BOLD_ID=@driver_id;
	
	SET @dr_status='free';
	
	IF(@on_launch>0)
	BEGIN
		SET @dr_status='onln';
	END;
	
	IF(@busy>0)
	BEGIN
		SET @dr_status='busy';
	END;
	
	SET @res=@res+CAST(@driver_id as varchar(20))+
		'","dst":"'+@dr_status+'"';
	
	SELECT @sector_id=ISNULL(ws.BOLD_ID,-1),
	@sector_name=REPLACE(REPLACE(
	ISNULL(dict.Naimenovanie,'НЕ ОПРЕДЕЛЕН'),'"',' '),'''',' ')  
	FROM Sektor_raboty ws JOIN Spravochnik dict 
	ON ws.BOLD_ID=dict.BOLD_ID JOIN Voditelj dr
	ON dr.rabotaet_na_sektore=ws.BOLD_ID
	WHERE dr.BOLD_ID=@driver_id;
	
	SET @res=@res+',"sid":"'+
		CAST(@sector_id as varchar(20))+'"';
		
	SELECT @position=COUNT(*)+1 
		FROM Voditelj dr WHERE
		dr.Vremya_poslednei_zayavki<
		@last_order_time AND 
		dr.rabotaet_na_sektore=@sector_id
		AND dr.V_rabote=1 AND dr.Pozyvnoi>0 
		and S_klass=0 and Zanyat_drugim_disp=0 and Na_pereryve=0;
		
	SET @res=@res+',"scn":"'+@sector_name+
		'","dp":"'+CAST(@position as varchar(20))+'","ocn":"';
	
	SELECT @order_count=COUNT(*)
	FROM Zakaz ord WHERE 
		ord.vypolnyaetsya_voditelem=@driver_id AND
		ord.Arhivnyi=0 AND ord.Soobsheno_voditelyu=0
		AND ord.Zavershyon=0 AND ord.NO_TRANSMITTING=0 
		AND ord.REMOTE_SET NOT IN(0,16,26,100)
		AND (ord.is_early = 0 OR ord.is_started_early = 1 OR ord.REMOTE_SYNC = 1);
	
	IF (@order_count>0)
	BEGIN
	
		SET @res=@res+
			CAST(@order_count as varchar(20))+'"';
	
		IF (@order_sort_dr_assign=1)
		BEGIN
		IF (@show_phone>0)
		BEGIN
			SET @CURSOR  = CURSOR SCROLL
			FOR
			SELECT ord.BOLD_ID, ((CASE WHEN (@show_region_in_addr = 1 AND ISNULL(ds.name, '') <> '') THEN ('(' + ds.name + ') ') ELSE '' END) + ord.Telefon_klienta+
			':'+ ord.Adres_vyzova_vvodim + (CASE WHEN (ord.is_early = 1) THEN (' (' + CAST(ord.early_date as varchar(50)) + ') ') ELSE '' END)) as order_data,
			ord.REMOTE_SYNC, ord.WAITING, ord.TARIFF_ID, ord.OPT_COMB_STR, ord.PR_POLICY_ID,
			ord.prev_price, ord.cargo_desc, ord.end_adres, ord.client_name, ord.prev_distance,
			ord.Data_predvariteljnaya, ord.on_place, ord.bonus_use, ord.is_early  
			FROM Zakaz ord LEFT JOIN DISTRICTS ds ON ord.district_id = ds.id WHERE 
			ord.vypolnyaetsya_voditelem=@driver_id AND
			ord.Arhivnyi=0 AND ord.Soobsheno_voditelyu=0
			AND ord.Zavershyon=0 AND ord.NO_TRANSMITTING=0 
			AND ord.REMOTE_SET NOT IN(0,16,26,100) 
			AND (ord.is_early = 0 OR ord.is_started_early = 1 OR ord.REMOTE_SYNC = 1)
			ORDER BY ISNULL(ord.dr_assign_date,GETDATE()) ASC;
		END
		ELSE
		BEGIN
			SET @CURSOR  = CURSOR SCROLL
			FOR
			SELECT ord.BOLD_ID, ((CASE WHEN (@show_region_in_addr = 1 AND ISNULL(ds.name, '') <> '') THEN ('(' + ds.name + ') ') ELSE '' END) + ord.Adres_vyzova_vvodim + 
			(CASE WHEN (ord.is_early = 1) THEN (' (' + CAST(ord.early_date as varchar(50)) + ') ') ELSE '' END)) as order_data,
			ord.REMOTE_SYNC, ord.WAITING, ord.TARIFF_ID, ord.OPT_COMB_STR, ord.PR_POLICY_ID,
			ord.prev_price, ord.cargo_desc, ord.end_adres, ord.client_name, ord.prev_distance,
			ord.Data_predvariteljnaya, ord.on_place, ord.bonus_use, ord.is_early  
			FROM Zakaz ord LEFT JOIN DISTRICTS ds ON ord.district_id = ds.id WHERE 
			ord.vypolnyaetsya_voditelem=@driver_id AND
			ord.Arhivnyi=0 AND ord.Soobsheno_voditelyu=0
			AND ord.Zavershyon=0 AND ord.NO_TRANSMITTING=0 
			AND ord.REMOTE_SET NOT IN(0,16,26,100)
			AND (ord.is_early = 0 OR ord.is_started_early = 1 OR ord.REMOTE_SYNC = 1)
			ORDER BY ISNULL(ord.dr_assign_date,GETDATE()) ASC;
		END;
		END
		ELSE
		BEGIN
		IF (@show_phone>0)
		BEGIN
			SET @CURSOR  = CURSOR SCROLL
			FOR
			SELECT ord.BOLD_ID, ((CASE WHEN (@show_region_in_addr = 1 AND ISNULL(ds.name, '') <> '') THEN ('(' + ds.name + ') ') ELSE '' END) + ord.Telefon_klienta+
			':' + ord.Adres_vyzova_vvodim + (CASE WHEN (ord.is_early = 1) THEN (' (' + CAST(ord.early_date as varchar(50)) + ') ') ELSE '' END)) as order_data,
			ord.REMOTE_SYNC, ord.WAITING, ord.TARIFF_ID, ord.OPT_COMB_STR, ord.PR_POLICY_ID,
			ord.prev_price, ord.cargo_desc, ord.end_adres, ord.client_name, ord.prev_distance,
			ord.Data_predvariteljnaya, ord.on_place, ord.bonus_use, ord.is_early   
			FROM Zakaz ord LEFT JOIN DISTRICTS ds ON ord.district_id = ds.id WHERE 
			ord.vypolnyaetsya_voditelem=@driver_id AND
			ord.Arhivnyi=0 AND ord.Soobsheno_voditelyu=0
			AND ord.Zavershyon=0 AND ord.NO_TRANSMITTING=0 
			AND ord.REMOTE_SET NOT IN(0,16,26,100)
			AND (ord.is_early = 0 OR ord.is_started_early = 1 OR ord.REMOTE_SYNC = 1) 
			ORDER BY ord.Nachalo_zakaza_data ASC;
		END
		ELSE
		BEGIN
			SET @CURSOR  = CURSOR SCROLL
			FOR
			SELECT ord.BOLD_ID, ((CASE WHEN (@show_region_in_addr = 1 AND ISNULL(ds.name, '') <> '') THEN ('(' + ds.name + ') ') ELSE '' END) + ord.Adres_vyzova_vvodim + 
			(CASE WHEN (ord.is_early = 1) THEN (' (' + CAST(ord.early_date as varchar(50)) + ') ') ELSE '' END)) as order_data,
			ord.REMOTE_SYNC, ord.WAITING, ord.TARIFF_ID, ord.OPT_COMB_STR, ord.PR_POLICY_ID,
			ord.prev_price, ord.cargo_desc, ord.end_adres, ord.client_name, ord.prev_distance,
			ord.Data_predvariteljnaya, ord.on_place, ord.bonus_use, ord.is_early   
			FROM Zakaz ord LEFT JOIN DISTRICTS ds ON ord.district_id = ds.id WHERE 
			ord.vypolnyaetsya_voditelem=@driver_id AND
			ord.Arhivnyi=0 AND ord.Soobsheno_voditelyu=0
			AND ord.Zavershyon=0 AND ord.NO_TRANSMITTING=0 
			AND ord.REMOTE_SET NOT IN(0,16,26,100)
			AND (ord.is_early = 0 OR ord.is_started_early = 1 OR ord.REMOTE_SYNC = 1)
			ORDER BY ord.Nachalo_zakaza_data ASC;
		END;
		END;
		/*Открываем курсор*/
		OPEN @CURSOR
		/*Выбираем первую строку*/
		FETCH NEXT FROM @CURSOR INTO @order_id, @order_data, @rsync, @waiting, @tarif_id, @opt_comb, @tplan_id, @prev_price, @cargo_desc, @end_adres, @client_name, @prev_distance, @prev_date, @on_place, @bonus_use, @is_early;
		/*Выполняем в цикле перебор строк*/
		WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @res=@res+',"oid'+
				CAST(@counter as varchar(20))+'":"'+
				CAST(@order_id as varchar(20))+'","odt'+
				CAST(@counter as varchar(20))+'":"'+
				REPLACE(REPLACE(@order_data,'"',' '),'''',' ')+'"';
			IF (@rsync<>0)
			BEGIN
				SET @res=@res+',"sn'+
				CAST(@counter as varchar(20))+'":"y"';
			END;
			IF (@send_wait_info=1)
			BEGIN
				SET @res=@res+',"wtr'+
				CAST(@counter as varchar(20))+'":"'+
				CAST(@waiting as varchar(20))+'"';
			END;
			IF (@tarif_id<>0)
			BEGIN
				SET @res=@res+',"tar'+
				CAST(@counter as varchar(20))+'":"'+
				CAST(@tarif_id as varchar(20))+'"';
			END;
			
			SET @opt_comb=ISNULL(@opt_comb,'-');
			IF (@opt_comb='')
			BEGIN
				SET @opt_comb='-';
			END;
			
			SET @res=@res+',"oo'+
			CAST(@counter as varchar(20))+'":"'+
			@opt_comb+'"';
			
			IF (@tplan_id>=0)
			BEGIN
			SET @res=@res+',"otpid'+
			CAST(@counter as varchar(20))+'":"'+
			CAST(@tplan_id as varchar(20))+'"';
			END;

			IF (@prev_price>0)
			BEGIN
			SET @res=@res+',"oppr'+
			CAST(@counter as varchar(20))+'":"'+
			convert(varchar,convert(decimal(8,2),@prev_price))+'"';
			END;

			IF (@prev_distance>0)
			BEGIN
			SET @res=@res+',"opdn'+
			CAST(@counter as varchar(20))+'":"'+
			convert(varchar,convert(decimal(8,2),@prev_distance))+'"';
			END;

			IF (@bonus_use>0)
			BEGIN
			SET @res=@res+',"obus'+
			CAST(@counter as varchar(20))+'":"'+
			convert(varchar,convert(decimal(8,2),@bonus_use))+'"';
			END;

			IF (@is_early = 1)
			BEGIN
				SET @res=@res + ',"ie' +
				CAST(@counter as varchar(20)) + '":"1"';
			END;

			IF (@cargo_desc<>'')
			BEGIN
			SET @res=@res+',"ocrd'+
			CAST(@counter as varchar(20))+'":"'+
			REPLACE(REPLACE(@cargo_desc,'"',' '),'''',' ')+'"';
			END;

			IF (ISNULL(@end_adres,'')<>'')
			BEGIN
			SET @res=@res+',"oena'+
			CAST(@counter as varchar(20))+'":"'+
			REPLACE(REPLACE(ISNULL(@end_adres,''),'"',' '),'''',' ')+'"';
			END;

			IF (ISNULL(@client_name,'')<>'')
			BEGIN
			SET @res=@res+',"ocln'+
			CAST(@counter as varchar(20))+'":"'+
			REPLACE(REPLACE(ISNULL(@client_name,''),'"',' '),'''',' ')+'"';
			END;

			SET @res=@res+',"oprd'+
			CAST(@counter as varchar(20))+'":"'+
			CAST(DATEDIFF(second,{d '1970-01-01'},@prev_date) AS varchar(100))+'"';

			SET @res = @res + ',"dopl' +
				CAST(@counter as varchar(20)) + '":"' +
				CAST(@on_place as varchar(20)) + '"';
			
			SET @counter=@counter+1;
			/*Выбираем следующую строку*/
			FETCH NEXT FROM @CURSOR INTO @order_id, @order_data, @rsync, @waiting, @tarif_id, @opt_comb, @tplan_id, @prev_price, @cargo_desc, @end_adres, @client_name, @prev_distance, @prev_date, @on_place, @bonus_use, @is_early;
		END
		CLOSE @CURSOR
	END
	ELSE
	BEGIN
		SET @res=@res+'0"';
	END;
	
	SET @res=@res+',"msg_end":"ok"}';
	
	END
	ELSE
	BEGIN
		SET @res=@res+'-1","msg_end":"ok"}';	
	END;
	
END





GO

/****** Object:  Trigger [dbo].[AFTER_DRIVER_WORKSTART]    Script Date: 19.12.2018 12:58:49 ******/
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

					
					IF @daily_payment_expire > 0 BEGIN
						SET @daily_payment_expire = -@daily_payment_expire
					END ELSE
					BEGIN
						SET @daily_payment_expire = -24
					END;

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
GO

