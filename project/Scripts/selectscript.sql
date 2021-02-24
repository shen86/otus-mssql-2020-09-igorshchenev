use CarShowroom;
go

select
	e.NumTab,
	e.NameF,
	e.NameI,
	e.NameO,
	s.SexName,
	c.CountryName,
	e.HireDate,
	e.EmailEmp,
	e.PhoneEmp,
	d.DepartmentName,
	j.JobName,
	isnull(e_root.NameF,'') as NameFMgr,
	isnull(e_root.NameI,'') as NameIMgr,
	isnull(e_root.NameO,'') as NameOMgr
from
	Employees e
		join Sexes s on s.ID = e.SexID
		join Countries c on c.ID = e.NationID
		join Appointments a on a.EmpID = e.ID
			join Departments d on d.ID = a.DepID and getdate() between d.StartDate and d.EndDate
			join Jobs j on j.ID = a.JobID and getdate() between j.StartDate and j.EndDate
		left join Employees e_root on e_root.ID = e.ManagerID;



with cte as
(
select id, CategoryID, ServiceName from CarServices
union
select id, CategoryID, CarPartsName from CarParts
union
select id, CategoryID, CarName from Cars
)
select
	e.NameF,
	e.NameI,
	s.NumSal,
	s.DateSal,
	c.NameF,
	c.NameI,
	c.NameO,
	cte.ServiceName,
	sl.Quantity,
	sl.SumTotal
from
	Sales s
		join Employees e on e.ID = s.EmpID
		join Clients c on c.ID = s.ClientID
		join SalesLines sl on sl.SalesID = s.ID
			join cte on cte.ID = sl.PositionID and cte.CategoryID = sl.CategoryID
where
	s.DateSal between '2021-01-01' and '2021-12-31';