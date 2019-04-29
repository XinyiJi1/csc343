SET SEARCH_PATH to parlgov;
drop table if exists q3 cascade;


Create table q3(
    countryName VARCHAR(50),
    partyName VARCHAR(100),
    partyFamily VARCHAR(50),
    wonElections INT,
    mostRecentlyWonElectionId INT,
    mostRecentlyWonElectionYear INT
);

drop view if exists voteWin cascade;
Create view voteWin as
Select election_id, max(votes) as win_vote
From election_result
Group by election_id;

drop view if exists partiesWin cascade;
Create view partiesWin as
Select er.party_id as party_id, er.election_id as election_id, p.country_id as country_id, extract(year from e.e_date) as year
From election_result er, voteWin v, party p, election e
Where er.election_id = v.election_id and er.votes = v.win_vote and er.party_id = p.id and er.election_id = e.id;

drop view if exists totalWinsCountry cascade;
Create view totalWinsCountry as
Select country_id, count(*) as total_wins
From partiesWin
Group by country_id;

drop view if exists avgWins cascade;
Create view avgWins as
Select country_id, (cast(total_wins as float)/total_parties) as avg_wins
From totalWinsCountry
    Natural join (
        Select country_id, count(id) as total_parties
        From party
        Group by country_id
    ) as r1;

drop view if exists totalWinsParty cascade;
Create view totalWinsParty as
Select id as party_id, country_id, total_wins
From party
    Natural join (
        Select party_id as id, count(*) as total_wins
        From partiesWin
        Group by party_id
    ) as r2;

drop view if exists wonMoreThan3TimesAvg cascade;
Create view wonMoreThan3TimesAvg as
Select t.party_id as party_id, t.country_id as country_id
From totalWinsParty t, avgWins a
Where t.country_id = a.country_id and t.total_wins > 3 * a.avg_wins;

drop view if exists wonElectionYear cascade;
Create view wonElectionYear as
Select w.party_id as party_id, pw.election_id as election_id, pw.year as year
From wonMoreThan3TimesAvg w, partiesWin pw
Where w.party_id = pw.party_id;

drop view if exists notMostRecentlyWonElection cascade;
Create view notMostRecentlyWonElection as
Select w1.party_id as party_id, w1.election_id as election_id, w1.year as year
From wonElectionYear w1, wonElectionYear w2
Where w1.party_id = w2.party_id and w1.year < w2.year;

drop view if exists mostRecentlyWonElection cascade;
Create view mostRecentlyWonElection as
Select *
From wonElectionYear
Except
Select *
From notMostRecentlyWonElection;

drop view if exists result cascade;
Create view result as
Select x.countryName as countryName, x.partyName as partyName, pf.family as partyFamily,
       x.wonElections as wonElections, m.election_id as mostRecentlyWonElectionId,
       m.year as mostRecentlyWonElectionYear
From (
    Select w.party_id as party_id, c.name as countryName, p.name as partyName, t.total_wins as wonElections
    From wonMoreThan3TimesAvg w, country c, party p, totalWinsParty t
    Where w.country_id = c.id and w.party_id = p.id and w.party_id = t.party_id
) as x
Left join party_family pf on x.party_id = pf.party_id
Join mostRecentlyWonElection m on x.party_id = m.party_id;


insert into q3 (select * from result);
