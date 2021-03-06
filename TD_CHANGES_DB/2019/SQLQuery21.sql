USE [TD5R1]
GO
/****** Object:  StoredProcedure [dbo].[CalcBonusSumm]    Script Date: 30.03.2019 0:57:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[GetDailyTaxParams] 
	-- Add the parameters for the stored procedure here
	(@tax_percent decimal(18, 5) OUTPUT, @fix_payment decimal(18, 5) OUTPUT, 
	@no_percent_max_summ decimal(18, 5) OUTPUT, @no_percent_ms_payment decimal(18, 5) OUTPUT)
AS
BEGIN   
	DECLARE @startOfToday datetime, @now datetime;

	SET @startOfToday = DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0);
	SET @now = GETDATE();
	SET @tax_percent = ISNULL(@tax_percent, 0);
	SET @fix_payment = ISNULL(@fix_payment, 0);
	SET @no_percent_max_summ = ISNULL(@no_percent_max_summ, 0);
	SET @no_percent_ms_payment = ISNULL(@no_percent_ms_payment, 0);

	SELECT TOP 1 @tax_percent = tax_percent, @fix_payment = fix_payment,
	@no_percent_max_summ = no_percent_max_summ, @no_percent_ms_payment = no_percent_ms_payment
	FROM DAILY_PARAMS
	WHERE its_tax_percent = 1 AND start_time < end_time AND 
	@now > (@startOfToday + start_time) AND @now < (@startOfToday + end_time);

    return
END

