--Q1_A:
Select npi,
   sum(total_claim_count) as total_claim
From prescription
Group by npi
Order by total_claim desc;
--A: NPI-1881634483, Total 99707

--Q1_B:
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

--Q2_A:
Select p1.specialty_description,
    sum(p2.total_claim_count) as total_claim
From prescriber as p1
join prescription as p2
on p1.npi = p2.npi
Group by p1.specialty_description
order by total_claim desc;
--A: Family Practice w/ 9752347

--Q2_B:
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
--A: Nurse Practitioner w/ 9551

--Q2_C:
Select distinct(p1.specialty_description),
    p1.npi
From prescriber as p1
Where p1.npi not in 
    (Select p2.npi 
    From prescription as p2);
   
   







--Q3_A:
Select d.generic_name,
    sum(p2.total_drug_cost) as total_cost
From drug as d
Join prescription as p2
Group by d.generic_name
order by total_cost;