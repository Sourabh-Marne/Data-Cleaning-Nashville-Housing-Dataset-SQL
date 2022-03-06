-- View all the Raw Data 

SELECT * FROM SQLProject.dbo.NashvilleHousing;

--Modifying the date format to standard date format

ALTER TABLE SQLProject.dbo.NashvilleHousing
ADD SaleDate1 DATE;

UPDATE SQLProject.dbo.NashvilleHousing
SET Saledate1 = CONVERT(DATE,Saledate);

SELECT SaleDate1
FROM SQLProject.dbo.NashvilleHousing;

ALTER TABLE SQLProject.dbo.NashvilleHousing
DROP COLUMN SaleDate;

-- Dealing with null values in PropertyAddress
-- As the parcel_ID associated property address is same for every ID, we will populate the Null values with those addresses.

SELECT x.ParcelId, x.PropertyAddress, y.ParcelId, y.PropertyAddress, isnull(x.PropertyAddress, y.PropertyAddress) AS Address_to_populate
FROM SQLProject.dbo.NashvilleHousing x
JOIN SQLProject.dbo.NashvilleHousing y
ON x.ParcelId = y.ParcelId
AND x.UniqueId != y.UniqueId
WHERE x.PropertyAddress IS NULL;

-- Set the address associated with same parcelID to remove NULL values
UPDATE x
SET PropertyAddress = isnull(x.PropertyAddress,y.PropertyAddress)
FROM SQLProject.dbo.NashvilleHousing x
JOIN SQLProject.dbo.NashvilleHousing y
ON x.ParcelId = y.ParcelId
AND x.UniqueId != y.UniqueId
WHERE x.PropertyAddress IS NULL;

-- Separating the PropertyAddress into Address and City and format

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address_first_part,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
FROM SQLProject.dbo.NashvilleHousing;

ALTER TABLE SQLProject.dbo.NashvilleHousing
ADD First_Address Nvarchar(255);

UPDATE SQLProject.dbo.NashvilleHousing
SET First_Address= SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );


ALTER TABLE SQLProject.dbo.NashvilleHousing
ADD City varchar(50);

UPDATE SQLProject.dbo.NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));


SELECT * FROM SQLProject.dbo.NashvilleHousing;

-- Owner Address splitting into Address, City and State

Select OwnerAddress
From SQLProject.dbo.NashvilleHousing;


Select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From SQLProject.dbo.NashvilleHousing;

ALTER TABLE SQLProject.dbo.NashvilleHousing
ADD OwnerAddress_first nvarchar(250);

UPDATE SQLProject.dbo.NashvilleHousing
SET OwnerAddress_first= PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

ALTER TABLE SQLProject.dbo.NashvilleHousing
ADD OwnerCity nvarchar(250);

UPDATE SQLProject.dbo.NashvilleHousing
SET OwnerCity= PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

ALTER TABLE SQLProject.dbo.NashvilleHousing
ADD OwnerState nvarchar(250);

UPDATE SQLProject.dbo.NashvilleHousing
SET OwnerState= PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

SELECT * FROM SQLProject.dbo.NashvilleHousing;


-- Update SoldasVacant data (0s and 1s) bits to Yes and No format varchar

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM SQLProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

ALTER TABLE SQLProject.dbo.NashvilleHousing
ALTER COLUMN SoldAsVacant varchar(30);


UPDATE SQLProject.dbo.NashvilleHousing
SET SoldasVacant= CASE
	WHEN SoldasVacant= '1' THEN 'Yes'
	WHEN SoldasVacant= '0' THEN 'No'
	ELSE SoldasVacant
END

SELECT DISTINCT(SoldasVacant) FROM SQLProject.dbo.NashvilleHousing;

-- Removing Duplicates


WITH CTE as 
(
SELECT *,
ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate1,
				 LegalReference
				 ORDER BY UniqueID
				) AS row_num
FROM SQLProject.dbo.NashvilleHousing
)

Select * from CTE;

DELETE FROM CTE
WHERE row_num>1

-- Dropping unused columns

ALTER TABLE SQLProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress;

ALTER TABLE project.dbo.NashvilleHousing
DROP COLUMN SaleDate;

SELECT * FROM SQLProject.dbo.NashvilleHousing;

--Now our data is free from duplicates and available in the right format to start analysis
