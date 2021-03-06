USE [TD5R1]
GO
/****** Object:  Trigger [dbo].[AFTER_ORDER_INUM]    Script Date: 17.02.2019 0:38:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[AFTER_ORDER_INUM] 
   ON  [dbo].[Zakaz] 
   AFTER UPDATE
AS 
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @db_version int, @prize_reserved_limit smallint, 
	@lock_reserv_on_limit smallint;
	
	SELECT TOP 1 @db_version=ISNULL(db_version,3),
	@prize_reserved_limit = prize_reserved_limit,
	@lock_reserv_on_limit = lock_reserv_on_limit 
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';
	
	if(@db_version>=5)
	BEGIN

	DECLARE @nOldValue int, @nNewValue int, 
		@RSOldValue int, @order_count int,
		@NewArhValue int, @NewComplValue int,
		@OldArhValue int, @OldComplValue int,
		@newDrId int, @oldDrId int,
		@oldDiscount int, @oldSpec int,
		@dr_sect int, @newEndSect int, 
		@oldEndSect int, @endSectNum int,
		@oldPhone varchar(255), @newPhone varchar(255),
		@oldAdr varchar(255), @newAdr varchar(255),
		@oldINum varchar(255), @newINum varchar(255),
		@ordDictItCount int,
		@view_bonus int, @view_ab_bonus int,
		@bonus_num int, @bonus_count int, 
		@ab_bonus_count int, @use_ab_account int,
		@old_bonus_num int,
		@newDrNum int, @oldDrNum int,
		@prise_only_online smallint,
		@rclient_id int;
		
	SET @view_bonus=0;
	SET @view_ab_bonus=0;
	SET @bonus_count=0;
	SET @ab_bonus_count=0;
	SET @use_ab_account=0;
	
	SELECT TOP 1 @view_bonus=ISNULL(view_bonuses,0),
		@view_ab_bonus=ISNULL(view_ab_bonuses,0),
		@use_ab_account = ISNULL(use_ab_account,0),
		@prise_only_online = prise_only_online 
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';
		
	SELECT @nOldValue=b.BOLD_ID, 
	@nNewValue=a.REMOTE_SET,
	@RSOldValue=b.REMOTE_SET,
	@NewArhValue=a.Arhivnyi,
	@NewComplValue=a.Zavershyon,
	@OldArhValue=b.Arhivnyi,
	@OldComplValue=b.Zavershyon,
	@newDrId = a.vypolnyaetsya_voditelem,
	@oldDrId = b.vypolnyaetsya_voditelem,
	@oldDiscount = b.Nomer_skidki,
	@oldSpec = b.Slugebnyi,
	@newEndSect = a.konechnyi_sektor_raboty,
	@oldEndSect = b.konechnyi_sektor_raboty,
	@newPhone = a.Telefon_klienta,
	@oldPhone = b.Telefon_klienta,
	@newAdr = a.Adres_vyzova_vvodim,
	@oldAdr = b.Adres_vyzova_vvodim,
	@newINum = a.Adres_okonchaniya_zayavki,
	@oldINum = b.Adres_okonchaniya_zayavki,
	@old_bonus_num = ISNULL(b.Nomer_skidki,0),
	@newDrNum = ISNULL(a.REMOTE_DRNUM,0), 
	@oldDrNum = ISNULL(b.REMOTE_DRNUM,0), -- Get the Old and New values
	@rclient_id = a.rclient_id
	FROM inserted a, deleted b

	IF @nNewValue=100 
	BEGIN
		DELETE FROM ORDER_ACCEPTING WHERE 
		ORDER_ACCEPTING.ORDER_ID=@nOldValue;
	END;
	
	--ORDER_NO_REM_STATUS = 0;ORDER_INDIVID_TAKE = 1;
	--ORDER_SECTOR_PUBLISHING = 2;ORDER_ALL_PUBLISHING = 3;
	--ORDER_PUBLUSHED_WAIT = 4;
	--ORDER_IS_OCCUPED = 5;ORDER_OCCUPED_DENY = 6;
	--ORDER_OCCUPED_ALLOW = 7;ORDER_BUSY = 8;
	--ORDER_ONHAND_ALLOW = 9;ORDER_ONHAND_ACTIVE = 10;
	--ORDER_DISP_CANCEL = 11;ORDER_DISP_CANCEL_DR_INCOURSE = 12;
	--ORDER_DRV_CANCEL = 13;ORDER_DRV_CANCEL_DISP_ALLOW = 14;
	--ORDER_DRV_COMPLETE = 15;ORDER_COMLETE_ALLOW = 16;
	--ORDER_ALLOW_ASK_WAIT = 17;ORDER_ONHAND_ALLOW_ASK_WAIT = 18;
	--ORDER_DISP_CANCEL_ASK_WAIT = 19;ORDER_CLOSE_ERROR = 20;
	--ORDER_DRCANCEL_DENY = 21;ORDER_INWORKING_WAIT = 22;
	--ORDER_ONHAND_ATTEPMT = 23;ORDER_ONHAND_DENY = 24;
	--ORDER_ONHAND_ALLOW_USER_WAIT = 25;ORDER_COMPLETE_ALLOW_USER_WAIT = 26;
	--ORDER_CLOSE_ASK_WAIT = 27;
	--ORDER_ONHAND_ABORT = 28; ORDER_CLOSE = 100;
	
	DECLARE @inum_count int, @inum_int int,
		@inum_phone varchar(255), @inum_adr varchar(255);
	
	IF ((@newINum<>@oldINum) AND (@use_ab_account>0))
	BEGIN
	
		IF (ISNUMERIC(@oldINum)=1)
		BEGIN
			UPDATE Persona 
			SET Dom=Dom-1 
			WHERE Korpus=CAST(@oldINum AS int) AND 
			Elektronnyi_adres='Индивидуальный клиент';
		END;
	
		IF (ISNUMERIC(@newINum)=1)
		BEGIN
			SET @inum_int = CAST(@newINum AS int);
			
			SET @inum_int = ISNULL(@inum_int,-1);
			
			SELECT @inum_count=COUNT(*)
			FROM Persona
			WHERE Korpus=@inum_int AND 
			Elektronnyi_adres='Индивидуальный клиент';
			
			IF (@inum_count>0)
			BEGIN
			
				--возможно использ доп усл в запросе???
				UPDATE Persona 
				SET Dom=Dom+1 
				WHERE Korpus=@inum_int AND 
				Elektronnyi_adres='Индивидуальный клиент' AND 
				(RESERVED_PRESENTS < @prize_reserved_limit OR @lock_reserv_on_limit <= 0 
				OR @prize_reserved_limit <= 0);
			
				SELECT TOP 1
				@inum_phone=Rabochii_telefon,
				@inum_adr=Ulica,
				@ab_bonus_count=Dom
				FROM Persona
				WHERE Korpus=@inum_int AND 
				Elektronnyi_adres='Индивидуальный клиент';
				
				SET @bonus_num=0;
				SET @inum_phone = ISNULL(@inum_phone,'');
				SET @inum_adr = ISNULL(@inum_adr,'');
				SET @ab_bonus_count = ISNULL(@ab_bonus_count,0);
				
				if ((@view_ab_bonus>0) AND 
					(@ab_bonus_count>0) and
					(@rclient_id > 0 OR @prise_only_online <> 1))
				begin
					SELECT @bonus_num=
						dbo.GetDiscountNumOnOrderCount
						(@ab_bonus_count);
				end;
				
				IF (ISNULL(@bonus_num,0)=0)
				BEGIN
					SET @bonus_num=@old_bonus_num;
				END;
				
				if ((ISNULL(@newPhone,'')='') AND 
					NOT (ISNULL(@inum_phone,'')=''))
				BEGIN
					UPDATE Zakaz 
					SET Telefon_klienta=@inum_phone
					FROM Zakaz JOIN inserted i
					ON Zakaz.BOLD_ID=i.BOLD_ID;
				END;
				
				if (NOT ISNULL(@newAdr,'')='')
				BEGIN
					SET @inum_adr=@newAdr;
				END;
				
				if ( ((ISNULL(@newAdr,'')='') AND 
					NOT (ISNULL(@inum_adr,'')='')) OR 
					(@bonus_num>0))
				BEGIN
					UPDATE Zakaz 
					SET Adres_vyzova_vvodim=@inum_adr,
						Nomer_skidki=@bonus_num
					FROM Zakaz JOIN inserted i
					ON Zakaz.BOLD_ID=i.BOLD_ID;
				END;
				
			END;
				
		END;
		
		UPDATE Personal SET EstjVneshnieManip=1, Prover_vodit=1;
		
	END;
	
	
	
	END;
	
END

