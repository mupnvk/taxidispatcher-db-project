USE [TD5R1]
GO
/****** Object:  StoredProcedure [dbo].[SetDriverDailyPaymStatus]    Script Date: 11/30/2014 12:07:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [dbo].[SetDriverDailyPaymStatus] 
	-- Add the parameters for the stored procedure here
	(@driver_id int, @pstatus int, @count int OUT)
AS
BEGIN 

	DECLARE @pay_status smallint, @day_payment decimal(28,10), 
		@pdate datetime, @dr_num int;
	--PAY_NULL = 0;
	--PAY_REQU = 1;
	--PAY_REQU_SEND = 2;
	--PAY_ALLOW = 3;
	--PAY_DECLINE = 4;

	SET @count=0;
	SET @pay_status = 0;
	SET @day_payment = 0;
	SET @pdate=GETDATE();
	SET @dr_num=0;
	

	SELECT @pay_status=ISNULL(daily_paym_status,0), @day_payment=ISNULL(day_payment,0),
	@pdate=paym_check_date, @dr_num=Pozyvnoi  
	FROM Voditelj WHERE BOLD_ID=@driver_id;
	
	IF @day_payment<=0 BEGIN
		SELECT TOP 1 @day_payment = ISNULL(day_payment,0) 
		FROM Objekt_vyborki_otchyotnosti
		WHERE Tip_objekta='for_drivers';
	END

	IF @pay_status=2 BEGIN
	    UPDATE Voditelj 
			SET Voditelj.daily_paym_status=@pstatus 
			WHERE Voditelj.BOLD_ID=@driver_id;
		IF @pstatus=3 BEGIN
			SET @day_payment = -@day_payment;
			EXEC InsertNewDriverIncome -1, 1, @day_payment, @pdate, @dr_num, @count = @count OUTPUT;
		END
		IF @pstatus=4 BEGIN
		    DECLARE @desc varchar(255);
			set @desc='Водитель '+CAST(@dr_num as varchar(20))+' отказывается оплатить сутки! Вычесть? '+CAST(@pdate as varchar(50));
			EXEC InsertEvent3 7, -1, @driver_id, -1, 
								@pdate, @desc, '',
								'', @dr_num, '',
								'', 1, 'app_server', @day_payment, @count = @count OUTPUT;
		END
	END;
	
END




