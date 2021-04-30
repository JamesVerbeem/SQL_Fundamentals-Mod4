-- Module 4 Class Project

-- Create a backup of the original data
USE [COVID19_Vaccinations]
GO

/****** Object:  Table [dbo].[country_vaccinations]    Script Date: 2021-03-09 1:44:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[OriginalData](
	[country] [nvarchar](max) NOT NULL,
	[iso_code] [nvarchar](max) NULL,
	[date] [datetime2](7) NOT NULL,
	[total_vaccinations] [float] NULL,
	[people_vaccinated] [float] NULL,
	[people_fully_vaccinated] [float] NULL,
	[daily_vaccinations_raw] [float] NULL,
	[daily_vaccinations] [float] NULL,
	[total_vaccinations_per_hundred] [float] NULL,
	[people_vaccinated_per_hundred] [float] NULL,
	[people_fully_vaccinated_per_hundred] [float] NULL,
	[daily_vaccinations_per_million] [float] NULL,
	[vaccines] [nvarchar](max) NOT NULL,
	[source_name] [nvarchar](max) NOT NULL,
	[source_website] [nvarchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
;

-- There is currently no primary key established in the database

-- View table
SELECT *
	FROM Country_Vaccinations

-- Retrieve list of columns and data types for each
SELECT
		COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, DATETIME_PRECISION, IS_NULLABLE
	FROM
		INFORMATION_SCHEMA.COLUMNS
	WHERE
		TABLE_NAME = 'Country_Vaccinations'
	ORDER BY ORDINAL_POSITION

-- EntryID column needed to compare records
ALTER TABLE Country_Vaccinations
	ADD entryID INT IDENTITY(1, 1) NOT NULL

SELECT entryID,
	REVERSE(PARSENAME(REPLACE(REVERSE(vaccines), ',', '.'), 1)) AS Mnfct1
	, REVERSE(PARSENAME(REPLACE(REVERSE(vaccines), ',', '.'), 2)) AS Mnfct2
	, REVERSE(PARSENAME(REPLACE(REVERSE(vaccines), ',', '.'), 3)) AS Mnfct3
	, REVERSE(PARSENAME(REPLACE(REVERSE(vaccines), ',', '.'), 4)) AS Mnfct4
	, REVERSE(PARSENAME(REPLACE(REVERSE(vaccines), ',', '.'), 5)) AS Mnfct5
	FROM Country_Vaccinations
	WHERE Mnfct5 IS NOT NULL
	
;

SELECT entryID, vaccines
	FROM Country_Vaccinations


SELECT DISTINCT entryID, vaccines
	FROM Country_Vaccinations
	WHERE vaccines = 'Oxford/AstraZeneca, Pfizer/BioNTech, Sinopharm/Beijing, Sinopharm/Wuhan, Sputnik V'

-- Leaving Manufacturers out of the final data for now, will work on the problem later
;

-- Update the missing iso_code values in main data table so it can be transferred into the new Countries table that will be created
SELECT DISTINCT country, iso_code
	FROM Country_Vaccinations
	WHERE iso_code IS NULL
;

SELECT DISTINCT country
	FROM Country_Vaccinations
	WHERE iso_code = 'GBE'
	OR iso_code = 'GBN'
	OR iso_code = 'GBS'
	OR iso_code = 'GBW'
	OR iso_code = 'USA'
; -- Returns one value for USA, the other codes are not currently used and can be inserted

BEGIN TRAN
UPDATE Country_Vaccinations
	SET iso_code = CASE
		WHEN country = 'England' THEN 'GBE'
		WHEN country = 'Northern Ireland' THEN 'GBN'
		WHEN country = 'Scotland' THEN 'GBS'
		WHEN country = 'Wales' THEN 'GBW'
		ELSE NULL
		END
	WHERE iso_code IS NULL
; --Transaction worked as planned

ROLLBACK TRAN --Test of ROLLBACK, worked
;

COMMIT TRAN --Commits the transaction as permanent;
;
-- This entire section needs to be redone
/*	-- Create Country table
CREATE TABLE Countries (
	ISOCode nvarchar(5)
	, VacCountry nvarchar(50)
	)
;

INSERT INTO Countries(VacCountry)
	SELECT DISTINCT country
		FROM Country_Vaccinations
		WHERE country NOT IN (
			SELECT VacCountry
				FROM Countries
		)
;

INSERT INTO Countries(ISOCode)
SELECT DISTINCT iso_code
	FROM Country_Vaccinations

SELECT *
	FROM Countries
;

SELECT Countries.VacCountry, Country_Vaccinations.iso_code
	FROM Countries
	LEFT JOIN Country_Vaccinations
		ON Countries.VacCountry = Country_Vaccinations.country
		GROUP BY Countries.VacCountry, Countries.ISOCode
; -- Doesn't give the desired results

-- Copy Country_Vaccinations.iso_code to Countries.ISOCode
UPDATE Countries
	SET ISOCode = 
	SELECT DISTINCT iso_code
		FROM Country_Vaccinations
		WHERE iso_code NOT IN (
			SELECT ISOCode
				FROM Countries
); -- Didn't work

SELECT *
	FROM Countries
	ORDER BY VacCountry asc

SELECT Countries.VacCountry,
	FROM Country_Vaccinations
	INNER JOIN Countries
	ON Countries.VacCountry = Country_Vaccinations.country
	ORDER BY country asc
		FROM Country_Vaccinations

BEGIN TRAN -- Doesn't work
	UPDATE Countries
		SET Countries.ISOCode = Country_Vaccinations.iso_code
		WHERE Countries.VacCountry = Country_Vaccinations.country
		
SELECT Countries.VacCountry, Country_Vaccinations.iso_code
	FROM Countries
	INNER JOIN  Country_Vaccinations
	ON Countries.VacCountry = Country_Vaccinations.country
	ORDER BY VacCountry asc

SELECT Countries.VacCountry, Country_Vaccinations.iso_code
	FROM Country_Vaccinations
	INNER JOIN  Countries
	ON Countries.VacCountry = Country_Vaccinations.country
	ORDER BY VacCountry asc
*/;

-- Start over
TRUNCATE TABLE Countries

SELECT *
	FROM Countries -- Table is now blank again
;

-- Copy over the data from both the Countries and the ISO Code columns of the original data. There was a problem.
/*
INSERT INTO Countries(ISOCode, VacCountry)
	SELECT DISTINCT iso_code, country
		FROM Country_Vaccinations
*/;

-- Data from iso_code is too long for at least one entry!!!
/*
SELECT DISTINCT country, iso_code
	FROM Country_Vaccinations
;

SELECT iso_code
	FROM Country_Vaccinations
	WHERE LEN(iso_code) > 5
;

ALTER TABLE Countries
	ALTER COLUMN ISOCode nvarchar(16) -- All ISO codes should now fit
;
*/;

-- Copy distinct data from dbo.Country_Vaccinations over to dbo.Countries. Make Countries.ISOCode the PK and Countries.VacCountry UNIQUE
/*
INSERT INTO Countries(ISOCode, VacCountry)
	SELECT DISTINCT iso_code, country
		FROM Country_Vaccinations

ALTER TABLE Countries
	ALTER COLUMN ISOCode nvarchar(16) NOT NULL;

ALTER TABLE Countries
	ADD PRIMARY KEY (ISOCode)
	, UNIQUE (VacCountry);

ALTER TABLE Countries
	DROP CONSTRAINT UQ__Countrie__CB76887B3A7AF6F3;

ALTER TABLE Countries
	DROP COLUMN VacCountry;

ALTER TABLE Countries
	ADD VacCountry nvarchar(64) NOT NULL;

ALTER TABLE Countries
	ADD UNIQUE (VacCountry);

INSERT INTO Countries(ISOCode, VacCountry)
	SELECT DISTINCT iso_code, country
		FROM Country_Vaccinations;
*/;

/*-- dbo.Countries table is complete move onto the dbo.Sources table*/

SELECT COUNT(DISTINCT country) AS CNT_C
	FROM Country_Vaccinations
SELECT COUNT(DISTINCT source_name) AS CNT_SN
	FROM Country_Vaccinations
SELECT COUNT(DISTINCT source_website) AS CNT_SW
	FROM Country_Vaccinations
	-- The various record counts are not equal
;

SELECT COUNT(*), country, source_name, source_website
	FROM Country_Vaccinations
	GROUP BY country, source_name, source_website

SELECT *
	FROM Country_Vaccinations
	WHERE source_name IN (
		SELECT source_name
			FROM Country_Vaccinations
			GROUP BY source_name
			HAVING COUNT(source_name) > 1)

SELECT source_name, source_website, iso_code, COUNT(*) Occurences
	FROM Country_Vaccinations
	GROUP BY source_name, source_website, iso_code
	HAVING COUNT(*) > 1

SELECT DISTINCT source_name, source_website, iso_code
	FROM Country_Vaccinations
	ORDER BY iso_code
	-- 129 entries, the various UK regions (GBE, GBN, GBR, GBuse the same source

CREATE TABLE Sources
	