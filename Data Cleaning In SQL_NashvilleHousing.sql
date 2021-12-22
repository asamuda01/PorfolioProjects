--Cleaning Data in SQL
Select *
from PortfolioProject.dbo.NashvilleHousing


------------------------------------------------------------------------------------------------------------------------
--Standardize Date Format

Select SaleDate, Convert(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date,SaleDate)

Select SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------
--Populate Property Address Data
--from the data nulls were present in property address but it was evident that instances where parcel ID was the sames a link to the same property address 
Select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID
--to populate the nulls (SELF jOIN) - ISNULL

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]

--------------------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)

----PropertyAddress has address and City one delimiter -SUBSTRING & CHARINDEX
Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing


--NB Below(-1/+1 in chardIndex to remove the comma posistion)
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as PropertySplitAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as PropertySplitCity
from PortfolioProject.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
from PortfolioProject.dbo.NashvilleHousing

-----OwnerAddress Has 2 Delimiters---- Cleaning Using PARSENAME (since parsename works with periods, the commas will be replaced with periods)
Select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing 
--Parsename operates in reverse order
Select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3) as OwnerSplitAddress,
PARSENAME(Replace(OwnerAddress, ',', '.'), 2) as OwnerSplitCity,
PARSENAME(Replace(OwnerAddress, ',', '.'), 1) as OwnerSplitState
from PortfolioProject.dbo.NashvilleHousing 

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

Select *
from PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------
--Changing Y and N to Yes and NO in "Sold as Vacant" Field (Initially More fields have data entered as Yes and No -cleaning to keep uniformity)
Select Distinct(SoldAsVacant), Count(SoldAsVacant) as Instances
from PortfolioProject.dbo.NashvilleHousing
Group by (SoldAsVacant)
Order by 2

---Using Case Statement
Select SoldAsVacant,
Case when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant
	 End
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant
	 End

-------------------------------------------------------------------------------------------------------------------------
--Removing Duplicates (Not a Standard Practice to delete data from database)
--Using a CTE
--ROWNUMBER
WITH RowNumCTE as(
Select *,
ROW_NUMBER() Over (
Partition by ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	Order by
	UniqueID) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Delete (--to delete duplicates)
--Select * (replace at end to check if removed)
from RowNumCTE
where row_num > 1



--------------------------------------------------------------------------------------------------------------------------
--Deleting Unused Columns (always talk to team before using this)
Select *
from PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, PropertyAddress

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate