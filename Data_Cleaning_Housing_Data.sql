USE PortfolioProject2;
-- View the data
SELECT * FROM housingdata;

-- Standardize Date Format
ALTER TABLE housingdata ADD COLUMN Converteddate VARCHAR(15);

SET SQL_SAFE_UPDATES = 0;
UPDATE housingdata
SET Converteddate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%d-%m-%Y');
SET SQL_SAFE_UPDATES = 1;

SELECT SaleDate, Converteddate
FROM housingdata;

-- Populate Property Address Data

SELECT * 
FROM housingdata
ORDER BY ParcelID;

-- Identify missing PropertyAddress entries
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
       COALESCE(a.PropertyAddress, b.PropertyAddress) AS ResolvedAddress
FROM housingdata a
JOIN housingdata b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Update PropertyAddress using the resolved addresses
UPDATE housingdata a
JOIN housingdata b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress IS NULL;

-- Break out Address into Individual Columns (Address, City, State)
-- View split address components
SELECT 
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS City
FROM housingdata;

-- Add new columns for split components
ALTER TABLE housingdata
ADD COLUMN PropertySplitAddress VARCHAR(255),
ADD COLUMN PropertySplitCity VARCHAR(255);

-- Populate the new columns
UPDATE housingdata
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1),
    PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);

-- Repeat similar steps for OwnerAddress
ALTER TABLE housingdata
ADD COLUMN OwnerSplitAddress VARCHAR(255),
ADD COLUMN OwnerSplitCity VARCHAR(255);

UPDATE housingdata
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1),
    OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

-- Change Y and N to Yes and No in "SoldAsVacant" Field

-- View distinct values in the field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) 
FROM housingdata 
GROUP BY SoldAsVacant
ORDER BY 2;

-- Update the field with Yes and No
UPDATE housingdata
SET SoldAsVacant = CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

-- Remove Duplicates
-- Identify duplicates using ROW_NUMBER-like logic
WITH RowNumCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
           PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
           ORDER BY UniqueID) AS row_num
    FROM housingdata
)
SELECT * FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

-- Delete duplicates
SET SQL_SAFE_UPDATES = 0;
DELETE t1
FROM housingdata t1
JOIN housingdata t2
  ON t1.ParcelID = t2.ParcelID
  AND t1.PropertyAddress = t2.PropertyAddress
  AND t1.SalePrice = t2.SalePrice
  AND t1.SaleDate = t2.SaleDate
  AND t1.LegalReference = t2.LegalReference
WHERE t1.UniqueID > t2.UniqueID;

SET SQL_SAFE_UPDATES = 1;

-- Delete Unused Columns
ALTER TABLE housingdata 
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress, 
DROP COLUMN SaleDate;
