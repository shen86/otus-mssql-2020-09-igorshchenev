USE WideWorldImporters;
GO

--Создаем таблицу

CREATE TABLE Sales.UserCountInvBtwDate
(
ID INT NOT NULL IDENTITY(1, 1) CONSTRAINT PK_UserCountInvBtwDate_ID PRIMARY KEY,
CustomerID INT NOT NULL,
CountInvoice INT NOT NULL,
DateStart DATE NOT NULL,
DateEnd DATE NOT NULL
);



--Создаем процедуру для отправки сообщения

CREATE PROCEDURE Sales.UserSendCustomer
	@CustomerId INT,
	@StartDate DATE,
	@EndDate DATE
AS
BEGIN
	SET NOCOUNT ON;

    --Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER; 
	DECLARE @RequestMessage NVARCHAR(4000); 
	
	BEGIN TRAN 

	--Prepare the Message
	SELECT @RequestMessage = (SELECT DISTINCT CustomerID, @StartDate AS StartDate, @EndDate AS EndDate
							  FROM Sales.Invoices AS Inv
							  WHERE CustomerID = @CustomerId
							  FOR XML AUTO, root('RequestMessage')); 
	
	--Determine the Initiator Service, Target Service and the Contract 
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/InitiatorService]
	TO SERVICE
	'//WWI/SB/TargetService'
	ON CONTRACT
	[//WWI/SB/Contract]
	WITH ENCRYPTION=OFF; 

	--Send the Message
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/RequestMessage]
	(@RequestMessage);
	--SELECT @RequestMessage AS SentRequestMessage;
	COMMIT TRAN 
END;
GO



--Создаем процедуру для получения сообщения

CREATE PROCEDURE Sales.UserGetCustomer
AS
BEGIN
	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER, 
			@Message NVARCHAR(4000),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@CustomerID INT,
			@StartDate DATE,
			@EndDate DATE,
			@xml XML; 
	
	BEGIN TRAN; 

	--Receive message from Initiator
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.TargetQueueWWI; 

	SET @xml = CAST(@Message AS XML);

	SELECT	@CustomerID = R.Iv.value('@CustomerID','INT'),
			@StartDate = R.Iv.value('@StartDate','DATE'),
			@EndDate = R.Iv.value('@EndDate', 'DATE')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);

	IF EXISTS (SELECT * FROM Sales.Invoices WHERE CustomerID = @CustomerID)
	BEGIN
	INSERT INTO Sales.UserCountInvBtwDate (CustomerId, CountInvoice, DateStart, DateEnd)
	VALUES (@CustomerID, (SELECT COUNT(*) FROM Sales.Invoices WHERE CustomerId = @CustomerID AND InvoiceDate BETWEEN @StartDate AND @EndDate), @StartDate, @EndDate);
	END;

	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/RequestMessage'
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;
	END 

	COMMIT TRAN;
END;
GO



--Создаем процедуру подтверждения

CREATE PROCEDURE Sales.UserConfirmReport
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER, 
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.InitiatorQueueWWI; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; 

	COMMIT TRAN; 
END;
GO