USE [TD5R1]
GO
/****** Object:  StoredProcedure [dbo].[One10SecTask]    Script Date: 02.02.2019 9:32:35 ******/
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
			@dont_auto_wtout_adr_appr smallint,
			@early_orders_started_time smallint;
	
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
	@dont_auto_wtout_adr_appr = dont_auto_wtout_adr_appr,
	@early_orders_started_time = early_orders_started_time
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
		UPDATE dbo.Zakaz 
			SET is_started_early = 1
			WHERE is_early = 1 AND is_started_early = 0 AND 
			Arhivnyi = 0 AND Zavershyon = 0  
			AND ((ABS(DATEDIFF(MINUTE, early_date, GETDATE())) < @early_orders_started_time)
			OR early_date < GETDATE()) AND Telefon_klienta<>'' AND Adres_vyzova_vvodim<>''; 

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
			UPDATE dbo.Zakaz SET REMOTE_SET = 100, Zavershyon = 1, Arhivnyi = 1, arhive_sms_state = 1
			WHERE (Arhivnyi = 0) AND (Zavershyon = 0) AND (REMOTE_SET < 8) AND (Predvariteljnyi = 0) 
			AND Pozyvnoi_ustan = 0 AND (ABS(DATEDIFF(HOUR, LAST_STATUS_TIME, GETDATE())) > 5)
			SET @success = 1;
		end
	END TRY
	BEGIN CATCH
		SET @success=0;
	END CATCH;

END
