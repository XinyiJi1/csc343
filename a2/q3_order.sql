SET SEARCH_PATH to parlgov;

Select *
From q3
Order by countryName, wonElections, partyName desc;
