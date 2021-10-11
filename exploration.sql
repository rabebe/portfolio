--The Impacts of COVID-19 on educational stress

SELECT * FROM portfolio.dbo.beforec

--Select the data to focus on: Children in educational institutions

SELECT b.Category, b.Country, b.[Before-Environment], a.[Now-Environment], b.[Before-ClassworkStress], a.[Now-ClassworkStress]
FROM portfolio.dbo.afterc a
INNER JOIN portfolio.dbo.beforec b
ON a.StudentID = b.StudentID 
WHERE b.Category = 'SchoolCollegeTraining'

--Show the number of school environments by type
SELECT Category, Country, [Before-Environment], COUNT([Before-Environment])
FROM portfolio.dbo.stress
WHERE Category like '%SchoolCollege%'
GROUP BY Country, [Before-Environment], Category
ORDER BY Country

SELECT Category, Country, [Now-Environment], COUNT([Now-Environment])
FROM portfolio.dbo.stress
WHERE Category like '%SchoolCollege%'
GROUP BY Country, [Now-Environment], Category
ORDER BY Country

--Focus on one country: U.S. and look at data by state
SELECT b.Category, b.State, b.[Before-Environment], b.[Before-ClassworkStress],a.[Now-Environment], a.[Now-ClassworkStress]
FROM portfolio.dbo.afterc a
INNER JOIN portfolio.dbo.beforec b
ON a.StudentID = b.StudentID 
WHERE b.Category = 'SchoolCollegeTraining'
AND b.Country = 'US'

--Look at the average length of homework hours and homework stress by state
SELECT State, AVG([Before-HomeworkHours]) AS AvgHWHours, AVG([Before-HomeworkStress]) AS AvgHWStress
FROM portfolio.dbo.beforec
WHERE Category = 'SchoolCollegeTraining'
AND Country = 'US'
GROUP BY State
ORDER BY AvgHWStress DESC

SELECT State, AVG([Now-HomeworkHours]) AS AvgHWHours, AVG([Now-HomeworkStress]) AS AvgHWStress
FROM portfolio.dbo.afterc
WHERE Category = 'SchoolCollegeTraining'
AND Country = 'US'
GROUP BY State
ORDER BY AvgHWStress DESC

--Find the difference in stress and average state stress level
SELECT b.Country, b.Gender, (a.[Now-HomeworkStress] - b.[Before-HomeworkStress]) AS DiffInStress
FROM portfolio.dbo.afterc a
INNER JOIN portfolio.dbo.beforec b
ON a.StudentID = b.StudentID

--Find the national average difference in homework hours across the US between pre and post-pandemic
SELECT AVG(diff)
FROM (
SELECT (a.[Now-HomeworkHours] - b.[Before-HomeworkHours]) AS diff
FROM portfolio.dbo.afterc a
INNER JOIN portfolio.dbo.beforec b
ON a.StudentID = b.StudentID
WHERE b.Category = 'SchoolCollegeTraining'
AND b.Country = 'US'
) AS d

--Find the national average difference in classwork stress across the US between pre and post-pandemic
SELECT AVG(diff)
FROM (
SELECT (a.[Now-ClassworkStress] - b.[Before-ClassworkStress]) AS diff
FROM portfolio.dbo.afterc a
JOIN portfolio.dbo.beforec b
ON a.StudentID = b.StudentID
WHERE b.Category = 'SchoolCollegeTraining'
AND b.Country = 'US'
) AS p


--Show which environments have the highest stress levels for states
SELECT State, [Before-Environment], [Now-Environment], [Now-ClassworkStress]
FROM portfolio.dbo.stress
WHERE Category LIKE '%College%' AND Country LIKE '%US%'
GROUP BY State, [Before-Environment], [Now-Environment], [Now-ClassworkStress]
Order BY [Now-ClassworkStress] DESC, State 

--Changes in FriendRelationship Stress by Gender in US
SELECT Gender, AVG(FriendRelationships)
FROM portfolio.dbo.beforec b
WHERE Category LIKE '%College%' AND Country LIKE '%US%'
GROUP BY Gender
ORDER BY 2


--Changes to Family and Friend Relationships
SELECT Gender, CASE 
	WHEN FriendRelationships > 0 THEN 'Improved'
	WHEN FriendRelationships < 0 THEN 'Worsened'
	ELSE 'No Change'
	END AS Friendtext
FROM portfolio.dbo.beforec b

SELECT Gender,
CASE 
	WHEN FamilyRelationships > 0 THEN 'Improved'
	WHEN FamilyRelationships < 0 THEN 'Worsened'
	ELSE 'No Change'
	END AS Familytext
FROM portfolio.dbo.stress s 

--Number of students and average stressors by State
SELECT b.state, COUNT(b.state), 
AVG((a.[Now-ClassworkStress] - b.[Before-ClassworkStress])) AS diffClassStress,
AVG(a.FamilyRelationships) AS AVGfamilyStress, AVG(b.FriendRelationships) AS AVGfriendStress
FROM portfolio.dbo.afterc a 
JOIN portfolio.dbo.beforec b
ON b.StudentID = a.StudentID 
WHERE b.Category LIKE '%College%' AND b.Country LIKE '%US%'
GROUP BY b.state
ORDER BY diffClassStress DESC

-- Adding Averages of Stressors in Classwork Stress

SELECT b.state, ROW_NUMBER () OVER(PARTITION BY b.state 
ORDER BY a.[Now-ClassworkStress] DESC) AS "Row Number",
a.[Now-ClassworkStress],
AVG(a.[Now-ClassworkStress]) OVER(PARTITION BY b.state) AS AvgClassStress,
AVG(a.FamilyRelationships) OVER(PARTITION BY b.state) AS AvgFamilyStress
FROM portfolio.dbo.afterc a
JOIN portfolio.dbo.beforec b 
ON a.StudentID = b.StudentID 
WHERE a.Category LIKE '%College%' AND a.Country LIKE '%US%'
ORDER BY AvgClassStress DESC

select * from portfolio.dbo.afterc

--Use a CTE to calculate averages by state for visualization

WITH statestress (State, AvgFamily, AvgFriends, AvgClassStress, AvgHWStress, AvgHWHours)
AS 
(
SELECT b.State,
	AVG(a.FamilyRelationships),
	AVG(b.FriendRelationships),
	AVG(a.[Now-ClassworkStress] - b.[Before-ClassworkStress]),
	AVG(a.[Now-HomeworkStress] - b.[Before-HomeworkStress]),
	AVG(a.[Now-HomeworkHours] - b.[Before-HomeworkHours])
FROM portfolio.dbo.afterc a

JOIN portfolio.dbo.beforec b 
ON a.StudentID = b.StudentID

WHERE a.Category LIKE '%College%' AND a.Country LIKE '%US%'
GROUP BY b.State
)

SELECT * from statestress

WITH genderstress (Gender, AvgFamily, AvgFriends, AvgClassStress, AvgHWStress, AvgHWHours)
AS 
(
SELECT b.Gender,
	AVG(a.FamilyRelationships),
	AVG(b.FriendRelationships),
	AVG(a.[Now-ClassworkStress] - b.[Before-ClassworkStress]),
	AVG(a.[Now-HomeworkStress] - b.[Before-HomeworkStress]),
	AVG(a.[Now-HomeworkHours] - b.[Before-HomeworkHours])
FROM portfolio.dbo.afterc a

JOIN portfolio.dbo.beforec b 
ON a.StudentID = b.StudentID

WHERE a.Category LIKE '%College%' AND a.Country LIKE '%US%'
GROUP BY b.Gender
)

SELECT * from genderstress

WITH agestress (Age, AvgFamily, AvgFriends, AvgClassStress, AvgHWStress, AvgNowHW, AvgHWHours)
AS 
(
SELECT b.Age,
	AVG(a.FamilyRelationships),
	AVG(b.FriendRelationships),
	AVG(a.[Now-ClassworkStress] - b.[Before-ClassworkStress]),
	AVG(a.[Now-HomeworkStress] - b.[Before-HomeworkStress]),
	AVG(a.[Now-HomeworkHours]),
	AVG(a.[Now-HomeworkHours] - b.[Before-HomeworkHours])
FROM portfolio.dbo.afterc a

JOIN portfolio.dbo.beforec b 
ON a.StudentID = b.StudentID

WHERE a.Category LIKE '%College%' AND a.Country LIKE '%US%'
GROUP BY b.Age
)

SELECT * from agestress

--Look at differences between environments before and after pandemic
WITH envir (Prepandemic_environment, NumSchoolspre, Postpandemic_environment, NumSchoolspost)
AS
(
SELECT b.[Before-Environment],
	COUNT(b.[Before-Environment]),
	a.[Now-Environment],
	COUNT(a.[Now-Environment])
FROM portfolio.dbo.beforec b

JOIN portfolio.dbo.afterc a 
ON a.StudentID = b.StudentID

WHERE a.Category LIKE '%College%' AND a.Country LIKE '%US%'
GROUP BY a.[Now-Environment], b.[Before-Environment]
)

SELECT * from envir
