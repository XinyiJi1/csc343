SET SEARCH_PATH to parlgov;

Select *
From q4
Order by year desc, countryName desc, voteRange desc, partyName desc;
