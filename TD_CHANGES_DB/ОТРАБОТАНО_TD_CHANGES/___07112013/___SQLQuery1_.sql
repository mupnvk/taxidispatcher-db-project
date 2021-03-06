USE [TD5R1]
GO
/****** Object:  StoredProcedure [dbo].[ManualSetOrderRemoteStatus]    Script Date: 11/07/2013 12:25:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[ManualSetOrderRemoteStatus] 
	-- Add the parameters for the stored procedure here
	(@order_id int, @dest_status int, @count int OUT)
AS
BEGIN 

	SET @count = 0;
	
	--ORDER_NO_REM_STATUS
	if (@dest_status=0) begin
    
		UPDATE Zakaz 
		SET Zakaz.REMOTE_SET=@dest_status 
		WHERE Zakaz.BOLD_ID=@order_id;
	
		SET @count=@@ROWCOUNT;
    
    end

	--ORDER_OCCUPED_ALLOW
    if (@dest_status=7) begin
    
		UPDATE Zakaz 
		SET Zakaz.REMOTE_SET=@dest_status 
		WHERE Zakaz.BOLD_ID=@order_id
		AND Zakaz.REMOTE_DRNUM>0 AND 
		(Zakaz.REMOTE_SET<7) AND 
		(Zakaz.REMOTE_SET>0);
	
		SET @count=@@ROWCOUNT;
    
    end
    
    --ORDER_ONHAND_ALLOW
    if (@dest_status=9) begin
    
		--ORDER_ONHAND_ATTEPMT = 23;
		--ORDER_ONHAND_ALLOW_USER_WAIT = 25;
		UPDATE Zakaz 
		SET Zakaz.REMOTE_SET=@dest_status 
		WHERE Zakaz.BOLD_ID=@order_id 
		AND Zakaz.REMOTE_DRNUM>0 AND 
		((Zakaz.REMOTE_SET=23) OR 
		(Zakaz.REMOTE_SET=25));
	
		SET @count=@@ROWCOUNT;
    
    end
    
    --ORDER_BUSY = 8; //???
    if (@dest_status=8) begin
    
		--ORDER_OCCUPED_ALLOW = 7;
		--ORDER_BUSY = 8; //???
		--ORDER_ONHAND_ALLOW = 9;
		--ORDER_ONHAND_ACTIVE = 10;
		--ORDER_ALLOW_ASK_WAIT = 17;
		--ORDER_ONHAND_ALLOW_ASK_WAIT = 18;
		--ORDER_CLOSE_ERROR = 20;
		--ORDER_DRCANCEL_DENY = 21;
		--ORDER_ONHAND_ATTEPMT = 23;
		--ORDER_ONHAND_DENY = 24;
		--ORDER_ONHAND_ALLOW_USER_WAIT = 25;
		UPDATE Zakaz 
		SET Zakaz.REMOTE_SET=@dest_status 
		WHERE Zakaz.BOLD_ID=@order_id AND 
		((Zakaz.REMOTE_SET>0 AND Zakaz.REMOTE_SET<7) OR 
		(Zakaz.REMOTE_SET IN (9,25,18,23)));
	
		SET @count=@@ROWCOUNT;
    
    end;
    
    --ORDER_DISP_CANCEL
    if (@dest_status=11) begin
    
		--ORDER_OCCUPED_ALLOW = 7;
		--ORDER_BUSY = 8; //???
		--ORDER_ONHAND_ALLOW = 9;
		--ORDER_ONHAND_ACTIVE = 10;
		--ORDER_ALLOW_ASK_WAIT = 17;
		--ORDER_ONHAND_ALLOW_ASK_WAIT = 18;
		--ORDER_CLOSE_ERROR = 20;
		--ORDER_DRCANCEL_DENY = 21;
		--ORDER_ONHAND_ATTEPMT = 23;
		--ORDER_ONHAND_DENY = 24;
		--ORDER_ONHAND_ALLOW_USER_WAIT = 25;
		UPDATE Zakaz 
		SET Zakaz.REMOTE_SET=@dest_status 
		WHERE Zakaz.BOLD_ID=@order_id;
	
		SET @count=@@ROWCOUNT;
    
    end;
    
    if (@dest_status=100) begin
    
		--ORDER_DRV_COMPLETE = 15;
		--ORDER_COMLETE_ALLOW = 16;
		--ORDER_COMPLETE_ALLOW_USER_WAIT = 26;
		--ORDER_CLOSE_ASK_WAIT = 27;
		UPDATE Zakaz 
		SET Zakaz.REMOTE_SET=@dest_status,
		Zakaz.Zavershyon=1 
		WHERE Zakaz.BOLD_ID=@order_id;
		-- AND
		--Zakaz.REMOTE_SET IN (15,16,26,27);
	
		SET @count=@@ROWCOUNT;
		
		DECLARE @order_dr_id int;
		
		if(@count>0)
		begin
		
			SELECT @order_dr_id=
			ordr.vypolnyaetsya_voditelem 
			FROM Zakaz ordr
			WHERE ordr.BOLD_ID=@order_id;
			
			--UPDATE Voditelj 
			--SET Vremya_poslednei_zayavki=CURRENT_TIMESTAMP
			--WHERE BOLD_ID=@order_dr_id;
		
			EXEC CheckDriverBusy @order_dr_id;
		end;
    
    end
    
    --ORDER_ONHAND_DENY = 24;
    --ORDER_CLOSE_ERROR = 20;
    --ORDER_DRCANCEL_DENY = 21;
    --ORDER_DRV_CANCEL_DISP_ALLOW = 14;
    --ORDER_CLOSE = 100;
    

	
END



