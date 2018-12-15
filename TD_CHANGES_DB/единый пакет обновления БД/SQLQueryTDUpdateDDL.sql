USE [TD5R1081218SB]
GO
--------------------------------------------------------------------
--------------------------------------------------------------------
-- ������� ������� ��������
--------------------------------------------------------------------
--------------------------------------------------------------------
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF COL_LENGTH('Voditelj','phone_number') IS NULL
BEGIN
	ALTER TABLE dbo.Voditelj 
	ADD [phone_number] [varchar](50) NOT NULL 
	CONSTRAINT [DF_Voditelj_phone_number]  DEFAULT ('');
END

GO

IF COL_LENGTH('Voditelj','auto_bith_year') IS NULL
BEGIN
	ALTER TABLE dbo.Voditelj 
	ADD [auto_bith_year] [int] NOT NULL 
	CONSTRAINT [DF_Voditelj_auto_bith_year]  DEFAULT ((2000));
END

GO

IF COL_LENGTH('Voditelj','auto_material') IS NULL
BEGIN
	ALTER TABLE dbo.Voditelj 
	ADD [auto_material] [varchar](255) NULL;
END

GO

IF COL_LENGTH('Voditelj','dr_cargo_services') IS NULL
BEGIN
	ALTER TABLE dbo.Voditelj 
	ADD [dr_cargo_services] [varchar](1500) NULL;
END

GO

IF COL_LENGTH('Voditelj','addit_cargo_info') IS NULL
BEGIN
	ALTER TABLE dbo.Voditelj 
	ADD [addit_cargo_info] [varchar](3000) NULL;
END

GO

IF COL_LENGTH('Voditelj','is_our') IS NULL
BEGIN
	ALTER TABLE dbo.Voditelj 
	ADD [is_our] [smallint] NOT NULL 
	CONSTRAINT [DF_Voditelj_is_our]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Voditelj','dont_reset_time') IS NULL
BEGIN
	ALTER TABLE dbo.Voditelj 
	ADD [dont_reset_time] [smallint] NOT NULL 
	CONSTRAINT [DF_Voditelj_dont_reset_time]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Voditelj','full_name') IS NULL
BEGIN
	ALTER TABLE dbo.Voditelj 
	ADD [full_name] [varchar](500) NULL;
END

GO

IF COL_LENGTH('Voditelj','cc_updated') IS NULL
BEGIN
	ALTER TABLE dbo.Voditelj 
	ADD [cc_updated] [smallint] NOT NULL 
	CONSTRAINT [DF_Voditelj_cc_updated]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Voditelj','rating') IS NULL
BEGIN
	ALTER TABLE dbo.Voditelj 
	ADD [rating] [decimal](18, 5) NOT NULL 
	CONSTRAINT [DF_Voditelj_rating]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Voditelj','referral_driver_id') IS NULL
BEGIN
	ALTER TABLE dbo.Voditelj 
	ADD [referral_driver_id] [int] NULL;
END

GO

IF COL_LENGTH('Voditelj','referral_set_date') IS NULL
BEGIN
	ALTER TABLE dbo.Voditelj 
	ADD [referral_set_date] [datetime] NOT NULL 
	CONSTRAINT [DF_Voditelj_referral_set_date]  DEFAULT (getdate());
END

GO

IF COL_LENGTH('Voditelj','cc_monitoring_upd') IS NULL
BEGIN
	ALTER TABLE dbo.Voditelj 
	ADD [cc_monitoring_upd] [smallint] NOT NULL 
	CONSTRAINT [DF_Voditelj_cc_monitoring_upd]  DEFAULT ((0));
END

IF COL_LENGTH('Voditelj','daily_payment_expire') IS NULL
BEGIN
	ALTER TABLE dbo.Voditelj 
	ADD [daily_payment_expire] [smallint] NOT NULL CONSTRAINT [DF_Voditelj_daily_payment_expire]  DEFAULT ((0));
END

GO

------------------------------------------------------
------------------------------------------------------
---- ����������� ������� ��������
------------------------------------------------------
------------------------------------------------------
SET ANSI_PADDING OFF
GO

DECLARE @CK_Voditelj_OBJECT_ID int;

SET @CK_Voditelj_OBJECT_ID = OBJECT_ID('dbo.CK_Voditelj');

IF @CK_Voditelj_OBJECT_ID IS NULL
BEGIN
	ALTER TABLE [dbo].[Voditelj]  WITH CHECK 
	ADD  CONSTRAINT [CK_Voditelj] CHECK  (([Pozyvnoi]<(100000)))
END

IF @CK_Voditelj_OBJECT_ID IS NULL
BEGIN
	ALTER TABLE [dbo].[Voditelj] CHECK CONSTRAINT [CK_Voditelj]
END

GO

--------------------------------------------------------------------
--------------------------------------------------------------------
-- ������� ������� ��������
--------------------------------------------------------------------
--------------------------------------------------------------------
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','auto_bsect_notmanual_ord') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [auto_bsect_notmanual_ord] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_auto_bsect_notmanual_ord]  DEFAULT ((1));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','auto_close_client_canceling') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [auto_close_client_canceling] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_auto_close_client_canceling]  DEFAULT ((1));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','auto_close_clcancel_time') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [auto_close_clcancel_time] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_auto_close_clcancel_time]  DEFAULT ((10));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','sip1_robot_active_time') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [sip1_robot_active_time] [datetime] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_sip1_robot_active_time]  DEFAULT (getdate());
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','sip2_robot_active_time') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [sip2_robot_active_time] [datetime] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_sip2_robot_active_time]  DEFAULT (getdate());
END

GO
	
IF COL_LENGTH('Objekt_vyborki_otchyotnosti','robot_active_time_interval') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [robot_active_time_interval] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_robot_active_time_interval]  DEFAULT ((60));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','replace_sms_with_robot') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [replace_sms_with_robot] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_replace_sms_with_robot]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','use_call_robot') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [use_call_robot] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_use_call_robot]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','start_first_song_code') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [start_first_song_code] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_start_first_song_code]  DEFAULT ((1));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','onplace_first_song_code') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [onplace_first_song_code] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_onplace_first_song_code]  DEFAULT ((3));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','web_protected_code') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [web_protected_code] [varchar](50) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_web_protected_code]  DEFAULT ('psdevelop4psw');
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','auto_arh_empty_orders') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [auto_arh_empty_orders] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_auto_arh_empty_orders]  DEFAULT ((1));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','no_percent_before') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [no_percent_before] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_no_percent_before]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','no_percent_before_summ') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [no_percent_before_summ] [decimal](28, 10) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_no_percent_before_summ]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','no_percent_before_payment') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [no_percent_before_payment] [decimal](28, 10) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_no_percent_before_payment]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','use_prize_reserved_limit') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [use_prize_reserved_limit] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_use_prize_reserved_limit]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','prize_reserved_limit') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [prize_reserved_limit] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_prize_reserved_limit]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','prize_reward_summ') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [prize_reward_summ] [decimal](28, 10) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_prize_reward_summ]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','lock_reserv_on_limit') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [lock_reserv_on_limit] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_lock_reserv_on_limit]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','first_trip_bonus') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [first_trip_bonus] [decimal](28, 10) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_first_trip_bonus]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','trip_bonus') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [trip_bonus] [decimal](28, 10) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_trip_bonus]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','percent_bonus_min_summ') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [percent_bonus_min_summ] [decimal](28, 10) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_percent_bonus_min_summ]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','bonus_percent') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [bonus_percent] [decimal](28, 10) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_bonus_percent]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','lock_free_orders_info') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [lock_free_orders_info] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_lock_free_orders_info]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','use_drivers_rating') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [use_drivers_rating] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_use_drivers_rating]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','base_referral_bonus') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [base_referral_bonus] [decimal](18, 5) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_base_referral_bonus]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','base_ref_bonus_interval') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [base_ref_bonus_interval] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_referral_bonus_exp_interval]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','old_order_rating_bonus') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [old_order_rating_bonus] [decimal](18, 5) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_old_order_rating_bonus]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','order_rating_bonus') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [order_rating_bonus] [decimal](18, 5) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_order_rating_bonus]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','peak_one_start') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [peak_one_start] [time](7) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_peak_one_start]  DEFAULT ('00:00');
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','peak_one_lenght') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [peak_one_lenght] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_peak_one_lenght]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','peak_one_bonus') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [peak_one_bonus] [decimal](18, 5) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_peak_one_bonus]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','peak_two_start') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [peak_two_start] [time](7) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_peak_two_start]  DEFAULT ('00:00');
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','peak_two_lenght') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [peak_two_lenght] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_peak_two_lenght]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','peak_two_bonus') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [peak_two_bonus] [decimal](18, 5) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_peak_two_bonus]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','peak_three_start') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [peak_three_start] [time](7) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_peak_three_start]  DEFAULT ('00:00');
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','peak_three_lenght') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [peak_three_lenght] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_peak_three_lenght]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','peak_three_bonus') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [peak_three_bonus] [decimal](18, 5) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_peak_three_bonus]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','base_referral_cashback') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [base_referral_cashback] [decimal](18, 5) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_base_referral_cashback]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','order_late_rating_fine') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [order_late_rating_fine] [decimal](18, 5) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_order_late_fine]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','order_refusal_rating_fine') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [order_refusal_rating_fine] [decimal](18, 5) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_order_refusal_fating_fine]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','order_refusal_balance_fine') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [order_refusal_balance_fine] [decimal](18, 5) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_order_refusal_cash_fine]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','old_order_time') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [old_order_time] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_old_order_time]  DEFAULT ((180));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','order_late_rating_time') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [order_late_rating_time] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_order_late_rating_time]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','order_refusal_rating_time') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [order_refusal_rating_time] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_order_refusal_rating_time]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','order_rating_bonus_time') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [order_rating_bonus_time] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_order_rating_bonus_time]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','old_order_rbonus_time') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [old_order_rbonus_time] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_old_order_rbonus_time]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','peak_one_bonus_time') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [peak_one_bonus_time] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_peak_one_bonus_time]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','peak_two_bonus_time') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [peak_two_bonus_time] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_peak_two_bonus_time]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','peak_three_bonus_time') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [peak_three_bonus_time] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_peak_three_bonus_time]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','referral_rbonus_expire') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [referral_rbonus_expire] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_referral_rbonus_expire]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','rating_pretendent_sorting') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [rating_pretendent_sorting] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_rating_pretendent_sorting]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','auto_detect_sector_by_addr') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [auto_detect_sector_by_addr] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_auto_detect_sector_by_addr]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','geocode_default_prefix') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [geocode_default_prefix] [varchar](255) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_geocode_default_prefix]  DEFAULT ('');
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','auto_detect_driver_sector') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [auto_detect_driver_sector] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_auto_detect_driver_sector]  DEFAULT ((1));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','use_opengts_monitoring') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [use_opengts_monitoring] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_use_opengts_monitoring]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','on_gps_signaling') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [on_gps_signaling] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_on_gps_signaling]  DEFAULT ((1));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','dnts_wait_oth_company') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [dnts_wait_oth_company] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_dnts_wait_oth_company]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','dnts_wait_wtout_company') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [dnts_wait_wtout_company] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_dnts_wait_wtout_company]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','auto_show_wait_dialog') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [auto_show_wait_dialog] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_auto_show_wait_dialog]  DEFAULT ((1));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','wait_dlg_with_sectors') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [wait_dlg_with_sectors] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_wait_dlg_with_sectors]  DEFAULT ((1));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','dispatcher_phone') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [dispatcher_phone] [varchar](50) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_dispatcher_phone]  DEFAULT ('');
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','alart_order_confirm') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [alart_order_confirm] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_alart_order_confirm]  DEFAULT ((1));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','confirm_lineout_on_exit') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [confirm_lineout_on_exit] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_confirm_lineout_on_exit]  DEFAULT ((1));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','hide_other_sect_wait_orders') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [hide_other_sect_wait_orders] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_hide_other_sect_wait_orders]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','dont_wait_in_busy_state') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [dont_wait_in_busy_state] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_dont_wait_in_busy_state]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','show_all_sectwait_manual') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [show_all_sectwait_manual] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_show_all_sectwait_manual]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','taxm_block_wtout_onplace') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [taxm_block_wtout_onplace] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_taxm_block_wtout_onplace]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','reserved_ip') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [reserved_ip] [varchar](50) NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_reserved_ip]  DEFAULT ('');
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','start_free_distance') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [start_free_distance] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_start_free_distance]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','start_free_time') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [start_free_time] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_start_free_time]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','auto_assign_driver_by_coords') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [auto_assign_driver_by_coords] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_auto_assign_driver_by_coords]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','aass_driver_max_radius') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [aass_driver_max_radius] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_aass_driver_max_radius]  DEFAULT ((5000));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','addr_actualization_time') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [addr_actualization_time] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_addr_actualization_time]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','auto_for_all_tender') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [auto_for_all_tender] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_auto_for_all_tender]  DEFAULT ((1));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','auto_for_all_longtime') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [auto_for_all_longtime] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_auto_for_all_longtime]  DEFAULT ((50));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','auto_for_all_empty_sector') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [auto_for_all_empty_sector] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_auto_for_all_empty_sector]  DEFAULT ((1));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','show_region_in_addr') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [show_region_in_addr] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_show_region_in_addr]  DEFAULT ((1));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','dont_auto_wtout_adr_appr') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [dont_auto_wtout_adr_appr] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_dont_auto_wtout_adr_appr]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','auto_assign_wait_orders') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [auto_assign_wait_orders] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_auto_assign_wait_orders]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','early_orders_started_time') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [early_orders_started_time] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_early_orders_started_time]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','autoasg_drby_coord_by_rating') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [autoasg_drby_coord_by_rating] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_autoa_drby_coord_by_rating]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','prev_orders_started_time') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [prev_orders_started_time] [int] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_prev_orders_started_time]  DEFAULT ((30));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','show_phone_in_orders') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [show_phone_in_orders] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_show_phone_in_orders]  DEFAULT ((1));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','set_manual_addr_change') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [set_manual_addr_change] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_set_manual_addr_change]  DEFAULT ((1));
END

GO

IF COL_LENGTH('Objekt_vyborki_otchyotnosti','set_addr_manual_enter') IS NULL
BEGIN
	ALTER TABLE dbo.Objekt_vyborki_otchyotnosti 
	ADD [set_addr_manual_enter] [smallint] NOT NULL 
	CONSTRAINT [DF_Objekt_vyborki_otchyotnosti_set_addr_manual_enter]  DEFAULT ((0));
END

GO

--------------------------------------------------------------------
--------------------------------------------------------------------
-- ������� ������� �������
--------------------------------------------------------------------
--------------------------------------------------------------------

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF COL_LENGTH('Zakaz','adr_manual_set') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [adr_manual_set] [smallint] NOT NULL 
	CONSTRAINT [DF_Zakaz_adr_manual_set]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Zakaz','prev_price') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [prev_price] [decimal](28, 10) NOT NULL 
	CONSTRAINT [DF_Zakaz_prev_price]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Zakaz','cargo_desc') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [cargo_desc] [varchar](5000) NOT NULL 
	CONSTRAINT [DF_Zakaz_cargo_desc]  DEFAULT ('');
END

GO

IF COL_LENGTH('Zakaz','end_adres') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [end_adres] [varchar](1000) NULL;
END

GO

IF COL_LENGTH('Zakaz','client_name') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [client_name] [varchar](500) NULL;
END

GO
	
IF COL_LENGTH('Zakaz','prev_distance') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [prev_distance] [decimal](28, 10) NOT NULL 
	CONSTRAINT [DF_Zakaz_prev_distance]  DEFAULT ((0));
END

GO
	
IF COL_LENGTH('Zakaz','CLIENT_CALL_STATE') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [CLIENT_CALL_STATE] [int] NOT NULL 
	CONSTRAINT [DF_Zakaz_CLIENT_CALL_STATE]  DEFAULT ((0));
END

GO	

IF COL_LENGTH('Zakaz','src') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [src] [int] NOT NULL CONSTRAINT [DF_Zakaz_src]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Zakaz','src_id') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [src_id] [varchar](50) NOT NULL 
	CONSTRAINT [DF_Zakaz_src_id]  DEFAULT ('');
END

GO

IF COL_LENGTH('Zakaz','src_state') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [src_state] [varchar](50) NOT NULL 
	CONSTRAINT [DF_Zakaz_src_state]  DEFAULT ('');
END

GO

IF COL_LENGTH('Zakaz','passengers') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [passengers] [int] NOT NULL 
	CONSTRAINT [DF_Zakaz_passengers]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Zakaz','luggage') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [luggage] [varchar](1000) NULL;
END

GO

IF COL_LENGTH('Zakaz','src_status_code') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [src_status_code] [int] NOT NULL 
	CONSTRAINT [DF_Zakaz_src_status_code]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Zakaz','src_on_place') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [src_on_place] [smallint] NOT NULL 
	CONSTRAINT [DF_Zakaz_src_on_place]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Zakaz','src_wait_sended') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [src_wait_sended] [smallint] NOT NULL 
	CONSTRAINT [DF_Zakaz_src_wait_sended]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Zakaz','bonus_add') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [bonus_add] [decimal](28, 10) NOT NULL 
	CONSTRAINT [DF_Zakaz_bonus_add]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Zakaz','bonus_use') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [bonus_use] [decimal](28, 10) NOT NULL 
	CONSTRAINT [DF_Zakaz_bonus_use]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Zakaz','bonus_all') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [bonus_all] [decimal](28, 10) NOT NULL 
	CONSTRAINT [DF_Zakaz_bonus_all]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Zakaz','driver_rating_diff') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [driver_rating_diff] [decimal](18, 5) NOT NULL 
	CONSTRAINT [DF_Zakaz_rating_change_value]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Zakaz','driver_rating_expire_date') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [driver_rating_expire_date] [datetime] NOT NULL 
	CONSTRAINT [DF_Zakaz_rating_bonus_expire_date]  DEFAULT (getdate());
END

GO

IF COL_LENGTH('Zakaz','driver_rating_bonus_code') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [driver_rating_bonus_code] [varchar](255) NOT NULL 
	CONSTRAINT [DF_Zakaz_driver_rating_bonus_code]  DEFAULT ('');
END

GO

IF COL_LENGTH('Zakaz','adr_detect_lat') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [adr_detect_lat] [varchar](50) NULL;
END

GO

IF COL_LENGTH('Zakaz','adr_detect_lon') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [adr_detect_lon] [varchar](50) NULL;
END

GO

IF COL_LENGTH('Zakaz','failed_adr_coords_detect') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [failed_adr_coords_detect] [smallint] NOT NULL 
	CONSTRAINT [DF_Zakaz_failed_adr_coords_detect]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Zakaz','detected_sector') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [detected_sector] [int] NOT NULL 
	CONSTRAINT [DF_Zakaz_detected_sector]  DEFAULT ((-1));
END

GO

IF COL_LENGTH('Zakaz','is_coordinates_upd') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [is_coordinates_upd] [smallint] NOT NULL 
	CONSTRAINT [DF_Zakaz_is_coordinates_upd]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Zakaz','for_all_sectors') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [for_all_sectors] [smallint] NOT NULL 
	CONSTRAINT [DF_Zakaz_for_all_sectors]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Zakaz','fail_app_coords_geocode') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [fail_app_coords_geocode] [smallint] NOT NULL 
	CONSTRAINT [DF_Zakaz_fail_app_coords_geocode]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Zakaz','district_id') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [district_id] [int] NOT NULL 
	CONSTRAINT [DF_Zakaz_district_id]  DEFAULT ((-1));
END

GO

IF COL_LENGTH('Zakaz','is_early') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [is_early] [smallint] NOT NULL 
	CONSTRAINT [DF_Zakaz_is_early]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Zakaz','is_started_early') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [is_started_early] [smallint] NOT NULL 
	CONSTRAINT [DF_Zakaz_is_started_early]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Zakaz','early_date') IS NULL
BEGIN
	ALTER TABLE dbo.Zakaz 
	ADD [early_date] [datetime] NOT NULL 
	CONSTRAINT [DF_Zakaz_early_date]  DEFAULT (getdate());
END

GO

--------------------------------------------------------------------
--------------------------------------------------------------------
-- ������� ������� ��������
--------------------------------------------------------------------
--------------------------------------------------------------------
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF COL_LENGTH('Sektor_raboty','ford_count') IS NULL
BEGIN
	ALTER TABLE dbo.Sektor_raboty 
	ADD [ford_count] [int] NOT NULL 
	CONSTRAINT [DF_Sektor_raboty_ford_count]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Sektor_raboty','ford_json') IS NULL
BEGIN
	ALTER TABLE dbo.Sektor_raboty 
	ADD [ford_json] [varchar](5000) NOT NULL 
	CONSTRAINT [DF_Sektor_raboty_ford_json]  DEFAULT ('');
END

GO

IF COL_LENGTH('Sektor_raboty','has_fords') IS NULL
BEGIN
	ALTER TABLE dbo.Sektor_raboty 
	ADD [has_fords] [smallint] NOT NULL 
	CONSTRAINT [DF_Sektor_raboty_has_fords]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Sektor_raboty','to_show_fords') IS NULL
BEGIN
	ALTER TABLE dbo.Sektor_raboty 
	ADD [to_show_fords] [smallint] NOT NULL 
	CONSTRAINT [DF_Sektor_raboty_to_show_fords]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Sektor_raboty','company_id') IS NULL
BEGIN
	ALTER TABLE dbo.Sektor_raboty 
	ADD [company_id] [int] NOT NULL 
	CONSTRAINT [DF_Sektor_raboty_company_id]  DEFAULT ((-1));
END

GO	

IF COL_LENGTH('Sektor_raboty','district_id') IS NULL
BEGIN
	ALTER TABLE dbo.Sektor_raboty 
	ADD [district_id] [int] NOT NULL 
	CONSTRAINT [DF_Sektor_raboty_district_id]  DEFAULT ((-1));
END

GO	

IF COL_LENGTH('Sektor_raboty','for_all') IS NULL
BEGIN
	ALTER TABLE dbo.Sektor_raboty 
	ADD [for_all] [smallint] NOT NULL 
	CONSTRAINT [DF_Sektor_raboty_for_all]  DEFAULT ((0));
END

GO	

--------------------------------------------------------------------
--------------------------------------------------------------------
-- ������� ������� �������
--------------------------------------------------------------------
--------------------------------------------------------------------
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF COL_LENGTH('ORDER_TARIF','miss_every_nkm') IS NULL
BEGIN
	ALTER TABLE dbo.ORDER_TARIF 
	ADD [miss_every_nkm] [int] NOT NULL 
	CONSTRAINT [DF_ORDER_TARIF_miss_km_nvalue]  DEFAULT ((0));
END

GO

--------------------------------------------------------------------
--------------------------------------------------------------------
-- ������� ������� ��������� ���������
--------------------------------------------------------------------
--------------------------------------------------------------------
IF OBJECT_ID('dbo.DRIVER_RATING') IS NOT NULL
BEGIN
	DROP TABLE [dbo].[DRIVER_RATING];
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[DRIVER_RATING](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[driver_id] [int] NOT NULL,
	[expire_date] [datetime] NOT NULL CONSTRAINT [DF_DRIVER_RATING_expire]  DEFAULT (getdate()),
	[change_code] [varchar](255) NULL,
	[change_value] [decimal](18, 5) NOT NULL CONSTRAINT [DF_DRIVER_RATING_change_value]  DEFAULT ((0))
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

--------------------------------------------------------------------
--------------------------------------------------------------------
-- ������� ������� ���������
--------------------------------------------------------------------
--------------------------------------------------------------------
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF COL_LENGTH('Personal','drivers_coord_updated') IS NULL
BEGIN
	ALTER TABLE dbo.Personal 
	ADD [drivers_coord_updated] [smallint] NOT NULL 
	CONSTRAINT [DF_Personal_driver_coord_updated]  DEFAULT ((0));
END

GO

IF COL_LENGTH('Personal','orders_coord_updated') IS NULL
BEGIN
	ALTER TABLE dbo.Personal 
	ADD [orders_coord_updated] [smallint] NOT NULL 
	CONSTRAINT [DF_Personal_orders_coord_updated]  DEFAULT ((0));
END

GO

--------------------------------------------------------------------
--------------------------------------------------------------------
-- ������� ������� ����������� �����������
--------------------------------------------------------------------
--------------------------------------------------------------------
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF COL_LENGTH('Sootvetstvie_parametrov_zakaza','bonus_summ') IS NULL
BEGIN
	ALTER TABLE dbo.Sootvetstvie_parametrov_zakaza 
	ADD [bonus_summ] [decimal](28, 10) NOT NULL 
	CONSTRAINT [DF_Sootvetstvie_parametrov_zakaza_bonus_summ]  DEFAULT ((0));
END

GO

--------------------------------------------------------------------
--------------------------------------------------------------------
-- ������� ������� ����� �������
--------------------------------------------------------------------
--------------------------------------------------------------------
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF COL_LENGTH('AREA_LINES','sector_id') IS NULL
BEGIN
	ALTER TABLE dbo.AREA_LINES 
	ADD [sector_id] [int] NOT NULL 
	CONSTRAINT [DF_AREA_LINES_sector_id]  DEFAULT ((-1));
END

GO

