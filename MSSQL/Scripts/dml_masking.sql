UPDATE [db1].[dbo].[pass]
SET json=JSON_MODIFY(JSON_MODIFY(json,
	     'strict $.passengerFirstName', SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(json, '$.passengerFirstName')), 2), 3, 10)),
		 'strict $.passengerLastName',  SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(json, '$.passengerLastName')),  2), 3, 10));

UPDATE [db1].[dbo].[pass_222]
SET json=JSON_MODIFY(JSON_MODIFY(json,
	     'strict $.passengerFirstName', SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(json, '$.passengerFirstName')), 2), 3, 10)),
		 'strict $.passengerLastName',  SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(json, '$.passengerLastName')),  2), 3, 10));

UPDATE [db1].[dbo].[pass]
SET json=JSON_MODIFY(JSON_MODIFY(json,
	     'strict $.passengerFirstName', SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(json, '$.passengerFirstName')), 2), 3, 10)),
		 'strict $.passengerLastName',  SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(json, '$.passengerLastName')),  2), 3, 10));

UPDATE [db1].[dbo].[pass_222]
SET json=JSON_MODIFY(JSON_MODIFY(json,
	     'strict $.passengerFirstName', SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(json, '$.passengerFirstName')), 2), 3, 10)),
		 'strict $.passengerLastName',  SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(json, '$.passengerLastName')),  2), 3, 10));

UPDATE [db1].[dbo].[pass]
SET json=JSON_MODIFY(json,
	     'strict $.passengerFirstName', SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(json, '$.passengerFirstName')), 2), 3, 10))
WHERE JSON_VALUE(json, '$.passengerFirstName') IS NOT NULL;

UPDATE [db1].[dbo].[pass]
SET json=JSON_MODIFY(json,
	     'strict $.passengerLastName',  SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(json, '$.passengerLastName')),  2), 3, 10))
WHERE JSON_VALUE(json, '$.passengerLastName') IS NOT NULL;

UPDATE [db1].[dbo].[pass_222]
SET json=JSON_MODIFY(json,
	     'strict $.passengerFirstName', SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(json, '$.passengerFirstName')), 2), 3, 10))
WHERE JSON_VALUE(json, '$.passengerFirstName') IS NOT NULL;

UPDATE [db1].[dbo].[pass_222]
SET json=JSON_MODIFY(json,
	     'strict $.passengerLastName',  SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(json, '$.passengerLastName')),  2), 3, 10))
WHERE JSON_VALUE(json, '$.passengerLastName') IS NOT NULL;

UPDATE [db1].[dbo].[pass_aa_222]
SET json=JSON_MODIFY(JSON_MODIFY(json,
	     'strict $.passengerFirstName', SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(json, '$.passengerFirstName')), 2), 3, 10)),
		 'strict $.passengerLastName',  SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(json, '$.passengerLastName')),  2), 3, 10));

UPDATE [db1].[dbo].[pass_aa_223]
SET json=JSON_MODIFY(JSON_MODIFY(json,
	     'strict $.passengerFirstName', SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(json, '$.passengerFirstName')), 2), 3, 10)),
		 'strict $.passengerLastName',  SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(json, '$.passengerLastName')),  2), 3, 10));

-- ================================================
-- Template generated from Template Explorer using:
-- Create Trigger (New Menu).SQL
--
-- Use the Specify Values for Template Parameters
-- command (Ctrl-Shift-M) to fill in the parameter
-- values below.
--
-- See additional Create Trigger templates for more
-- examples of different Trigger statements.
--
-- This block of comments will not be included in
-- the definition of the function.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Masks passenger first and last name in the json column
-- =============================================
CREATE OR ALTER TRIGGER dbo.trg_ai_Passenger
   ON  dbo.Passenger
   AFTER INSERT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @passFirstName VARCHAR(MAX), @passLastName VARCHAR(MAX);

	IF EXISTS (SELECT 1 FROM inserted where JSON_VALUE(json, '$.passengerFirstName') IS NOT NULL)
		SELECT @passFirstName = SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(i.json, '$.passengerFirstName')), 2), 3, 10)
		FROM inserted i

	IF EXISTS (SELECT 1 FROM inserted where JSON_VALUE(json, '$.passengerLastName') IS NOT NULL)
		SELECT @passLastName = SUBSTRING(CONVERT(varchar(MAX), HASHBYTES('MD5',JSON_VALUE(i.json, '$.passengerLastName')), 2), 3, 10)
		FROM inserted i

	IF @passFirstName IS NOT NULL AND @passLastName IS NOT NULL
		UPDATE Passenger SET Passenger.json = JSON_MODIFY(JSON_MODIFY(Passenger.json, 'strict $.passengerFirstName', @passFirstName), '$.passengerLastName', @passLastName)
		FROM inserted i WHERE Passenger.id = i.id

	IF @passFirstName IS NOT NULL and @passLastName IS NULL
		UPDATE Passenger SET Passenger.json = JSON_MODIFY(Passenger.json, 'strict $.passengerFirstName', @passFirstName)
		FROM inserted i WHERE Passenger.id = i.id

	IF @passLastName IS NOT NULL and @passFirstName IS NULL
		UPDATE Passenger SET Passenger.json = JSON_MODIFY(Passenger.json, 'strict $.passengerLastName', @passLastName)
		FROM inserted i WHERE Passenger.id = i.id
END
GO
