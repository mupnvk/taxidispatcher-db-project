USE [TD5R1]
GO
/****** Object:  Trigger [dbo].[AFTER_DRIVER_UPDATE]    Script Date: 08/14/2014 23:50:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER TRIGGER [dbo].[AFTER_DRIVER_UPDATE] 
   ON  [dbo].[Voditelj] 
   AFTER UPDATE
AS 
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @db_version INT, @has_dr_changes int,
		@dont_reset_dr_queue smallint;
	
	SET @has_dr_changes = 0;
	
	SELECT TOP 1 @db_version=ISNULL(db_version,3),
		@dont_reset_dr_queue=ISNULL(dont_reset_dr_queue,0) 
	FROM Objekt_vyborki_otchyotnosti
	WHERE Tip_objekta='for_drivers';
	
	if(@db_version>=5)
	BEGIN
	
	DECLARE @nOldValue int, @nNewValue int,
		@RSOldValue int, @itsRemoteDr int,
		@NewLaunchValue int, @NewComplValue int,
		@OldLaunchValue int, @OldComplValue int,
		@newSectId int, @oldSectId int,
		@newOnLineValue int, @oldOnLineValue int,
		@order_id int, @oldSyncStat int, @newSyncStat INT,
		@oldOrdDate DATETIME, @newOrdDate DATETIME,
		@oldHasAEv smallint, @newHasAEv smallint,
		@aEvCount int, @newRemoteDr int;
		
	
	SELECT @nOldValue=b.BOLD_ID, 
	@nNewValue=a.REMOTE_STATUS,
	@RSOldValue=b.REMOTE_STATUS,
	@NewLaunchValue=a.Na_pereryve,
	@NewComplValue=a.Zanyat_drugim_disp,
	@OldLaunchValue=b.Na_pereryve,
	@OldComplValue=b.Zanyat_drugim_disp,
	@newSectId = a.rabotaet_na_sektore,
	@oldSectId = b.rabotaet_na_sektore,
	@newOnLineValue = a.V_rabote,
	@oldOnLineValue = b.V_rabote,
	@newRemoteDr = a.ITS_REMOTE_CLIENT,
	@itsRemoteDr = b.ITS_REMOTE_CLIENT,
	@oldSyncStat = b.SYNC_STATUS,
	@newSyncStat = a.SYNC_STATUS,
	@oldOrdDate = b.Vremya_poslednei_zayavki,
	@newOrdDate = a.Vremya_poslednei_zayavki,
	@oldHasAEv = b.has_active_events,
	@newHasAEv = a.has_active_events -- Get the Old and New values
	FROM inserted a, deleted b;
	
	IF ((@itsRemoteDr=0) OR (1=1))
	BEGIN
	
		IF (@itsRemoteDr<>@newRemoteDr)
		BEGIN
			SET @has_dr_changes = 1;
		END;
	
		IF ((@OldLaunchValue=1) AND
			(@NewLaunchValue<>@OldLaunchValue))
		BEGIN
			SET @has_dr_changes = 1;
			EXEC InsertFictiveDrOrder @nOldValue, 
			'Снялся с перерыва', -1, @order_id, 1;
		END;
		
		IF ((@OldLaunchValue=0) AND
			(@NewLaunchValue<>@OldLaunchValue))
		BEGIN
			SET @has_dr_changes = 1;
			EXEC InsertFictiveDrOrder @nOldValue, 
			'Взял перерыв', -1, @order_id, 1;
		END;
		
		IF ((@oldOnLineValue=1) AND
			(@newOnLineValue<>@oldOnLineValue))
		BEGIN
			SET @has_dr_changes = 1;
			UPDATE Voditelj 
			SET Na_pereryve=0 
			WHERE BOLD_ID=@nOldValue;
		
			EXEC InsertFictiveDrOrder @nOldValue, 
			'Снятие с линии', -1, @order_id, 1;
		END;
		
		IF ((@oldOnLineValue=0) AND
			(@newOnLineValue<>@oldOnLineValue))
		BEGIN
			SET @has_dr_changes = 1;
			UPDATE Voditelj 
			SET Vremya_poslednei_zayavki=CURRENT_TIMESTAMP,
				Na_pereryve=0 
			WHERE BOLD_ID=@nOldValue;
		
			EXEC InsertFictiveDrOrder @nOldValue, 
			'Постановка на линию', -1, @order_id, 1;
		END;
		
		IF ((@oldOrdDate<>@newOrdDate) OR
			(@NewComplValue<>@OldComplValue))
		BEGIN
			SET @has_dr_changes = 1;
		END;
		
		IF ((@OldComplValue=0) AND
			(@NewComplValue<>@OldComplValue))
		BEGIN
		
			UPDATE Voditelj 
			SET Na_pereryve=0 
			WHERE BOLD_ID=@nOldValue;
		
		END;
		
		IF ((@newSectId<>@oldSectId))
		BEGIN
		
			
			
			if (@dont_reset_dr_queue<>1)
			begin
			
				SET @has_dr_changes = 1;
				EXEC InsertFictiveDrOrder @nOldValue, 
				'Перенос на сектор', -1, @order_id, 1;
			
				UPDATE Voditelj 
				SET Vremya_poslednei_zayavki=CURRENT_TIMESTAMP 
				WHERE BOLD_ID=@nOldValue;
			end
			else
			begin
				SET @has_dr_changes = 1;
				EXEC InsertFictiveDrOrder @nOldValue, 
				'Перенос на сектор', -1, @order_id, -1;
			end
		
		END;
		
		
		
	END;
	
	IF (@newHasAEv<>@oldHasAEv)
	BEGIN
		
		SET @has_dr_changes = 1;
		
	END;
	
	IF ((@nNewValue<>@RSOldValue)) --OR (@newSyncStat<>@oldSyncStat))
	BEGIN
	
		SET @has_dr_changes = 1;
	
		UPDATE Voditelj 
		SET LAST_STATUS_TIME=CURRENT_TIMESTAMP
		WHERE BOLD_ID=@nOldValue;
	END;	
	
	IF (@has_dr_changes>0)
	BEGIN
		UPDATE Personal SET EstjVneshnieManip=1, Prover_vodit=1;
	END;
	
	END;

END

