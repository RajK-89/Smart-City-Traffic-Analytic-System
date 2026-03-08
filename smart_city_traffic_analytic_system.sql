CREATE DATABASE smart_city_traffic_analytic_system;

USE smart_city_traffic_analytic_system;

-- For Storing Zones
CREATE TABLE zones (
    zone_id INT PRIMARY KEY,
    zone_name VARCHAR(100) NOT NULL,
    zone_code VARCHAR(20) NOT NULL UNIQUE,
    area_sq_km DECIMAL(8,2) NOT NULL,
    population_density INT NOT NULL
);

-- For Storing Roads
CREATE TABLE roads (
    road_id INT PRIMARY KEY,
    zone_id INT NOT NULL,
    road_name VARCHAR(150) NOT NULL,
    road_type VARCHAR(50) NOT NULL,
    total_lanes INT NOT NULL,
    length_km DECIMAL(6,2) NOT NULL,
    CONSTRAINT fk_roads_zone
        FOREIGN KEY (zone_id) REFERENCES zones(zone_id)
        ON DELETE CASCADE
);

-- For Storing Intersections
CREATE TABLE intersections (
    intersection_id INT PRIMARY KEY,
    zone_id INT NOT NULL,
    intersection_name VARCHAR(150) NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    connected_roads INT NOT NULL,
    CONSTRAINT fk_intersections_zone
        FOREIGN KEY (zone_id) REFERENCES zones(zone_id)
        ON DELETE CASCADE
);

-- For Storing Traffic_Signals
CREATE TABLE traffic_signals (
    signal_id INT PRIMARY KEY,
    intersection_id INT NOT NULL,
    current_status ENUM('RED','YELLOW','GREEN') NOT NULL,
    cycle_duration_sec INT NOT NULL,
    last_updated DATETIME NOT NULL,
    CONSTRAINT fk_signals_intersection
        FOREIGN KEY (intersection_id) REFERENCES intersections(intersection_id)
        ON DELETE CASCADE
);

-- For Storing Signal_Timing_Plans
CREATE TABLE signal_timing_plans (
    plan_id INT PRIMARY KEY,
    signal_id INT NOT NULL,
    green_time_sec INT NOT NULL,
    yellow_time_sec INT NOT NULL,
    red_time_sec INT NOT NULL,
    effective_from DATETIME NOT NULL,
    CONSTRAINT fk_timing_signal
        FOREIGN KEY (signal_id) REFERENCES traffic_signals(signal_id)
        ON DELETE CASCADE
);

-- For Storing Sensors
CREATE TABLE sensors (
    sensor_id INT PRIMARY KEY,
    road_id INT NOT NULL,
    sensor_type VARCHAR(50) NOT NULL,
    installation_date DATE NOT NULL,
    status ENUM('ACTIVE','INACTIVE') NOT NULL,
    last_service_date DATE NOT NULL,
    CONSTRAINT fk_sensors_road
        FOREIGN KEY (road_id) REFERENCES roads(road_id)
        ON DELETE CASCADE
);

-- For Storing Traffic_Readings
CREATE TABLE traffic_readings (
    reading_id BIGINT PRIMARY KEY,
    sensor_id INT NOT NULL,
    vehicle_count INT NOT NULL,
    avg_speed_kmph DECIMAL(5,2) NOT NULL,
    occupancy_rate DECIMAL(5,2) NOT NULL,
    recorded_at DATETIME NOT NULL,
    CONSTRAINT fk_readings_sensor
        FOREIGN KEY (sensor_id) REFERENCES sensors(sensor_id)
        ON DELETE CASCADE
);

-- For Storing Cameras
CREATE TABLE cameras (
    camera_id INT PRIMARY KEY,
    intersection_id INT NOT NULL,
    camera_type VARCHAR(50) NOT NULL,
    resolution VARCHAR(20) NOT NULL,
    status ENUM('ACTIVE','INACTIVE') NOT NULL,
    installation_date DATE NOT NULL,
    CONSTRAINT fk_cameras_intersection
        FOREIGN KEY (intersection_id) REFERENCES intersections(intersection_id)
        ON DELETE CASCADE
);

-- For Storing Vehicles
CREATE TABLE vehicles (
    vehicle_id BIGINT PRIMARY KEY,
    vehicle_number VARCHAR(20) NOT NULL UNIQUE,
    vehicle_type VARCHAR(50) NOT NULL,
    registration_state VARCHAR(50) NOT NULL,
    registered_date DATE NOT NULL
);

-- For Storing Violations
CREATE TABLE violations (
    violation_id BIGINT PRIMARY KEY,
    vehicle_id BIGINT NOT NULL,
    camera_id INT NOT NULL,
    violation_type VARCHAR(100) NOT NULL,
    violation_time DATETIME NOT NULL,
    fine_amount DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_violation_vehicle
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_violation_camera
        FOREIGN KEY (camera_id) REFERENCES cameras(camera_id)
        ON DELETE CASCADE
);

-- For Storing Fines
CREATE TABLE fines (
    fine_id INT PRIMARY KEY,
    violation_id BIGINT NOT NULL,
    amount_due DECIMAL(10,2) NOT NULL,
    payment_status ENUM('PENDING','PAID') NOT NULL,
    issued_date DATE NOT NULL,
    due_date DATE NOT NULL,
    CONSTRAINT fk_fines_violation
        FOREIGN KEY (violation_id) REFERENCES violations(violation_id)
        ON DELETE CASCADE
);

-- For Storing Incidents
CREATE TABLE incidents (
    incident_id INT PRIMARY KEY,
    road_id INT NOT NULL,
    incident_type VARCHAR(100) NOT NULL,
    severity_level VARCHAR(50) NOT NULL,
    reported_time DATETIME NOT NULL,
    status ENUM('OPEN','RESOLVED') NOT NULL,
    CONSTRAINT fk_incident_road
        FOREIGN KEY (road_id) REFERENCES roads(road_id)
        ON DELETE CASCADE
);

-- For Storing Emergency_Responses
CREATE TABLE emergency_responses (
    response_id INT PRIMARY KEY,
    incident_id INT NOT NULL,
    response_team_name VARCHAR(100) NOT NULL,
    dispatch_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    clearance_time DATETIME NOT NULL,
    CONSTRAINT fk_response_incident
        FOREIGN KEY (incident_id) REFERENCES incidents(incident_id)
        ON DELETE CASCADE
);

-- For Storing Public_Transport
CREATE TABLE public_transport (
    transport_id INT PRIMARY KEY,
    vehicle_number VARCHAR(20) NOT NULL,
    route_name VARCHAR(100) NOT NULL,
    capacity INT NOT NULL,
    operator_name VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL
);

-- For Storing GPS_Tracking Details
CREATE TABLE gps_tracking (
    tracking_id BIGINT PRIMARY KEY,
    transport_id INT NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    speed_kmph DECIMAL(5,2) NOT NULL,
    recorded_at DATETIME NOT NULL,
    CONSTRAINT fk_tracking_transport
        FOREIGN KEY (transport_id) REFERENCES public_transport(transport_id)
        ON DELETE CASCADE
);

-- Data For zones
INSERT INTO zones (zone_id, zone_name, zone_code, area_sq_km, population_density) VALUES
(1, 'Chennai Central', 'CHC01', 15.50, 12000),
(2, 'Chennai North', 'CHN02', 25.75, 8000),
(3, 'Chennai South', 'CHS03', 30.25, 9000),
(4, 'Coimbatore Central', 'COC04', 20.10, 8500),
(5, 'Coimbatore East', 'COE05', 18.75, 7800),
(6, 'Madurai Central', 'MDC06', 22.50, 9500),
(7, 'Madurai South', 'MDS07', 25.00, 8800),
(8, 'Tiruchirappalli Central', 'TRC08', 21.25, 8200),
(9, 'Tirunelveli Central', 'TNC09', 19.80, 7400),
(10, 'Salem Central', 'SAC10', 23.00, 8000),
(11, 'Erode Central', 'ERC11', 17.50, 7600),
(12, 'Vellore Central', 'VEC12', 20.00, 8100),
(13, 'Tiruppur Central', 'TPC13', 18.50, 7900),
(14, 'Nagapattinam Central', 'NAC14', 16.20, 7200),
(15, 'Thoothukudi Central', 'THC15', 19.00, 7300),
(16, 'Dindigul Central', 'DIC16', 17.75, 7700),
(17, 'Kanchipuram Central', 'KAC17', 21.00, 8000),
(18, 'Chengalpattu Central', 'CHG18', 20.50, 7900),
(19, 'Cuddalore Central', 'CUC19', 18.00, 7500),
(20, 'Namakkal Central', 'NAC20', 17.25, 7400),
(21, 'Pudukkottai Central', 'PUC21', 16.80, 7200),
(22, 'Ramanathapuram Central', 'RAC22', 19.50, 7600),
(23, 'Thanjavur Central', 'THC23', 22.00, 7800),
(24, 'Kanyakumari Central', 'KKC24', 18.50, 7300),
(25, 'Sivaganga Central', 'SVC25', 17.90, 7400),
(26, 'Karur Central', 'KRC26', 18.75, 7500),
(27, 'Viluppuram Central', 'VIC27', 20.25, 7700),
(28, 'Tiruvannamalai Central', 'TVC28', 21.00, 7800),
(29, 'Perambalur Central', 'PEC29', 16.50, 7100),
(30, 'Krishnagiri Central', 'KRC30', 19.50, 7600),
(31, 'Thiruvallur Central', 'THC31', 23.25, 8200),
(32, 'Theni Central', 'THN32', 20.75, 7800),
(33, 'Nagapattinam South', 'NAS33', 17.50, 7200),
(34, 'Tiruppur South', 'TPS34', 18.25, 7700),
(35, 'Coimbatore South', 'COS35', 21.50, 8100),
(36, 'Madurai North', 'MDN36', 24.00, 8900),
(37, 'Chennai West', 'CHW37', 26.50, 8300),
(38, 'Salem East', 'SAE38', 20.25, 7800),
(39, 'Erode South', 'ERS39', 18.50, 7500),
(40, 'Vellore East', 'VEE40', 19.75, 7600);

-- Data For roads -- 
INSERT INTO roads (road_id, zone_id, road_name, road_type, total_lanes, length_km) VALUES
(01, 1, 'Anna Salai', 'Arterial', 6, 12.5),
(02, 1, 'Mount Road', 'Arterial', 4, 10.2),
(03, 2, 'Sowcarpet Road', 'Urban Street', 2, 5.5),
(04, 2, 'Ponneri Road', 'Highway', 4, 15.3),
(05, 3, 'Adyar Main Road', 'Arterial', 4, 8.8),
(06, 3, 'Besant Nagar Road', 'Urban Street', 2, 6.5),
(07, 4, 'Avinashi Road', 'Highway', 6, 14.0),
(08, 4, 'Race Course Road', 'Urban Street', 2, 4.5),
(09, 5, 'Trichy Road', 'Arterial', 4, 12.2),
(10, 5, 'Gandhipuram Road', 'Urban Street', 2, 5.0),
(11, 6, 'Alagar Koil Road', 'Urban Street', 2, 6.8),
(12, 6, 'Samanar Malai Road', 'Arterial', 4, 9.5),
(13, 7, 'Theni Road', 'Highway', 4, 13.0),
(14, 7, 'Madurai Bye-Pass', 'Highway', 6, 15.5),
(15, 8, 'BHEL Road', 'Arterial', 4, 11.0),
(16, 8, 'Trichy Bye-Pass', 'Highway', 6, 16.0),
(17, 9, 'Palayamkottai Road', 'Urban Street', 2, 5.5),
(18, 9, 'Sankarankoil Road', 'Arterial', 4, 12.0),
(19, 10, 'Omalur Road', 'Urban Street', 2, 6.5),
(20, 10, 'Salem Bye-Pass', 'Highway', 6, 14.2),
(21, 11, 'Bhavani Road', 'Arterial', 4, 10.5),
(22, 12, 'Katpadi Road', 'Arterial', 4, 11.2),
(23, 13, 'KKN Road', 'Highway', 6, 13.8),
(24, 14, 'Nagapattinam Beach Road', 'Urban Street', 2, 5.0),
(25, 15, 'Tuticorin Port Road', 'Highway', 4, 12.0),
(26, 16, 'Dindigul Bye-Pass', 'Highway', 6, 14.5),
(27, 17, 'Kanchipuram Temple Road', 'Urban Street', 2, 6.0),
(28, 18, 'Chengalpattu High Road', 'Arterial', 4, 9.8),
(29, 19, 'Cuddalore Main Road', 'Arterial', 4, 10.0),
(30, 20, 'Namakkal Ring Road', 'Highway', 6, 13.2),
(31, 21, 'Pudukkottai Market Road', 'Urban Street', 2, 5.5),
(32, 22, 'Ramanathapuram Coast Road', 'Highway', 4, 12.5),
(33, 23, 'Thanjavur East Road', 'Arterial', 4, 11.5),
(34, 24, 'Kanyakumari Main Road', 'Highway', 6, 14.0),
(35, 25, 'Sivaganga Bye-Pass', 'Highway', 6, 13.5),
(36, 26, 'Karur Textile Road', 'Arterial', 4, 10.0),
(37, 27, 'Viluppuram South Road', 'Urban Street', 2, 5.8),
(38, 28, 'Tiruvannamalai High Road', 'Highway', 6, 12.5),
(39, 29, 'Perambalur Ring Road', 'Arterial', 4, 10.5),
(40, 30, 'Krishnagiri Bye-Pass', 'Highway', 6, 14.0);

-- Data For Intersections --  
INSERT INTO intersections (intersection_id, zone_id, intersection_name, latitude, longitude, connected_roads) VALUES
(01, 1, 'Anna Salai & Mount Road', 13.0827, 80.2707, 4),
(02, 1, 'Egmore Junction', 13.0829, 80.2618, 3),
(03, 2, 'Sowcarpet Main Junction', 13.1050, 80.2820, 3),
(04, 2, 'Ponneri Crossroads', 13.2467, 80.2960, 4),
(05, 3, 'Adyar Signal', 13.0102, 80.2450, 3),
(06, 3, 'Besant Nagar Beach Junction', 12.9751, 80.2590, 3),
(07, 4, 'Avinashi & Race Course Junction', 11.0168, 76.9558, 4),
(08, 4, 'Gandhipuram Junction', 11.0123, 76.9690, 3),
(09, 5, 'Trichy Road Cross', 11.0183, 76.9620, 3),
(10, 5, 'Peelamedu Junction', 11.0305, 76.9850, 3),
(11, 6, 'Alagar Koil & Main Road', 9.9252, 78.1198, 3),
(12, 6, 'Madurai Bye-Pass Junction', 9.9120, 78.1230, 4),
(13, 7, 'Theni Cross', 10.0100, 77.4800, 3),
(14, 7, 'Samanar Malai Junction', 9.9500, 78.1300, 3),
(15, 8, 'BHEL & Trichy Bye-Pass', 10.7905, 78.7047, 4),
(16, 8, 'Railway Junction', 10.7910, 78.7055, 3),
(17, 9, 'Palayamkottai Signal', 8.7139, 77.7560, 3),
(18, 9, 'Sankarankoil Cross', 9.0680, 77.5180, 3),
(19, 10, 'Omalur Road Junction', 11.6670, 78.1510, 3),
(20, 10, 'Salem Bye-Pass Cross', 11.6700, 78.1550, 4),
(21, 11, 'Bhavani Road Cross', 11.3200, 77.6320, 3),
(22, 11, 'Erode Central Junction', 11.3410, 77.7170, 4),
(23, 12, 'Katpadi Road Signal', 12.9200, 79.1320, 3),
(24, 12, 'Vellore Fort Junction', 12.9205, 79.1330, 3),
(25, 13, 'Tiruppur Textile Road', 11.1080, 77.3410, 4),
(26, 13, 'Avinashi Road Cross', 11.1090, 77.3420, 3),
(27, 14, 'Nagapattinam Beach Cross', 10.7700, 79.8420, 3),
(28, 14, 'Harbour Junction', 10.7710, 79.8430, 3),
(29, 15, 'Tuticorin Port Road', 8.7640, 78.1340, 4),
(30, 15, 'V.O.C. Road Junction', 8.7650, 78.1350, 3),
(31, 16, 'Dindigul Central Junction', 10.3600, 77.9800, 3),
(32, 16, 'Palani Road Cross', 10.3640, 77.9850, 3),
(33, 17, 'Kanchipuram Temple Cross', 12.8350, 79.7040, 3),
(34, 17, 'Vellore Road Junction', 12.8400, 79.7100, 3),
(35, 18, 'Chengalpattu High Road', 12.6900, 79.9800, 4),
(36, 18, 'Tambaram Junction', 12.9250, 80.1230, 4),
(37, 19, 'Cuddalore Main Cross', 11.7480, 79.7680, 3),
(38, 19, 'Thittakudi Junction', 11.7490, 79.7700, 3),
(39, 20, 'Namakkal Ring Junction', 11.2180, 78.1670, 3),
(40, 20, 'Velur Cross', 11.2190, 78.1700, 3);

-- Data For traffic_signals
INSERT INTO traffic_signals (signal_id, intersection_id, current_status, cycle_duration_sec, last_updated) VALUES
(01, 01, 'RED', 120, '2026-02-22 08:00:00'),
(02, 02, 'GREEN', 90, '2026-02-22 08:02:00'),
(03, 03, 'YELLOW', 60, '2026-02-22 08:05:00'),
(04, 04, 'RED', 100, '2026-02-22 08:03:00'),
(05, 05, 'GREEN', 80, '2026-02-22 08:06:00'),
(06, 06, 'RED', 110, '2026-02-22 08:08:00'),
(07, 07, 'GREEN', 120, '2026-02-22 08:10:00'),
(08, 08, 'YELLOW', 90, '2026-02-22 08:12:00'),
(09, 09, 'RED', 100, '2026-02-22 08:14:00'),
(10, 10, 'GREEN', 95, '2026-02-22 08:16:00'),
(11, 11, 'RED', 110, '2026-02-22 08:18:00'),
(12, 12, 'YELLOW', 85, '2026-02-22 08:20:00'),
(13, 13, 'GREEN', 120, '2026-02-22 08:22:00'),
(14, 14, 'RED', 100, '2026-02-22 08:24:00'),
(15, 15, 'YELLOW', 90, '2026-02-22 08:26:00'),
(16, 16, 'GREEN', 110, '2026-02-22 08:28:00'),
(17, 17, 'RED', 95, '2026-02-22 08:30:00'),
(18, 18, 'GREEN', 100, '2026-02-22 08:32:00'),
(19, 19, 'YELLOW', 80, '2026-02-22 08:34:00'),
(20, 20, 'RED', 120, '2026-02-22 08:36:00'),
(21, 21, 'GREEN', 90, '2026-02-22 08:38:00'),
(22, 22, 'RED', 100, '2026-02-22 08:40:00'),
(23, 23, 'YELLOW', 85, '2026-02-22 08:42:00'),
(24, 24, 'GREEN', 110, '2026-02-22 08:44:00'),
(25, 25, 'RED', 120, '2026-02-22 08:46:00'),
(26, 26, 'YELLOW', 90, '2026-02-22 08:48:00'),
(27, 27, 'GREEN', 100, '2026-02-22 08:50:00'),
(28, 28, 'RED', 110, '2026-02-22 08:52:00'),
(29, 29, 'YELLOW', 95, '2026-02-22 08:54:00'),
(30, 30, 'GREEN', 120, '2026-02-22 08:56:00'),
(31, 31, 'RED', 100, '2026-02-22 08:58:00'),
(32, 32, 'GREEN', 90, '2026-02-22 09:00:00'),
(33, 33, 'YELLOW', 85, '2026-02-22 09:02:00'),
(34, 34, 'RED', 110, '2026-02-22 09:04:00'),
(35, 35, 'GREEN', 120, '2026-02-22 09:06:00'),
(36, 36, 'YELLOW', 100, '2026-02-22 09:08:00'),
(37, 37, 'RED', 90, '2026-02-22 09:10:00'),
(38, 38, 'GREEN', 100, '2026-02-22 09:12:00'),
(39, 39, 'YELLOW', 95, '2026-02-22 09:14:00'),
(40, 40, 'RED', 120, '2026-02-22 09:16:00');

-- Data For signal_timing_plans
INSERT INTO signal_timing_plans (plan_id, signal_id, green_time_sec, yellow_time_sec, red_time_sec, effective_from) VALUES
(01, 01, 60, 5, 55, '2026-02-22 08:00:00'),
(02, 02, 50, 5, 35, '2026-02-22 08:00:00'),
(03, 03, 45, 5, 40, '2026-02-22 08:00:00'),
(04, 04, 55, 5, 40, '2026-02-22 08:00:00'),
(05, 05, 50, 5, 30, '2026-02-22 08:00:00'),
(06, 06, 60, 5, 45, '2026-02-22 08:00:00'),
(07, 07, 65, 5, 50, '2026-02-22 08:00:00'),
(08, 08, 50, 5, 35, '2026-02-22 08:00:00'),
(09, 09, 55, 5, 40, '2026-02-22 08:00:00'),
(10, 10, 60, 5, 35, '2026-02-22 08:00:00'),
(11, 11, 55, 5, 50, '2026-02-22 08:00:00'),
(12, 12, 50, 5, 40, '2026-02-22 08:00:00'),
(13, 13, 60, 5, 45, '2026-02-22 08:00:00'),
(14, 14, 55, 5, 50, '2026-02-22 08:00:00'),
(15, 15, 50, 5, 35, '2026-02-22 08:00:00'),
(16, 16, 60, 5, 50, '2026-02-22 08:00:00'),
(17, 17, 55, 5, 40, '2026-02-22 08:00:00'),
(18, 18, 60, 5, 45, '2026-02-22 08:00:00'),
(19, 19, 50, 5, 35, '2026-02-22 08:00:00'),
(20, 20, 55, 5, 50, '2026-02-22 08:00:00'),
(21, 21, 60, 5, 45, '2026-02-22 08:00:00'),
(22, 22, 50, 5, 40, '2026-02-22 08:00:00'),
(23, 23, 55, 5, 50, '2026-02-22 08:00:00'),
(24, 24, 60, 5, 45, '2026-02-22 08:00:00'),
(25, 25, 50, 5, 35, '2026-02-22 08:00:00'),
(26, 26, 60, 5, 50, '2026-02-22 08:00:00'),
(27, 27, 55, 5, 40, '2026-02-22 08:00:00'),
(28, 28, 60, 5, 45, '2026-02-22 08:00:00'),
(29, 29, 50, 5, 35, '2026-02-22 08:00:00'),
(30, 30, 55, 5, 50, '2026-02-22 08:00:00'),
(31, 31, 60, 5, 45, '2026-02-22 08:00:00'),
(32, 32, 50, 5, 40, '2026-02-22 08:00:00'),
(33, 33, 55, 5, 50, '2026-02-22 08:00:00'),
(34, 34, 60, 5, 45, '2026-02-22 08:00:00'),
(35, 35, 50, 5, 35, '2026-02-22 08:00:00'),
(36, 36, 60, 5, 50, '2026-02-22 08:00:00'),
(37, 37, 55, 5, 40, '2026-02-22 08:00:00'),
(38, 38, 60, 5, 45, '2026-02-22 08:00:00'),
(39, 39, 50, 5, 35, '2026-02-22 08:00:00'),
(40, 40, 55, 5, 50, '2026-02-22 08:00:00');

-- Data For sensors
INSERT INTO sensors (sensor_id, road_id, sensor_type, installation_date, status, last_service_date) VALUES
(01, 1, 'Inductive Loop', '2025-12-01', 'ACTIVE', '2026-01-01'),
(02, 2, 'Radar', '2025-12-03', 'ACTIVE', '2026-01-03'),
(03, 3, 'Infrared', '2025-12-05', 'INACTIVE', '2026-01-05'),
(04, 4, 'Inductive Loop', '2025-12-07', 'ACTIVE', '2026-01-07'),
(05, 5, 'Radar', '2025-12-09', 'ACTIVE', '2026-01-09'),
(06, 6, 'Infrared', '2025-12-11', 'ACTIVE', '2026-01-11'),
(07, 7, 'Inductive Loop', '2025-12-13', 'INACTIVE', '2026-01-13'),
(08, 8, 'Radar', '2025-12-15', 'ACTIVE', '2026-01-15'),
(09, 9, 'Infrared', '2025-12-17', 'ACTIVE', '2026-01-17'),
(10, 10, 'Inductive Loop', '2025-12-19', 'ACTIVE', '2026-01-19'),
(11, 11, 'Radar', '2025-12-21', 'INACTIVE', '2026-01-21'),
(12, 12, 'Infrared', '2025-12-23', 'ACTIVE', '2026-01-23'),
(13, 13, 'Inductive Loop', '2025-12-25', 'ACTIVE', '2026-01-25'),
(14, 14, 'Radar', '2025-12-27', 'ACTIVE', '2026-01-27'),
(15, 15, 'Infrared', '2025-12-29', 'INACTIVE', '2026-01-29'),
(16, 16, 'Inductive Loop', '2026-01-01', 'ACTIVE', '2026-02-01'),
(17, 17, 'Radar', '2026-01-03', 'ACTIVE', '2026-02-03'),
(18, 18, 'Infrared', '2026-01-05', 'ACTIVE', '2026-02-05'),
(19, 19, 'Inductive Loop', '2026-01-07', 'INACTIVE', '2026-02-07'),
(20, 20, 'Radar', '2026-01-09', 'ACTIVE', '2026-02-09'),
(21, 1, 'Infrared', '2026-01-11', 'ACTIVE', '2026-02-11'),
(22, 2, 'Inductive Loop', '2026-01-13', 'ACTIVE', '2026-02-13'),
(23, 3, 'Radar', '2026-01-15', 'INACTIVE', '2026-02-15'),
(24, 4, 'Infrared', '2026-01-17', 'ACTIVE', '2026-02-17'),
(25, 5, 'Inductive Loop', '2026-01-19', 'ACTIVE', '2026-02-19'),
(26, 6, 'Radar', '2026-01-21', 'ACTIVE', '2026-02-21'),
(27, 7, 'Infrared', '2026-01-23', 'INACTIVE', '2026-02-23'),
(28, 8, 'Inductive Loop', '2026-01-25', 'ACTIVE', '2026-02-25'),
(29, 9, 'Radar', '2026-01-27', 'ACTIVE', '2026-02-27'),
(30, 10, 'Infrared', '2026-01-29', 'ACTIVE', '2026-02-28'),
(31, 11, 'Inductive Loop', '2026-02-01', 'INACTIVE', '2026-02-15'),
(32, 12, 'Radar', '2026-02-03', 'ACTIVE', '2026-02-17'),
(33, 13, 'Infrared', '2026-02-05', 'ACTIVE', '2026-02-19'),
(34, 14, 'Inductive Loop', '2026-02-07', 'ACTIVE', '2026-02-21'),
(35, 15, 'Radar', '2026-02-09', 'INACTIVE', '2026-02-23'),
(36, 16, 'Infrared', '2026-02-11', 'ACTIVE', '2026-02-25'),
(37, 17, 'Inductive Loop', '2026-02-13', 'ACTIVE', '2026-02-27'),
(38, 18, 'Radar', '2026-02-15', 'ACTIVE', '2026-02-28'),
(39, 19, 'Infrared', '2026-02-17', 'INACTIVE', '2026-02-20'),
(40, 20, 'Inductive Loop', '2026-02-19', 'ACTIVE', '2026-02-22');

-- Data For traffic_readings
INSERT INTO traffic_readings (reading_id, sensor_id, vehicle_count, avg_speed_kmph, occupancy_rate, recorded_at) VALUES
(01, 01, 120, 45.5, 30.2, '2026-02-22 08:00:00'),
(02, 02, 85, 50.1, 25.5, '2026-02-22 08:05:00'),
(03, 03, 60, 35.0, 40.0, '2026-02-22 08:10:00'),
(04, 04, 150, 42.0, 32.5, '2026-02-22 08:15:00'),
(05, 05, 95, 48.0, 28.0, '2026-02-22 08:20:00'),
(06, 06, 110, 46.5, 29.5, '2026-02-22 08:25:00'),
(07, 07, 55, 33.0, 38.0, '2026-02-22 08:30:00'),
(08, 08, 130, 44.0, 31.0, '2026-02-22 08:35:00'),
(09, 09, 75, 49.0, 27.0, '2026-02-22 08:40:00'),
(10, 10, 140, 43.5, 33.0, '2026-02-22 08:45:00'),
(11, 11, 50, 34.0, 36.0, '2026-02-22 08:50:00'),
(12, 12, 125, 45.0, 30.0, '2026-02-22 08:55:00'),
(13, 13, 90, 47.5, 28.5, '2026-02-22 09:00:00'),
(14, 14, 135, 42.5, 32.0, '2026-02-22 09:05:00'),
(15, 15, 65, 36.0, 39.0, '2026-02-22 09:10:00'),
(16, 16, 150, 44.5, 31.5, '2026-02-22 09:15:00'),
(17, 17, 80, 48.0, 27.5, '2026-02-22 09:20:00'),
(18, 18, 115, 46.0, 29.0, '2026-02-22 09:25:00'),
(19, 19, 55, 32.5, 37.5, '2026-02-22 09:30:00'),
(20, 20, 130, 43.0, 32.0, '2026-02-22 09:35:00'),
(21, 21, 95, 47.0, 28.0, '2026-02-22 09:40:00'),
(22, 22, 140, 44.0, 31.5, '2026-02-22 09:45:00'),
(23, 23, 60, 35.0, 39.0, '2026-02-22 09:50:00'),
(24, 24, 125, 46.0, 30.0, '2026-02-22 09:55:00'),
(25, 25, 85, 48.5, 27.0, '2026-02-22 10:00:00'),
(26, 26, 145, 43.5, 32.0, '2026-02-22 10:05:00'),
(27, 27, 70, 37.0, 38.0, '2026-02-22 10:10:00'),
(28, 28, 155, 45.0, 31.0, '2026-02-22 10:15:00'),
(29, 29, 90, 48.0, 27.5, '2026-02-22 10:20:00'),
(30, 30, 120, 44.5, 30.5, '2026-02-22 10:25:00'),
(31, 31, 50, 33.5, 36.5, '2026-02-22 10:30:00'),
(32, 32, 135, 46.5, 30.5, '2026-02-22 10:35:00'),
(33, 33, 80, 47.0, 28.0, '2026-02-22 10:40:00'),
(34, 34, 150, 44.0, 32.0, '2026-02-22 10:45:00'),
(35, 35, 65, 36.5, 38.5, '2026-02-22 10:50:00'),
(36, 36, 140, 45.0, 31.0, '2026-02-22 10:55:00'),
(37, 37, 75, 48.0, 28.0, '2026-02-22 11:00:00'),
(38, 38, 155, 43.5, 32.5, '2026-02-22 11:05:00'),
(39, 39, 60, 34.0, 37.0, '2026-02-22 11:10:00'),
(40, 40, 130, 44.5, 31.0, '2026-02-22 11:15:00');

-- Data For cameras
INSERT INTO cameras (camera_id, intersection_id, camera_type, resolution, status, installation_date) VALUES
(01, 1, 'CCTV', '1080p', 'ACTIVE', '2025-11-01'),
(02, 2, 'AI Camera', '4K', 'ACTIVE', '2025-11-02'),
(03, 3, 'Speed Camera', '1080p', 'ACTIVE', '2025-11-03'),
(04, 4, 'CCTV', '1080p', 'INACTIVE', '2025-11-04'),
(05, 5, 'AI Camera', '4K', 'ACTIVE', '2025-11-05'),
(06, 6, 'Speed Camera', '1080p', 'ACTIVE', '2025-11-06'),
(07, 7, 'CCTV', '720p', 'ACTIVE', '2025-11-07'),
(08, 8, 'AI Camera', '4K', 'ACTIVE', '2025-11-08'),
(09, 9, 'Speed Camera', '1080p', 'INACTIVE', '2025-11-09'),
(10, 10, 'CCTV', '1080p', 'ACTIVE', '2025-11-10'),
(11, 11, 'AI Camera', '4K', 'ACTIVE', '2025-11-11'),
(12, 12, 'Speed Camera', '1080p', 'ACTIVE', '2025-11-12'),
(13, 13, 'CCTV', '1080p', 'ACTIVE', '2025-11-13'),
(14, 14, 'AI Camera', '4K', 'INACTIVE', '2025-11-14'),
(15, 15, 'Speed Camera', '1080p', 'ACTIVE', '2025-11-15'),
(16, 16, 'CCTV', '1080p', 'ACTIVE', '2025-11-16'),
(17, 17, 'AI Camera', '4K', 'ACTIVE', '2025-11-17'),
(18, 18, 'Speed Camera', '1080p', 'ACTIVE', '2025-11-18'),
(19, 19, 'CCTV', '1080p', 'INACTIVE', '2025-11-19'),
(20, 20, 'AI Camera', '4K', 'ACTIVE', '2025-11-20'),
(21, 21, 'Speed Camera', '1080p', 'ACTIVE', '2025-11-21'),
(22, 22, 'CCTV', '1080p', 'ACTIVE', '2025-11-22'),
(23, 23, 'AI Camera', '4K', 'ACTIVE', '2025-11-23'),
(24, 24, 'Speed Camera', '1080p', 'INACTIVE', '2025-11-24'),
(25, 25, 'CCTV', '1080p', 'ACTIVE', '2025-11-25'),
(26, 26, 'AI Camera', '4K', 'ACTIVE', '2025-11-26'),
(27, 27, 'Speed Camera', '1080p', 'ACTIVE', '2025-11-27'),
(28, 28, 'CCTV', '1080p', 'ACTIVE', '2025-11-28'),
(29, 29, 'AI Camera', '4K', 'INACTIVE', '2025-11-29'),
(30, 30, 'Speed Camera', '1080p', 'ACTIVE', '2025-11-30'),
(31, 31, 'CCTV', '1080p', 'ACTIVE', '2025-12-01'),
(32, 32, 'AI Camera', '4K', 'ACTIVE', '2025-12-02'),
(33, 33, 'Speed Camera', '1080p', 'ACTIVE', '2025-12-03'),
(34, 34, 'CCTV', '1080p', 'INACTIVE', '2025-12-04'),
(35, 35, 'AI Camera', '4K', 'ACTIVE', '2025-12-05'),
(36, 36, 'Speed Camera', '1080p', 'ACTIVE', '2025-12-06'),
(37, 37, 'CCTV', '1080p', 'ACTIVE', '2025-12-07'),
(38, 38, 'AI Camera', '4K', 'ACTIVE', '2025-12-08'),
(39, 39, 'Speed Camera', '1080p', 'INACTIVE', '2025-12-09'),
(40, 40, 'CCTV', '1080p', 'ACTIVE', '2025-12-10');

-- Data For vehicles
INSERT INTO vehicles (vehicle_id, vehicle_number, vehicle_type, registration_state, registered_date) VALUES
(01, 'TN01AB1234', 'Car', 'Tamil Nadu', '2022-01-15'),
(02, 'TN02BC2345', 'Motorbike', 'Tamil Nadu', '2022-03-20'),
(03, 'TN03CD3456', 'Truck', 'Tamil Nadu', '2022-05-10'),
(04, 'TN04DE4567', 'Bus', 'Tamil Nadu', '2022-07-12'),
(05, 'TN05EF5678', 'Car', 'Tamil Nadu', '2022-08-05'),
(06, 'TN06FG6789', 'Motorbike', 'Tamil Nadu', '2022-09-15'),
(07, 'TN07GH7890', 'Truck', 'Tamil Nadu', '2022-10-18'),
(08, 'TN08HI8901', 'Bus', 'Tamil Nadu', '2022-11-25'),
(09, 'TN09IJ9012', 'Car', 'Tamil Nadu', '2023-01-10'),
(10, 'TN10JK0123', 'Motorbike', 'Tamil Nadu', '2023-02-14'),
(11, 'TN11KL1234', 'Truck', 'Tamil Nadu', '2023-03-18'),
(12, 'TN12LM2345', 'Bus', 'Tamil Nadu', '2023-04-22'),
(13, 'TN13MN3456', 'Car', 'Tamil Nadu', '2023-05-30'),
(14, 'TN14NO4567', 'Motorbike', 'Tamil Nadu', '2023-06-15'),
(15, 'TN15OP5678', 'Truck', 'Tamil Nadu', '2023-07-12'),
(16, 'TN16PQ6789', 'Bus', 'Tamil Nadu', '2023-08-20'),
(17, 'TN17QR7890', 'Car', 'Tamil Nadu', '2023-09-05'),
(18, 'TN18RS8901', 'Motorbike', 'Tamil Nadu', '2023-10-12'),
(19, 'TN19ST9012', 'Truck', 'Tamil Nadu', '2023-11-01'),
(20, 'TN20TU0123', 'Bus', 'Tamil Nadu', '2023-12-05'),
(21, 'TN21UV1234', 'Car', 'Tamil Nadu', '2024-01-10'),
(22, 'TN22VW2345', 'Motorbike', 'Tamil Nadu', '2024-02-14'),
(23, 'TN23WX3456', 'Truck', 'Tamil Nadu', '2024-03-18'),
(24, 'TN24XY4567', 'Bus', 'Tamil Nadu', '2024-04-22'),
(25, 'TN25YZ5678', 'Car', 'Tamil Nadu', '2024-05-30'),
(26, 'TN26ZA6789', 'Motorbike', 'Tamil Nadu', '2024-06-15'),
(27, 'TN27AB7890', 'Truck', 'Tamil Nadu', '2024-07-12'),
(28, 'TN28BC8901', 'Bus', 'Tamil Nadu', '2024-08-20'),
(29, 'TN29CD9012', 'Car', 'Tamil Nadu', '2024-09-05'),
(30, 'TN30DE0123', 'Motorbike', 'Tamil Nadu', '2024-10-12'),
(31, 'TN31EF1234', 'Truck', 'Tamil Nadu', '2024-11-01'),
(32, 'TN32FG2345', 'Bus', 'Tamil Nadu', '2024-12-05'),
(33, 'TN33GH3456', 'Car', 'Tamil Nadu', '2025-01-10'),
(34, 'TN34HI4567', 'Motorbike', 'Tamil Nadu', '2025-02-14'),
(35, 'TN35IJ5678', 'Truck', 'Tamil Nadu', '2025-03-18'),
(36, 'TN36JK6789', 'Bus', 'Tamil Nadu', '2025-04-22'),
(37, 'TN37KL7890', 'Car', 'Tamil Nadu', '2025-05-30'),
(38, 'TN38LM8901', 'Motorbike', 'Tamil Nadu', '2025-06-15'),
(39, 'TN39MN9012', 'Truck', 'Tamil Nadu', '2025-07-12'),
(40, 'TN40NO0123', 'Bus', 'Tamil Nadu', '2025-08-20');

-- Data For violations
INSERT INTO violations (violation_id, vehicle_id, camera_id, violation_type, violation_time, fine_amount) VALUES
(01, 01, 01, 'Speeding', '2026-02-20 08:15:00', 1500.00),
(02, 02, 02, 'Signal Jump', '2026-02-20 08:20:00', 1000.00),
(03, 03, 03, 'Wrong Parking', '2026-02-20 08:25:00', 500.00),
(04, 04, 04, 'Speeding', '2026-02-20 08:30:00', 2000.00),
(05, 05, 05, 'Signal Jump', '2026-02-20 08:35:00', 1200.00),
(06, 06, 06, 'Wrong Parking', '2026-02-20 08:40:00', 800.00),
(07, 07, 07, 'Speeding', '2026-02-20 08:45:00', 1800.00),
(08, 08, 08, 'Signal Jump', '2026-02-20 08:50:00', 1100.00),
(09, 09, 09, 'Wrong Parking', '2026-02-20 08:55:00', 600.00),
(10, 10, 10, 'Speeding', '2026-02-20 09:00:00', 1600.00),
(11, 11, 11, 'Signal Jump', '2026-02-20 09:05:00', 1000.00),
(12, 12, 12, 'Wrong Parking', '2026-02-20 09:10:00', 700.00),
(13, 13, 13, 'Speeding', '2026-02-20 09:15:00', 1500.00),
(14, 14, 14, 'Signal Jump', '2026-02-20 09:20:00', 1200.00),
(15, 15, 15, 'Wrong Parking', '2026-02-20 09:25:00', 800.00),
(16, 16, 16, 'Speeding', '2026-02-20 09:30:00', 1900.00),
(17, 17, 17, 'Signal Jump', '2026-02-20 09:35:00', 1100.00),
(18, 18, 18, 'Wrong Parking', '2026-02-20 09:40:00', 900.00),
(19, 19, 19, 'Speeding', '2026-02-20 09:45:00', 1700.00),
(20, 20, 20, 'Signal Jump', '2026-02-20 09:50:00', 1000.00),
(21, 21, 21, 'Wrong Parking', '2026-02-20 09:55:00', 600.00),
(22, 22, 22, 'Speeding', '2026-02-20 10:00:00', 1800.00),
(23, 23, 23, 'Signal Jump', '2026-02-20 10:05:00', 1200.00),
(24, 24, 24, 'Wrong Parking', '2026-02-20 10:10:00', 800.00),
(25, 25, 25, 'Speeding', '2026-02-20 10:15:00', 1600.00),
(26, 26, 26, 'Signal Jump', '2026-02-20 10:20:00', 1000.00),
(27, 27, 27, 'Wrong Parking', '2026-02-20 10:25:00', 700.00),
(28, 28, 28, 'Speeding', '2026-02-20 10:30:00', 1900.00),
(29, 29, 29, 'Signal Jump', '2026-02-20 10:35:00', 1100.00),
(30, 30, 30, 'Wrong Parking', '2026-02-20 10:40:00', 900.00),
(31, 31, 31, 'Speeding', '2026-02-20 10:45:00', 1500.00),
(32, 32, 32, 'Signal Jump', '2026-02-20 10:50:00', 1200.00),
(33, 33, 33, 'Wrong Parking', '2026-02-20 10:55:00', 800.00),
(34, 34, 34, 'Speeding', '2026-02-20 11:00:00', 1700.00),
(35, 35, 35, 'Signal Jump', '2026-02-20 11:05:00', 1000.00),
(36, 36, 36, 'Wrong Parking', '2026-02-20 11:10:00', 600.00),
(37, 37, 37, 'Speeding', '2026-02-20 11:15:00', 1800.00),
(38, 38, 38, 'Signal Jump', '2026-02-20 11:20:00', 1100.00),
(39, 39, 39, 'Wrong Parking', '2026-02-20 11:25:00', 900.00),
(40, 40, 40, 'Speeding', '2026-02-20 11:30:00', 1600.00);

-- Data For fines
INSERT INTO fines (fine_id, violation_id, amount_due, payment_status, issued_date, due_date) VALUES
(01, 01, 1500.00, 'PENDING', '2026-02-21', '2026-03-21'),
(02, 02, 1000.00, 'PAID', '2026-02-21', '2026-03-21'),
(03, 03, 500.00, 'PENDING', '2026-02-21', '2026-03-21'),
(04, 04, 2000.00, 'PENDING', '2026-02-21', '2026-03-21'),
(05, 05, 1200.00, 'PAID', '2026-02-21', '2026-03-21'),
(06, 06, 800.00, 'PENDING', '2026-02-21', '2026-03-21'),
(07, 07, 1800.00, 'PAID', '2026-02-21', '2026-03-21'),
(08, 08, 1100.00, 'PENDING', '2026-02-21', '2026-03-21'),
(09, 09, 600.00, 'PAID', '2026-02-21', '2026-03-21'),
(10, 10, 1600.00, 'PENDING', '2026-02-21', '2026-03-21'),
(11, 11, 1000.00, 'PAID', '2026-02-21', '2026-03-21'),
(12, 12, 700.00, 'PENDING', '2026-02-21', '2026-03-21'),
(13, 13, 1500.00, 'PENDING', '2026-02-21', '2026-03-21'),
(14, 14, 1200.00, 'PAID', '2026-02-21', '2026-03-21'),
(15, 15, 800.00, 'PENDING', '2026-02-21', '2026-03-21'),
(16, 16, 1900.00, 'PAID', '2026-02-21', '2026-03-21'),
(17, 17, 1100.00, 'PENDING', '2026-02-21', '2026-03-21'),
(18, 18, 900.00, 'PAID', '2026-02-21', '2026-03-21'),
(19, 19, 1700.00, 'PENDING', '2026-02-21', '2026-03-21'),
(20, 20, 1000.00, 'PAID', '2026-02-21', '2026-03-21');

-- Data For incidents
INSERT INTO incidents (incident_id, road_id, incident_type, severity_level, reported_time, status) VALUES
(01, 01, 'Accident', 'High', '2026-02-21 08:00:00', 'OPEN'),
(02, 02, 'Traffic Jam', 'Medium', '2026-02-21 08:05:00', 'OPEN'),
(03, 03, 'Roadblock', 'High', '2026-02-21 08:10:00', 'RESOLVED'),
(04, 04, 'Accident', 'Low', '2026-02-21 08:15:00', 'OPEN'),
(05, 05, 'Traffic Jam', 'Medium', '2026-02-21 08:20:00', 'RESOLVED'),
(06, 06, 'Roadblock', 'High', '2026-02-21 08:25:00', 'OPEN'),
(07, 07, 'Accident', 'Low', '2026-02-21 08:30:00', 'RESOLVED'),
(08, 08, 'Traffic Jam', 'Medium', '2026-02-21 08:35:00', 'OPEN'),
(09, 09, 'Roadblock', 'High', '2026-02-21 08:40:00', 'RESOLVED'),
(10, 10, 'Accident', 'Low', '2026-02-21 08:45:00', 'OPEN'),
(11, 11, 'Traffic Jam', 'Medium', '2026-02-21 08:50:00', 'RESOLVED'),
(12, 12, 'Roadblock', 'High', '2026-02-21 08:55:00', 'OPEN'),
(13, 13, 'Accident', 'Low', '2026-02-21 09:00:00', 'RESOLVED'),
(14, 14, 'Traffic Jam', 'Medium', '2026-02-21 09:05:00', 'OPEN'),
(15, 15, 'Roadblock', 'High', '2026-02-21 09:10:00', 'RESOLVED'),
(16, 16, 'Accident', 'Low', '2026-02-21 09:15:00', 'OPEN'),
(17, 17, 'Traffic Jam', 'Medium', '2026-02-21 09:20:00', 'RESOLVED'),
(18, 18, 'Roadblock', 'High', '2026-02-21 09:25:00', 'OPEN'),
(19, 19, 'Accident', 'Low', '2026-02-21 09:30:00', 'RESOLVED'),
(20, 20, 'Traffic Jam', 'Medium', '2026-02-21 09:35:00', 'OPEN');

-- Data For emergency_responses
INSERT INTO emergency_responses (response_id, incident_id, response_team_name, dispatch_time, arrival_time, clearance_time) VALUES
(01, 01, 'Fire Brigade', '2026-02-21 08:02:00', '2026-02-21 08:10:00', '2026-02-21 08:45:00'),
(02, 02, 'Traffic Police', '2026-02-21 08:07:00', '2026-02-21 08:15:00', '2026-02-21 08:40:00'),
(03, 03, 'Road Maintenance', '2026-02-21 08:12:00', '2026-02-21 08:20:00', '2026-02-21 08:55:00'),
(04, 04, 'Fire Brigade', '2026-02-21 08:17:00', '2026-02-21 08:25:00', '2026-02-21 09:00:00'),
(05, 05, 'Traffic Police', '2026-02-21 08:22:00', '2026-02-21 08:30:00', '2026-02-21 09:05:00'),
(06, 06, 'Road Maintenance', '2026-02-21 08:27:00', '2026-02-21 08:35:00', '2026-02-21 09:10:00'),
(07, 07, 'Fire Brigade', '2026-02-21 08:32:00', '2026-02-21 08:40:00', '2026-02-21 09:15:00'),
(08, 08, 'Traffic Police', '2026-02-21 08:37:00', '2026-02-21 08:45:00', '2026-02-21 09:20:00'),
(09, 09, 'Road Maintenance', '2026-02-21 08:42:00', '2026-02-21 08:50:00', '2026-02-21 09:25:00'),
(10, 10, 'Fire Brigade', '2026-02-21 08:47:00', '2026-02-21 08:55:00', '2026-02-21 09:30:00'),
(11, 11, 'Traffic Police', '2026-02-21 08:52:00', '2026-02-21 09:00:00', '2026-02-21 09:35:00'),
(12, 12, 'Road Maintenance', '2026-02-21 08:57:00', '2026-02-21 09:05:00', '2026-02-21 09:40:00'),
(13, 13, 'Fire Brigade', '2026-02-21 09:02:00', '2026-02-21 09:10:00', '2026-02-21 09:45:00'),
(14, 14, 'Traffic Police', '2026-02-21 09:07:00', '2026-02-21 09:15:00', '2026-02-21 09:50:00'),
(15, 15, 'Road Maintenance', '2026-02-21 09:12:00', '2026-02-21 09:20:00', '2026-02-21 09:55:00'),
(16, 16, 'Fire Brigade', '2026-02-21 09:17:00', '2026-02-21 09:25:00', '2026-02-21 10:00:00'),
(17, 17, 'Traffic Police', '2026-02-21 09:22:00', '2026-02-21 09:30:00', '2026-02-21 10:05:00'),
(18, 18, 'Road Maintenance', '2026-02-21 09:27:00', '2026-02-21 09:35:00', '2026-02-21 10:10:00'),
(19, 19, 'Fire Brigade', '2026-02-21 09:32:00', '2026-02-21 09:40:00', '2026-02-21 10:15:00'),
(20, 20, 'Traffic Police', '2026-02-21 09:37:00', '2026-02-21 09:45:00', '2026-02-21 10:20:00');

-- Data For public_transport
INSERT INTO public_transport (transport_id, vehicle_number, route_name, capacity, operator_name, status) VALUES
(01, 'TN01PT001', 'Chennai to Madurai', 50, 'TNSTC', 'Active'),
(02, 'TN02PT002', 'Coimbatore to Trichy', 45, 'TNSTC', 'Active'),
(03, 'TN03PT003', 'Salem to Erode', 40, 'Private', 'Inactive'),
(04, 'TN04PT004', 'Tirunelveli to Kanyakumari', 50, 'Private', 'Active'),
(05, 'TN05PT005', 'Chennai to Pondicherry', 45, 'TNSTC', 'Active'),
(06, 'TN06PT006', 'Madurai to Rameswaram', 40, 'Private', 'Inactive'),
(07, 'TN07PT007', 'Coimbatore to Ooty', 45, 'TNSTC', 'Active'),
(08, 'TN08PT008', 'Trichy to Karaikudi', 50, 'Private', 'Active'),
(09, 'TN09PT009', 'Chennai to Vellore', 40, 'TNSTC', 'Inactive'),
(10, 'TN10PT010', 'Salem to Namakkal', 45, 'Private', 'Active'),
(11, 'TN11PT011', 'Tiruppur to Erode', 50, 'TNSTC', 'Active'),
(12, 'TN12PT012', 'Madurai to Dindigul', 45, 'Private', 'Active'),
(13, 'TN13PT013', 'Chennai to Kanchipuram', 40, 'TNSTC', 'Inactive'),
(14, 'TN14PT014', 'Coimbatore to Tirupur', 45, 'Private', 'Active'),
(15, 'TN15PT015', 'Trichy to Thanjavur', 50, 'TNSTC', 'Active'),
(16, 'TN16PT016', 'Salem to Erode', 45, 'Private', 'Active'),
(17, 'TN17PT017', 'Madurai to Sivagangai', 40, 'TNSTC', 'Inactive'),
(18, 'TN18PT018', 'Tirunelveli to Nagercoil', 50, 'Private', 'Active'),
(19, 'TN19PT019', 'Chennai to Villupuram', 45, 'TNSTC', 'Active'),
(20, 'TN20PT020', 'Coimbatore to Pollachi', 40, 'Private', 'Inactive');

-- Data For gps_tracking
INSERT INTO gps_tracking (tracking_id, transport_id, latitude, longitude, speed_kmph, recorded_at) VALUES
(01, 01, 13.0827, 80.2707, 60.50, '2026-02-21 08:00:00'),
(02, 02, 11.0168, 76.9558, 55.30, '2026-02-21 08:05:00'),
(03, 03, 11.6643, 78.1460, 50.00, '2026-02-21 08:10:00'),
(04, 04, 8.7139, 77.7568, 45.70, '2026-02-21 08:15:00'),
(05, 05, 12.2958, 76.6394, 60.00, '2026-02-21 08:20:00'),
(06, 06, 9.2820, 78.1139, 48.50, '2026-02-21 08:25:00'),
(07, 07, 10.7905, 78.7047, 55.00, '2026-02-21 08:30:00'),
(08, 08, 10.7679, 78.8139, 50.20, '2026-02-21 08:35:00'),
(09, 09, 12.9165, 79.1325, 45.00, '2026-02-21 08:40:00'),
(10, 10, 11.6643, 78.1460, 55.10, '2026-02-21 08:45:00'),
(11, 11, 11.0168, 76.9558, 60.00, '2026-02-21 08:50:00'),
(12, 12, 13.0827, 80.2707, 50.00, '2026-02-21 08:55:00'),
(13, 13, 12.2958, 76.6394, 48.00, '2026-02-21 09:00:00'),
(14, 14, 10.7905, 78.7047, 55.50, '2026-02-21 09:05:00'),
(15, 15, 11.0168, 76.9558, 45.00, '2026-02-21 09:10:00'),
(16, 16, 9.2820, 78.1139, 50.50, '2026-02-21 09:15:00'),
(17, 17, 8.7139, 77.7568, 60.00, '2026-02-21 09:20:00'),
(18, 18, 12.9165, 79.1325, 55.00, '2026-02-21 09:25:00'),
(19, 19, 10.7679, 78.8139, 45.50, '2026-02-21 09:30:00'),
(20, 20, 13.0827, 80.2707, 50.00, '2026-02-21 09:35:00');

-- Scenario Based Questions --

-- 1. List all zones along with the number of roads in each zone.

SELECT * FROM zones;
SELECT * FROM roads;

SELECT z.zone_name, COUNT(r.road_id) AS total_roads
FROM zones z
LEFT JOIN roads r ON z.zone_id = r.zone_id
GROUP BY z.zone_name;

-- 2. Show zones where population_density > 5000 and sort by area_sq_km.

SELECT * FROM zones;

SELECT * FROM zones
WHERE population_density > 5000
ORDER BY area_sq_km ASC;

-- 3. List zones and their average number of connected roads per intersection.

SELECT * FROM zones;
SELECT * FROM intersections;

SELECT z.zone_name, AVG(i.connected_roads) AS avg_connected_roads
FROM zones z
JOIN intersections i ON z.zone_id = i.zone_id
GROUP BY z.zone_name;

-- 4. Find the largest zone by area.

SELECT * FROM zones;

SELECT * FROM zones ORDER BY area_sq_km DESC LIMIT 1;

-- 5. Show all arterial roads along with their zone name.

SELECT * FROM roads;
SELECT * FROM zones;

SELECT r.road_name, r.road_type, z.zone_name
FROM roads r
JOIN zones z ON r.zone_id = z.zone_id
WHERE r.road_type = 'Arterial';

-- 6. Find roads with more than 4 lanes and length over 2 km.

SELECT * FROM roads;

SELECT * FROM roads
WHERE total_lanes > 4 AND length_km > 2;

-- 7. List zones and the total number of lanes in each.

SELECT * FROM zones;
SELECT * FROM roads;

SELECT z.zone_name, SUM(r.total_lanes) AS total_lanes
FROM zones z
JOIN roads r ON z.zone_id = r.zone_id
GROUP BY z.zone_name;

-- 8. Find the road with the maximum length.

SELECT * FROM roads;

SELECT * FROM roads ORDER BY length_km DESC LIMIT 1;

-- 9. List intersections along with their zone name.

SELECT * FROM intersections;
SELECT * FROM zones;

SELECT i.intersection_name, z.zone_name
FROM intersections i
JOIN zones z ON i.zone_id = z.zone_id;

-- 10. Show intersections with more than 3 connected roads.

SELECT * FROM intersections;

SELECT * FROM intersections WHERE connected_roads > 3;

-- 11. Count intersections in each zone.

SELECT * FROM zones;
SELECT * FROM intersections;

SELECT z.zone_name, COUNT(i.intersection_id) AS total_intersections
FROM zones z
JOIN intersections i ON z.zone_id = i.zone_id
GROUP BY z.zone_name;

-- 12. List intersections in 'Chennai CBD' zone.


SELECT * FROM intersections;
SELECT * FROM zones;

SELECT i.*
FROM intersections i
JOIN zones z ON i.zone_id = z.zone_id
WHERE z.zone_name = 'Chennai CBD';

-- 13. Show all signals and their intersection names.

SELECT * FROM traffic_signals;
SELECT * FROM intersections;

SELECT ts.signal_id, ts.current_status, i.intersection_name
FROM traffic_signals ts
JOIN intersections i ON ts.intersection_id = i.intersection_id;

-- 14. Count signals by current_status.

SELECT * FROM traffic_signals;

SELECT current_status, COUNT(*) AS total_signals
FROM traffic_signals
GROUP BY current_status;

-- 15. List signals with cycle duration greater than or equal to 120 seconds.

SELECT * FROM traffic_signals;

SELECT * FROM traffic_signals WHERE cycle_duration_sec >= 120;

-- 16. Find the average cycle duration per intersection.

SELECT * FROM traffic_signals;
SELECT * FROM intersections;

SELECT i.intersection_name, AVG(ts.cycle_duration_sec) AS avg_cycle
FROM traffic_signals ts
JOIN intersections i ON ts.intersection_id = i.intersection_id
GROUP BY i.intersection_name;

-- 17. Show timing plans along with the intersection name.

SELECT * FROM signal_timing_plans;
SELECT * FROM intersections;

SELECT stp.plan_id, ts.signal_id, stp.green_time_sec, i.intersection_name
FROM signal_timing_plans stp
JOIN traffic_signals ts ON stp.signal_id = ts.signal_id
JOIN intersections i ON ts.intersection_id = i.intersection_id;

-- 18. Find plans where green_time > 60 seconds.

SELECT * FROM signal_timing_plans;

SELECT * FROM signal_timing_plans WHERE green_time_sec > 60;

-- 19. Count the number of timing plans per signal.

SELECT * FROM signal_timing_plans;

SELECT signal_id, COUNT(plan_id) AS total_plans
FROM signal_timing_plans
GROUP BY signal_id;

-- 20. Show plans effective after '2026-02-01' along with signal status.

SELECT * FROM signal_timing_plans;
SELECT * FROM traffic_signals;

SELECT stp.*, ts.current_status
FROM signal_timing_plans stp
JOIN traffic_signals ts ON stp.signal_id = ts.signal_id
WHERE stp.effective_from >= '2026-02-01';

-- 21. List all active sensors along with the road name.

SELECT * FROM sensors;
SELECT * FROM roads;

SELECT s.sensor_id, s.sensor_type, r.road_name
FROM sensors s
JOIN roads r ON s.road_id = r.road_id
WHERE s.status = 'ACTIVE';

-- 22. Count sensors per road.

SELECT * FROM roads;
SELECT * FROM sensors;

SELECT r.road_name, COUNT(s.sensor_id) AS total_sensors
FROM roads r
LEFT JOIN sensors s ON r.road_id = s.road_id
GROUP BY r.road_name;

-- 23. Find sensors installed after '2025-01-01'.

SELECT * FROM sensors;

SELECT * FROM sensors WHERE installation_date > '2025-01-01';

-- 24. Show sensor type distribution.

SELECT * FROM sensors;

SELECT sensor_type, COUNT(*) AS total
FROM sensors
GROUP BY sensor_type;

-- 25. Show readings with average speed < 35 km/h.

SELECT * FROM traffic_readings;

SELECT * FROM traffic_readings WHERE avg_speed_kmph < 35;

-- 26. Find total vehicles recorded per sensor.

SELECT * FROM traffic_readings;

SELECT sensor_id, SUM(vehicle_count) AS total_vehicles
FROM traffic_readings
GROUP BY sensor_id;

-- 27. Show readings recorded today.

SELECT * FROM traffic_readings;

SELECT * FROM traffic_readings WHERE recorded_at >= CURDATE();

-- 28. Find readings with occupancy_rate > 30%.

SELECT * FROM traffic_readings;

SELECT * FROM traffic_readings WHERE occupancy_rate > 30;

-- 29. List vehicles and their registration state.

SELECT * FROM vehicles;

SELECT vehicle_number, registration_state FROM vehicles;

-- 30. Count vehicles by type.

SELECT * FROM vehicles;

SELECT vehicle_type, COUNT(*) AS total
FROM vehicles
GROUP BY vehicle_type;

-- 31. Find vehicles registered after '2025-01-01'.

SELECT * FROM vehicles;

SELECT * FROM vehicles WHERE registered_date > '2025-01-01';

-- 32. Show vehicles whose number starts with 'TN'.

SELECT * FROM vehicles;

SELECT * FROM vehicles WHERE vehicle_number LIKE 'TN%';

-- 33. List violations along with vehicle number and camera ID.

SELECT * FROM violations;
SELECT * FROM vehicles;

SELECT v.violation_id, ve.vehicle_number, v.camera_id, v.violation_type
FROM violations v
JOIN vehicles ve ON v.vehicle_id = ve.vehicle_id;

-- 34. Count violations by type.

SELECT * FROM violations;

SELECT violation_type, COUNT(*) AS total
FROM violations
GROUP BY violation_type;

-- 35. Show violations with fine_amount > 1000.

SELECT * FROM violations;

SELECT * FROM violations WHERE fine_amount > 1000;

-- 36. List violations recorded in February 2026.

SELECT * FROM violations;

SELECT * FROM violations
WHERE violation_time BETWEEN '2026-02-01' AND '2026-02-28';

-- 37. List fines and their violation type.

SELECT * FROM fines;
SELECT * FROM violations;

SELECT f.fine_id, f.amount_due, f.payment_status, v.violation_type
FROM fines f
JOIN violations v ON f.violation_id = v.violation_id;

-- 38. Count fines by payment status.

SELECT * FROM fines;

SELECT payment_status, COUNT(*) AS total
FROM fines
GROUP BY payment_status;

-- 39. Show fines issued in the last month.

SELECT * FROM fines;

SELECT * FROM fines
WHERE issued_date >= NOW() - INTERVAL 1 MONTH;

-- 40. Find fines where payment is pending.

SELECT * FROM fines;

SELECT * FROM fines WHERE payment_status = 'PENDING';