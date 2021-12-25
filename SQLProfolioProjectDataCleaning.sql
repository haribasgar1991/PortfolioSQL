/* Data Cleanning in SQL using Queries */

--Standarize the date format

Select SaleDateConverted,CONVERT(Date, SaleDate)
from [dbo].[NashvilleHousing]

--UPDATE [dbo].[NashvilleHousing]
--SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE [NashvilleHousing]
ADD SaleDateConverted Date;

UPDATE [dbo].[NashvilleHousing]
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address Data

Select  *, [PropertyAddress]
from [NashvilleHousing]
--where [PropertyAddress] IS NULL
Order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from [NashvilleHousing] a
JOIN [NashvilleHousing] b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [NashvilleHousing] a
JOIN [NashvilleHousing] b 
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--Breaking out address into Individual columns (Address, City, State)

Select PropertyAddress
from [NashvilleHousing]

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
from [NashvilleHousing]

ALTER TABLE [NashvilleHousing]
ADD PropertySplitAddress NVARCHAR(255);

UPDATE [dbo].[NashvilleHousing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [NashvilleHousing]
ADD PropertySplitCity NVARCHAR(255);

UPDATE [dbo].[NashvilleHousing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
		PARSENAME(REPLACE(OwnerAddress,',','.'),2),
		PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from [NashvilleHousing]


ALTER TABLE [NashvilleHousing]
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE [dbo].[NashvilleHousing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [NashvilleHousing]
ADD OwnerSplitCity NVARCHAR(255);

UPDATE [dbo].[NashvilleHousing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [NashvilleHousing]
ADD OwnerSplitState NVARCHAR(255);

UPDATE [dbo].[NashvilleHousing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select *
From [NashvilleHousing]


--Change Y and N to Yes and No in 'Sold as vacant' Field

Select  SoldAsVacant , COUNT(SoldAsVacant)
from [NashvilleHousing]
Group by SoldAsVacant

Select  SoldAsVacant 
		, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				WHEN SoldAsVacant = 'N' THEN 'No'
				ELSE SoldAsVacant
				END
from [NashvilleHousing]

Update [NashvilleHousing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
				WHEN SoldAsVacant = 'N' THEN 'No'
				ELSE SoldAsVacant
				END

--Remove Duplicates

WITH CTE AS (
Select *
		, ROW_NUMBER() OVER (
		  PARTITION BY ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
		ORDER BY
				UniqueID) row_num
from [NashvilleHousing]
)

Select *
from CTE
Where row_num = 1

--Delete Unused columns

ALTER TABLE [NashvilleHousing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [NashvilleHousing]
DROP COLUMN SaleDate

Select * 
from [NashvilleHousing]