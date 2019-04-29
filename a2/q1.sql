SET SEARCH_PATH to parlgov;
drop table if exists q1 cascade;

Create table q1 (
    countryId INT,
    alliedPartyId1 INT,
    alliedPartyId2 INT,
    primary key (alliedPartyId1, alliedPartyId2)
);

DROP VIEW IF EXISTS haveBeenAllies CASCADE;
Create view haveBeenAllies as
Select e1.election_id as election_id, e1.party_id as pid1, e2.party_id as pid2
From election_result e1, election_result e2
Where e1.party_id < e2.party_id and e1.election_id = e2.election_id and (e1.alliance_id = e2.alliance_id or
    (e1.alliance_id is NULL and e2.alliance_id = e1.id) or (e2.alliance_id is NULL and e1.alliance_id = e2.id));

DROP VIEW IF EXISTS numOfElectionsInCountry CASCADE;
Create view numOfElectionsInCountry as
Select country_id, count(id) as num_election
From election
Group by country_id;

DROP VIEW IF EXISTS alliesInCountry CASCADE;
Create view alliesInCountry as
Select h.pid1 as pid1, h.pid2 as pid2, e.country_id as country_id, count(*) as num
From haveBeenAllies h, election e
Where h.election_id = e.id
Group by (h.pid1, h.pid2, e.country_id);

DROP VIEW IF EXISTS result CASCADE;
Create view result as
Select a.country_id as countryId, a.pid1 as alliedPartyId1, a.pid2 as alliedPartyId2
From alliesInCountry a join numOfElectionsInCountry n on a.country_id = n.country_id
Where (CAST(a.num as FLOAT)/n.num_election >= 0.3);


insert into q1 (Select * From result);
