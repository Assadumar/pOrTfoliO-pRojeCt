--Cleaning Data in SQL

Select *
from Portfolio..Nashville

Select SaleDateConverted, Convert(date,SaleDate)
from Portfolio..Nashville

update Nashville
Set SaleDate=Convert(date,SaleDate)

ALter Table Nashville
add SaleDateConverted Date;

Update Nashville
Set SaleDateConverted = CONVERt(Date, SaleDate)



--Populate Property address Data

Select Propertyaddress
From Portfolio..Nashville

where PropertyAddress is null


Select *
From Portfolio..Nashville
--Order by ParcelID
where propertyaddress is null


--there is some similar ParcelID which have some null address, LETs Identify them
Select a.ParcelID, a.PropertyAddress, b.parcelid, b.propertyaddress
from Portfolio..Nashville a
join Portfolio..Nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

-- Lets make null propertyaddress to valued address from similar ParcelID

Select a.ParcelID, a.PropertyAddress, b.parcelid, b.propertyaddress, isnull(a.PropertyAddress,b.propertyaddress)
from Portfolio..Nashville a
join Portfolio..Nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--Lets UPDATE the changes

Update a
set Propertyaddress =  isnull(a.PropertyAddress,b.propertyaddress)
from Portfolio..Nashville a
join Portfolio..Nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]

--Lets Check the Update


Select a.ParcelID, a.PropertyAddress, b.parcelid, b.propertyaddress
from Portfolio..Nashville a
join Portfolio..Nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out Address into individual Column (Address, City, States)

Select
Substring(Propertyaddress, 1, charindex(',', propertyaddress)) as address

from Portfolio..Nashville

--hint-- whereas 1 shows the position and ',' worked as delimiter

--if we don't want a "," at the end then we should use the -1, which means we don't want the delimiter to be shown

Select
Substring(Propertyaddress, 1, charindex(',', propertyaddress)-1) as address
from Portfolio..Nashville

--+1 means we don't want the , before address

Select
Substring(Propertyaddress, 1, charindex(',', propertyaddress)-1) as address,
Substring(Propertyaddress, charindex(',', propertyaddress)+1, LEN(Propertyaddress)) as address
from Portfolio..Nashville



--Lets update the changes by adding new columns of splited addresses
Alter Table portfolio..Nashville
add Propertysplitaddress nvarchar(255);

update portfolio..Nashville
set Propertysplitaddress = Substring(Propertyaddress, 1, charindex(',', propertyaddress)-1)

Alter Table portfolio..Nashville
add PropertysplitCity nvarchar(255);

update portfolio..Nashville
set PropertysplitCity = Substring(Propertyaddress, charindex(',', propertyaddress)+1, LEN(Propertyaddress))

--Lets see the result

Select * 
from portfolio..Nashville

-- There is an another easy method to split "ParsName"
Select Owneraddress,
Parsename(Owneraddress, 1)

from portfolio..Nashville




-- But PARSENAME only support periods not Comma's so we need to replace it with periods

Select 
Parsename(Replace(Owneraddress, ',', '.'), 3),
Parsename(Replace(Owneraddress, ',', '.'), 2),
Parsename(Replace(Owneraddress, ',', '.'), 1)
from portfolio..Nashville


Alter table portfolio..nashville
add OwnerSplitaddress nvarchar(255)

update portfolio..nashville
Set OwnerSplitaddress = Parsename(Replace(Owneraddress, ',', '.'), 3)

Alter table portfolio..nashville
add OwnerSplitCity nvarchar(255)

update portfolio..nashville
Set OwnerSplitCity = Parsename(Replace(Owneraddress, ',', '.'), 2)

Alter table portfolio..nashville
add OwnerSplitstate nvarchar(255)

update portfolio..nashville
Set OwnerSplitState = Parsename(Replace(Owneraddress, ',', '.'), 1)

Select distinct(SoldAsVacant), count(soldasvacant)
from Portfolio..Nashville
Group by soldasvacant
order by 2
--using case statement

Select soldasvacant
, Case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
from Portfolio..Nashville


update Portfolio..Nashville
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end

Select Distinct(SoldAsVacant), count(soldasvacant)
from Portfolio..Nashville
group by SoldAsVacant


--Removing Duplicate data
With RowNumCTE As(
Select *,
Row_number() Over(
Partition by ParcelID,
			Propertyaddress,
			SalePrice,
			Saledate,
			Legalreference
			Order by uniqueID
			) RowNum
from Portfolio..Nashville)
--order by ParcelID
Select *
From RowNumCTE 
where rownum > 1
order by Propertyaddress


--Deleting Columns
Select*
from Portfolio..Nashville


Alter table Portfolio..Nashville
Drop Column owneraddress, TaxDistrict, Propertyaddress

Alter table Portfolio..Nashville
Drop Column Saledate


Select *
from Portfolio..Nashville


---To delete duplicates just replace Select* with Delete

With RowNumCTE As(
Select *,
Row_number() Over(
Partition by ParcelID,
			Propertyaddress,
			SalePrice,
			Saledate,
			Legalreference
			Order by uniqueID
			) RowNum
from Portfolio..Nashville)
--order by ParcelID
Delete
From RowNumCTE 
where rownum > 1
--order by Propertyaddress

