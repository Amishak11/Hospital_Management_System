DROP DATABASE IF EXISTS db;
CREATE DATABASE Hospital;
USE Hospital;

CREATE TABLE Patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    contact VARCHAR(25)
);

CREATE TABLE Appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    doctor_name VARCHAR(100),
    appointment_date DATE,
    status VARCHAR(50) DEFAULT 'Scheduled',
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

CREATE TABLE Billing (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT,
    amount DECIMAL(10,2),
    status VARCHAR(50) DEFAULT 'Pending',
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id)
);

DELIMITER $$

CREATE PROCEDURE AddPatient(
    IN p_name VARCHAR(100),
    IN p_age INT,
    IN p_gender VARCHAR(10),
    IN p_contact VARCHAR(15)
)
BEGIN
    INSERT INTO Patients (name, age, gender, contact)
    VALUES (p_name, p_age, p_gender, p_contact);
    SELECT LAST_INSERT_ID() AS patient_id;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE BookAppointment(
    IN p_id INT,
    IN doc_name VARCHAR(100),
    IN app_date DATE
)
BEGIN
    INSERT INTO Appointments (patient_id, doctor_name, appointment_date)
    VALUES (p_id, doc_name, app_date);
    SELECT LAST_INSERT_ID() AS appointment_id;
END $$

DELIMITER ;



DELIMITER $$

CREATE PROCEDURE GenerateBill(IN p_id INT, IN bill_amount DECIMAL(10,2))
BEGIN
    INSERT INTO Billing (patient_id, amount, status)
    VALUES (p_id, bill_amount, 'Pending');
END $$

DELIMITER ;




DELIMITER $$

CREATE PROCEDURE PayBill(IN p_id INT)
BEGIN
    DECLARE bill_amount DECIMAL(10,2);
    
    START TRANSACTION;
    
    SELECT amount INTO bill_amount FROM Billing WHERE patient_id = p_id AND status = 'Pending' LIMIT 1;
    
    IF bill_amount IS NOT NULL THEN
        UPDATE Billing SET status = 'Paid' WHERE patient_id = p_id AND status = 'Pending';
        COMMIT;
    ELSE
        ROLLBACK;
    END IF;
    
END $$

DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetAllPatients()
BEGIN
    SELECT * FROM Patients;
END //

DELIMITER ;
DELIMITER //





DELIMITER $$

CREATE TRIGGER After_Appointment_Update
AFTER INSERT ON Appointments
FOR EACH ROW
BEGIN
    UPDATE Patients
    SET contact = CONCAT('Updated-', contact)
    WHERE patient_id = NEW.patient_id;
END $$
///
DELIMITER ;

DROP TRIGGER IF EXISTS After_Appointment_Update;


DELIMITER $$
CREATE PROCEDURE PayBill(IN b_id INT)
BEGIN
    UPDATE Bills 
    SET status = 'Paid' 
    WHERE bill_id = b_id;  -- Update only the selected bill
END;
//
DELIMITER ;



SELECT * FROM db.appointments;

DELETE  from appointments where doctor_name ="Dr Taksh";

SET SQL_SAFE_UPDATES = 0;
DELETE FROM appointments WHERE doctor_name = "Dr Taksh";
SET SQL_SAFE_UPDATES = 1;





SELECT * FROM db.billing;

delete from billing;
SET SQL_SAFE_UPDATES = 0;
delete from billing;
SET SQL_SAFE_UPDATES = 1;


