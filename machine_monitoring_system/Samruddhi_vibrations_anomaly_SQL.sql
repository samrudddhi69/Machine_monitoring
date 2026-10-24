CREATE DATABASE machine_monitoring;
USE machine_monitoring;

CREATE TABLE Machines (
    machine_id INT PRIMARY KEY,
    machine_name VARCHAR(50) NOT NULL,
    plant VARCHAR(30) NOT NULL,
    temperature_limit DECIMAL(6,2) NOT NULL,
    vibration_limit DECIMAL(6,2) NOT NULL,
    power_limit_kw DECIMAL(7,2) NOT NULL,
    target_units_per_day INT NOT NULL,
    maintenance_interval_days INT NOT NULL,
    last_maintenance_date DATE NOT NULL
);

CREATE TABLE SensorReadings (
    reading_id INT PRIMARY KEY,
    machine_id INT NOT NULL,
    recorded_at DATETIME NOT NULL,
    temperature_c DECIMAL(6,2),
    vibration_mm_s DECIMAL(6,2),
    power_kw DECIMAL(7,2),
    FOREIGN KEY (machine_id) REFERENCES Machines(machine_id)
);

CREATE TABLE ProductionLogs (
    log_id INT PRIMARY KEY,
    machine_id INT NOT NULL,
    production_date DATE NOT NULL,
    units_produced INT NOT NULL,
    units_rejected INT NOT NULL,
    downtime_minutes INT NOT NULL,
    FOREIGN KEY (machine_id) REFERENCES Machines(machine_id)
);

CREATE TABLE MaintenanceEvents (
    event_id INT PRIMARY KEY,
    machine_id INT NOT NULL,
    maintenance_date DATE NOT NULL,
    issue_type VARCHAR(60) NOT NULL,
    action_taken VARCHAR(100) NOT NULL,
    downtime_minutes INT NOT NULL,
    FOREIGN KEY (machine_id) REFERENCES Machines(machine_id)
);     

INSERT INTO Machines VALUES
(101,'CNC-01','Plant-A',80,4.5,18,500,90,'2026-08-20'),
(102,'Press-02','Plant-A',75,5.0,25,800,60,'2026-09-10'),
(103,'Conveyor-03','Plant-B',65,3.5,12,1200,45,'2026-09-01'),
(104,'Pump-04','Plant-B',70,4.0,10,350,30,'2026-09-20'),
(105,'Robot-05','Plant-A',85,6.0,30,600,120,'2026-07-15');

INSERT INTO SensorReadings VALUES
(1001,101,'2026-10-24 09:00:00',78,3.4,16.5),
(1002,101,'2026-10-24 09:15:00',84,4.8,19.1),
(1003,102,'2026-10-24 09:00:00',70,3.8,22.5),
(1004,102,'2026-10-24 09:15:00',77,5.4,26.2),
(1005,103,'2026-10-24 09:00:00',63,3.2,11.5),
(1006,103,'2026-10-24 09:15:00',68,4.1,12.7),
(1007,104,'2026-10-24 09:00:00',72,4.4,10.8),
(1008,105,'2026-10-24 09:00:00',81,5.5,31.0),
(1009,105,'2026-10-24 09:15:00',88,6.5,33.0);

INSERT INTO ProductionLogs VALUES
(2001,101,'2026-10-23',480,12,35),
(2002,101,'2026-10-24',450,30,60),
(2003,102,'2026-10-23',790,20,25),
(2004,102,'2026-10-24',700,42,90),
(2005,103,'2026-10-23',1180,18,15),
(2006,104,'2026-10-24',320,24,120),
(2007,105,'2026-10-24',610,8,10);

INSERT INTO MaintenanceEvents VALUES
(3001,101,'2026-08-20','Bearing','Lubrication and inspection',45),
(3002,102,'2026-09-10','Hydraulic','Hydraulic inspection',30),
(3003,103,'2026-09-01','Belt','Belt adjustment',60),
(3004,104,'2026-09-20','Pump seal','Seal replacement',120);


-- Query 1
-- Write a query listing every reading above the machine vibration limit, with machine name, plant, timestamp, measured value, configured limit, and excess above the limit.

SELECT
    m.machine_name,
    m.plant,
    s.recorded_at,
    s.vibration_mm_s,
    m.vibration_limit,
    s.vibration_mm_s - m.vibration_limit AS excess
FROM Machines m
JOIN SensorReadings s
    ON m.machine_id = s.machine_id
WHERE s.vibration_mm_s > m.vibration_limit
ORDER BY m.machine_id, s.recorded_at;

-- Query 2
-- Write a summary query grouped by machine that returns average vibration, maximum vibration, and count of above-limit readings. 
-- Show only machines with at least two above-limit readings. 
-- (This aggregate query does not need to detect consecutiveness.)


SELECT
    m.machine_id,
    m.machine_name,
    AVG(s.vibration_mm_s) AS avg_vibration,
    MAX(s.vibration_mm_s) AS max_vibration,
    SUM(
        CASE
            WHEN s.vibration_mm_s > m.vibration_limit THEN 1
            ELSE 0
        END
    ) AS above_limit_count
FROM Machines m
JOIN SensorReadings s
    ON m.machine_id = s.machine_id
GROUP BY m.machine_id, m.machine_name
HAVING SUM(
    CASE
        WHEN s.vibration_mm_s > m.vibration_limit THEN 1
        ELSE 0
    END
) >= 2;