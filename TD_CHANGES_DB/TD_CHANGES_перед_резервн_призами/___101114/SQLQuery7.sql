USE [TD5R1]
GO
/****** Object:  Trigger [dbo].[AFTER_TPLAN_ASSGN]    Script Date: 11/10/2014 11:57:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER TRIGGER [dbo].[AFTER_TPLAN_ASSGN] 
   ON  [dbo].[Zakaz] 
   AFTER UPDATE
AS 
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @db_version INT, @autotarif_by_driver smallint,
		@overtar_by_driver smallint, @autotarif_by_tplan smallint,
		@PR_POLICY_ID int, @TARIF_ID int, @OPTION_ID int, 
		@OPTION_STR varchar(255);
		
	SET @OPTION_STR='';
	SET @TARIF_ID=-1;
	
	SELECT TOP 1 @db_version=ISNULL(db_version,3),
	@autotarif_by_driver=ISNULL(autotarif_by_driver,0),
	@overtar_by_driver=ISNULL(overtar_by_driver,0),
	@autotarif_by_tplan=ISNULL(autotarif_by_tplan,0)
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';
	
	IF((@db_version>=5) AND (@autotarif_by_driver=1))
	BEGIN

	DECLARE @nOldValue int, @newDrId int, @oldDrId int,
		@newPolicyId int, @oldPolicyId int;
		
	SELECT @nOldValue=b.BOLD_ID, 
	@newDrId=a.vypolnyaetsya_voditelem,
	@oldDrId=b.vypolnyaetsya_voditelem,
	@newPolicyId=a.PR_POLICY_ID,
	@oldPolicyId=b.PR_POLICY_ID
	FROM inserted a, deleted b;
	
	IF (@newDrId>0)
	BEGIN
	
	IF ((@autotarif_by_tplan=1) AND (@newPolicyId>0) AND (@newPolicyId<>@oldPolicyId) )
			BEGIN
			
			    SELECT ID FROM ORDER_TARIF 
				WHERE PR_POLICY_ID=@newPolicyId AND IF_DEF=1;
			
				IF @@ROWCOUNT>0
				BEGIN
					SELECT TOP 1 @TARIF_ID=ID FROM ORDER_TARIF 
					WHERE PR_POLICY_ID=@newPolicyId AND IF_DEF=1;
				END;
				
				--UPDATE Zakaz SET TARIFF_ID=1,
				--	OPT_COMB_STR='1' 
				--	WHERE (BOLD_ID=@nOldValue);
				
				SET @TARIF_ID = ISNULL(@TARIF_ID,0);
				
				
				DECLARE @CURSOR cursor, @opt_cnt int;
				SET @opt_cnt=0;
				
				SELECT ID FROM ORDER_OPTION WHERE IF_DEF=1 
				AND PR_POLICY_ID=@newPolicyId;
				IF @@ROWCOUNT>0
				BEGIN
					SET @CURSOR  = CURSOR SCROLL
					FOR SELECT ID FROM ORDER_OPTION WHERE IF_DEF=1 
					AND PR_POLICY_ID=@newPolicyId;
					
					/*Открываем курсор*/
					OPEN @CURSOR
					/*Выбираем первую строку*/
					FETCH NEXT FROM @CURSOR INTO @OPTION_ID;
					/*Выполняем в цикле перебор строк*/
					WHILE @@FETCH_STATUS = 0
					BEGIN
					    if(@opt_cnt>0)
					    BEGIN
							SET @OPTION_STR=@OPTION_STR+',';
					    END
					    SET @OPTION_STR=@OPTION_STR+CAST(@OPTION_ID as varchar(20));
						SET @opt_cnt=@opt_cnt+1;
						FETCH NEXT FROM @CURSOR INTO @OPTION_ID;
					END
					CLOSE @CURSOR
				END
				ELSE
				BEGIN
					SET @OPTION_STR='-';
				END;
				
				SET @OPTION_STR=ISNULL(@OPTION_STR,'-');
				IF @TARIF_ID>0 BEGIN
					UPDATE Zakaz SET TARIFF_ID=@TARIF_ID,
					OPT_COMB_STR=@OPTION_STR 
					WHERE (BOLD_ID=@nOldValue);
				END;
				
			END;
	
	END;

	END;
	
	
	
END



