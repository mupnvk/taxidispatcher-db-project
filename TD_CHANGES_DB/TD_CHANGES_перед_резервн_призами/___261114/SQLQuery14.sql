USE [TD5R1]
GO
/****** Object:  StoredProcedure [dbo].[InsertEvent3]    Script Date: 11/26/2014 12:53:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[InsertEvent3] 
	-- Add the parameters for the stored procedure here
	(@etype_id int, @order_id int, @driver_id int, @sector_id int, 
	@edate datetime, @description varchar(2000), @adres varchar(255), 
	@phone varchar(255), @dr_num int, @LATITUDE varchar(20), 
	@LONGITUDE varchar(20), @CONFIRMATED smallint, @uname varchar(255),
	@summ decimal(28,10), @count int OUT)
AS
BEGIN 
	--DECLARE @count int;
	SET @count = 0;
	SET @summ=ISNULL(@summ, 0);
	
	INSERT INTO TD_EVENTS (ETYPE_ID, ORDER_ID, DRIVER_ID, SECTOR_ID, EDATE,
		DESCRIPT, ADRES, PHONE, DR_NUM, LATITUDE, LONGITUDE, CONFIRMATED, UNAME, SUMM) VALUES(@etype_id, @order_id, @driver_id,
		@sector_id, @edate, @description, @adres, @phone, @dr_num, @LATITUDE, @LONGITUDE, @CONFIRMATED,
		ISNULL(@uname,''), @summ);
	
	SET @count=@@ROWCOUNT;
	
	DELETE FROM TD_EVENTS WHERE CLOSED=1;
	UPDATE Voditelj SET has_active_events=1 WHERE BOLD_ID=@driver_id;
	UPDATE Personal SET EstjVneshnieManip=1, Prover_vodit=1;
	
END







