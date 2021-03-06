USE [TD5R1]
GO
/****** Object:  UserDefinedFunction [dbo].[GetDrIDByNum]    Script Date: 05/21/2014 12:08:20 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE FUNCTION [dbo].[GetDrUseDynBByNum]  ( @dr_num int)
RETURNS int
AS
BEGIN
   declare @res smallint
   
   SET @res=0
   
   if (@dr_num>0)
   begin
	select @res=use_dyn_balance   
	from Voditelj where 
		Pozyvnoi=@dr_num 
   end

   SET @res=ISNULL(@res,0);

   RETURN(@res)
END