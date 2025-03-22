-- Create Specializations Table
CREATE TABLE Specializations (
    SpecializationID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL UNIQUE
);

-- Create Doctors Table
CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    SpecializationID INT,
    ContactNumber VARCHAR(15) UNIQUE,
    Email VARCHAR(100) UNIQUE,
    FOREIGN KEY (SpecializationID) REFERENCES Specializations(SpecializationID) ON DELETE SET NULL
);

-- Create Patients Table
CREATE TABLE Patients (
    PatientID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    DOB DATE,
    Gender ENUM('Male', 'Female', 'Other'),
    ContactNumber VARCHAR(15) UNIQUE,
    Email VARCHAR(100) UNIQUE
);

-- Create Appointments Table
CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY AUTO_INCREMENT,
    PatientID INT,
    DoctorID INT,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    Status ENUM('Scheduled', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE,
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID) ON DELETE CASCADE
);

-- Create Prescriptions Table
CREATE TABLE Prescriptions (
    PrescriptionID INT PRIMARY KEY AUTO_INCREMENT,
    AppointmentID INT,
    MedicineDetails TEXT NOT NULL,
    Instructions TEXT NOT NULL,
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID) ON DELETE CASCADE
);

-- Create Payments Table
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY AUTO_INCREMENT,
    AppointmentID INT,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentDate DATE NOT NULL,
    PaymentStatus ENUM('Pending', 'Completed') DEFAULT 'Pending',
    FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID) ON DELETE CASCADE
);

-- Insert Sample Data
INSERT INTO Specializations (Name) VALUES ('Cardiologist'), ('Dermatologist'), ('Orthopedic');

INSERT INTO Doctors (Name, SpecializationID, ContactNumber, Email) 
VALUES ('Dr. A Sharma', 1, '9876543210', 'a.sharma@example.com'),
       ('Dr. B Mehta', 2, '9876543211', 'b.mehta@example.com');

INSERT INTO Patients (Name, DOB, Gender, ContactNumber, Email)
VALUES ('Rahul Kumar', '1990-05-15', 'Male', '9123456789', 'rahul.k@example.com'),
       ('Sneha Rao', '1995-10-20', 'Female', '9234567890', 'sneha.rao@example.com');

INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, AppointmentTime, Status)
VALUES (1, 1, '2024-03-25', '10:30:00', 'Scheduled'),
       (2, 2, '2024-03-26', '11:00:00', 'Completed');

INSERT INTO Prescriptions (AppointmentID, MedicineDetails, Instructions)
VALUES (2, 'Paracetamol 500mg, Vitamin C', 'Take after food');

INSERT INTO Payments (AppointmentID, Amount, PaymentDate, PaymentStatus)
VALUES (2, 500.00, '2024-03-26', 'Completed');

-- Queries for Scheduling, Rescheduling, and Cancelling

-- Reschedule an Appointment
UPDATE Appointments 
SET AppointmentDate = '2024-04-01', AppointmentTime = '12:00:00' 
WHERE AppointmentID = 1;

-- Cancel an Appointment
UPDATE Appointments 
SET Status = 'Cancelled' 
WHERE AppointmentID = 1;

-- Retrieve Scheduled Appointments
SELECT a.AppointmentID, p.Name AS PatientName, d.Name AS DoctorName, a.AppointmentDate, a.AppointmentTime
FROM Appointments a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Doctors d ON a.DoctorID = d.DoctorID
WHERE a.Status = 'Scheduled';

-- Retrieve All Specializations
SELECT * FROM Specializations;

-- Retrieve All Doctors
SELECT d.DoctorID, d.Name AS DoctorName, s.Name AS Specialization, d.ContactNumber, d.Email
FROM Doctors d
LEFT JOIN Specializations s ON d.SpecializationID = s.SpecializationID;

-- Retrieve All Patients
SELECT * FROM Patients;
SELECT * FROM Doctors;
-- Retrieve All Appointments
SELECT a.AppointmentID, p.Name AS PatientName, d.Name AS DoctorName, a.AppointmentDate, a.AppointmentTime, a.Status
FROM Appointments a
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Doctors d ON a.DoctorID = d.DoctorID;

-- Retrieve All Prescriptions
SELECT pr.PrescriptionID, p.Name AS PatientName, d.Name AS DoctorName, pr.MedicineDetails, pr.Instructions
FROM Prescriptions pr
JOIN Appointments a ON pr.AppointmentID = a.AppointmentID
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Doctors d ON a.DoctorID = d.DoctorID;

-- Retrieve All Payments
SELECT py.PaymentID, p.Name AS PatientName, d.Name AS DoctorName, py.Amount, py.PaymentDate, py.PaymentStatus
FROM Payments py
JOIN Appointments a ON py.AppointmentID = a.AppointmentID
JOIN Patients p ON a.PatientID = p.PatientID
JOIN Doctors d ON a.DoctorID = d.DoctorID;
