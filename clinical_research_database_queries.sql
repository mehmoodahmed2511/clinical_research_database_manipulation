-- Create Database

CREATE DATABASE ClinicalResearchDB;
GO

USE ClinicalResearchDB;
GO

-- =========================
-- Tables
-- =========================

CREATE TABLE Patients (
    patientID INT PRIMARY KEY,
    firstName VARCHAR(50),
    lastName VARCHAR(50),
    gender VARCHAR(10),
    dateOfBirth DATE,
    city VARCHAR(50)
);

CREATE TABLE Doctors (
    doctorID INT PRIMARY KEY,
    doctorName VARCHAR(100),
    specialization VARCHAR(50)
);

CREATE TABLE Trials (
    trialID INT PRIMARY KEY,
    trialName VARCHAR(100),
    startDate DATE,
    endDate DATE
);

CREATE TABLE PatientTrials (
    patientTrialID INT PRIMARY KEY,
    patientID INT,
    trialID INT,
    enrollmentDate DATE,
    FOREIGN KEY (patientID) REFERENCES Patients(patientID),
    FOREIGN KEY (trialID) REFERENCES Trials(trialID)
);

CREATE TABLE Visits (
    visitID INT PRIMARY KEY,
    patientID INT,
    doctorID INT,
    visitDate DATE,
    diagnosis VARCHAR(100),
    FOREIGN KEY (patientID) REFERENCES Patients(patientID),
    FOREIGN KEY (doctorID) REFERENCES Doctors(doctorID)
);

CREATE TABLE Medications (
    medicationID INT PRIMARY KEY,
    medicationName VARCHAR(100),
    dosage VARCHAR(50)
);

CREATE TABLE Prescriptions (
    prescriptionID INT PRIMARY KEY,
    visitID INT,
    medicationID INT,
    quantity INT,
    FOREIGN KEY (visitID) REFERENCES Visits(visitID),
    FOREIGN KEY (medicationID) REFERENCES Medications(medicationID)
);

-- =========================
-- Insert Data
-- =========================

INSERT INTO Patients VALUES
(1, 'Ali', 'Khan', 'Male', '1995-05-10', 'Karachi'),
(2, 'Sara', 'Ahmed', 'Female', '1998-08-21', 'Lahore'),
(3, 'John', 'Doe', 'Male', '1990-02-15', 'Karachi'),
(4, 'Ayesha', 'Malik', 'Female', '1992-11-30', 'Islamabad'),
(5, 'David', 'Smith', 'Male', '1985-07-07', 'Karachi');

INSERT INTO Doctors VALUES
(1, 'Dr. Hassan', 'Cardiology'),
(2, 'Dr. Fatima', 'Neurology'),
(3, 'Dr. John', 'Oncology');

INSERT INTO Trials VALUES
(1, 'Cancer Study A', '2024-01-01', '2025-01-01'),
(2, 'Heart Study B', '2024-03-01', '2025-03-01');

INSERT INTO PatientTrials VALUES
(1, 1, 2, '2024-03-10'),
(2, 2, 1, '2024-01-15'),
(3, 3, 1, '2024-02-20'),
(4, 4, 2, '2024-03-25');

INSERT INTO Visits VALUES
(1, 1, 1, '2024-04-01', 'Hypertension'),
(2, 2, 2, '2024-04-02', 'Migraine'),
(3, 3, 3, '2024-04-03', 'Cancer'),
(4, 1, 1, '2024-04-10', 'Follow-up'),
(5, 5, 1, '2024-04-11', 'Heart Disease');

INSERT INTO Medications VALUES
(1, 'MedA', '10mg'),
(2, 'MedB', '5mg'),
(3, 'MedC', '20mg');

INSERT INTO Prescriptions VALUES
(1, 1, 1, 10),
(2, 2, 2, 5),
(3, 3, 3, 7),
(4, 4, 1, 8),
(5, 5, 2, 6);


--First names of patients from Karachi--
SELECT firstName from Patients where city='Karachi' order by firstName;

--Total patients in each city--
SELECT city, count(patientID) AS totalPatients from Patients group by city;

--Patient with visit id, first name, last name, visit date--
SELECT v.visitID, v.patientID, p.firstName, p.lastName, v.visitDate from Visits v join Patients p on v.patientID = p.patientID;

--Doctor with patient name, visit id, visit date, and diagnosis--
SELECT d.doctorName, p.firstName AS patientName, v.visitID, v.visitDate, v.diagnosis from Doctors d join Visits v on d.doctorID = v.doctorID join Patients p on v.patientID = p.patientID;

--Patient with trail id and admission data--
SELECT pt.patientID, pt.trialID, pt.enrollmentDate, p.firstName, p.lastName from Patients p left join patientTrials pt on p.patientID = pt.patientID left join Trials t on pt.trialID = t.trialID;

--Patient and its admission date--
SELECT p.patientID, p.firstName, p.lastName, pt.trialID, pt.enrollmentDate from Patients p left join PatientTrials pt on p.patientID = pt.patientID;

--Patient with trial id--
SELECT p.patientID, p.firstName, p.lastName, pt.patientTrialID from Patients p left join PatientTrials pt on p.patientID = pt.patientID where pt.patientTrialID IS NULL;

--Each visit with Prescription and medication detail--
SELECT v.visitID, v.visitDate, p. prescriptionID, p.medicationID, m.medicationName, m.dosage from Visits v left join Prescriptions p on v.visitID = p.visitID join Medications m on p.medicationID = m.medicationID;

--Doctors with total visits--
SELECT v.doctorID, count(v.doctorID), d.doctorName, count(visitID) as totalVisits, d.doctorName from Visits v join Doctors d on v.doctorID = d.doctorID group by v.doctorID;


--Aggregation & Group By--

--Patient with total visits--
SELECT patientID, count(visitID) AS TotalVisits from Visits group by patientID;

--Patient who visited the clinic most--
SELECT TOP 1 patientID, count(visitID) AS TotalVisits from Visits GROUP BY patientID ORDER BY TotalVisits DESC;

--Count number of Patients in each Trial--
SELECT trialID, count(patientID) AS TotalPatients from PatientTrials GROUP BY trialID;

--Medication with average prescription quantity--
SELECT medicationID, AVG(quantity) AS AvergaePrescriptionQuantity from Prescriptions group by medicationID;
--OR (using Inner join)--
SELECT m.medicationID, AVG(p.quantity) AS AveragePrescriptionQuantity from Medications m JOIN Prescriptions p on m.medicationID = p.medicationID GROUP BY m.medicationID;

--Get top 2 doctors with highest number of visits--
SELECT TOP 2 d.doctorID, d.doctorName, COUNT(v.visitID) AS TotalVisits FROM Doctors d JOIN Visits v on d.doctorID = v.doctorID GROUP BY d.doctorID,d.doctorName ORDER BY TotalVisits DESC;


--Find patients who have more visits than average--
SELECT patientID FROM Visits WHERE COUNT(visitID) > (SELECT AVG(visitID) from Visits);

SELECT patientID FROM Visits HAVING COUNT(VisitID) > AVG(COUNT(VisitID));

WITH TotalVisitsPerPatient AS(
SELECT patientID, COUNT(visitID) AS TotalVisits FROM Visits GROUP BY patientID
)
SELECT patientID from TotalVisitsPerPatient WHERE TotalVisits > (SELECT AVG(TotalVisits) FROM TotalVisitsPerPatient);

--Get doctors who handled more visits than average--
WITH TotalVisitsPerDoctor AS(
SELECT doctorID, COUNT(visitID) AS TotalVisits FROM Visits GROUP BY doctorID
)
SELECT doctorID FROM TotalVisitsPerDoctor WHERE TotalVisits > (SELECT AVG(TotalVisits) FROM TotalVisitsPerDoctor);

--Find patients who participated in "Cancer Study A"--
SELECT pt.patientID, p.firstName,p.lastName, t.trialName FROM PatientTrials pt JOIN Patients p ON pt.patientID = p.patientID JOIN Trials t on pt.trialID = t.trialID WHERE trialName = 'Cancer Study A';

--Get medications that were prescribed more than average quantity--
WITH TotalPrescriptionPerMedication AS(
SELECT medicationID, quantity, count(quantity) AS TotalQuantity FROM Prescriptions GROUP BY medicationID
)
SELECT medicationID FROM TotalPrescriptionPerMedication WHERE TotalQuantity > (SELECT AVG(TotalQuantity) FROM TotalPrescriptionPerMedication);

--Find patients who visited more than 1 doctor--
SELECT patientID, COUNT(doctorID) AS TotalDoctors FROM Visits GROUP BY patientID HAVING COUNT(doctorID) > 1;

--Get latest visit for each patient--


--Find patients with no prescriptions--
SELECT p.patientID, p.firstName, p.lastName, pr.visitID FROM Prescriptions pr JOIN Visits v on pr.visitID = v.visitID JOIN Patients p ON v.patientID = p.patientID WHERE pr.prescriptionID IS NULL OR pr.prescriptionID = '';

--Get running total of prescriptions quantity ordered by visit date--
SELECT SUM(p.quantity) AS TotalPrescriptions, v.visitDate FROM Prescriptions p JOIN Visits v ON p.visitID = v.visitID GROUP BY v.visitDate;

--Rank doctors based on number of visits--
SELECT d.doctorID, d.doctorName, COUNT(v.visitID) AS TotalVisits FROM Doctors d JOIN Visits v ON d.doctorID = v.doctorID GROUP BY d.doctorID, d.doctorName ORDER BY TotalVisits DESC;

--Find second most active doctor (by visits)--
SELECT d.doctorID, d.doctorName, COUNT(visitID) AS TotalVisits FROM Doctors d JOIN Visits v ON d.doctorID = v.doctorID GROUP BY d.doctorID, d.doctorName ORDER BY COUNT(visitID) DESC
OFFSET 1 ROWS
FETCH NEXT 1 ROWS ONLY;

--Get latest visit for each patient--
SELECT p.patientID, p.firstName, p.lastName, visitID, visitDate FROM (
 SELECT *, ROW_NUMBER() OVER (PARTITION BY patientID ORDER BY visitDate DESC) AS rn FROM Visits) t JOIN Patients p ON t.patientID = p.patientID
 WHERE rn=1;


--Get latest visit for each doctor--
 SELECT d.doctorID,d.doctorName, visitID, visitDate FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY doctorID ORDER BY visitDate DESC) AS rn FROM Visits) t JOIN Doctors d ON d.doctorID = t.doctorID WHERE rn = 1;

 --A patient visited multiple times — find first visit date per patient--
 SELECT patientID, visitDate, COUNT(visitID) AS TotalVisits FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY patientID ORDER BY visitDate) AS rn FROM Visits) t
 WHERE rn =1 AND COUNT(patientID) > 1;


--Create a stored procedure to Get all patients from a given city (input parameter)--
CREATE OR ALTER PROCEDURE SameCityPatients @cityName CHAR(30) AS BEGIN
SELECT patientID, firstName, lastName, city FROM Patients WHERE city = @cityName END;

EXEC SameCityPatients 'Karachi';

--Create a stored procedure to: Return all visits of a specific patientID--
CREATE OR ALTER PROCEDURE getVisitDetails @patientID INT AS BEGIN
SELECT * FROM Visits WHERE patientID = @patientID END;
GO
EXEC getvisitDetails 2;

--Create a stored procedure to: Get all doctors by specialization--
CREATE OR ALTER PROCEDURE doctorsSpecialization AS BEGIN
SELECT * FROM Doctors ORDER BY specialization END;
GO
EXEC doctorsSpecialization;
GO

--Create a stored procedure to: Count number of visits for a given patientID and Return the count--
CREATE OR ALTER PROCEDURE getVisitCount @patientID INT AS BEGIN
SELECT p.patientID, p.firstName, p.lastName, COUNT(v.visitID) AS TotalVisits FROM Visits v JOIN Patients p ON v.patientID = p.patientID WHERE p.patientID = @patientID GROUP BY p.patientID, p.firstName, p.lastName END;
GO
EXEC getVisitCount 2;

--Create a stored procedure to: Get all patients who are enrolled in a specific trial name--
CREATE OR ALTER PROCEDURE getPatientFromTrial @trialName CHAR(40) AS BEGIN
SELECT p.patientID, p.firstName, p.lastName, pt.patientTrialID, t.trialName FROM Patients p JOIN PatientTrials pt ON p.patientID = pt.patientID JOIN Trials t ON pt.trialID = t.trialID WHERE t.trialName = @trialName END;
GO 
EXEC getPatientFromTrial 'Heart Study B';

--Create a stored procedure to: Insert a new patient into the Patients table (Use parameters for all fields)--
CREATE OR ALTER PROCEDURE insertPatient 
@patientID INT,
@firstName CHAR,
@lastName CHAR,
@gender CHAR(6),
@dateOfBirth DATE,
@city CHAR (30)

AS BEGIN 
INSERT INTO Patients VALUES(@patientID, @firstName, @lastName, @gender, @dateOfBirth, @city) END;
GO
EXEC insertPatient 6, Tahir, Ali, Male, '2026-03-23', 'Hyderabad';

--Create a stored procedure to: Return latest visit details for a given patient--
CREATE OR ALTER PROCEDURE getPatientVisitDetails @patientID INT AS BEGIN
SELECT TOP 1 p.patientID, p.firstName, p.lastName, v.visitDate FROM Patients p JOIN Visits v ON p.patientID = v.patientID WHERE p.patientID = @patientID ORDER BY v.visitDate END;
GO
EXEC getPatientVisitDetails 3;

--Create a stored procedure to: Get doctor-wise total visits (Use GROUP BY inside procedure)--
CREATE OR ALTER PROCEDURE getDoctorVisits AS BEGIN
SELECT d.doctorID, d.doctorName, COUNT(v.visitID) AS TotalVisits FROM Doctors d JOIN Visits v ON d.doctorID = v.doctorID GROUP BY d.doctorID, d.doctorName END;
EXEC getDoctorVisits;

--Create a stored procedure to: Return patients who have more than X visits (X should be a parameter)--
CREATE OR ALTER PROCEDURE getPatientXVisits @visit INT AS BEGIN
SELECT p.patientID, p.firstName, p.lastName, COUNT(v.visitID) AS TotalVisits FROM Patients p JOIN Visits v ON p.patientID = v.patientID GROUP BY p.patientID, p.firstName, p.lastName HAVING COUNT(v.visitID) > @visit END;
GO
EXEC getPatientXVisits 1;

--Create a stored procedure to: Update medication quantity for a given prescriptionID--
CREATE OR ALTER PROCEDURE updatePrescriptionQuantity @prescriptionID INT, @quantity INT AS BEGIN
UPDATE Prescriptions 
SET quantity = @quantity
WHERE prescriptionID = @prescriptionID END;
GO
EXEC updatePrescriptionQuantity 2, 7;

--Create a stored procedure to: Delete duplicate patients based on:firstName lastName dateOfBirth--
CREATE OR ALTER PROCEDURE deleteDuplicatedPatients AS BEGIN
DELETE FROM Patients HAVING COUNT(*) > 1 GROUP BY patientID END;

--Create a stored procedure to: Return a ranked list of doctors based on number of visits--
CREATE OR ALTER PROCEDURE getDoctorsRanks AS BEGIN
SELECT d.doctorID, d.doctorName, COUNT(v.visitID) AS TotalVisits FROM Doctors d JOIN Visits v ON d.doctorID = v.doctorID GROUP BY d.doctorID, d.doctorName ORDER BY COUNT(v.visitID) DESC END;
GO 
EXEC getDoctorsRanks;






