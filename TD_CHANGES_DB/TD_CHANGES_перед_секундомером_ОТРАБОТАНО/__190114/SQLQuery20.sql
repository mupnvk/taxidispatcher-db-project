USE [TD5R1]
GO
/****** Object:  UserDefinedFunction [dbo].[GetDrDaysIntervalFixedSumm]    Script Date: 01/19/2014 21:23:04 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO




ALTER FUNCTION [dbo].[GetDrDaysIntervalFixedSumm]  (@Drnum int, @start_date datetime, @end_date datetime, @free_days_count int)
RETURNS decimal(28, 10)
AS
BEGIN
   DECLARE @onday_fixed decimal(28, 10),
           @days_count int,
           @dr_count int,
           @res decimal(28, 10), 
           @d_kl int
   
   SET @onday_fixed=0
   SET @days_count=0
   SET @dr_count=0
   SET @res=0
   
   if (@end_date<@start_date)
   begin
	SET @end_date=@start_date
   end
   
   select @dr_count=COUNT(*) from Voditelj
   where Pozyvnoi=@Drnum 
   
   IF @dr_count=0 BEGIN
     SET @res=0
   END
    ELSE
   BEGIN
     
     select @d_kl=D_klass from Voditelj
	 where Pozyvnoi=@Drnum
      
     if @d_kl=0 BEGIN 
		 SET @days_count=DATEDIFF(day, @start_date, @end_date) - 
			@free_days_count;
	    
		 select @onday_fixed=ovo.Kol_posl_dnei from Objekt_vyborki_otchyotnosti ovo
		 where ovo.Tip_objekta='for_drivers';

		 SET @res=@onday_fixed*@days_count;
     end
   END  

   RETURN(@res)
END




