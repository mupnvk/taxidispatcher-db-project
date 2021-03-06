USE [TD5R1]
GO
/****** Object:  Trigger [dbo].[AFTER_REMOTE_CLOSING]    Script Date: 13.03.2019 19:10:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[AFTER_REMOTE_CLOSING] 
   ON  [dbo].[Zakaz] 
   AFTER UPDATE
AS 
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @db_version int;
	
	SELECT TOP 1 @db_version=ISNULL(db_version,3) 
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
		@newDrNum int, @oldDrNum int, @ord_summ DECIMAL(28,10),
		@dont_reset_time smallint,
		@prise_only_online smallint,
		@rclient_id int,
		@dont_reset_que_early_complete smallint,
		@newEarly smallint;
		
	SET @view_bonus=0;
	SET @view_ab_bonus=0;
	SET @bonus_count=0;
	SET @ab_bonus_count=0;
	SET @use_ab_account=0;
	
	SELECT TOP 1 @view_bonus=ISNULL(view_bonuses,0),
		@view_ab_bonus=ISNULL(view_ab_bonuses,0),
		@use_ab_account = ISNULL(use_ab_account,0),
		@prise_only_online = prise_only_online,
		@dont_reset_que_early_complete = dont_reset_que_early_complete
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
	@oldDrNum = ISNULL(b.REMOTE_DRNUM,0),
	@ord_summ = ISNULL(a.Uslovn_stoim,0), -- Get the Old and New values
	@rclient_id = a.rclient_id,
	@newEarly = a.is_early
	FROM inserted a, deleted b

	SET @newDrId = ISNULL(@newDrId, 0)
	SET @dont_reset_time = ISNULL(@dont_reset_time, 0)

	IF @newDrId > 0 BEGIN
		SELECT @dont_reset_time = dont_reset_time 
		FROM Voditelj 
		WHERE BOLD_ID = @newDrId;
	END

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
	
	DECLARE @dict_adr varchar(255);
	SET @dict_adr='';
	SET @inum_adr='';
	SET @inum_count=0;
	SET @inum_int=0;
	
	IF ((@newPhone<>@oldPhone) OR 
		(@newAdr<>@oldAdr))
	BEGIN
				
		if (@newPhone<>@oldPhone)
		BEGIN
		
			UPDATE Zakaz 
			SET Nachalo_zakaza_data=CURRENT_TIMESTAMP,
				Data_podachi=CURRENT_TIMESTAMP
			FROM Zakaz JOIN inserted i
			ON Zakaz.BOLD_ID=i.BOLD_ID;
			
			IF(NOT (ISNULL(@oldPhone,'')=''))
			BEGIN
				UPDATE Sootvetstvie_parametrov_zakaza
				SET Summarn_chislo_vyzovov=
				Summarn_chislo_vyzovov-1
				WHERE Telefon_klienta=@oldPhone;
			END;
			
			IF(NOT (ISNULL(@newPhone,'')=''))
			BEGIN
			
				DECLARE @bad_count int,
					@bad_adr varchar(255);
					
				SET @bad_adr='';
			
				SELECT @bad_count=COUNT(*)	
				FROM Plohie_klienty 
				WHERE Telefon_klienta=@newPhone;
				
				IF (@bad_count>0)
				BEGIN
				
					SELECT TOP 1 @bad_adr=Adres_vyzova_vvodim	
					FROM Plohie_klienty 
					WHERE Telefon_klienta=@newPhone;
					
					SET @bad_adr=ISNULL(@bad_adr,'');
				
					UPDATE Zakaz 
					SET Nomer_skidki=-1000,
						Adres_vyzova_vvodim=@bad_adr
					FROM Zakaz JOIN inserted i
					ON Zakaz.BOLD_ID=i.BOLD_ID;
				END;
			
				UPDATE Sootvetstvie_parametrov_zakaza
				SET Summarn_chislo_vyzovov=
					Summarn_chislo_vyzovov+1
				WHERE Telefon_klienta=@newPhone;
				
				IF ((@use_ab_account>0) AND 
					(ISNULL(@oldINum,'')=''))
				BEGIN
				
					SELECT @inum_count=COUNT(*)
					FROM Persona
					WHERE Rabochii_telefon=@newPhone AND 
					Elektronnyi_adres='Индивидуальный клиент';
					
					IF (@inum_count>0)
					BEGIN
					
						SELECT TOP 1
						@inum_adr=Ulica,
						@inum_int=Korpus
						FROM Persona
						WHERE Rabochii_telefon=@newPhone AND 
						Elektronnyi_adres='Индивидуальный клиент';
						
						SET @inum_int=ISNULL(@inum_int, 0);
						
						IF (@inum_int>0)
						BEGIN
							if ((NOT ISNULL(@newAdr,'')='') OR 
								(ISNULL(@inum_adr,'')='')) 
								
							BEGIN
								UPDATE Zakaz 
								SET Adres_okonchaniya_zayavki=@inum_int
								FROM Zakaz JOIN inserted i
								ON Zakaz.BOLD_ID=i.BOLD_ID;
							END
							ELSE
							BEGIN
								UPDATE Zakaz 
								SET Adres_vyzova_vvodim=(ISNULL(@bad_adr,'')+@inum_adr),
									Adres_okonchaniya_zayavki=@inum_int
								FROM Zakaz JOIN inserted i
								ON Zakaz.BOLD_ID=i.BOLD_ID;
							END;
						END;
						
					END;
					
				END;
			
				IF ((@inum_count=0) OR (ISNULL(@inum_adr,'')='') 
					OR (@use_ab_account<=0) OR (@inum_int<=0))
				BEGIN
				
					SELECT @ordDictItCount=COUNT(*)
					FROM Sootvetstvie_parametrov_zakaza
					WHERE Telefon_klienta=@newPhone;
						
					IF(@ordDictItCount>0)
					BEGIN
					
						SELECT TOP 1 @bonus_count=Summarn_chislo_vyzovov,
							@dict_adr=Adres_vyzova_vvodim
						FROM Sootvetstvie_parametrov_zakaza
						WHERE Telefon_klienta=@newPhone;
						
						SET @bonus_num=0;
						SET @bonus_count=ISNULL(@bonus_count, 0);
						SET @dict_adr=ISNULL(@dict_adr, '---');
					
						if ((@view_bonus>0) AND 
							(@bonus_count>0) and 
							@newPhone=REPLACE(@newPhone,'Фиктивная','') and
							(@rclient_id > 0 OR @prise_only_online <> 1)) 
						begin
							SELECT @bonus_num=
								dbo.GetDiscountNumOnOrderCount
								(@bonus_count);
						end;
						
						IF ((@bad_count>0) AND (ISNULL(@bonus_num,0)=0))
						BEGIN
							SET @bonus_num=-1000;
						END;
						
						IF (ISNULL(@bonus_num,0)=0)
						BEGIN
							SET @bonus_num=@old_bonus_num;
						END;
						
						if (@view_bonus>0)
						BEGIN
						if ((NOT ISNULL(@newAdr,'')='') OR 
							(ISNULL(@dict_adr,'')=''))
						BEGIN
							UPDATE Zakaz 
							SET Nomer_skidki=@bonus_num
							FROM Zakaz JOIN inserted i
							ON Zakaz.BOLD_ID=i.BOLD_ID;
						END
						ELSE
						BEGIN
							UPDATE Zakaz 
							SET Adres_vyzova_vvodim=(ISNULL(@bad_adr,'')+@dict_adr),
								Nomer_skidki=@bonus_num
							FROM Zakaz JOIN inserted i
							ON Zakaz.BOLD_ID=i.BOLD_ID;
						END;
						END
						ELSE
						BEGIN
							if ((ISNULL(@newAdr,'')='') AND 
							(ISNULL(@inum_adr,'')='') AND 
							((ISNULL(@dict_adr,'')<>'') OR 
							(ISNULL(@bonus_num,0)<>0) ) )
							BEGIN
								IF (@inum_count=0) 
								BEGIN
									UPDATE Zakaz 
									SET Adres_vyzova_vvodim=(ISNULL(@bad_adr,'')+@dict_adr),
									Nomer_skidki=@bonus_num
									FROM Zakaz JOIN inserted i
									ON Zakaz.BOLD_ID=i.BOLD_ID;
								END
								ELSE
								BEGIN
									UPDATE Zakaz 
									SET Adres_vyzova_vvodim=(ISNULL(@bad_adr,'')+@dict_adr)
									FROM Zakaz JOIN inserted i
									ON Zakaz.BOLD_ID=i.BOLD_ID;
								END;
							END;
						END;
						
					END;
							
				END;
			
			
			END;	
				
		end;
		
		if (@newAdr<>@oldAdr)
		BEGIN
		
			if ((ISNULL(@newAdr,'')<>'') and (ISNULL(@oldAdr,'')<>'')
				and (@oldDrId>0))
			EXEC SetDriverStatSyncStatus @oldDrId, 1, 0;
		
			if((ISNULL(@newPhone,'')<>'') AND
				(ISNULL(@newAdr,'')<>''))
			BEGIN
				SELECT @ordDictItCount=COUNT(*)
				FROM Sootvetstvie_parametrov_zakaza
				WHERE Telefon_klienta=@newPhone;
				
				IF(@ordDictItCount=0)
				BEGIN
					EXEC InsertNewOrderDictItem 
						@newPhone, @newAdr,
						1, @ordDictItCount;
				END;
				
			END;
		END;
		
	END;
	
	--IF (@newDrId<>@oldDrId)
	--BEGIN
	--	UPDATE Zakaz 
	--	SET Nachalo_zakaza_data=CURRENT_TIMESTAMP
	--	FROM Zakaz JOIN inserted i
	--	ON Zakaz.BOLD_ID=i.BOLD_ID;
	--END;
	
	IF (@newEndSect<>@oldEndSect)
	BEGIN
	
		SELECT @endSectNum=Nomer_sektora 
		FROM Sektor_raboty
		WHERE BOLD_ID=@newEndSect;
	
		UPDATE Voditelj 
		SET rabotaet_na_sektore=@newEndSect,
			Nomer_posl_sektora = @endSectNum
		WHERE BOLD_ID=@newDrId;
	END;
	
	DECLARE @stat_dr_count int;
	
	IF ((@nNewValue<8) AND (@RSOldValue=8))
	BEGIN
		IF (@oldDrId>0)
		BEGIN
			
			UPDATE Zakaz 
			SET Pozyvnoi_ustan=0, 
			REMOTE_DRNUM=0,
			vypolnyaetsya_voditelem=-1
			FROM Zakaz JOIN inserted i
			ON Zakaz.BOLD_ID=i.BOLD_ID;
			
			EXEC CheckDriverBusy @oldDrId;
			EXEC SetDriverStatSyncStatus @oldDrId, 1, @stat_dr_count;
		END;	
	END;
	
	IF (((@nNewValue=100 OR @nNewValue=8 
		OR @nNewValue=16 OR @nNewValue=0 OR @nNewValue=26) 
		AND @RSOldValue<>@nNewValue) OR 
		(@newDrId<>@oldDrId) OR 
		(@NewComplValue<>@OldComplValue))
	BEGIN
	
		DECLARE @sdr_id int;
	
		IF ((@nNewValue=8) AND 
			(@oldDrId<=0) AND (@RSOldValue IN (9, 18, 23, 25))
			AND (@newDrId=@oldDrId) AND (@newDrNum>0))
		BEGIN
			SELECT TOP 1 @sdr_id=ISNULL(BOLD_ID,-1)
			FROM Voditelj
			WHERE Pozyvnoi=@newDrNum;
			
			IF (@sdr_id>0)
			BEGIN
				UPDATE Zakaz 
				SET Pozyvnoi_ustan=@newDrNum,
				vypolnyaetsya_voditelem=@sdr_id
				FROM Zakaz JOIN inserted i
				ON Zakaz.BOLD_ID=i.BOLD_ID;
				
				EXEC CheckDriverBusy @sdr_id;
				EXEC SetDriverStatSyncStatus @sdr_id, 1, @stat_dr_count;
			END;	
		END;
	
		IF ((@oldDrId>0) AND (@newDrId<>@oldDrId))
		BEGIN
			EXEC CheckDriverBusy @oldDrId;
			EXEC SetDriverStatSyncStatus @oldDrId, 1, @stat_dr_count;
			
			UPDATE Voditelj SET SYNC_STATUS=1
			WHERE BOLD_ID=@oldDrId;
		END;
		
		IF ((@NewComplValue<>@OldComplValue) AND 
		(@NewComplValue=1))
		BEGIN
		
			--SELECT @dr_sect=rabotaet_na_sektore
			--FROM Voditelj
			--WHERE BOLD_ID=@newDrId;
			
			IF ((@nNewValue>0) AND (@nNewValue<100))
			BEGIN
				UPDATE Zakaz 
				SET REMOTE_SET=100
				FROM Zakaz JOIN inserted i
				ON Zakaz.BOLD_ID=i.BOLD_ID;
			END;
			
			UPDATE Zakaz 
			SET Konec_zakaza_data=CURRENT_TIMESTAMP--,
			--	sektor_voditelya=ISNULL(@dr_sect, -1)
			FROM Zakaz JOIN inserted i
			ON Zakaz.BOLD_ID=i.BOLD_ID;
			
			
			if ((@oldDiscount>0) OR (@oldSpec=1) OR (@NewArhValue=1))
			BEGIN
				UPDATE Voditelj 
				SET Vremya_poslednei_zayavki=DATEADD(day,-10,CURRENT_TIMESTAMP),
					DR_SUMM=dbo.GetDrWorkSumm(@newDrId)
				WHERE BOLD_ID=@newDrId;
			END
			ELSE
			BEGIN
				if ((@RSOldValue<=8) and (@ord_summ>0))
				BEGIN
				IF ISNULL(@dont_reset_time, 0) <> 1 AND 
					NOT (@newEarly = 1 AND @dont_reset_que_early_complete = 1) BEGIN
					UPDATE Voditelj 
					SET Vremya_poslednei_zayavki=CURRENT_TIMESTAMP
					WHERE BOLD_ID=@newDrId;
				END

				UPDATE Voditelj 
				SET DR_SUMM=dbo.GetDrWorkSumm(@newDrId)
				WHERE BOLD_ID=@newDrId;

				END
				else
				UPDATE Voditelj 
				SET DR_SUMM=dbo.GetDrWorkSumm(@newDrId)
				WHERE BOLD_ID=@newDrId;
			END;
		
		END;
		
		--EXEC CheckDriverBusy @oldDrId;
		EXEC CheckDriverBusy @newDrId;
		EXEC SetDriverStatSyncStatus @newDrId, 1, @stat_dr_count;
		
		--UPDATE Voditelj SET SYNC_STATUS=1
		--WHERE BOLD_ID=@newDrId;
	END;
	
	IF (@RSOldValue<>@nNewValue)
	BEGIN
		UPDATE Zakaz 
		SET LAST_STATUS_TIME=CURRENT_TIMESTAMP
		FROM Zakaz JOIN inserted i
		ON Zakaz.BOLD_ID=i.BOLD_ID;
	END;
	
	IF ((@NewArhValue=1) AND  
		(@NewArhValue<>@OldArhValue))
	BEGIN
	
		IF (ISNULL(@newPhone,'')<>'') BEGIN
			UPDATE Sootvetstvie_parametrov_zakaza 
			SET Summarn_chislo_vyzovov=Summarn_chislo_vyzovov-1
			WHERE Telefon_klienta=@newPhone;
		END;
	
		IF ((@use_ab_account>0) 
			AND (ISNULL(@newINum,'')<>'')) BEGIN
			UPDATE Persona 
			SET Dom=ISNULL(Dom,0)-1
			WHERE CAST(Korpus AS VARCHAR(255))=@newINum AND 
			Elektronnyi_adres='Индивидуальный клиент';
		END;
		
		IF (@oldDrId>0)
		BEGIN
			UPDATE Voditelj 
			SET Vremya_poslednei_zayavki=DATEADD(day,-10,CURRENT_TIMESTAMP)
			WHERE BOLD_ID=@oldDrId;
		END;
	END;
	
	UPDATE Personal SET EstjVneshnieManip=1, Prover_vodit=1;
	
	END;
	
END