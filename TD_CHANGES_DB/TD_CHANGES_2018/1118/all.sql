USE [TD5R1]
GO
/****** Object:  Trigger [dbo].[AFTER_ORDER_COMPLETE]    Script Date: 11.11.2018 0:45:38 ******/
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
GO

/****** Object:  View [dbo].[ActiveOrders]    Script Date: 11.11.2018 0:46:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[ActiveOrders]
AS
SELECT        dbo.Zakaz.BOLD_ID, dbo.Zakaz.Yavl_pochasovym, dbo.Zakaz.Kolichestvo_chasov, dbo.Zakaz.Nachalo_zakaza_data, dbo.Zakaz.Konec_zakaza_data, dbo.Zakaz.Telefon_klienta, dbo.Zakaz.Data_podachi, 
                         dbo.Zakaz.Zavershyon, dbo.Zakaz.Arhivnyi, dbo.Zakaz.Uslovn_stoim, dbo.Zakaz.Adres_vyzova_vvodim, dbo.Zakaz.Predvariteljnyi, dbo.Zakaz.Data_predvariteljnaya, dbo.Zakaz.Zadeistv_predvarit, 
                         dbo.Zakaz.Data_po_umolchaniyu, dbo.Zakaz.Soobsheno_voditelyu, dbo.Zakaz.vypolnyaetsya_voditelem, dbo.Zakaz.otpuskaetsya_dostepcherom, dbo.Zakaz.ocenivaetsya_cherez, dbo.Zakaz.adres_sektora, 
                         dbo.Zakaz.konechnyi_sektor_raboty, dbo.Zakaz.sektor_voditelya, dbo.Zakaz.Nomer_zakaza, dbo.Zakaz.Adres_okonchaniya_zayavki, dbo.Zakaz.Pozyvnoi_ustan, dbo.Zakaz.Data_pribytie, dbo.Zakaz.Nomer_skidki, 
                         dbo.Zakaz.Ustan_pribytie, dbo.Zakaz.Primechanie, dbo.Zakaz.Slugebnyi, dbo.Zakaz.otpravlyaetsya, dbo.Zakaz.Opr_s_obsh_linii, dbo.Zakaz.Data_na_tochke, dbo.Zakaz.REMOTE_SET, dbo.Zakaz.REMOTE_INCOURSE, 
                         dbo.Zakaz.REMOTE_ACCEPTED, dbo.Zakaz.REMOTE_DRNUM, dbo.Zakaz.DRIVER_SMS_SEND_STATE, dbo.Zakaz.CLIENT_SMS_SEND_STATE, dbo.Zakaz.SMS_SEND_DRNUM, dbo.Zakaz.SMS_SEND_CLPHONE, 
                         dbo.Zakaz.Priority_counter, dbo.Zakaz.Individ_order, dbo.Zakaz.Individ_sending, dbo.Zakaz.SECTOR_ID, dbo.Zakaz.REMOTE_SUMM, dbo.Zakaz.REMOTE_SYNC, dbo.Zakaz.LAST_STATUS_TIME, 
                         dbo.Zakaz.NO_TRANSMITTING, dbo.Zakaz.RESTORED, dbo.Zakaz.AUTO_ARHIVED, dbo.Zakaz.WAITING, dbo.Zakaz.direct_sect_id, dbo.Zakaz.fixed_time, dbo.Zakaz.fixed_summ, dbo.Zakaz.on_place, 
                         dbo.Zakaz.dr_assign_date, dbo.Zakaz.tm_distance, dbo.Zakaz.tm_summ, dbo.Zakaz.TARIFF_ID, dbo.Zakaz.OPT_COMB, dbo.Zakaz.OPT_COMB_STR, dbo.Zakaz.PR_POLICY_ID, dbo.Zakaz.call_it, dbo.Zakaz.rclient_id, 
                         dbo.Zakaz.rclient_status, dbo.Zakaz.clsync, dbo.Zakaz.tmsale, dbo.Zakaz.tmhistory, dbo.Zakaz.status_accumulate, dbo.Zakaz.rclient_lat, dbo.Zakaz.rclient_lon, dbo.Zakaz.alarmed, dbo.Zakaz.adr_manual_set, 
                         dbo.Zakaz.prev_price, dbo.Zakaz.cargo_desc, dbo.Zakaz.end_adres, dbo.Zakaz.client_name, dbo.Zakaz.prev_distance, dbo.Zakaz.CLIENT_CALL_STATE, CAST(DATEPART(hh, dbo.Zakaz.Nachalo_zakaza_data) AS CHAR(2)) 
                         + ':' + CAST(DATEPART(mi, dbo.Zakaz.Nachalo_zakaza_data) AS CHAR(2)) AS start_dt, CAST(DATEPART(hh, dbo.Zakaz.Konec_zakaza_data) AS CHAR(2)) + ':' + CAST(DATEPART(mi, dbo.Zakaz.Konec_zakaza_data) AS CHAR(2)) 
                         AS end_dt, dbo.GetCustComment(dbo.Zakaz.Nomer_zakaza, dbo.Zakaz.Nachalo_zakaza_data, dbo.Zakaz.Telefon_klienta + dbo.Zakaz.Adres_vyzova_vvodim, dbo.Zakaz.otpuskaetsya_dostepcherom, 
                         dbo.Zakaz.otpravlyaetsya, dbo.Zakaz.Pozyvnoi_ustan) AS MainCComment, dbo.GetOrderINumComment(dbo.Zakaz.Adres_okonchaniya_zayavki) AS INumInfo, dbo.GetEndSectorNameByID(dbo.Zakaz.konechnyi_sektor_raboty) 
                         AS esect, dbo.GetEndSectorNameByID(dbo.Zakaz.SECTOR_ID) AS order_sect, dbo.GetEndSectorNameByID(dbo.Zakaz.direct_sect_id) AS dir_sect, dbo.GetRemoteCustComment(dbo.Zakaz.REMOTE_SET, 
                         dbo.Zakaz.REMOTE_INCOURSE, dbo.Zakaz.REMOTE_ACCEPTED, dbo.Zakaz.REMOTE_DRNUM) AS RemCustComment, dbo.GetSendSMSCustComment(dbo.Zakaz.DRIVER_SMS_SEND_STATE, 
                         dbo.Zakaz.CLIENT_SMS_SEND_STATE, dbo.Zakaz.SMS_SEND_DRNUM, dbo.Zakaz.SMS_SEND_CLPHONE) AS SendSMSCustComment, dbo.GetOrdTarifNameByTId(dbo.Zakaz.TARIFF_ID) AS tarif_name, 
                         dbo.GetRemoteOrderStatusInfo(dbo.Zakaz.REMOTE_SET, dbo.Zakaz.WAITING) AS remoteOrderStatusInfo, dbo.Zakaz.src, dbo.Zakaz.src_status_code, dbo.Zakaz.src_id, dbo.Voditelj.Marka_avtomobilya, 
                         dbo.Voditelj.Gos_nomernoi_znak, dbo.Voditelj.phone_number, ISNULL(dbo.Voditelj.full_name, '') AS driver_name, dbo.Zakaz.src_on_place, dbo.Zakaz.src_wait_sended, dbo.GetEndSectorNameByID(dbo.Zakaz.detected_sector) 
                         AS det_sect_name, ISNULL(dbo.DISTRICTS.name, '') AS order_district, dbo.Zakaz.bonus_use, dbo.Zakaz.bonus_all, dbo.Zakaz.bonus_add, dbo.Zakaz.driver_rating_diff, dbo.Zakaz.driver_rating_expire_date, 
                         dbo.Zakaz.driver_rating_bonus_code, dbo.Zakaz.adr_detect_lat, dbo.Zakaz.adr_detect_lon, dbo.Zakaz.for_all_sectors, dbo.Zakaz.district_id, dbo.Zakaz.is_coordinates_upd, dbo.Zakaz.detected_sector, 
                         dbo.Zakaz.fail_app_coords_geocode, dbo.Zakaz.is_early, dbo.Zakaz.failed_adr_coords_detect, dbo.Zakaz.luggage, dbo.Zakaz.passengers, dbo.Zakaz.src_state
FROM            dbo.Zakaz LEFT OUTER JOIN
                         dbo.Voditelj ON dbo.Zakaz.vypolnyaetsya_voditelem = dbo.Voditelj.BOLD_ID LEFT OUTER JOIN
                         dbo.DISTRICTS ON dbo.Zakaz.district_id = dbo.DISTRICTS.id

GO

/****** Object:  UserDefinedFunction [dbo].[GetRemoteOrderStatusInfo]    Script Date: 11.11.2018 0:47:18 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER FUNCTION [dbo].[GetRemoteOrderStatusInfo]  ( @REMOTE_SET int, @WAITING int)
RETURNS varchar(255)
AS
BEGIN
   declare @res varchar(255)

   SET @res='.....'
   
   if (@REMOTE_SET<>0) begin
       if (@REMOTE_SET=-1)  begin
        SET @res='Отмена диспетчером для '
       end 

       else if (@REMOTE_SET=-2)  begin
        SET @res='Отмена водителем '
       end 

       else if (@REMOTE_SET=-3)  begin
        SET @res='Отмена принята водителем '
       end

	   else if (@REMOTE_SET=1)  begin
        SET @res='Рассыл одному, можно назначить'
       end 

       else if (@REMOTE_SET = 2)  begin
        SET @res='Рассыл сектору, можно назначить'
       end 

	   else if (@REMOTE_SET = 3)  begin
        SET @res='Рассыл всем, можно назначить'
       end 

	   else if (@REMOTE_SET = 4)  begin
        SET @res='Рассыл завершен, назначьте'
       end 

	   else if (@REMOTE_SET = 5)  begin
        SET @res='Есть претенденты, назначьте'
       end 

	   else if (@REMOTE_SET = 6)  begin
        SET @res='Есть претенденты, назначьте'
       end 

	   else if (@REMOTE_SET = 7)  begin
        SET @res='Дано разрешение'
       end 

	   else if (@REMOTE_SET = 8)  begin
        SET @res='На исполнении'
       end 

	   else if (@REMOTE_SET = 9)  begin
        SET @res='Дано разрешение с руки'
       end 

	   else if (@REMOTE_SET = 10)  begin
        SET @res='На исполнении'
       end 

	   else if (@REMOTE_SET = 11)  begin
        SET @res='Диспетчер отменяет'
       end 

	   else if (@REMOTE_SET = 12)  begin
        SET @res='Вод. подтв. отмену дисп.'
       end 

	   else if (@REMOTE_SET = 13)  begin
        SET @res='Водитель отменяет'
       end 

	   else if (@REMOTE_SET = 14)  begin
        SET @res='Дисп. подтв. отмену вод.'
       end 

	   else if (@REMOTE_SET = 15)  begin
        SET @res='Водитель отчитался'
       end 

	   else if (@REMOTE_SET = 16)  begin
        SET @res='Отчет принят, ждем...'
       end 

	   else if (@REMOTE_SET = 17)  begin
        SET @res='Дано разрешение, ждем'
       end 

	   else if (@REMOTE_SET = 18)  begin
        SET @res='Дано разрешение с руки, ждем'
       end 

	   else if (@REMOTE_SET = 19)  begin
        SET @res='Диспетчер отменил, ждем'
       end 

	   else if (@REMOTE_SET = 20)  begin
        SET @res='Ошибка отчета'
       end 

	   else if (@REMOTE_SET = 21)  begin
        SET @res='Отмена водителем не принята'
       end 

	   else if (@REMOTE_SET = 23)  begin
        SET @res='Просят с руки'
       end 

	   else if (@REMOTE_SET = 24)  begin
        SET @res='Отказано с руки'
       end 

	   else if (@REMOTE_SET = 25)  begin
        SET @res='Просят с руки'
       end 

	   else if (@REMOTE_SET = 26)  begin
        SET @res='Дан отчет'
       end 

	   else if (@REMOTE_SET = 27)  begin
        SET @res='Отчет принят, закрытие...'
       end 

	   else if (@REMOTE_SET = 100)  begin
        SET @res='Заявка закрыта'
       end 

   end

   RETURN(@res)
END
GO

/****** Object:  StoredProcedure [dbo].[AutoAssignDriverByCoords]    Script Date: 22.11.2018 0:52:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[AutoAssignDriverByCoords] 
	-- Add the parameters for the stored procedure here
	(@order_id int, @latStr varchar(50), @lonStr varchar(50), @count int OUT)
AS
BEGIN 
	DECLARE @prev_dr_id int, 
	@on_launch int, @driverNum int,
	@lat decimal(28,10), @lon decimal(28,10),
	@latDr decimal(28,10), @lonDr decimal(28,10),
	@aass_driver_max_radius int, @driver_id int,
	@autoasg_drby_coord_by_rating smallint;

	SELECT @aass_driver_max_radius = aass_driver_max_radius,
	@autoasg_drby_coord_by_rating = autoasg_drby_coord_by_rating
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';

	SET @autoasg_drby_coord_by_rating = ISNULL(@autoasg_drby_coord_by_rating, 0);

	IF @latStr <> '' AND @lonStr <> '' BEGIN

		SET @lat = CAST(@latStr as decimal(28, 10));
		SET @lon = CAST(@lonStr as decimal(28, 10));

		IF @lat > -250 AND @lat < 250 AND @lon > -250 AND @lon < 250 BEGIN

			IF @autoasg_drby_coord_by_rating = 1 BEGIN
				SELECT TOP 1 @latDr = CAST(last_lat as decimal(28, 10)), 
				@lonDr = CAST(last_lon as decimal(28, 10)), @driver_id = BOLD_ID FROM Voditelj
				WHERE last_lat <> '' AND last_lon <> '' AND (ABS(DATEDIFF(minute, last_cctime, GETDATE())) < 10) 
				AND Zanyat_drugim_disp = 0 AND V_rabote = 1 AND Na_pereryve = 0 AND
				dbo.DistanceBetweenTwoCoords(@lat, @lon, CAST(last_lat as decimal(28, 10)), 
				CAST(last_lon as decimal(28, 10))) < @aass_driver_max_radius
				ORDER BY dbo.GetDriverRating(BOLD_ID) DESC;
			END
			ELSE BEGIN
				SELECT TOP 1 @latDr = CAST(last_lat as decimal(28, 10)), 
				@lonDr = CAST(last_lon as decimal(28, 10)), @driver_id = BOLD_ID FROM Voditelj
				WHERE last_lat <> '' AND last_lon <> '' AND (ABS(DATEDIFF(minute, last_cctime, GETDATE())) < 10) 
				AND Zanyat_drugim_disp = 0 AND V_rabote = 1 AND Na_pereryve = 0 
				ORDER BY dbo.DistanceBetweenTwoCoords(@lat, @lon, CAST(last_lat as decimal(28, 10)), 
				CAST(last_lon as decimal(28, 10))) ASC;
			END;

			IF @@ROWCOUNT > 0 AND @latDr > -250 AND @latDr < 250 AND 
				@lonDr > -250 AND @lonDr < 250
			BEGIN
				IF @autoasg_drby_coord_by_rating = 1 BEGIN
					EXEC AssignDriverOnOrder @order_id, @driver_id, 
						-1, @count = @count OUTPUT;
				END
				ELSE IF (dbo.DistanceBetweenTwoCoords(@lat, @lon, @latDr, @lonDr) * 1000) < 
				@aass_driver_max_radius BEGIN
					EXEC AssignDriverOnOrder @order_id, @driver_id, 
						-1, @count = @count OUTPUT;
				END;
			END;

		END;

	END;

END

GO

/****** Object:  StoredProcedure [dbo].[One10SecTask]    Script Date: 22.11.2018 0:53:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[One10SecTask] 
	(@success int OUT)
AS
BEGIN 

	DECLARE @auto_bsector_longorders smallint, @auto_bsectorid_longorders int,
			@auto_bsector_longtime int, @auto_bsector_onlineorders smallint,
			@auto_bsectorid_onlineorders int, @auto_bsector_onlinetime int,
			@auto_neardriver_onlineorders smallint, @auto_neardriver_onlinetime int,
			@auto_bsect_notmanual_ord smallint, @auto_close_client_canceling smallint,
			@auto_close_clcancel_time int, @auto_arh_empty_orders smallint,
			@use_fordbroadcast_priority smallint,
			@auto_for_all_tender smallint,
			@auto_for_all_longtime int,
			@auto_for_all_empty_sector smallint,
			@dont_auto_wtout_adr_appr smallint;
	
	SELECT TOP 1 @auto_bsector_longorders=ISNULL(auto_bsector_longorders,0),
	@auto_bsectorid_longorders=ISNULL(auto_bsectorid_longorders,-1),
	@auto_bsector_longtime=ISNULL(auto_bsector_longtime,0),
	@auto_bsector_onlineorders=ISNULL(auto_bsector_onlineorders,0),
	@auto_bsectorid_onlineorders=ISNULL(auto_bsectorid_onlineorders,-1),
	@auto_bsector_onlinetime=ISNULL(auto_bsector_onlinetime,0),
	@auto_neardriver_onlineorders=ISNULL(auto_neardriver_onlineorders,0), 
	@auto_neardriver_onlinetime=ISNULL(auto_neardriver_onlinetime,0),
	@auto_bsect_notmanual_ord=ISNULL(auto_bsect_notmanual_ord,0),
	@auto_close_client_canceling=ISNULL(auto_close_client_canceling,0),
	@auto_close_clcancel_time=ISNULL(auto_close_clcancel_time,7),
	@auto_arh_empty_orders=ISNULL(auto_arh_empty_orders,0),
	@use_fordbroadcast_priority = use_fordbroadcast_priority,
	@auto_for_all_tender = auto_for_all_tender,
	@auto_for_all_longtime = auto_for_all_longtime,
	@auto_for_all_empty_sector = auto_for_all_empty_sector,
	@dont_auto_wtout_adr_appr = dont_auto_wtout_adr_appr
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';
	
	SET @success=0;
	SET @dont_auto_wtout_adr_appr = ISNULL(@dont_auto_wtout_adr_appr, 0);

	if @auto_bsectorid_longorders<=-1 begin
		SELECT TOP 1 @auto_bsectorid_longorders=BOLD_ID FROM Sektor_raboty;
	end

	if @auto_bsectorid_onlineorders<=-1 begin
		SELECT TOP 1 @auto_bsectorid_onlineorders=BOLD_ID FROM Sektor_raboty;
	end

	BEGIN TRY
		if @auto_for_all_tender = 1 AND @auto_for_all_longtime > 0 BEGIN
			UPDATE dbo.Zakaz 
			SET 
			--konechnyi_sektor_raboty=(CASE WHEN (detected_sector > 0) THEN detected_sector ELSE @auto_bsectorid_longorders END), 
			--SECTOR_ID = (CASE WHEN (detected_sector > 0) THEN detected_sector ELSE @auto_bsectorid_longorders END),
			REMOTE_SET=2, Priority_counter=0, for_all_sectors = 1
			WHERE (Arhivnyi = 0) AND (Zavershyon = 0) AND (REMOTE_SET = 2)  
			and (Predvariteljnyi=0) and (rclient_status=0) AND for_all_sectors <> 1
			AND (ABS(DATEDIFF(SECOND, LAST_STATUS_TIME, GETDATE())) > @auto_for_all_longtime)
			AND Telefon_klienta<>'' AND ((Adres_vyzova_vvodim<>'' AND adr_manual_set=1) OR (@auto_bsect_notmanual_ord=1 AND adr_manual_set=0))
			
			IF @@ROWCOUNT > 0 BEGIN

			IF (@use_fordbroadcast_priority = 1) 
			BEGIN
				DELETE FROM DR_ORD_PRIORITY WHERE order_id IN 
				(SELECT BOLD_ID FROM Zakaz 
					WHERE (Arhivnyi = 0) AND (Zavershyon = 0) AND (REMOTE_SET = 2 OR REMOTE_SET = 3)  
					and (Predvariteljnyi=0) and (rclient_status=0) AND for_all_sectors <> 1
					AND (ABS(DATEDIFF(SECOND, LAST_STATUS_TIME, GETDATE())) > @auto_for_all_longtime)
					AND Telefon_klienta<>'' AND ((Adres_vyzova_vvodim<>'' AND adr_manual_set=1) OR (@auto_bsect_notmanual_ord=1 AND adr_manual_set=0)));
			END;

			EXEC SetOrdersWideBroadcasts 1, '';

			END;

			SET @success=1;
		END;

		if @auto_bsector_longorders>0 and @auto_bsector_longtime>0 and @auto_bsectorid_longorders>-1 begin
			UPDATE dbo.Zakaz SET konechnyi_sektor_raboty=(CASE WHEN (detected_sector > 0) THEN detected_sector ELSE @auto_bsectorid_longorders END), 
			SECTOR_ID = (CASE WHEN (detected_sector > 0) THEN detected_sector ELSE @auto_bsectorid_longorders END), REMOTE_SET=2, Priority_counter=0, 
			for_all_sectors = (CASE WHEN (detected_sector > 0 AND failed_adr_coords_detect <= 0 AND (dbo.GetSectorDrCount(detected_sector) > 0 OR @auto_for_all_empty_sector <> 1)) THEN 0 ELSE 1 END),
			Adres_vyzova_vvodim = CAST(CASE WHEN (adr_manual_set=0 AND @auto_bsect_notmanual_ord=1) THEN 'позвони клиенту' ELSE Adres_vyzova_vvodim END AS varchar(255))
			WHERE (Arhivnyi = 0) AND (Zavershyon = 0) AND (REMOTE_SET = 0) and (Predvariteljnyi=0) and (rclient_status=0)
			AND (ABS(DATEDIFF(SECOND, Nachalo_zakaza_data, GETDATE())) > @auto_bsector_longtime)
			AND Telefon_klienta<>'' AND ((Adres_vyzova_vvodim<>'' AND adr_manual_set=1) OR (@auto_bsect_notmanual_ord=1 AND adr_manual_set=0)) AND
			((adr_manual_set = 1) OR (@dont_auto_wtout_adr_appr=0))
			SET @success=1;
		end
		if @auto_bsector_onlineorders>0 and @auto_bsector_onlinetime>0 and @auto_bsectorid_onlineorders>-1 begin
			UPDATE dbo.Zakaz SET konechnyi_sektor_raboty=(CASE WHEN (detected_sector > 0) THEN detected_sector ELSE @auto_bsectorid_onlineorders END), 
			SECTOR_ID=(CASE WHEN (detected_sector > 0) THEN detected_sector ELSE @auto_bsectorid_onlineorders END), REMOTE_SET=2, Priority_counter=0,
			for_all_sectors = (CASE WHEN (detected_sector > 0 AND failed_adr_coords_detect <= 0 AND (dbo.GetSectorDrCount(detected_sector) > 0 OR @auto_for_all_empty_sector <> 1)) THEN 0 ELSE 1 END)
			WHERE (Arhivnyi = 0) AND (Zavershyon = 0) AND (REMOTE_SET = 0) and (Predvariteljnyi=0) AND rclient_id>-1 and (rclient_status>0)
			AND (ABS(DATEDIFF(SECOND, Nachalo_zakaza_data, GETDATE())) > @auto_bsector_onlinetime)
			AND Telefon_klienta<>'' AND Adres_vyzova_vvodim<>''
			SET @success=1;
		end
		if @auto_close_client_canceling>0 and @auto_close_clcancel_time>0 begin
			UPDATE dbo.Zakaz SET REMOTE_SET=100, Zavershyon=1
			WHERE (Arhivnyi = 0) AND (Zavershyon = 0) AND (REMOTE_SET <= 8) and (Predvariteljnyi=0) AND (rclient_id > -1 OR src > 0) and (rclient_status=-1)
			AND (ABS(DATEDIFF(SECOND, LAST_STATUS_TIME, GETDATE())) > @auto_close_clcancel_time)
			SET @success=1;
		end
		if @auto_arh_empty_orders = 1 begin
			UPDATE dbo.Zakaz SET REMOTE_SET = 100, Zavershyon = 1, Arhivnyi = 1
			WHERE (Arhivnyi = 0) AND (Zavershyon = 0) AND (REMOTE_SET < 8) AND (Predvariteljnyi = 0) 
			AND Pozyvnoi_ustan = 0 AND (ABS(DATEDIFF(HOUR, LAST_STATUS_TIME, GETDATE())) > 5)
			SET @success = 1;
		end
	END TRY
	BEGIN CATCH
		SET @success=0;
	END CATCH;

END

GO




