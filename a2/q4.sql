SET SEARCH_PATH to parlgov;

drop table if exists q4 cascade;

create table q4 (
        year int,
        countryName VARCHAR(50) NOT NULL,
        voteRange VARCHAR(20),
        partyName VARCHAR(10) NOT NULL,
    primary key(year,countryName,partyName)
);

--drop view if exists full_e cascade;
--Create view full_e as
--(Select id, country_id, e_date, votes_valid as votes_total
--From election)
--Union
--(Select id, country_id, e_date,
--              (select sum(votes) from election_result where election_result.election_id = election.id) as votes_total
--From election
--Where votes_valid is NULL);

drop view if exists whole cascade;
Create view whole as
Select extract(year from election.e_date) as year, country.name as countryName, cast(election_result.votes as float)/election.votes_valid*100 as vote, party.name_short as partyName
From country,party,election_result,election
Where country.id=party.country_id and party.id=election_result.party_id and election.id=election_result.election_id and election_result.votes is not NULL;

drop view if exists include cascade;
Create view include as
Select year, countryName, vote, partyName
From whole
Where year>=1996 and year<=2016;

drop view if exists includeCountryAverage cascade;
Create view includeCountryAverage as
Select year, countryName, avg(vote) as vote, partyName
From include
Group by(year, countryName, partyName);

drop view if exists r05 cascade;
Create view r05 as
Select year, countryName, '(0-5]'::text as voteRange, partyName
From includeCountryAverage
Where vote>0 and vote<=5;

drop view if exists r510 cascade;
Create view r510 as
Select year,countryName,'(5-10]'::text as voteRange, partyName
From includeCountryAverage
Where vote>5 and vote<=10;

drop view if exists r1020 cascade;
Create view r1020 as
Select year,countryName,'(10-20]'::text as voteRange, partyName
From includeCountryAverage
Where vote>10 and vote<=20;

drop view if exists r2030 cascade;
Create view r2030 as
Select year,countryName,'(20-30]'::text as voteRange, partyName
From includeCountryAverage
Where vote>20 and vote<=30;

drop view if exists r3040 cascade;
Create view r3040 as
Select year,countryName,'(30-40]'::text as voteRange, partyName
From includeCountryAverage
Where vote>30 and vote<=40;

drop view if exists r40 cascade;
Create view r40 as
Select year,countryName,'(40-100]'::text as voteRange, partyName
From includeCountryAverage
Where vote>40;


Insert into q4 ((select * from r05) union (select * from r510) union (select * from r1020) union (select * from r2030) union (select * from r3040) union (select * from r40));
