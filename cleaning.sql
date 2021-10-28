--Cleaning data of Used German Car for sale on eBay


SELECT * FROM auto a 

--Drop null rows

DELETE FROM auto 
WHERE yearOfRegistration IS NULL


-- Standardize Date Format of dateCrawled column

ALTER TABLE auto 
ADD dateCrawledconv Date

UPDATE auto 
SET dateCrawledconv = CONVERT(Date, dateCrawled)


-- Convert price into numeric column

UPDATE auto
SET price = REPLACE([price], '$', '')
FROM auto

UPDATE auto
SET price = REPLACE([price], ',', '')
FROM auto


--If above doesn't work, convert price into integer by creating a new column

ALTER TABLE auto 
ADD price_conv int

UPDATE auto 
SET price = CONVERT(int, price)


--Update odometer column same as price column

UPDATE auto
SET odometer = REPLACE([odometer], 'km', '')
FROM auto

UPDATE auto
SET odometer = REPLACE([odometer], ',', '')
FROM auto

ALTER TABLE auto 
ADD odometer_conv int

UPDATE auto 
SET odometer_conv = CONVERT(int, odometer)


--Extract the make of the car from name column

SELECT SUBSTRING(name, 0, charindex('_', name, 0)) AS make
FROM auto

ALTER TABLE auto
ADD make varchar(55)

UPDATE auto
SET make = SUBSTRING(name, 0, charindex('_', name, 0))


--Clean name column by removing underscores

UPDATE auto
SET name = REPLACE([name], '_', ' ')
FROM auto


--Remove unused columns

ALTER TABLE auto
DROP COLUMN seller

ALTER TABLE auto
DROP COLUMN offerType

ALTER TABLE auto 
DROP COLUMN abtest


--Drop rows with missing information

DELETE FROM auto 
WHERE vehicleType = ''

DELETE FROM auto
WHERE monthOfRegistration = 0


--Combine month of registration and year of registration columns

UPDATE auto
SET yearOfRegistration = REPLACE(yearOfRegistration, ' ', '')
FROM auto

SELECT CAST(CONCAT(yearOfRegistration, '-', monthOfRegistration, '-01') AS date)
FROM auto

ALTER TABLE auto
ADD RegistrationDate date

UPDATE auto
SET RegistrationDate = CAST(CONCAT(yearOfRegistration, '-', monthOfRegistration, '-01') AS date)


--Calculate age of car

SELECT DATEDIFF(year, RegistrationDate, dateCrawledconv)
FROM auto

ALTER TABLE auto 
ADD car_age int

UPDATE auto 
SET car_age = DATEDIFF(year, RegistrationDate, dateCrawledconv)
FROM auto


--Translate text in columns from German to English

UPDATE auto
SET gearbox = REPLACE(gearbox, 'manuell', 'Manual')

UPDATE auto
SET gearbox = REPLACE(gearbox, 'automatik', 'Automatic')

UPDATE auto
SET model = REPLACE(model, '00', 'er')

UPDATE auto
SET model = REPLACE(model, '_klasse', '-class')


--Capitalize first letter of word in columns

UPDATE auto 
SET model = UPPER(LEFT(cast(model as nvarchar(max)),1)) +
LOWER(SUBSTRING(cast(model as nvarchar(max)),2,
LEN(cast(model as nvarchar(max)))))

UPDATE auto 
SET vehicleType = UPPER(LEFT(cast(vehicleType as nvarchar(max)),1)) +
LOWER(SUBSTRING(cast(vehicleType as nvarchar(max)),2,
LEN(cast(vehicleType as nvarchar(max)))))
