USE [TD5R1]
GO
/****** Object:  Trigger [dbo].[AFTER_DRASS_TPLAN]    Script Date: 07/14/2015 01:22:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER TRIGGER [dbo].[AFTER_DRASS_TPLAN] 
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
	
	IF(@newDrId<>@oldDrId)
	BEGIN
	
		SET @PR_POLICY_ID=ISNULL(dbo.GetDrTariffPlanId(@newDrId),0);
	
		IF (@PR_POLICY_ID>0 AND @PR_POLICY_ID<>@newPolicyId) BEGIN
			UPDATE Zakaz SET PR_POLICY_ID=@PR_POLICY_ID,
			TARIFF_ID=-1, OPT_COMB_STR='-' 
			WHERE ((PR_POLICY_ID<=0) OR (@overtar_by_driver=1)) 
			AND (BOLD_ID=@nOldValue);
			
		END;
	
	END;
	
	END;

	END;
	
	
	
END



