--Cleaning data in SQL Queries

SELECT *
FROM PortfolioProject..NashvilleHousing






--STANDARDISE DATE FORMAT

SELECT SaleDate, CONVERT(date,SaleDate) 
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD NewSaleDate Date

UPDATE NashvilleHousing
SET NewSaleDate=CONVERT(date,SaleDate)

SELECT *
FROM PortfolioProject..NashvilleHousing









--Populate Property Address


SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID


SELECT a.PropertyAddress,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  ON a.ParcelID=b.ParcelID
  AND a.[UniqueID ]!=b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  ON a.ParcelID=b.ParcelID
  AND a.[UniqueID ]!=b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



SELECT *
FROM PortfolioProject..NashvilleHousing








--Breaking out Address into Individual Columns(Address,City,State)

SELECT PropertyAddress,
       SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
	   SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET  PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


SELECT *
FROM PortfolioProject..NashvilleHousing





SELECT OwnerAddress,
       PARSENAME(REPLACE(owneraddress,',','.'),3),
	   PARSENAME(REPLACE(owneraddress,',','.'),2),
	   PARSENAME(REPLACE(owneraddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress =PARSENAME(REPLACE(owneraddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity  nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(owneraddress,',','.'),2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState  nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState= PARSENAME(REPLACE(owneraddress,',','.'),1)


SELECT *
FROM PortfolioProject..NashvilleHousing








--Change Y and N to Yes and No in 'Sold As Vacant' Field

SELECT DISTINCT SoldAsVacant,COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant)



SELECT SoldAsVacant,
       CASE
	   WHEN SoldAsVacant='Y' THEN 'Yes'
	   WHEN SoldAsVacant='N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing
--GROUP BY SoldAsVacant
--ORDER BY COUNT(SoldAsVacant)



UPDATE NashvilleHousing
SET SoldAsVacant=CASE
	   WHEN SoldAsVacant='Y' THEN 'Yes'
	   WHEN SoldAsVacant='N' THEN 'No'
	   ELSE SoldAsVacant
	   END








--Remove Duplicates

SELECT *,
     ROW_NUMBER() OVER(
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SaleDate,
				  SalePrice,
				  LegalReference
				  ORDER BY UniqueID
				  ) row_num
FROM PortfolioProject..NashvilleHousing
Order By ParcelID


WITH ROW_NUMCTE AS (

SELECT *,
     ROW_NUMBER() OVER(
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SaleDate,
				  SalePrice,
				  LegalReference
				  ORDER BY UniqueID
				  ) row_num
FROM PortfolioProject..NashvilleHousing)
--Order By ParcelID

--DELETE
--FROM ROW_NUMCTE
--WHERE row_num>1



SELECT *
FROM ROW_NUMCTE
WHERE row_num>1



SELECT *
FROM PortfolioProject..NashvilleHousing




--Delete Unused Columns




SELECT *
FROM PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,PropertyAddress,TaxDistrict,SaleDate

