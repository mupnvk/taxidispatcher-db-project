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