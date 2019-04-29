SET SEARCH_PATH to parlgov;
drop table if exists q2 cascade;


Create table q2(
    countryName VARCHAR(50) NOT NULL,
    partyName VARCHAR(100) NOT NULL,
    partyFamily VARCHAR(50) NOT NULL,
    stateMarket REAL CHECK(stateMarket >= 0.0 AND stateMarket <= 10.0),
    primary key (countryName, partyName, partyFamily)
);

drop view if exists cabinetsPast20Years cascade;
Create view cabinetsPast20Years as
Select id, country_id
From cabinet
Where '2019-12-31' >= start_date and start_date >= '1999-1-1';

drop view if exists cabinetParty cascade;
Create view cabinetParty as
Select cabinetsPast20Years.country_id as country_id, cabinetsPast20Years.id as cabinet, cabinet_party.party_id as party
From cabinetsPast20Years, cabinet_party
Where cabinetsPast20Years.id=cabinet_party.cabinet_id;

drop view if exists shouldHaveInclude cascade;
Create view shouldHaveInclude as
Select cabinetsPast20Years.country_id as country_id, cabinetsPast20Years.id as cabinet, party.id as party
From cabinetsPast20Years, party
Where cabinetsPast20Years.country_id=party.country_id;

drop view if exists notInclude cascade;
Create view notInclude as
Select distinct c.country_id,c.party
From ((select * from shouldHaveInclude) EXCEPT (select * from cabinetParty)) c;

drop view if exists whole cascade;
create view whole as
select distinct cabinetsPast20Years.country_id as country_id, party.id as party
from cabinetsPast20Years, party
where cabinetsPast20Years.country_id=party.country_id;

drop view if exists include cascade;
create view include as
(select * from whole) except (select * from notInclude);

drop view if exists result cascade;
Create view result as
Select country.name as countryName, party.name as partyName, party_family.family as partyFamily, party_position.state_market as stateMarket
From include, party, country, party_position, party_family
Where include.party=party.id and include.country_id = country.id and party_family.party_id=party.id and party_position.party_id=party.id;

insert into q2 (select * from result);
