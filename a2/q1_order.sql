SET SEARCH_PATH to parlgov;

Select *
From q1
Order by countryId desc, alliedPartyId1 desc, alliedPartyId2 desc;
