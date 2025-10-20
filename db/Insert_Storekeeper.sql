use swp ;

INSERT INTO Account (
    accountId, username, passwordHash, fullName, email, phone, status
) VALUES (
    2,
    'ahihidongokk',
    '$2a$12$/EBvaV2Yx3HLbxL642jaEuYKh3KY7PYf7pZ8KOze.B7ZDX16Ky0Ba',
    'Trần Bảo Lâm',
    'lamtranbao1234@gmail.com'
    '1234567891',
    'Active'
);
INSERT INTO AccountProfile (
    profileId, 
    accountId, 
    address, 
    dateOfBirth, 
    avatarUrl, 
    nationalId, 
    verified, 
    extraData
) VALUES (
    2, 
    2, 
    'Hà Nội, Việt Nam', 
    '2000-05-20', 
    'https://example.com/avatar2.png', 
    '012345678912', 
    1, 
    'Khách VIP'
);


UPDATE AccountProfile 
SET address = 'Hà Đông', 
    dateOfBirth = '2005-1-18', 
    avatarUrl = 'https://example.com/avatar2.png', 
    nationalId = '012345678912', 
    verified = 1, 
    extraData = 'UpdateFirst' 
WHERE accountId = 2;



INSERT INTO Role (roleName)
VALUES ('Storekeeper');
SELECT * FROM AccountRole ;
 INSERT INTO AccountRole(AccountId,roleId)
 VALUES(2,4);
 DELETE FROM AccountRole
WHERE AccountId = 2 AND roleId = 2;
INSERT INTO AccountProfile (
    profileId,
    accountId,
    address,
    dateOfBirth,
    avatarUrl,
    nationalId,
    verified,
    extraData
)
VALUES (
    1, -- profileId
    2, -- accountId (khớp với Account.accountId = 2)
    '123 Đường ABC, Quận 1, TP.HCM', -- địa chỉ (bạn có thể đổi)
    '2002-05-12',                    -- ngày sinh
    'https://example.com/avatar/lam.jpg', -- avatar
    '079123456789',                  -- số CCCD (ví dụ)
    1,                               -- đã xác thực
    'Khách VIP, thích chơi game'     -- dữ liệu thêm
);





INSERT INTO Part VALUES (1, 'Engine Oil Filter', 'High performance oil filter for car engines', 120.50, 2, '2025-10-10');
INSERT INTO Part VALUES (2, 'Air Filter', 'Ensures clean airflow to the engine', 90.00, 2, '2025-10-10');
INSERT INTO Part VALUES (3, 'Brake Pad Set', 'Front brake pad set for compact cars', 450.75, 2, '2025-10-10');
INSERT INTO Part VALUES (4, 'Spark Plug', 'Copper spark plug for gasoline engines', 65.20, 2, '2025-10-10');
INSERT INTO Part VALUES (5, 'Timing Belt', 'Durable rubber belt for engine timing system', 800.00, 2, '2025-10-10');
INSERT INTO Part VALUES (6, 'Battery 12V', 'Maintenance-free 12V car battery', 1500.00, 2, '2025-10-10');
INSERT INTO Part VALUES (7, 'Fuel Pump', 'Electric fuel pump suitable for most sedans', 980.00, 2, '2025-10-10');
INSERT INTO Part VALUES (8, 'Radiator Hose', 'Flexible coolant hose for engine radiator', 180.00, 2, '2025-10-10');
INSERT INTO Part VALUES (9, 'Alternator', 'Generates electricity for car battery and systems', 2150.50, 2, '2025-10-10');
INSERT INTO Part VALUES (10, 'Shock Absorber', 'Rear shock absorber for SUV models', 1250.00, 2, '2025-10-10');
INSERT INTO Part VALUES (11, 'Wiper Blade', 'Durable rubber wiper for clear windshield view', 95.50, 2, '2025-10-10');
INSERT INTO Part VALUES (12, 'Radiator', 'Aluminum radiator for efficient engine cooling', 1750.00, 2, '2025-10-10');
INSERT INTO Part VALUES (13, 'Clutch Plate', 'High-friction clutch plate for manual transmission', 1320.00, 2, '2025-10-10');
INSERT INTO Part VALUES (14, 'Headlight Bulb', 'LED headlight bulb, 6000K white light', 220.00, 2, '2025-10-10');
INSERT INTO Part VALUES (15, 'Tail Light Assembly', 'Rear light assembly for modern cars', 880.50, 2, '2025-10-10');
INSERT INTO Part VALUES (16, 'Engine Mount', 'Rubber mount for reducing engine vibration', 560.00, 2, '2025-10-10');
INSERT INTO Part VALUES (17, 'Drive Belt', 'Multi-ribbed serpentine belt', 330.00, 2, '2025-10-10');
INSERT INTO Part VALUES (18, 'Oxygen Sensor', 'Monitors exhaust gas and optimizes fuel ratio', 710.00, 2, '2025-10-10');
INSERT INTO Part VALUES (19, 'Transmission Fluid', 'High-quality ATF for automatic transmissions', 320.50, 2, '2025-10-10');
INSERT INTO Part VALUES (20, 'Coolant Reservoir', 'Plastic coolant overflow tank for engine system', 275.00, 2, '2025-10-10');
INSERT INTO Part VALUES (21, 'Wheel Bearing', 'High precision wheel bearing for smooth rotation', 450.00, 2, '2025-10-10');
INSERT INTO Part VALUES (22, 'Brake Disc', 'Ventilated front brake disc for sedan', 950.00, 2, '2025-10-10');
INSERT INTO Part VALUES (23, 'Radiator Fan', 'Electric cooling fan for engine radiator', 620.00, 2, '2025-10-10');
INSERT INTO Part VALUES (24, 'AC Compressor', 'Air conditioning compressor unit for car cooling system', 2150.00, 2, '2025-10-10');
INSERT INTO Part VALUES (25, 'Fuel Injector', 'Precision fuel injector for better combustion', 740.00, 2, '2025-10-10');
INSERT INTO Part VALUES (26, 'Throttle Body', 'Controls air intake for efficient engine performance', 890.00, 2, '2025-10-10');
INSERT INTO Part VALUES (27, 'Power Steering Pump', 'Hydraulic pump for smooth steering control', 1300.00, 2, '2025-10-10');
INSERT INTO Part VALUES (28, 'Engine Gasket Set', 'Complete gasket kit for engine sealing', 480.00, 2, '2025-10-10');
INSERT INTO Part VALUES (29, 'Ignition Coil', 'High voltage coil for efficient spark generation', 520.00, 2, '2025-10-10');
INSERT INTO Part VALUES (30, 'Water Pump', 'Circulates coolant through the engine', 600.00, 2, '2025-10-10');
INSERT INTO Part VALUES (31, 'Thermostat', 'Controls engine temperature by regulating coolant flow', 180.00, 2, '2025-10-10');
INSERT INTO Part VALUES (32, 'Fuel Tank Cap', 'Sealed cap to prevent fuel evaporation', 85.00, 2, '2025-10-10');
INSERT INTO Part VALUES (33, 'Crankshaft Sensor', 'Monitors engine speed and crank position', 310.00, 2, '2025-10-10');
INSERT INTO Part VALUES (34, 'Camshaft Sensor', 'Measures camshaft position for precise timing', 290.00, 2, '2025-10-10');
INSERT INTO Part VALUES (35, 'Engine Control Module', 'Central computer controlling engine functions', 3250.00, 2, '2025-10-10');
INSERT INTO Part VALUES (36, 'ABS Sensor', 'Wheel speed sensor for anti-lock braking system', 360.00, 2, '2025-10-10');
INSERT INTO Part VALUES (37, 'Brake Caliper', 'Hydraulic component that squeezes brake pads', 1100.00, 2, '2025-10-10');
INSERT INTO Part VALUES (38, 'Fuel Filter', 'Removes impurities from fuel before combustion', 120.00, 2, '2025-10-10');
INSERT INTO Part VALUES (39, 'Cabin Air Filter', 'Purifies air entering the passenger compartment', 130.00, 2, '2025-10-10');
INSERT INTO Part VALUES (40, 'Rearview Mirror', 'Adjustable mirror for rear visibility', 240.00, 2, '2025-10-10');
INSERT INTO Part VALUES (41, 'Side Mirror', 'Left-side mirror assembly for driver visibility', 320.00, 2, '2025-10-10');
INSERT INTO Part VALUES (42, 'Door Handle', 'Exterior handle for car doors', 180.00, 2, '2025-10-10');
INSERT INTO Part VALUES (43, 'Window Regulator', 'Mechanism for raising and lowering car windows', 640.00, 2, '2025-10-10');
INSERT INTO Part VALUES (44, 'Windshield Washer Pump', 'Pumps washer fluid to windshield', 150.00, 2, '2025-10-10');
INSERT INTO Part VALUES (45, 'Radiator Cap', 'Maintains pressure in the cooling system', 95.00, 2, '2025-10-10');
INSERT INTO Part VALUES (46, 'Fuel Pressure Regulator', 'Maintains proper fuel pressure to injectors', 310.00, 2, '2025-10-10');
INSERT INTO Part VALUES (47, 'Exhaust Pipe', 'Metal pipe to direct exhaust gases from engine', 870.00, 2, '2025-10-10');
INSERT INTO Part VALUES (48, 'Muffler', 'Reduces exhaust noise from engine', 650.00, 2, '2025-10-10');
INSERT INTO Part VALUES (49, 'Catalytic Converter', 'Reduces harmful emissions from exhaust gases', 1850.00, 2, '2025-10-10');
INSERT INTO Part VALUES (50, 'Door Lock Actuator', 'Motor for locking and unlocking doors', 420.00, 2, '2025-10-10');
INSERT INTO Part VALUES (51, 'Engine Valve', 'Controls intake and exhaust gas flow', 210.00, 2, '2025-10-10');
INSERT INTO Part VALUES (52, 'Cylinder Head', 'Covers the top of the cylinders in the engine block', 4100.00, 2, '2025-10-10');
INSERT INTO Part VALUES (53, 'Oil Pan', 'Reservoir for engine oil storage', 770.00, 2, '2025-10-10');
INSERT INTO Part VALUES (54, 'Timing Chain', 'Synchronizes rotation of engine crankshaft and camshaft', 950.00, 2, '2025-10-10');
INSERT INTO Part VALUES (55, 'Valve Cover', 'Covers and seals engine valves', 440.00, 2, '2025-10-10');
INSERT INTO Part VALUES (56, 'Crankshaft', 'Converts linear motion to rotational motion in engine', 5100.00, 2, '2025-10-10');
INSERT INTO Part VALUES (57, 'Piston Ring Set', 'Seals combustion chamber and controls oil consumption', 380.00, 2, '2025-10-10');
INSERT INTO Part VALUES (58, 'Connecting Rod', 'Links piston to crankshaft in the engine', 850.00, 2, '2025-10-10');
INSERT INTO Part VALUES (59, 'Camshaft', 'Controls opening and closing of engine valves', 1800.00, 2, '2025-10-10');
INSERT INTO Part VALUES (60, 'Turbocharger', 'Increases engine power by forcing air into cylinders', 5500.00, 2, '2025-10-10');
INSERT INTO Part VALUES (61, 'Intercooler', 'Cools compressed air from turbocharger', 1450.00, 2, '2025-10-10');
INSERT INTO Part VALUES (62, 'Flywheel', 'Stores rotational energy to smooth engine operation', 2100.00, 2, '2025-10-10');
INSERT INTO Part VALUES (63, 'Clutch Cable', 'Transfers clutch pedal force to clutch system', 250.00, 2, '2025-10-10');
INSERT INTO Part VALUES (64, 'Gearbox Mount', 'Supports gearbox and absorbs vibration', 560.00, 2, '2025-10-10');
INSERT INTO Part VALUES (65, 'Transmission Mount', 'Reduces vibration between engine and transmission', 590.00, 2, '2025-10-10');
INSERT INTO Part VALUES (66, 'Driveshaft', 'Transfers torque from transmission to differential', 2700.00, 2, '2025-10-10');
INSERT INTO Part VALUES (67, 'Axle Shaft', 'Transfers power from differential to wheels', 1950.00, 2, '2025-10-10');
INSERT INTO Part VALUES (68, 'Differential Assembly', 'Distributes torque between drive wheels', 4850.00, 2, '2025-10-10');
INSERT INTO Part VALUES (69, 'Steering Rack', 'Converts steering wheel motion to wheel movement', 2800.00, 2, '2025-10-10');
INSERT INTO Part VALUES (70, 'Ball Joint', 'Connects steering knuckle to control arm', 390.00, 2, '2025-10-10');
INSERT INTO Part VALUES (71, 'Control Arm', 'Connects suspension to the vehicle frame', 1150.00, 2, '2025-10-10');
INSERT INTO Part VALUES (72, 'Stabilizer Bar', 'Reduces body roll during cornering', 670.00, 2, '2025-10-10');
INSERT INTO Part VALUES (73, 'Coil Spring', 'Supports vehicle weight and absorbs shock', 550.00, 2, '2025-10-10');
INSERT INTO Part VALUES (74, 'Leaf Spring', 'Suspension component for trucks and vans', 1250.00, 2, '2025-10-10');
INSERT INTO Part VALUES (75, 'Hub Assembly', 'Wheel hub assembly with bearing', 1450.00, 2, '2025-10-10');
INSERT INTO Part VALUES (76, 'Brake Master Cylinder', 'Supplies hydraulic pressure to brake system', 920.00, 2, '2025-10-10');
INSERT INTO Part VALUES (77, 'Clutch Master Cylinder', 'Hydraulic cylinder for clutch operation', 850.00, 2, '2025-10-10');
INSERT INTO Part VALUES (78, 'Brake Booster', 'Assists braking by amplifying pedal force', 1300.00, 2, '2025-10-10');
INSERT INTO Part VALUES (79, 'Air Conditioning Condenser', 'Dissipates heat from compressed refrigerant', 1650.00, 2, '2025-10-10');
INSERT INTO Part VALUES (80, 'Heater Core', 'Provides heat to cabin from engine coolant', 880.00, 2, '2025-10-10');
INSERT INTO Part VALUES (81, 'Seat Belt', 'Safety belt for driver and passengers', 350.00, 2, '2025-10-10');
INSERT INTO Part VALUES (82, 'Airbag Sensor', 'Triggers airbag deployment during collision', 1250.00, 2, '2025-10-10');
INSERT INTO Part VALUES (83, 'Speedometer Cable', 'Connects transmission to speedometer gauge', 280.00, 2, '2025-10-10');
INSERT INTO Part VALUES (84, 'Head Gasket', 'Seals cylinder head and engine block', 420.00, 2, '2025-10-10');
INSERT INTO Part VALUES (85, 'Brake Hose', 'Carries brake fluid to wheel cylinder', 260.00, 2, '2025-10-10');
INSERT INTO Part VALUES (86, 'Clutch Disc', 'Transfers power between engine and transmission', 980.00, 2, '2025-10-10');
INSERT INTO Part VALUES (87, 'Starter Motor', 'Cranks engine for starting', 2200.00, 2, '2025-10-10');
INSERT INTO Part VALUES (88, 'Alternator Belt', 'Belt for alternator and power steering system', 340.00, 2, '2025-10-10');
INSERT INTO Part VALUES (89, 'Windshield', 'Front glass panel for vehicle cabin', 3100.00, 2, '2025-10-10');
INSERT INTO Part VALUES (90, 'Rear Glass', 'Rear windshield for cars', 2450.00, 2, '2025-10-10');
INSERT INTO Part VALUES (91, 'Door Seal', 'Rubber weatherstrip to prevent water leaks', 180.00, 2, '2025-10-10');
INSERT INTO Part VALUES (92, 'Bonnet Hinge', 'Metal hinge connecting hood to frame', 320.00, 2, '2025-10-10');
INSERT INTO Part VALUES (93, 'Hood Latch', 'Locks hood securely in place', 230.00, 2, '2025-10-10');
INSERT INTO Part VALUES (94, 'Tailgate Strut', 'Gas strut for lifting tailgate', 450.00, 2, '2025-10-10');
INSERT INTO Part VALUES (95, 'License Plate Light', 'Small light to illuminate license plate', 95.00, 2, '2025-10-10');
INSERT INTO Part VALUES (96, 'Fog Light', 'Low-mounted light for fog visibility', 310.00, 2, '2025-10-10');
INSERT INTO Part VALUES (97, 'Horn Assembly', 'Electric horn for vehicle alert sound', 270.00, 2, '2025-10-10');
INSERT INTO Part VALUES (98, 'Battery Cable', 'Connects battery terminals to starter and alternator', 190.00, 2, '2025-10-10');
INSERT INTO Part VALUES (99, 'Fuse Box', 'Houses electrical fuses for protection', 650.00, 2, '2025-10-10');
INSERT INTO Part VALUES (100, 'ECU Connector', 'Electrical connector for vehicle ECU', 210.00, 2, '2025-10-10');
SELECT * FROM Part;
DELETE FROM Part
WHERE partId = 1;

INSERT INTO PartDetail VALUES (1, 1, 'ENG-OIL-001', 'Available', 'Warehouse A1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (2, 1, 'ENG-OIL-002', 'InUse', 'Garage 3', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (3, 2, 'AIR-FLT-001', 'Available', 'Warehouse A2', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (4, 2, 'AIR-FLT-002', 'Available', 'Warehouse A2', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (5, 3, 'BRK-PAD-001', 'InUse', 'Repair Bay 1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (6, 3, 'BRK-PAD-002', 'Faulty', 'Returned Zone', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (7, 4, 'SPK-PLG-001', 'Available', 'Warehouse B1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (8, 4, 'SPK-PLG-002', 'Available', 'Warehouse B1', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (9, 5, 'TMG-BLT-001', 'InUse', 'Garage 1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (10, 5, 'TMG-BLT-002', 'Available', 'Warehouse C1', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (11, 6, 'BAT-12V-001', 'Available', 'Battery Rack A', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (12, 6, 'BAT-12V-002', 'Retired', 'Recycling Area', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (13, 7, 'FUEL-PMP-001', 'Available', 'Warehouse D1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (14, 7, 'FUEL-PMP-002', 'InUse', 'Test Car 2', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (15, 8, 'RAD-HOSE-001', 'Available', 'Warehouse D2', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (16, 8, 'RAD-HOSE-002', 'Faulty', 'Return Desk', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (17, 9, 'ALT-001', 'Available', 'Warehouse E1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (18, 9, 'ALT-002', 'InUse', 'Truck Bay 2', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (19, 10, 'SHK-ABS-001', 'Available', 'Warehouse E2', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (20, 10, 'SHK-ABS-002', 'Faulty', 'Repair Section', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (21, 11, 'WPR-BLD-001', 'Available', 'Warehouse F1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (22, 11, 'WPR-BLD-002', 'Available', 'Warehouse F1', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (23, 12, 'RAD-001', 'InUse', 'Garage 4', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (24, 12, 'RAD-002', 'Available', 'Warehouse F2', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (25, 13, 'CLT-PLT-001', 'Available', 'Warehouse G1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (26, 13, 'CLT-PLT-002', 'Faulty', 'Return Zone', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (27, 14, 'HDL-BLB-001', 'Available', 'Warehouse G2', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (28, 14, 'HDL-BLB-002', 'InUse', 'Car Assembly Line', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (29, 15, 'TLG-ASSY-001', 'Available', 'Warehouse H1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (30, 15, 'TLG-ASSY-002', 'Available', 'Warehouse H1', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (31, 16, 'ENG-MNT-001', 'InUse', 'Garage 2', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (32, 16, 'ENG-MNT-002', 'Available', 'Warehouse I1', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (33, 17, 'DRV-BLT-001', 'Available', 'Warehouse I2', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (34, 17, 'DRV-BLT-002', 'Retired', 'Old Storage', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (35, 18, 'OXY-SEN-001', 'InUse', 'Engine Test Room', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (36, 18, 'OXY-SEN-002', 'Available', 'Warehouse J1', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (37, 19, 'TRN-FLD-001', 'Available', 'Warehouse J2', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (38, 19, 'TRN-FLD-002', 'Available', 'Warehouse J2', 2, '2025-10-10');

INSERT INTO PartDetail VALUES (39, 20, 'COL-RES-001', 'Available', 'Warehouse K1', 2, '2025-10-10');
INSERT INTO PartDetail VALUES (40, 20, 'COL-RES-002', 'Faulty', 'Returned Zone', 2, '2025-10-10');
SELECT * FROM PartDetail ;
INSERT INTO Inventory (inventoryId, partId, quantity, lastUpdatedBy, lastUpdatedDate)
VALUES
(1, 1, 120, 2, NOW()),  -- Engine Oil Filter
(2, 2, 80, 2, NOW()),   -- Air Filter
(3, 3, 200, 2, NOW()),  -- Brake Pad Set
(4, 4, 150, 2, NOW()),  -- Spark Plug
(5, 5, 60, 2, NOW()),   -- Timing Belt
(6, 6, 40, 2, NOW()),   -- Battery 12V
(7, 7, 90, 2, NOW()),   -- Fuel Pump
(8, 8, 130, 2, NOW()),  -- Radiator Hose
(9, 9, 35, 2, NOW()),   -- Alternator
(10, 10, 55, 2, NOW()); -- Shock Absorber
SELECT * FROM Inventory ;
SELECT * FROM Part ;


INSERT INTO Inventory (inventoryId, partId, quantity, lastUpdatedBy, lastUpdatedDate)
VALUES

(11, 11, 50, 1, CURRENT_DATE),
(12, 12, 60, 1, CURRENT_DATE),
(13, 13, 70, 1, CURRENT_DATE),
(14, 14, 80, 1, CURRENT_DATE),
(15, 15, 90, 1, CURRENT_DATE),
(16, 16, 100, 1, CURRENT_DATE),
(17, 17, 55, 1, CURRENT_DATE),
(18, 18, 65, 1, CURRENT_DATE),
(19, 19, 75, 1, CURRENT_DATE),
(20, 20, 85, 1, CURRENT_DATE),
(21, 21, 50, 1, CURRENT_DATE),
(22, 22, 60, 1, CURRENT_DATE),
(23, 23, 70, 1, CURRENT_DATE),
(24, 24, 80, 1, CURRENT_DATE),
(25, 25, 90, 1, CURRENT_DATE),
(26, 26, 100, 1, CURRENT_DATE),
(27, 27, 55, 1, CURRENT_DATE),
(28, 28, 65, 1, CURRENT_DATE),
(29, 29, 75, 1, CURRENT_DATE),
(30, 30, 85, 1, CURRENT_DATE),
(31, 31, 50, 1, CURRENT_DATE),
(32, 32, 60, 1, CURRENT_DATE),
(33, 33, 70, 1, CURRENT_DATE),
(34, 34, 80, 1, CURRENT_DATE),
(35, 35, 90, 1, CURRENT_DATE),
(36, 36, 100, 1, CURRENT_DATE),
(37, 37, 55, 1, CURRENT_DATE),
(38, 38, 65, 1, CURRENT_DATE),
(39, 39, 75, 1, CURRENT_DATE),
(40, 40, 85, 1, CURRENT_DATE),
(41, 41, 50, 1, CURRENT_DATE),
(42, 42, 60, 1, CURRENT_DATE),
(43, 43, 70, 1, CURRENT_DATE),
(44, 44, 80, 1, CURRENT_DATE),
(45, 45, 90, 1, CURRENT_DATE),
(46, 46, 100, 1, CURRENT_DATE),
(47, 47, 55, 1, CURRENT_DATE),
(48, 48, 65, 1, CURRENT_DATE),
(49, 49, 75, 1, CURRENT_DATE),
(50, 50, 85, 1, CURRENT_DATE),
(51, 51, 50, 1, CURRENT_DATE),
(52, 52, 60, 1, CURRENT_DATE),
(53, 53, 70, 1, CURRENT_DATE),
(54, 54, 80, 1, CURRENT_DATE),
(55, 55, 90, 1, CURRENT_DATE),
(56, 56, 100, 1, CURRENT_DATE),
(57, 57, 55, 1, CURRENT_DATE),
(58, 58, 65, 1, CURRENT_DATE),
(59, 59, 75, 1, CURRENT_DATE),
(60, 60, 85, 1, CURRENT_DATE),
(61, 61, 50, 1, CURRENT_DATE),
(62, 62, 60, 1, CURRENT_DATE),
(63, 63, 70, 1, CURRENT_DATE),
(64, 64, 80, 1, CURRENT_DATE),
(65, 65, 90, 1, CURRENT_DATE),
(66, 66, 100, 1, CURRENT_DATE),
(67, 67, 55, 1, CURRENT_DATE),
(68, 68, 65, 1, CURRENT_DATE),
(69, 69, 75, 1, CURRENT_DATE),
(70, 70, 85, 1, CURRENT_DATE),
(71, 71, 50, 1, CURRENT_DATE),
(72, 72, 60, 1, CURRENT_DATE),
(73, 73, 70, 1, CURRENT_DATE),
(74, 74, 80, 1, CURRENT_DATE),
(75, 75, 90, 1, CURRENT_DATE),
(76, 76, 100, 1, CURRENT_DATE),
(77, 77, 55, 1, CURRENT_DATE),
(78, 78, 65, 1, CURRENT_DATE),
(79, 79, 75, 1, CURRENT_DATE),
(80, 80, 85, 1, CURRENT_DATE),
(81, 81, 50, 1, CURRENT_DATE),
(82, 82, 60, 1, CURRENT_DATE),
(83, 83, 70, 1, CURRENT_DATE),
(84, 84, 80, 1, CURRENT_DATE),
(85, 85, 90, 1, CURRENT_DATE),
(86, 86, 100, 1, CURRENT_DATE),
(87, 87, 55, 1, CURRENT_DATE),
(88, 88, 65, 1, CURRENT_DATE),
(89, 89, 75, 1, CURRENT_DATE),
(90, 90, 85, 1, CURRENT_DATE),
(91, 91, 50, 1, CURRENT_DATE),
(92, 92, 60, 1, CURRENT_DATE),
(93, 93, 70, 1, CURRENT_DATE),
(94, 94, 80, 1, CURRENT_DATE),
(95, 95, 90, 1, CURRENT_DATE),
(96, 96, 100, 1, CURRENT_DATE),
(97, 97, 55, 1, CURRENT_DATE),
(98, 98, 65, 1, CURRENT_DATE),
(99, 99, 75, 1, CURRENT_DATE),
(100, 100, 85, 1, CURRENT_DATE);


INSERT INTO PartDetail (partId, serialNumber, status, location, lastUpdatedBy, lastUpdatedDate) VALUES
(1,'SN001','Available','Kho A',1,CURDATE()),
(2,'SN002','InUse','Kho B',1,CURDATE()),
(3,'SN003','Faulty','Kho C',1,CURDATE()),
(4,'SN004','Retired','Kho D',1,CURDATE()),
(5,'SN005','Available','Kho A',1,CURDATE()),
(6,'SN006','InUse','Kho B',1,CURDATE()),
(7,'SN007','Faulty','Kho C',1,CURDATE()),
(8,'SN008','Retired','Kho D',1,CURDATE()),
(9,'SN009','Available','Kho A',1,CURDATE()),
(10,'SN010','InUse','Kho B',1,CURDATE()),
(11,'SN011','Faulty','Kho C',1,CURDATE()),
(12,'SN012','Retired','Kho D',1,CURDATE()),
(13,'SN013','Available','Kho A',1,CURDATE()),
(14,'SN014','InUse','Kho B',1,CURDATE()),
(15,'SN015','Faulty','Kho C',1,CURDATE()),
(16,'SN016','Retired','Kho D',1,CURDATE()),
(17,'SN017','Available','Kho A',1,CURDATE()),
(18,'SN018','InUse','Kho B',1,CURDATE()),
(19,'SN019','Faulty','Kho C',1,CURDATE()),
(20,'SN020','Retired','Kho D',1,CURDATE()),
(21,'SN021','Available','Kho A',1,CURDATE()),
(22,'SN022','InUse','Kho B',1,CURDATE()),
(23,'SN023','Faulty','Kho C',1,CURDATE()),
(24,'SN024','Retired','Kho D',1,CURDATE()),
(25,'SN025','Available','Kho A',1,CURDATE()),
(26,'SN026','InUse','Kho B',1,CURDATE()),
(27,'SN027','Faulty','Kho C',1,CURDATE()),
(28,'SN028','Retired','Kho D',1,CURDATE()),
(29,'SN029','Available','Kho A',1,CURDATE()),
(30,'SN030','InUse','Kho B',1,CURDATE()),
(31,'SN031','Faulty','Kho C',1,CURDATE()),
(32,'SN032','Retired','Kho D',1,CURDATE()),
(33,'SN033','Available','Kho A',1,CURDATE()),
(34,'SN034','InUse','Kho B',1,CURDATE()),
(35,'SN035','Faulty','Kho C',1,CURDATE()),
(36,'SN036','Retired','Kho D',1,CURDATE()),
(37,'SN037','Available','Kho A',1,CURDATE()),
(38,'SN038','InUse','Kho B',1,CURDATE()),
(39,'SN039','Faulty','Kho C',1,CURDATE()),
(40,'SN040','Retired','Kho D',1,CURDATE()),
(41,'SN041','Available','Kho A',1,CURDATE()),
(42,'SN042','InUse','Kho B',1,CURDATE()),
(43,'SN043','Faulty','Kho C',1,CURDATE()),
(44,'SN044','Retired','Kho D',1,CURDATE()),
(45,'SN045','Available','Kho A',1,CURDATE()),
(46,'SN046','InUse','Kho B',1,CURDATE()),
(47,'SN047','Faulty','Kho C',1,CURDATE()),
(48,'SN048','Retired','Kho D',1,CURDATE()),
(49,'SN049','Available','Kho A',1,CURDATE()),
(50,'SN050','InUse','Kho B',1,CURDATE()),
(51,'SN051','Faulty','Kho C',1,CURDATE()),
(52,'SN052','Retired','Kho D',1,CURDATE()),
(53,'SN053','Available','Kho A',1,CURDATE()),
(54,'SN054','InUse','Kho B',1,CURDATE()),
(55,'SN055','Faulty','Kho C',1,CURDATE()),
(56,'SN056','Retired','Kho D',1,CURDATE()),
(57,'SN057','Available','Kho A',1,CURDATE()),
(58,'SN058','InUse','Kho B',1,CURDATE()),
(59,'SN059','Faulty','Kho C',1,CURDATE()),
(60,'SN060','Retired','Kho D',1,CURDATE()),
(61,'SN061','Available','Kho A',1,CURDATE()),
(62,'SN062','InUse','Kho B',1,CURDATE()),
(63,'SN063','Faulty','Kho C',1,CURDATE()),
(64,'SN064','Retired','Kho D',1,CURDATE()),
(65,'SN065','Available','Kho A',1,CURDATE()),
(66,'SN066','InUse','Kho B',1,CURDATE()),
(67,'SN067','Faulty','Kho C',1,CURDATE()),
(68,'SN068','Retired','Kho D',1,CURDATE()),
(69,'SN069','Available','Kho A',1,CURDATE()),
(70,'SN070','InUse','Kho B',1,CURDATE()),
(71,'SN071','Faulty','Kho C',1,CURDATE()),
(72,'SN072','Retired','Kho D',1,CURDATE()),
(73,'SN073','Available','Kho A',1,CURDATE()),
(74,'SN074','InUse','Kho B',1,CURDATE()),
(75,'SN075','Faulty','Kho C',1,CURDATE()),
(76,'SN076','Retired','Kho D',1,CURDATE()),
(77,'SN077','Available','Kho A',1,CURDATE()),
(78,'SN078','InUse','Kho B',1,CURDATE()),
(79,'SN079','Faulty','Kho C',1,CURDATE()),
(80,'SN080','Retired','Kho D',1,CURDATE()),
(81,'SN081','Available','Kho A',1,CURDATE()),
(82,'SN082','InUse','Kho B',1,CURDATE()),
(83,'SN083','Faulty','Kho C',1,CURDATE()),
(84,'SN084','Retired','Kho D',1,CURDATE()),
(85,'SN085','Available','Kho A',1,CURDATE()),
(86,'SN086','InUse','Kho B',1,CURDATE()),
(87,'SN087','Faulty','Kho C',1,CURDATE()),
(88,'SN088','Retired','Kho D',1,CURDATE()),
(89,'SN089','Available','Kho A',1,CURDATE()),
(90,'SN090','InUse','Kho B',1,CURDATE()),
(91,'SN091','Faulty','Kho C',1,CURDATE()),
(92,'SN092','Retired','Kho D',1,CURDATE()),
(93,'SN093','Available','Kho A',1,CURDATE()),
(94,'SN094','InUse','Kho B',1,CURDATE()),
(95,'SN095','Faulty','Kho C',1,CURDATE()),
(96,'SN096','Retired','Kho D',1,CURDATE()),
(97,'SN097','Available','Kho A',1,CURDATE()),
(98,'SN098','InUse','Kho B',1,CURDATE()),
(99,'SN099','Faulty','Kho C',1,CURDATE()),
(100,'SN100','Retired','Kho D',1,CURDATE());
SELECT * From PartDetail;

INSERT INTO PartDetail ( partId, serialNumber, status, location, lastUpdatedBy, lastUpdatedDate) VALUES
( 2, 'Air Filter #001', 'Available', 'Warehouse A', 1, '2025-10-15'),
( 2, 'Air Filter #002', 'Available', 'Warehouse A', 1, '2025-10-15'),
( 2, 'Air Filter #003', 'InUse', 'Garage 1', 2, '2025-10-14'),
( 2, 'Air Filter #004', 'Faulty', 'Repair Zone', 3, '2025-10-13'),
( 2, 'Air Filter #005', 'Available', 'Warehouse B', 1, '2025-10-15'),
( 2, 'Air Filter #006', 'Available', 'Warehouse A', 1, '2025-10-15'),
( 2, 'Air Filter #007', 'Retired', 'Storage Room', 2, '2025-10-10'),
( 2, 'Air Filter #008', 'Available', 'Warehouse C', 1, '2025-10-15'),
( 2, 'Air Filter #009', 'InUse', 'Garage 2', 2, '2025-10-14'),
( 2, 'Air Filter #010', 'Available', 'Warehouse B', 1, '2025-10-15');

INSERT INTO PartDetail ( partId, serialNumber, status, location, lastUpdatedBy, lastUpdatedDate) VALUES
( 3, 'Brake Pad Set #001', 'Available', 'Warehouse A', 1, '2025-10-15'),
( 3, 'Brake Pad Set #002', 'Available', 'Warehouse A', 1, '2025-10-15'),
( 3, 'Brake Pad Set #003', 'InUse', 'Garage 1', 2, '2025-10-14'),
( 3, 'Brake Pad Set #004', 'Faulty', 'Repair Zone', 3, '2025-10-13'),
( 3, 'Brake Pad Set #005', 'Available', 'Warehouse B', 1, '2025-10-15'),
( 3, 'Brake Pad Set #006', 'Available', 'Warehouse A', 1, '2025-10-15'),
( 3, 'Brake Pad Set #007', 'Available', 'Warehouse C', 1, '2025-10-15'),
( 3, 'Brake Pad Set #008', 'Retired', 'Storage Room', 2, '2025-10-12'),
( 3, 'Brake Pad Set #009', 'Available', 'Warehouse B', 1, '2025-10-15'),
( 3, 'Brake Pad Set #010', 'InUse', 'Garage 2', 2, '2025-10-14'),
( 3, 'Brake Pad Set #011', 'Available', 'Warehouse A', 1, '2025-10-15'),
( 3, 'Brake Pad Set #012', 'Available', 'Warehouse C', 1, '2025-10-15'),
( 3, 'Brake Pad Set #013', 'Faulty', 'Repair Zone', 3, '2025-10-13'),
( 3, 'Brake Pad Set #014', 'Available', 'Warehouse A', 1, '2025-10-15'),
( 3, 'Brake Pad Set #015', 'Available', 'Warehouse B', 1, '2025-10-15');



INSERT INTO Role (roleId, roleName) VALUES
(1, 'Admin'),
(2, 'Customer'),
(3, 'Customer Support Staff'),
(4, 'Technical Manager'),
(5, 'Storekeeper');




UPDATE AccountRole
SET roleId = 5
WHERE accountId = 2;
SELECT * FROM Account ;
UPDATE Account
SET passwordHash = '$2a$12$/EBvaV2Yx3HLbxL642jaEuYKh3KY7PYf7pZ8KOze.B7ZDX16Ky0Ba'
WHERE accountId = 2;
SELECT * FROM Role ; 
SELECT * FROM AccountRole ;
Update AccountRole SET roleId =1 WHERE AccountId = 1 ;