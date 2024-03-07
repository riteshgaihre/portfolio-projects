-- cleaning data in sql
--lets findout what is inside the housingData
select * from housingData

--Standarize date format
alter table housingData 
add column newSaleDate date

update housingData
set newSaleDate = saleDate::date

alter table housingData
drop column saleDate

alter table housingData
rename column newSaleDate to saleDate

select * from housingData

-- lets fix the null value of propertyAddress
select a.parcelId, a.propertyAddress, b.parcelID,b.propertyAddress, coalesce(a.propertyAddress,b.propertyAddress) from housingData a 
join housingData  b
on a.parcelID = b.parcelID and a.uniqueID <> b.uniqueID

UPDATE housingData AS a
SET propertyAddress = COALESCE(a.propertyAddress, b.propertyAddress)
FROM housingData AS b
WHERE a.parcelID = b.parcelID 
  AND a.uniqueID <> b.uniqueID 
  AND a.propertyAddress IS NULL;
  
select * from housingData
 
 -- lets break propertyAddress into individual columns(address, city, state)
 -- lets first see the propertyAddress
 select propertyAddress from housingData

-- lets use substring to find  only propertysSplitAddress

select substring(propertyAddress from 1 for position(',' in propertyAddress)-1) from housingData

-- lets use substring to find only propertySplitCity
 
 select trim(substring(propertyAddress from position(',' in propertyAddress)+1)) from housingData
 
 -- lets add column for propertySplitAddress and propertysplitCity and update it

alter table housingData
add column propertySplitAddress varchar(255),
add column propertySplitCity varchar(255);

update housingData
set propertySplitAddress =  substring(propertyAddress from 1 for position(',' in propertyAddress)-1),
propertySplitCity = trim(substring(propertyAddress from position(',' in propertyAddress)+1))

-- lets do the same thing for ownerAdress, as break into address,city and state
select ownerAddress from housingData
select substring(ownerAddress from 1 for position(',' in ownerAddress)-1) from housingData
select trim(split_part(ownerAddress, ',',1)) from housingData
select trim(split_part(ownerAddress,',',-1)) from housingData

alter table housingData 
add column ownerSplitAddress varchar(255),
add column ownerSplitCity varchar(255),
add column ownerSplitState varchar(50);

update housingData
set ownerSplitAddress =  substring(ownerAddress from 1 for position(',' in ownerAddress)-1),
ownerSplitCity =  trim(split_part(ownerAddress, ',',2)),
ownerSplitState = trim(split_part(ownerAddress,',',-1))
select * from housingData

-- change Y and N to yes and No in soldasvacant
select soldAsVacant, 
case when soldAsVacant = 'Y' THEN 'Yes'
     when soldAsVacant = 'N' THEN 'No'
	 else soldAsVacant
end
from housingData

update housingData 
set soldAsvacant =
case when soldAsVacant = 'Y' THEN 'Yes'
     when soldAsVacant = 'N' THEN 'No'
	 else soldAsVacant
end

select distinct soldAsVacant from housingData

-- Remove Duplicate
with cte as 
(select *, row_number()over(partition by parcelID, propertyAddress, salePrice, saleDate,legalReference
						   order by uniqueID)as rn from housingData)
				
delete from housingData
where uniqueID IN (select uniqueID from cte
				  where rn>1)
				  
-- delete unused columns

alter table housingData
drop column ownerAddress,
drop column propertyAddress,
drop column taxDistrict

select * from housingData






















