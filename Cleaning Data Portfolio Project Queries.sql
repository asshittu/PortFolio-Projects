/*

Cleaning Data in SQL Queries

Data Gotten from AlexTheAnalyst: https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx

Platform used: Google BigQuery

*/

SELECT * 
FROM `portfolio-project-362200.NashvilleHousing.HousingData` 
LIMIT 1000;


-- Standardize Date Format

SELECT 
  SaleDate,
  FORMAT_DATE('%Y/%m/%d', SaleDate) AS Formatted_SaleDate
FROM `portfolio-project-362200.NashvilleHousing.HousingData`;


-- Populate Property Address Data

SELECT *
FROM `portfolio-project-362200.NashvilleHousing.HousingData`
WHERE PropertyAddress IS NULL;


SELECT *
FROM `portfolio-project-362200.NashvilleHousing.HousingData`
ORDER BY ParcelID;


SELECT 
  a.ParcelID, 
  a.PropertyAddress, 
  b.ParcelID, 
  b.PropertyAddress,
  IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM `portfolio-project-362200.NashvilleHousing.HousingData` a
JOIN `portfolio-project-362200.NashvilleHousing.HousingData` b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID_ <> b.UniqueID_
WHERE a.PropertyAddress IS NULL;


UPDATE a
SET PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
FROM `portfolio-project-362200.NashvilleHousing.HousingData` a
JOIN `portfolio-project-362200.NashvilleHousing.HousingData` b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID_ <> b.UniqueID_
WHERE a.PropertyAddress IS NULL;


-- Breaking the PropertyAddress into Individual Columns (Address, City)

SELECT
  SPLIT(PropertyAddress, ","), [SAFE_OFFSET(0)] AS Address,
  SPLIT(PropertyAddress, ","), [SAFE_OFFSET(1)] AS City
FROM `portfolio-project-362200.NashvilleHousing.HousingData`;

UPDATE `portfolio-project-362200.NashvilleHousing.HousingData`
SET Address = SPLIT(PropertyAddress, ","), [SAFE_OFFSET(0)];

UPDATE `portfolio-project-362200.NashvilleHousing.HousingData`
SET City = SPLIT(PropertyAddress, ","), [SAFE_OFFSET(1)];


-- Checking Distinct rows for SoldAsVacant field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM `portfolio-project-362200.NashvilleHousing.HousingData`
GROUP BY SoldAsVacant

-- Changing from True and False to T and F in SoldAsVacant field

SELECT 
SoldAsVacant,
  CASE WHEN SoldAsVacant = 'True' THEN 'T'
       WHEN SoldAsVacant = 'False' THEN 'F'
       ELSE SoldAsVacant
       END
FROM `portfolio-project-362200.NashvilleHousing.HousingData`;

UPDATE `portfolio-project-362200.NashvilleHousing.HousingData`
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'True' THEN 'T'
  WHEN SoldAsVacant = 'False' THEN 'F'
  ELSE SoldAsVacant
  END;


-- Remove Duplicates from fields

WITH RowsNum AS(
  SELECT *,
	ROW_NUMBER() OVER (PARTITION BY 
  ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY UniqueID_
	) rows_num

From `portfolio-project-362200.NashvilleHousing.HousingData`
)

Select *
From RowsNum
Where rows_num > 1
Order by PropertyAddress;


-- Delete unused columns

Select *
From `portfolio-project-362200.NashvilleHousing.HousingData`


ALTER TABLE `portfolio-project-362200.NashvilleHousing.HousingData`
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
