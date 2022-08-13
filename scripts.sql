--Q1_A: Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims. 
Select npi,
   sum(total_claim_count) as total_claim
From prescription
Group by npi
Order by total_claim desc;
--A: NPI-1881634483, Total 99707

--Q1_B: Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.
Select p1.npi,
    sum(p2.total_claim_count) as total_claim,
    p1.nppes_provider_first_name,
    p1.nppes_provider_last_org_name,
    p1.specialty_description
From prescriber as p1
Join prescription as p2
On p1.npi = p2.npi
Group By p1.npi,
   p1.nppes_provider_first_name,
   p1.nppes_provider_last_org_name,
   p1.specialty_description
Order by total_claim desc;
--A: Total-99707, Bruce Pendley, Family Practice

--Q2_A: Which specialty had the most total number of claims (totaled over all drugs)?
Select distinct p1.specialty_description,
    sum(p2.total_claim_count) as total_claim
From prescriber as p1
left join prescription as p2
on p1.npi = p2.npi
Group by p1.specialty_description
order by total_claim desc;
--A: Family Practice w/ 9752347

--Q2_B:  Which specialty had the most total number of claims for opioids?
Select p1.specialty_description,
    sum(p2.total_claim_count)as total_claim,
    count(d.opioid_drug_flag) as total_opioid
From prescriber as p1
inner join prescription as p2
On p1.npi = p2.npi
inner Join drug as d
on p2.drug_name = d.drug_name
Where d.opioid_drug_flag = 'Y'
Group by p1.specialty_description
Order by total_opioid desc;
--A: Nurse Practitioner w/ 900845

--*************Q2_C: Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
Select p1.specialty_description,
    p1.npi
From prescriber as p1
left join prescription as p2
on p1.npi=p2.npi
Where p2.total_claim_count is null;
    
--**********Q2_D:  Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

--Q3_A:  Which drug (generic_name) had the highest total drug cost?
Select d.generic_name,
    p2.total_drug_cost
From drug as d
Join prescription as p2
On p2.drug_name = d.drug_name
Group by d.generic_name, p2.total_drug_cost
Order by p2.total_drug_cost desc;
--A: Pirfenidone, 2829174.3

--Q3_B: Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.
Select d.generic_name,
    Round(p2.total_drug_cost/total_day_supply, 2) as cost_per_day
From prescription as p2
Left Join drug as d
On p2.drug_name=d.drug_name
group by d.generic_name, cost_per_day
Order by cost_per_day desc;
--A: Immun Glob G(IGG)/GLY/IGA OV50, 7141.11

--Q4_A: For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
Select distinct drug_name,
(Case When opioid_drug_flag ='Y' Then 'opioid'
      When antibiotic_drug_flag ='Y' Then 'antibiotic'
      Else 'neither' End) As drug_type
From drug;
--A: "Run Query"

--Q4_B: Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision. 
Select sum(p.total_drug_cost) as cost, 
    Case When opioid_drug_flag ='Y' Then 'opioid'
    When antibiotic_drug_flag ='Y' Then 'antibiotic'
    Else 'neither' End As drug_type
From drug as d
Inner join prescription as p
On d.drug_name=p.drug_name
Group by drug_type
order by cost desc;
--A: Opioids

--Q5_A:  How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.
Select count(c.cbsa),
    f.state
From cbsa as c
inner join fips_county as f
on c.fipscounty=f.fipscounty
Where f.state = 'TN'
Group By f.state;
--A: 42

--Q5_B:  Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
Select c.cbsa,c.cbsaname,
    sum(p.population) as population
From cbsa as c
Inner Join fips_county
On c.fipscounty=fips_county.fipscounty
Inner join population as p
on fips_county.fipscounty=p.fipscounty
Group by c.cbsaname, c.cbsa
Order by sum(p.population) desc;
--A: Largest= Nashville-Davidson-Murfreesboro-Franklin,TN / 1830410 
--A: Smallest= Morristown, TN / 116352

--********Q5_C:  What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
Select c.cbsa, f.county,
    p.population
From cbsa as c
Inner Join fips_county as f
On c.fipscounty=f.fipscounty
Inner Join population as p
On f.fipscounty=p.fipscounty
Where 
Group by f.county, p.population, c.cbsa
Order By p.population desc;

Select * From cbsa;

--Q6_A: Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
Select drug_name,
    total_claim_count
From prescription
Where total_claim_count >= '3000';
--A: "Run Query"

--Q6_B: For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
Select p.drug_name,
    p.total_claim_count,
    Case When opioid_drug_flag='Y' Then 'opioid'
    Else 'not opioid' End As drug_type
From prescription as p
Join drug as d
On p.drug_name=d.drug_name
Where total_claim_count >= '3000'
Group By p.drug_name, p.total_claim_count, drug_type;
--A: "Run Query"

--6_C: Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
Select p.drug_name,
    p.total_claim_count,
    p2.nppes_provider_first_name as first_name,
    p2.nppes_provider_last_org_name as last_name,
    Case When opioid_drug_flag='Y' Then 'opioid'
    Else 'not opioid' End As drug_type
From prescriber as p2
Inner Join prescription as p
on p2.npi=p.npi
Inner Join drug as d
On p.drug_name=d.drug_name
Where total_claim_count >= '3000'
Group By p.drug_name, p.total_claim_count, drug_type, first_name,last_name;
--A: "Run Query"

--7_A: The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. Hint: The results from all 3 parts will have 637 rows.

-- First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
Select p1.npi,
    d.drug_name
From prescriber as p1
Left Join prescription as p2
On p1.npi=p2.npi
Left Join drug as d
On p2.drug_name=d.drug_name
Where p1.specialty_description = 'Pain Management'
And p1.nppes_provider_city = 'NASHVILLE'
And d.opioid_drug_flag = 'Y'
Group By p1.npi, d.drug_name;
--A: "Run Query"

--7_B:  Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
Select p1.npi,
    d.drug_name,
    p2.total_claim_count
From prescriber as p1
Left Join prescription as p2
On p1.npi=p2.npi
Left Join drug as d
On p2.drug_name=d.drug_name
Where p1.specialty_description = 'Pain Management'
And p1.nppes_provider_city = 'NASHVILLE'
And d.opioid_drug_flag = 'Y'
Group By p1.npi, d.drug_name, total_claim_count;

--7_C:  Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
Select p1.npi,
    d.drug_name,
    coalesce(p2.total_claim_count,0) as total_claim_count
From prescriber as p1
Left Join prescription as p2
On p1.npi=p2.npi
Left Join drug as d
On p2.drug_name=d.drug_name
Where p1.specialty_description = 'Pain Management'
And p1.nppes_provider_city = 'NASHVILLE'
And d.opioid_drug_flag = 'Y'
Group By p1.npi, d.drug_name, total_claim_count;