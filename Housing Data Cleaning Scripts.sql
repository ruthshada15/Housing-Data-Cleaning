

-- CLEANING DATA IN SQL QUERIES

SELECT * 
FROM PortfolioProject1..NashvilleHousing

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate) AS OnlyDate
FROM PortfolioProject1..NashvilleHousing

UPDATE PortfolioProject1..NashvilleHousing -- Have to precise whivh database will be using because the table name itself throws an error because i'M connected to "master"
SET SaleDate = CONVERT(Date, SaleDate) -- But this command still doesn't Update the column to date only

ALTER TABLE PortfolioProject1..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE PortfolioProject1..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


SELECT SaleDate,SaleDateConverted, CONVERT(Date, SaleDate) AS OnlyDate
FROM PortfolioProject1..NashvilleHousing
--New column succesfully created


-- Populate the Property Address Data
SELECT *
FROM PortfolioProject1..NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- Need to Compare a table to itself (Self Join)
SELECT a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Update the property address with the address found on the duplicate values
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject1..NashvilleHousing a
JOIN PortfolioProject1..NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Breaking out Addresses into individual columns (Address, City, State)


--Starting with the Property address
SELECT PropertyAddress
FROM PortfolioProject1..NashvilleHousing
;

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject1..NashvilleHousing

-- Creating new columns and adding the split address & city values to them

ALTER TABLE PortfolioProject1..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject1..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE PortfolioProject1..NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE PortfolioProject1..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Owner address

SELECT OwnerAddress 
FROM PortfolioProject1..NashvilleHousing

--Without using Substrings (Using Parsename & Replace) Cool trick that makes work easier :D

SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.'),3),
PARSENAME(REPLACE(OwnerAddress,',', '.'),2),
PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
FROM PortfolioProject1..NashvilleHousing

-- Creating new columns and adding the split address, city & state values to them

ALTER TABLE PortfolioProject1..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject1..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE PortfolioProject1..NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject1..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE PortfolioProject1..NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE PortfolioProject1..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) 
FROM PortfolioProject1..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProject1..NashvilleHousing

-- Now update the SoldAsVacant field with the correct values
UPDATE PortfolioProject1..NashvilleHousing
SET SoldAsVacant =
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END


-- Remove duplicates

WITH CTE_rowNum AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM PortfolioProject1..NashvilleHousing
--ORDER BY ParcelID
)
SELECT * 
FROM CTE_rowNum
WHERE row_num > 1
;

--Delete the DUPLICATES found by the above query

WITH CTE_rowNum AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM PortfolioProject1..NashvilleHousing
--ORDER BY ParcelID
)
DELETE 
FROM CTE_rowNum
WHERE row_num > 1


--Delete Unused columns

ALTER TABLE PortfolioProject1..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject1..NashvilleHousing
DROP COLUMN SaleDate


SELECT * 
FROM PortfolioProject1..NashvilleHousing