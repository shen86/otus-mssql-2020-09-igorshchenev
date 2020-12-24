--Запустим конфигурацию
--Чтобы сразу все проходило

ALTER QUEUE [dbo].[InitiatorQueueWWI] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF) 
	, ACTIVATION (   STATUS = ON ,
        PROCEDURE_NAME = Sales.UserConfirmReport, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO
ALTER QUEUE [dbo].[TargetQueueWWI] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF)
	, ACTIVATION (  STATUS = ON ,
        PROCEDURE_NAME = Sales.UserGetCustomer, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO


--И запустим процедуру

EXEC Sales.UserSendCustomer @CustomerId=2, @StartDate='2011-01-01', @EndDate='2014-01-31';



--Посмотрим таблицу

select * from Sales.UserCountInvBtwDate;




--Посмотрим очередь

SELECT conversation_handle, is_initiator, s.name as 'local service', 
far_service, sc.name 'contract', ce.state_desc
FROM sys.conversation_endpoints ce
LEFT JOIN sys.services s
ON ce.service_id = s.service_id
LEFT JOIN sys.service_contracts sc
ON ce.service_contract_id = sc.service_contract_id
ORDER BY conversation_handle;