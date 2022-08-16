--Q1_A: Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims. 
Select npi,
   sum(total_claim_count) as total_claim
From prescription
Group by npi
Order by total_claim desc;
--A: NPI-1881634483, TCC-99707

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
From prescription as p2
left join prescriber as p1
on p1.npi = p2.npi
Group by p1.specialty_description
order by total_claim desc;
--A: Family Practice w/ 9752347

--Q2_B:  Which specialty had the most total number of claims for opioids?
Select p1.specialty_description,
    sum(p2.total_claim_count)as total_claim
From prescriber as p1
inner join prescription as p2
On p1.npi = p2.npi
inner Join drug as d
on p2.drug_name = d.drug_name
Where d.opioid_drug_flag = 'Y'
Group by p1.specialty_description
Order by total_claim desc;
--A: Nurse Practitioner w/ 900845

--Q2_C: Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
Select p2.specialty_description,
    Sum(p.total_drug_cost) AS claims
From prescriber as p2
Full Join prescription as p
On p.npi = p2.npi
Group by specialty_description
Having Sum (p.total_claim_count) Is Null;
    
--**********Q2_D:  Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?
 SELECT 
	p2.specialty_description, 
	SUM(p1.total_claim_count) AS claims, 
	COALESCE(ROUND(SUM
				   (CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count END)
					/SUM(p1.total_claim_count)*100,2),0) AS perc_opioid
FROM prescription as p1
LEFT JOIN prescriber as p2
ON p1.npi = p2.npi
LEFT JOIN drug as d
ON p1.drug_name = d.drug_name
GROUP BY p2.specialty_description
ORDER BY perc_opioid DESC;
    
--Q3_A:  Which drug (generic_name) had the highest total drug cost?
Select d.generic_name,
    sum(p2.total_drug_cost) as drug_cost
From prescription as p2
left Join drug as d
On p2.drug_name = d.drug_name
Group by d.generic_name
Order by drug_cost desc;
--A: Insulin Glargine, 104264066.3

--Q3_B: Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.
Select d.generic_name,
    Round(sum(p2.total_drug_cost)/sum(total_day_supply), 2) as cost_per_day
From prescription as p2
Left Join drug as d
On p2.drug_name=d.drug_name
group by d.generic_name
Order by cost_per_day desc;
--A: C1 Esterase Inhibitor / 3495.22

--Q4_A: For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
Select distinct drug_name,
(Case When opioid_drug_flag ='Y' Then 'opioid'
      When antibiotic_drug_flag ='Y' Then 'antibiotic'
      Else 'neither' End) As drug_type
From drug;
--A: "Run Query"

--Q4_B: Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision. 
Select Money(sum(p.total_drug_cost)) as total_cost, 
    Case When opioid_drug_flag ='Y' Then 'opioid'
    When antibiotic_drug_flag ='Y' Then 'antibiotic'
    Else 'neither' End As drug_type
From drug as d
Inner join prescription as p
On d.drug_name=p.drug_name
Group by drug_type
order by total_cost desc;
--A: Opioids

--Q5_A:  How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.
Select count(distinct c.cbsa),
    f.state
From cbsa as c
inner join fips_county as f
on c.fipscounty=f.fipscounty
Where f.state = 'TN'
Group By f.state;
--A: 10

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
Select f.county,
    f.state,
    p.population
From fips_county as f
Inner Join population as p
Using (fipscounty)
Left Join cbsa as c
Using (fipscounty)
Where cbsa is null
Order By population desc;

--Q6_A: Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
Select drug_name,
    total_claim_count
From prescription
Where total_claim_count >= '3000';
--A: "Run Query"

--Q6_B: For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
Select drug_name,
    total_claim_count,
    opioid_drug_flag
From prescription
Left Join drug
Using (drug_name)
Where total_claim_count >= 3000;
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
Select npi,
    drug_name
From prescriber
Cross Join drug
Where specialty_description = 'Pain Management'
    And nppes_provider_city = 'NASHVILLE'
    And opioid_drug_flag = 'Y';

--A: "Run Query"

--7_B:  Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
Select prescriber.npi,
    drug_name,
    total_claim_count
From prescriber
Cross Join drug
Left Join prescription
Using (npi, drug_name)
Where specialty_description = 'Pain Management'
    And nppes_provider_city = 'NASHVILLE'
    And opioid_drug_flag = 'Y'
Order By drug_name;

--7_C:  Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
Select prescriber.npi,
    drug_name,
    coalesce(total_claim_count,0)
From prescriber
Cross Join drug
Left Join prescription
Using (npi, drug_name)
Where specialty_description = 'Pain Management'
    And nppes_provider_city = 'NASHVILLE'
    And opioid_drug_flag = 'Y'
Order By drug_name;