SET SEARCH_PATH to parlgov;
drop table if exists q6 cascade;

create table q6 (
        countryName VARCHAR(50) primary key,
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

DROP VIEW IF EXISTS countryParty CASCADE;
Create view countryParty as
Select country.name as countryName, party.id as partyId, party_position.left_right as leftRight
From country join party on country.id=party.country_id
                         join party_position on party.id=party_position.party_id;

DROP VIEW IF EXISTS r02 CASCADE;
Create view r02 as
Select countryName, count(partyId) as n02
From countryParty
Where leftRight>=0 and leftRight<2
Group by countryName;

DROP VIEW IF EXISTS r02c CASCADE;
Create view r02c as
(Select name as countryName, 0 as n02
From country
Where name not in (
        Select countryName
        From r02
    )
)
Union (Select * From r02);

DROP VIEW IF EXISTS r24 CASCADE;
Create view r24 as
Select countryName, count(partyId) as n24
From countryParty
Where leftRight>=2 and leftRight<4
Group by countryName;

DROP VIEW IF EXISTS r24c CASCADE;
Create view r24c as
(Select name as countryName, 0 as n24
From country
Where name not in (
        Select countryName
        From r24
    )
)
Union (Select * From r24);

DROP VIEW IF EXISTS r46 CASCADE;
Create view r46 as
Select countryName, count(partyId) as n46
From countryParty
Where leftRight>=4 and leftRight<6
Group by countryName;

DROP VIEW IF EXISTS r46c CASCADE;
Create view r46c as
(Select name as countryName, 0 as n46
From country
Where name not in (
        Select countryName
        From r46
    )
)
Union (Select * From r46);

DROP VIEW IF EXISTS r68 CASCADE;
Create view r68 as
Select countryName, count(partyId) as n68
From countryParty
Where leftRight>=6 and leftRight<8
Group by countryName;

DROP VIEW IF EXISTS r68c CASCADE;
Create view r68c as
(Select name as countryName, 0 as n68
From country
Where name not in (
        Select countryName
        From r68
    )
)
Union (Select * From r68);

DROP VIEW IF EXISTS r810 CASCADE;
Create view r810 as
Select countryName, count(partyId) as n810
From countryParty
Where leftRight>=8 and leftRight<=10
Group by countryName;

DROP VIEW IF EXISTS r810c CASCADE;
Create view r810c as
(Select name as countryName, 0 as n810
From country
Where name not in (
        Select countryName
        From r810
    )
)
Union (Select * From r810);

DROP VIEW IF EXISTS result CASCADE;
Create view result as
Select r02c.countryName as countryName, n02 as r0_2, n24 as r2_4, n46 as r4_6, n68 as r6_8, n810 as r8_10
From r02c,r24c,r46c,r68c,r810c
Where r02c.countryName=r24c.countryName and r02c.countryName=r46c.countryName and r02c.countryName=r68c.countryName and r02c.countryName=r810c.countryName;


Insert into q6 (Select * From result);
