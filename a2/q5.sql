SET SEARCH_PATH to parlgov;
drop table if exists q5 cascade;

create table q5 (
        countryName VARCHAR(50),
        year int,
        participationRatio real,
        primary key(countryName, year)
);

drop view if exists countryInclude cascade;
Create view countryInclude as
Select country.name
From country join election on country.id=election.country_id
Where extract(year from election.e_date)>=2001 and extract(year from election.e_date)<=2016
Group by country.name;

drop view if exists countryElectionDup cascade;
Create view countryElectionDup as
Select country.name as countryName, extract(year from election.e_date) as year,
       (CAST(election.votes_cast as FLOAT)/election.electorate) as participationRatio
From country join election on country.id=election.country_id
Where country.name in (select * from countryInclude) and election.votes_cast is not NULL and
      extract(year from election.e_date)>=2001 and extract(year from election.e_date)<=2016;

drop view if exists countryElection cascade;
Create view countryElection as
Select countryName, year, avg(participationRatio) as participationRatio
From countryElectionDup
Group by(countryName, year);

drop view if exists countryExclude cascade;
Create view countryExclude as
Select c1.countryName as countryName
From countryElection c1 , countryElection c2
Where c1.countryName=c2.countryName and c1.year<c2.year and c1.participationRatio>c2.participationRatio;

drop view if exists Result cascade;
Create view Result as
Select countryName,year,participationRatio
From countryElection
Where countryName not in (select * from countryExclude);

Insert into q5 (select * from Result);
