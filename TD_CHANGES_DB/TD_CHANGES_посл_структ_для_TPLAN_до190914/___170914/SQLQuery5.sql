USE [TD5R1]
GO
/****** Object:  Trigger [dbo].[AFTER_ORDER_TOPTS]    Script Date: 09/17/2014 23:51:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[AFTER_ORDER_TOPTS] 
   ON  [dbo].[Zakaz] 
   AFTER UPDATE
AS 
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @db_version INT, @taropt_accounting int;
	
	SELECT TOP 1 @db_version=ISNULL(db_version,3),
	@taropt_accounting=ISNULL(taropt_accounting,0)
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';
	
	IF((@db_version>=5) AND (@taropt_accounting>0))
	BEGIN

	DECLARE @nOldValue int, @newTarValue int, 
		@oldTarValue int, @oldOptsValue varchar(255),
		@newOptsValue varchar(255), @newDrId int,
		@oldTarifPlanId int, @newTarifPlanId int;
		
		
	SELECT @nOldValue=b.BOLD_ID, 
	@newTarValue=a.TARIFF_ID,
	@oldTarValue=b.TARIFF_ID,
	@oldOptsValue=b.OPT_COMB_STR,
	@newOptsValue=a.OPT_COMB_STR,
	@oldTarifPlanId=b.PR_POLICY_ID,
	@newTarifPlanId=a.PR_POLICY_ID,
	@newDrId=a.vypolnyaetsya_voditelem
	FROM inserted a, deleted b

	IF (((@newTarValue<>@oldTarValue) OR (@newOptsValue<>@oldOptsValue)
			OR (@newTarifPlanId<>@oldTarifPlanId)) 
		AND (@newDrId>0))
	BEGIN
		EXEC SetDriverStatSyncStatus @newDrId, 1, 0;
	END;

	END;
	
	
	
END
