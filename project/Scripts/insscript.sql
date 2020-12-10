USE CarShowroom;
GO

insert into Countries (CountryName, CountryCode)
values ('Austria', 'AUT');
insert into Countries (CountryName, CountryCode)
values ('Australia', 'AUS');
insert into Countries (CountryName, CountryCode)
values ('Argentina', 'ARG');
insert into Countries (CountryName, CountryCode)
values ('Brazil', 'BRA');
insert into Countries (CountryName, CountryCode)
values ('Belgium', 'BEL');
insert into Countries (CountryName, CountryCode)
values ('Czech Republic', 'CZE');
insert into Countries (CountryName, CountryCode)
values ('Canada', 'CAN');

select * from Countries where CountryCode like 'C%';
select CountryName from Countries where CountryCode = 'BRA';



insert into Firm (MakerName, AddressFirm, CountryID)
values ('AAA', 'Adr1', 1);
insert into Firm (MakerName, AddressFirm, CountryID)
values ('BBB', 'Adr2', 7);

select * from firm;