USE [TD5R1]
GO
/****** Object:  UserDefinedFunction [dbo].[GetRemoteOrderStatusInfo]    Script Date: 10.11.2018 11:01:12 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER FUNCTION [dbo].[GetRemoteOrderStatusInfo]  ( @REMOTE_SET int, @WAITING int)
RETURNS varchar(255)
AS
BEGIN
   declare @res varchar(255)

   SET @res='.....'
   
   if (@REMOTE_SET<>0) begin
       if (@REMOTE_SET=-1)  begin
        SET @res='Отмена диспетчером для '
       end 

       else if (@REMOTE_SET=-2)  begin
        SET @res='Отмена водителем '
       end 

       else if (@REMOTE_SET=-3)  begin
        SET @res='Отмена принята водителем '
       end

	   else if (@REMOTE_SET=1)  begin
        SET @res='Рассыл одному, можно назначить'
       end 

       else if (@REMOTE_SET = 2)  begin
        SET @res='Рассыл сектору, можно назначить'
       end 

	   else if (@REMOTE_SET = 3)  begin
        SET @res='Рассыл всем, можно назначить'
       end 

	   else if (@REMOTE_SET = 4)  begin
        SET @res='Рассыл завершен, назначьте'
       end 

	   else if (@REMOTE_SET = 5)  begin
        SET @res='Есть претенденты, назначьте'
       end 

	   else if (@REMOTE_SET = 6)  begin
        SET @res='Есть претенденты, назначьте'
       end 

	   else if (@REMOTE_SET = 7)  begin
        SET @res='Дано разрешение'
       end 

	   else if (@REMOTE_SET = 8)  begin
        SET @res='На исполнении'
       end 

	   else if (@REMOTE_SET = 9)  begin
        SET @res='Дано разрешение с руки'
       end 

	   else if (@REMOTE_SET = 10)  begin
        SET @res='На исполнении'
       end 

	   else if (@REMOTE_SET = 11)  begin
        SET @res='Диспетчер отменяет'
       end 

	   else if (@REMOTE_SET = 12)  begin
        SET @res='Вод. подтв. отмену дисп.'
       end 

	   else if (@REMOTE_SET = 13)  begin
        SET @res='Водитель отменяет'
       end 

	   else if (@REMOTE_SET = 14)  begin
        SET @res='Дисп. подтв. отмену вод.'
       end 

	   else if (@REMOTE_SET = 15)  begin
        SET @res='Водитель отчитался'
       end 

	   else if (@REMOTE_SET = 16)  begin
        SET @res='Отчет принят, ждем...'
       end 

	   else if (@REMOTE_SET = 17)  begin
        SET @res='Дано разрешение, ждем'
       end 

	   else if (@REMOTE_SET = 18)  begin
        SET @res='Дано разрешение с руки, ждем'
       end 

	   else if (@REMOTE_SET = 19)  begin
        SET @res='Диспетчер отменил, ждем'
       end 

	   else if (@REMOTE_SET = 20)  begin
        SET @res='Ошибка отчета'
       end 

	   else if (@REMOTE_SET = 21)  begin
        SET @res='Отмена водителем не принята'
       end 

	   else if (@REMOTE_SET = 23)  begin
        SET @res='Просят с руки'
       end 

	   else if (@REMOTE_SET = 24)  begin
        SET @res='Отказано с руки'
       end 

	   else if (@REMOTE_SET = 25)  begin
        SET @res='Просят с руки'
       end 

	   else if (@REMOTE_SET = 26)  begin
        SET @res='Дан отчет'
       end 

	   else if (@REMOTE_SET = 27)  begin
        SET @res='Отчет принят, закрытие...'
       end 

	   else if (@REMOTE_SET = 100)  begin
        SET @res='Заявка закрыта'
       end 

   end

   RETURN(@res)
END