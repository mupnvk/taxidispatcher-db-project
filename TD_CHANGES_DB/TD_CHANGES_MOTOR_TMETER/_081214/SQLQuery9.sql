USE [TD5R1]
GO
/****** Object:  StoredProcedure [dbo].[RealizeReservePresent]    Script Date: 12/08/2014 17:01:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[RealizeReservePresent] 
	-- Add the parameters for the stored procedure here
	(@order_id int,  @count int OUT)
AS
BEGIN 
	DECLARE @ab_num varchar(255), @discount_num int,
		@ab_count int, @person_id int, @reserved_cnt int;
	SET @count = 0;
	SET @ab_count = 0;
	SET @person_id = -1;
	SET @reserved_cnt = 0;

	SELECT @ab_num=Adres_okonchaniya_zayavki,
	@discount_num=Zakaz.Nomer_skidki FROM Zakaz
	WHERE (Zakaz.BOLD_ID=@order_id);
	
	IF (@ab_num<>'')
	BEGIN
		SELECT @ab_count=COUNT(*) FROM Persona
		WHERE Elektronnyi_adres='Индивидуальный клиент' 
		and CAST(Korpus as varchar(255))=@ab_num;
		IF(@ab_count=1)
		BEGIN
			SELECT @person_id=BOLD_ID, @reserved_cnt=RESERVED_PRESENTS FROM Persona
			WHERE Elektronnyi_adres='Индивидуальный клиент' 
			and CAST(Korpus as varchar(255))=@ab_num;
		END;
	END;
	
	IF ((@discount_num=0) and (@person_id>0) and (@reserved_cnt>0))
	BEGIN
	
	UPDATE Persona SET RESERVED_PRESENTS=RESERVED_PRESENTS-1 
	WHERE BOLD_ID=@person_id;
	
	UPDATE Zakaz 
	SET Nomer_skidki=1 
	WHERE BOLD_ID=@order_id;
	
	SET @count=@@ROWCOUNT;
	
	END
	
END



