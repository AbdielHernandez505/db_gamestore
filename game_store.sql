CREATE DATABASE game_store;
USE game_store;

# Roles Table
CREATE TABLE roles (
    role_id     INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    description VARCHAR(255)
);

# Categories Table (mejora)
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(50) NOT NULL,
    min_age     INT,
    description VARCHAR(255) -- 🔥 agregado
);

# Branches Table (mejorada)
CREATE TABLE branches (
    branch_id INT PRIMARY KEY AUTO_INCREMENT,
    name      VARCHAR(100) NOT NULL,
    address   VARCHAR(200) NOT NULL,
    phone     VARCHAR(20)  NOT NULL,
    schedule  VARCHAR(100), -- 🔥 agregado
    manager_id INT NULL,    -- 🔥 agregado (se conecta después)
    status    ENUM('active', 'inactive') DEFAULT 'active'
);

# Suppliers Table
CREATE TABLE suppliers (
    supplier_id  INT PRIMARY KEY AUTO_INCREMENT,
    name         VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    phone        VARCHAR(20)  NOT NULL,
    status       ENUM('active', 'inactive') DEFAULT 'active'
);

# Consoles Table (validación)
CREATE TABLE consoles (
    console_id   INT PRIMARY KEY AUTO_INCREMENT,
    name         VARCHAR(50)  NOT NULL,
    manufacturer VARCHAR(50)  NOT NULL,
    price        DECIMAL(10,2) NOT NULL CHECK (price >= 0), -- 🔥 validación
    status       ENUM('active', 'inactive') DEFAULT 'active'
);

# Games Table (validación)
CREATE TABLE games (
    game_id      INT PRIMARY KEY AUTO_INCREMENT,
    title        VARCHAR(150) NOT NULL,
    console_id   INT NOT NULL,
    category_id  INT NOT NULL,
    price        DECIMAL(10,2) NOT NULL CHECK (price >= 0), -- 🔥 validación
    status       ENUM('active', 'inactive') DEFAULT 'active',
    CONSTRAINT fk_game_console  FOREIGN KEY (console_id)  REFERENCES consoles(console_id),
    CONSTRAINT fk_game_category FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

# Products Table
CREATE TABLE products (
    product_id   INT PRIMARY KEY AUTO_INCREMENT,
    name         VARCHAR(100) NOT NULL,
    price        DECIMAL(10,2) NOT NULL CHECK (price >= 0), -- 🔥 validación
    status       ENUM('active', 'inactive') DEFAULT 'active'
);

# Inventory Table (mejorada)
CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_id    INT NOT NULL,
    game_id      INT NULL,
    console_id   INT NULL,
    product_id   INT NULL,
    quantity     INT NOT NULL DEFAULT 0 CHECK (quantity >= 0), -- 🔥 validación
    min_stock    INT NOT NULL DEFAULT 5 CHECK (min_stock >= 0), -- 🔥 validación
    last_update  DATETIME DEFAULT CURRENT_TIMESTAMP, -- 🔥 agregado
    status       ENUM('active', 'inactive') DEFAULT 'active',
    CONSTRAINT fk_inv_branch   FOREIGN KEY (branch_id)   REFERENCES branches(branch_id),
    CONSTRAINT fk_inv_game     FOREIGN KEY (game_id)     REFERENCES games(game_id),
    CONSTRAINT fk_inv_console  FOREIGN KEY (console_id)  REFERENCES consoles(console_id),
    CONSTRAINT fk_inv_product  FOREIGN KEY (product_id)  REFERENCES products(product_id),
    CONSTRAINT chk_inv_item CHECK (
        (game_id IS NOT NULL AND console_id IS NULL AND product_id IS NULL) OR
        (game_id IS NULL AND console_id IS NOT NULL AND product_id IS NULL) OR
        (game_id IS NULL AND console_id IS NULL AND product_id IS NOT NULL)
    )
);

# Employees Table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name  VARCHAR(50)  NOT NULL,
    last_name   VARCHAR(50)  NOT NULL,
    phone       VARCHAR(20)  NOT NULL,
    salary      DECIMAL(10,2) NOT NULL CHECK (salary >= 0), -- 🔥 validación
    role_id     INT NOT NULL,
    branch_id   INT NOT NULL,
    status      ENUM('active', 'inactive') DEFAULT 'active',
    CONSTRAINT fk_emp_role   FOREIGN KEY (role_id)   REFERENCES roles(role_id),
    CONSTRAINT fk_emp_branch FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

# 🔥 ahora sí se puede relacionar el manager
ALTER TABLE branches
ADD CONSTRAINT fk_branch_manager
FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

# Clients Table (mejorada)
CREATE TABLE clients (
    client_id  INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50)  NOT NULL,
    last_name  VARCHAR(50)  NOT NULL,
    phone      VARCHAR(20)  NOT NULL,
    email      VARCHAR(100), -- 🔥 agregado
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP, -- 🔥 agregado
    points     INT DEFAULT 0 CHECK (points >= 0), -- 🔥 validación
    status     ENUM('active', 'inactive') DEFAULT 'active'
);

# Sales Table
CREATE TABLE sales (
    sale_id     INT PRIMARY KEY AUTO_INCREMENT,
    client_id   INT NOT NULL,
    employee_id INT NOT NULL,
    branch_id   INT NOT NULL,
    sale_date   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total       DECIMAL(12,2) NOT NULL CHECK (total >= 0), -- 🔥 validación
    status      ENUM('active', 'inactive') DEFAULT 'active',
    CONSTRAINT fk_sale_client   FOREIGN KEY (client_id)   REFERENCES clients(client_id),
    CONSTRAINT fk_sale_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT fk_sale_branch   FOREIGN KEY (branch_id)   REFERENCES branches(branch_id)
);

# Purchases Table
CREATE TABLE purchases (
    purchase_id   INT PRIMARY KEY AUTO_INCREMENT,
    supplier_id   INT NOT NULL,
    branch_id     INT NOT NULL,
    purchase_date DATE NOT NULL,
    total         DECIMAL(12,2) NOT NULL CHECK (total >= 0), -- 🔥 validación
    status        ENUM('active', 'inactive') DEFAULT 'active',
    CONSTRAINT fk_purchase_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CONSTRAINT fk_purchase_branch   FOREIGN KEY (branch_id)   REFERENCES branches(branch_id)
);

# Sale Details Table
CREATE TABLE sale_details (
    detail_id   INT PRIMARY KEY AUTO_INCREMENT,
    sale_id     INT NOT NULL,
    game_id     INT NULL,
    console_id  INT NULL,
    product_id  INT NULL,
    quantity    INT NOT NULL CHECK (quantity > 0), -- 🔥 validación
    unit_price  DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    subtotal    DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    CONSTRAINT fk_detail_sale FOREIGN KEY (sale_id) REFERENCES sales(sale_id),
    CONSTRAINT fk_detail_game FOREIGN KEY (game_id) REFERENCES games(game_id),
    CONSTRAINT fk_detail_console FOREIGN KEY (console_id) REFERENCES consoles(console_id),
    CONSTRAINT fk_detail_product FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT chk_sale_item CHECK (
        (game_id IS NOT NULL AND console_id IS NULL AND product_id IS NULL) OR
        (game_id IS NULL AND console_id IS NOT NULL AND product_id IS NULL) OR
        (game_id IS NULL AND console_id IS NULL AND product_id IS NOT NULL)
    )
);

# Purchase Details Table
CREATE TABLE purchase_details (
    detail_id   INT PRIMARY KEY AUTO_INCREMENT,
    purchase_id INT NOT NULL,
    game_id     INT NULL,
    console_id  INT NULL,
    product_id  INT NULL,
    quantity    INT NOT NULL CHECK (quantity > 0),
    unit_cost   DECIMAL(10,2) NOT NULL CHECK (unit_cost >= 0),
    subtotal    DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    CONSTRAINT fk_pdetail_purchase FOREIGN KEY (purchase_id) REFERENCES purchases(purchase_id),
    CONSTRAINT fk_pdetail_game FOREIGN KEY (game_id) REFERENCES games(game_id),
    CONSTRAINT fk_pdetail_console FOREIGN KEY (console_id) REFERENCES consoles(console_id),
    CONSTRAINT fk_pdetail_product FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT chk_purchase_item CHECK (
        (game_id IS NOT NULL AND console_id IS NULL AND product_id IS NULL) OR
        (game_id IS NULL AND console_id IS NOT NULL AND product_id IS NULL) OR
        (game_id IS NULL AND console_id IS NULL AND product_id IS NOT NULL)
    )
);

# Audit Log Table (como tú pediste)
CREATE TABLE audit_log (
    id int auto_increment primary key,
    date_ datetime,
    user_ varchar(255),
    table_ varchar(255),
    operation varchar(10)
);

#inserts data 



INSERT INTO roles (name, description, permissions) VALUES
('Admin', 'System administrator', 'all'),
('Gerente', 'Branch manager', 'manage_branch'),
('Vendedor', 'Sales associate', 'sales'),
('Almacenista', 'Inventory manager', 'inventory');

INSERT INTO categories (name, description, min_age) VALUES
('Everyone', 'Suitable for all ages', 0),
('Everyone 10+', 'Ages 10 and up', 10),
('Teen', 'Ages 13 and up', 13),
('Mature 17+', 'Ages 17 and up', 17),
('Adults Only', 'Ages 18 and up', 18),
('Rating Pending', 'Not yet rated', 0);

INSERT INTO consoles (name, manufacturer, release_year, price) VALUES
('PlayStation 5', 'Sony', 2020, 5499.00),
('PlayStation 4', 'Sony', 2013, 3999.00),
('Xbox Series X', 'Microsoft', 2020, 5299.00),
('Xbox Series S', 'Microsoft', 2020, 3499.00),
('Nintendo Switch', 'Nintendo', 2017, 4499.00),
('Nintendo Switch OLED', 'Nintendo', 2021, 5499.00),
('PC Gaming', 'Various', 2023, 15999.00),
('PlayStation 5 Pro', 'Sony', 2024, 7999.00),
('Xbox Series X Pro', 'Microsoft', 2024, 7499.00),
('Nintendo Switch Lite', 'Nintendo', 2019, 2999.00);

INSERT INTO suppliers (name, contact_person, phone, email, address) VALUES
('Sony Mexico', 'Carlos Mendoza', '+526643333001', 'sales@sonymx.com', 'Av. Tecnológico 100, Col. Centro'),
('Microsoft Mexico', 'Ana García', '+526643333002', 'contact@msmx.com', 'Calle Norte 200, Col. Norte'),
('Nintendo Mexico', 'Luis Ramírez', '+526643333003', 'info@nintendo.mx', 'Av. Sur 300, Col. Sur'),
('Game Distribution', 'Patricia Herrera', '+526643333004', 'sales@gamedist.com', 'Blvd. Industrial 500, Col. Centro'),
('Game Supply MX', 'Fernando Ruiz', '+526643333005', 'info@supplymx.com', 'Calle Comercial 150, Col. Norte');

INSERT INTO branches (name, address, phone, email, schedule, branch_number, status) VALUES
('GameZone Centro', 'Av. Reforma 123, Col. Centro', '+526641111001', 'centro@gamezone.com', 'Lun-Dom 9:00-21:00', 'GZ001', 'active'),
('GameZone Norte', 'Av. Universidad 456, Col. Norte', '+526641111002', 'norte@gamezone.com', 'Lun-Dom 9:00-21:00', 'GZ002', 'active'),
('GameZone Sur', 'Av. Insurgentes 789, Col. Sur', '+526641111003', 'sur@gamezone.com', 'Lun-Dom 9:00-21:00', 'GZ003', 'active'),
('GameZone Este', 'Calle Oriente 321, Col. Este', '+526641111004', 'este@gamezone.com', 'Lun-Dom 10:00-20:00', 'GZ004', 'active'),
('GameZone Oeste', 'Calle Poniente 654, Col. Oeste', '+526641111005', 'oeste@gamezone.com', 'Lun-Dom 10:00-20:00', 'GZ005', 'active'),
('GameZone Plaza', 'Plaza Mayor 147, Col. Centro', '+526641111006', 'plaza@gamezone.com', 'Lun-Dom 9:00-22:00', 'GZ006', 'active'),
('GameZone Mall', 'Mall Centro 258, Col. Norte', '+526641111007', 'mall@gamezone.com', 'Lun-Dom 10:00-21:00', 'GZ007', 'active'),
('GameZone Premium', 'Av. Premium 369, Col. Sur', '+526641111008', 'premium@gamezone.com', 'Lun-Dom 11:00-21:00', 'GZ008', 'active'),
('GameZone Express', 'Calle Express 741, Col. Este', '+526641111009', 'express@gamezone.com', 'Lun-Dom 9:00-18:00', 'GZ009', 'active'),
('GameZone Outlet', 'Blvd. Outlet 852, Col. Oeste', '+526641111010', 'outlet@gamezone.com', 'Lun-Dom 10:00-19:00', 'GZ010', 'active');

INSERT INTO employees (first_name, last_name, email, phone, hire_date, salary, role_id, branch_id) VALUES
('Juan', 'Pérez', 'j.perez@gamezone.com', '+526642222001', '2020-01-15', 15000.00, 1, 1),
('María', 'González', 'm.gonzalez@gamezone.com', '+526642222002', '2020-03-20', 12000.00, 2, 2),
('Carlos', 'Mendoza', 'c.mendoza@gamezone.com', '+526642222003', '2020-05-01', 12000.00, 2, 3),
('Ana', 'López', 'a.lopez@gamezone.com', '+526642222004', '2020-07-15', 12000.00, 2, 4),
('Luis', 'Ramírez', 'l.ramirez@gamezone.com', '+526642222005', '2021-01-10', 12000.00, 2, 5),
('Rosa', 'Martínez', 'r.martinez@gamezone.com', '+526642222006', '2021-03-01', 12000.00, 2, 6),
('Pedro', 'Hernández', 'p.hernandez@gamezone.com', '+526642222007', '2021-05-20', 12000.00, 2, 7),
('Laura', 'Sánchez', 'l.sanchez@gamezone.com', '+526642222008', '2021-06-15', 12000.00, 2, 8),
('Jorge', 'Díaz', 'j.diaz@gamezone.com', '+526642222009', '2021-08-01', 12000.00, 2, 9),
('Carmen', 'Ruiz', 'c.ruiz@gamezone.com', '+526642222010', '2021-09-10', 12000.00, 2, 10),
('Fernando', 'Torres', 'f.torres@gamezone.com', '+526642222011', '2020-02-01', 8500.00, 3, 1),
('Patricia', 'Flores', 'p.flores@gamezone.com', '+526642222012', '2020-04-15', 8500.00, 3, 2),
('Miguel', 'Castro', 'm.castro@gamezone.com', '+526642222013', '2020-06-20', 8500.00, 3, 3),
('Sofia', 'Reyes', 's.reyes@gamezone.com', '+526642222014', '2020-08-10', 8500.00, 3, 4),
('Alejandro', 'Morales', 'a.morales@gamezone.com', '+526642222015', '2020-10-01', 8500.00, 3, 5),
('Isabel', 'Cruz', 'i.cruz@gamezone.com', '+526642222016', '2020-12-05', 8500.00, 3, 6),
('Roberto', 'Ortiz', 'r.ortiz@gamezone.com', '+526642222017', '2021-02-15', 8500.00, 3, 7),
('Gabriel', 'Jiménez', 'g.jimenez@gamezone.com', '+526642222018', '2021-04-20', 8500.00, 3, 8),
('Lucia', 'Méndez', 'l.mendez@gamezone.com', '+526642222019', '2021-06-30', 8500.00, 3, 9),
('Ricardo', 'Navarro', 'r.navarro@gamezone.com', '+526642222020', '2021-08-25', 8500.00, 3, 10),
('Daniela', 'Vargas', 'd.vargas@gamezone.com', '+526642222021', '2020-01-20', 8000.00, 4, 1),
('Oscar', 'Luna', 'o.luna@gamezone.com', '+526642222022', '2020-03-10', 8000.00, 4, 2),
('Monica', 'Alvarez', 'm.alvarez@gamezone.com', '+526642222023', '2020-05-25', 8000.00, 4, 3),
('Eduardo', 'Rojas', 'e.rojas@gamezone.com', '+526642222024', '2020-07-30', 8000.00, 4, 4),
('Claudia', 'Herrera', 'c.herrera@gamezone.com', '+526642222025', '2020-09-15', 8000.00, 4, 5);






#pongan mas juegos, si pueden unos 80 mas 
INSERT INTO games (title, console_id, category_id, price, release_date, rating, stock_total, status) VALUES
('God of War Ragnarok', 1, 4, 1299.00, '2022-11-09', 9.8, 50, 'available'),
('Halo Infinite', 3, 4, 1199.00, '2021-12-08', 9.0, 45, 'available'),
('Zelda Breath of the Wild', 5, 2, 999.00, '2017-03-03', 10.0, 60, 'available'),
('Elden Ring', 7, 4, 1399.00, '2022-02-25', 9.5, 40, 'available'),
('FIFA 24', 1, 1, 1099.00, '2023-09-29', 8.5, 80, 'available'),
('Call of Duty MW III', 3, 4, 1299.00, '2023-11-10', 8.8, 55, 'available'),
('Pokemon Scarlet', 5, 2, 899.00, '2022-11-18', 9.2, 70, 'available'),
('Spider-Man 2', 1, 2, 1299.00, '2023-10-20', 9.4, 35, 'available'),
('Super Mario Odyssey', 5, 1, 799.00, '2017-10-27', 9.7, 55, 'available'),
('Horizon Forbidden West', 1, 2, 1199.00, '2022-02-18', 9.1, 30, 'available'),
('Forza Horizon 5', 3, 1, 1099.00, '2021-11-09', 9.2, 45, 'available'),
('Animal Crossing', 5, 1, 799.00, '2020-03-20', 9.0, 65, 'available'),
('Resident Evil 4 Remake', 1, 4, 1299.00, '2023-03-24', 9.3, 25, 'available'),
('Final Fantasy XVI', 1, 3, 1399.00, '2023-06-22', 9.0, 20, 'available'),
('Mario Kart 8 Deluxe', 5, 1, 799.00, '2017-04-28', 9.3, 75, 'available'),
('Starfield', 7, 3, 1399.00, '2023-09-06', 8.5, 30, 'available'),
('Cyberpunk 2077', 7, 4, 899.00, '2020-12-10', 8.0, 25, 'available'),
('Gran Turismo 7', 1, 1, 1199.00, '2022-03-04', 9.1, 40, 'available'),
('Nintendo Switch Sports', 5, 1, 699.00, '2022-04-29', 7.5, 50, 'available'),
('Diablo IV', 1, 4, 1299.00, '2023-06-06', 8.8, 35, 'available'),
('Assassins Creed Mirage', 1, 3, 1199.00, '2023-10-12', 8.5, 28, 'available'),
('Pokemon Violet', 5, 2, 899.00, '2022-11-18', 9.0, 60, 'available'),
('Red Dead Redemption 2', 7, 4, 899.00, '2018-10-26', 9.7, 20, 'available'),
('Minecraft', 7, 1, 299.00, '2011-11-18', 9.5, 100, 'available'),
('GTA V', 1, 4, 699.00, '2014-11-18', 9.5, 45, 'available'),
('The Last of Us Part II', 1, 4, 999.00, '2020-06-19', 9.3, 22, 'available'),
('Super Smash Bros Ultimate', 5, 1, 899.00, '2018-12-07', 9.4, 55, 'available'),
('Metroid Dread', 5, 3, 899.00, '2021-10-08', 9.1, 30, 'available'),
('Hogwarts Legacy', 1, 3, 1299.00, '2023-02-10', 9.0, 35, 'available'),
('FIFA 24', 3, 1, 1099.00, '2023-09-29', 8.5, 60, 'available');

INSERT INTO products (name, description, price, stock_total, product_type, status) VALUES
('Pokémon Cards Booster Pack', '10 cartas aleatorias', 89.00, 200, 'cards', 'available'),
('Yu-Gi-Oh Cards Booster Pack', '9 cartas aleatorias', 79.00, 150, 'cards', 'available'),
('Magic The Gathering Booster', '15 cartas aleatorias', 99.00, 180, 'cards', 'available'),
('Mario Figurine 10cm', 'Figura coleccionable', 349.00, 50, 'figures', 'available'),
('Link Figurine 15cm', 'Figura Zelda BOTW', 499.00, 35, 'figures', 'available'),
('Master Chief Helmet Replica', 'Casco coleccionable', 1299.00, 10, 'merchandise', 'available'),
('PS5 Controller DualSense', 'Control oficial', 1599.00, 40, 'accessories', 'available'),
('Xbox Controller', 'Control oficial', 1399.00, 35, 'accessories', 'available'),
('Nintendo Switch Pro Controller', 'Control oficial', 1299.00, 30, 'accessories', 'available'),
('PS5 Headset Pulse 3D', 'Audífonos inalámbricos', 1599.00, 25, 'accessories', 'available'),
('Xbox Headset Wireless', 'Audífonos inalámbricos', 1399.00, 20, 'accessories', 'available'),
('Nintendo Switch Case', 'Funda protectora', 299.00, 60, 'accessories', 'available'),
('PS5 Stand Cooling Fan', 'Base con ventilador', 599.00, 15, 'accessories', 'available'),
('Xbox Series X Stand', 'Base vertical', 399.00, 20, 'accessories', 'available'),
('HDMI Cable 2.1 3m', 'Cable para 4K 120Hz', 299.00, 80, 'accessories', 'available'),
('Gaming Mouse Pad XL', 'Tapete grande', 199.00, 100, 'accessories', 'available'),
('Lego Mario Set', 'Set de construcción', 899.00, 25, 'merchandise', 'available'),
('Pokémon Plush Pikachu', 'Peluche 30cm', 349.00, 40, 'merchandise', 'available'),
('Zelda Poster Collection', 'Set de 3 pósters', 199.00, 50, 'merchandise', 'available'),
('Gaming Keychain Set', 'Set de 5 llaveros', 99.00, 120, 'merchandise', 'available');

# Clients (100+ records)
INSERT INTO clients (first_name, last_name, phone, email, address, membership_date, points, membership_type) VALUES
('Carlos', 'Hernández', '+526643333001', 'carlos.h@email.com', 'Calle 1 #123, Col. Centro', '2023-01-15', 500, 'silver'),
('Martha', 'López', '+526643333002', 'martha.l@email.com', 'Calle 2 #456, Col. Norte', '2023-01-20', 300, 'bronze'),
('Miguel', 'García', '+526643333003', 'miguel.g@email.com', 'Calle 3 #789, Col. Sur', '2023-02-01', 800, 'gold'),
('Sofia', 'Martínez', '+526643333004', 'sofia.m@email.com', 'Calle 4 #321, Col. Este', '2023-02-10', 150, 'bronze'),
('Alejandro', 'Rodríguez', '+526643333005', 'alejandro.r@email.com', 'Calle 5 #654, Col. Oeste', '2023-02-15', 1200, 'platinum'),
('Isabel', 'Cruz', '+526643333006', 'isabel.c@email.com', 'Calle 6 #987, Col. Centro', '2023-03-01', 450, 'silver'),
('Fernando', 'Torres', '+526643333007', 'fernando.t@email.com', 'Calle 7 #147, Col. Norte', '2023-03-10', 600, 'silver'),
('Lucia', 'Méndez', '+526643333008', 'lucia.m@email.com', 'Calle 8 #258, Col. Sur', '2023-03-15', 250, 'bronze'),
('Ricardo', 'Navarro', '+526643333009', 'ricardo.n@email.com', 'Calle 9 #369, Col. Este', '2023-03-20', 950, 'gold'),
('Patricia', 'Rojas', '+526643333010', 'patricia.r@email.com', 'Calle 10 #741, Col. Oeste', '2023-03-25', 180, 'bronze'),
('Gabriel', 'Herrera', '+526643333011', 'gabriel.h@email.com', 'Calle 11 #852, Col. Centro', '2023-04-01', 700, 'silver'),
('Mónica', 'Álvarez', '+526643333012', 'monica.a@email.com', 'Calle 12 #963, Col. Norte', '2023-04-05', 350, 'bronze'),
('Oscar', 'Jiménez', '+526643333013', 'oscar.j@email.com', 'Calle 13 #159, Col. Sur', '2023-04-10', 1100, 'platinum'),
('Claudia', 'Sánchez', '+526643333014', 'claudia.s@email.com', 'Calle 14 #357, Col. Este', '2023-04-15', 280, 'bronze'),
('Eduardo', 'Luna', '+526643333015', 'eduardo.l@email.com', 'Calle 15 #753, Col. Oeste', '2023-04-20', 520, 'silver'),
('Daniela', 'Vargas', '+526643333016', 'daniela.v@email.com', 'Calle 16 #159, Col. Centro', '2023-04-25', 150, 'bronze'),
('Roberto', 'Castro', '+526643333017', 'roberto.c@email.com', 'Calle 17 #268, Col. Norte', '2023-05-01', 650, 'silver'),
('Ana', 'Morales', '+526643333018', 'ana.m@email.com', 'Calle 18 #379, Col. Sur', '2023-05-05', 400, 'bronze'),
('Javier', 'Ramírez', '+526643333019', 'javier.r@email.com', 'Calle 19 #482, Col. Este', '2023-05-10', 880, 'gold'),
('Laura', 'Flores', '+526643333020', 'laura.f@email.com', 'Calle 20 #593, Col. Oeste', '2023-05-15', 220, 'bronze'),
('Andrés', 'Reyes', '+526643333021', 'andres.r@email.com', 'Calle 21 #684, Col. Centro', '2023-05-20', 750, 'silver'),
('Paulina', 'Gutiérrez', '+526643333022', 'paulina.g@email.com', 'Calle 22 #795, Col. Norte', '2023-05-25', 380, 'bronze'),
('Marco', 'Díaz', '+526643333023', 'marco.d@email.com', 'Calle 23 #816, Col. Sur', '2023-06-01', 1050, 'platinum'),
('Silvia', 'Moreno', '+526643333024', 'silvia.m@email.com', 'Calle 24 #927, Col. Este', '2023-06-05', 290, 'bronze'),
('Héctor', 'Ortiz', '+526643333025', 'hector.o@email.com', 'Calle 25 #138, Col. Oeste', '2023-06-10', 580, 'silver'),
('Valentina', 'Ruiz', '+526643333026', 'valentina.r@email.com', 'Calle 26 #241, Col. Centro', '2023-06-15', 170, 'bronze'),
('Diego', 'Mendoza', '+526643333027', 'diego.m@email.com', 'Calle 27 #352, Col. Norte', '2023-06-20', 920, 'gold'),
('Carolina', 'Lara', '+526643333028', 'carolina.l@email.com', 'Calle 28 #463, Col. Sur', '2023-06-25', 420, 'silver'),
('Raúl', 'Soto', '+526643333029', 'raul.s@email.com', 'Calle 29 #574, Col. Este', '2023-07-01', 210, 'bronze'),
('Adriana', 'Delgado', '+526643333030', 'adriana.d@email.com', 'Calle 30 #685, Col. Oeste', '2023-07-05', 680, 'silver'),
('Sergio', 'Vega', '+526643333031', 'sergio.v@email.com', 'Calle 31 #796, Col. Centro', '2023-07-10', 340, 'bronze'),
('Miriam', 'Castillo', '+526643333032', 'miriam.c@email.com', 'Calle 32 #817, Col. Norte', '2023-07-15', 1150, 'platinum'),
('Iván', 'Ríos', '+526643333033', 'ivan.r@email.com', 'Calle 33 #928, Col. Sur', '2023-07-20', 480, 'silver'),
('Vanessa', 'Mendoza', '+526643333034', 'vanessa.m@email.com', 'Calle 34 #139, Col. Este', '2023-07-25', 190, 'bronze'),
('Pablo', 'Aguilar', '+526643333035', 'pablo.a@email.com', 'Calle 35 #241, Col. Oeste', '2023-08-01', 770, 'silver'),
('Renata', 'Silva', '+526643333036', 'renata.s@email.com', 'Calle 36 #352, Col. Centro', '2023-08-05', 260, 'bronze'),
('Gustavo', 'Campos', '+526643333037', 'gustavo.c@email.com', 'Calle 37 #463, Col. Norte', '2023-08-10', 890, 'gold'),
('Elena', 'Villa', '+526643333038', 'elena.v@email.com', 'Calle 38 #574, Col. Sur', '2023-08-15', 310, 'bronze'),
('Arturo', 'Salazar', '+526643333039', 'arturo.s@email.com', 'Calle 39 #685, Col. Este', '2023-08-20', 540, 'silver'),
('Natalia', 'Romero', '+526643333040', 'natalia.r@email.com', 'Calle 40 #796, Col. Oeste', '2023-08-25', 140, 'bronze'),
('Emilio', 'Zapata', '+526643333041', 'emilio.z@email.com', 'Calle 41 #817, Col. Centro', '2023-09-01', 620, 'silver'),
('Patricia', 'Núñez', '+526643333042', 'patricia.n@email.com', 'Calle 42 #928, Col. Norte', '2023-09-05', 230, 'bronze'),
('Federico', 'Beltrán', '+526643333043', 'federico.b@email.com', 'Calle 43 #139, Col. Sur', '2023-09-10', 980, 'gold'),
('Alicia', 'Peña', '+526643333044', 'alicia.p@email.com', 'Calle 44 #241, Col. Este', '2023-09-15', 370, 'bronze'),
('Rubén', 'Cortés', '+526643333045', 'ruben.c@email.com', 'Calle 45 #352, Col. Oeste', '2023-09-20', 550, 'silver'),
('Gabriela', 'Serrano', '+526643333046', 'gabriela.s@email.com', 'Calle 46 #463, Col. Centro', '2023-09-25', 180, 'bronze'),
('Tomás', 'Velasco', '+526643333047', 'tomas.v@email.com', 'Calle 47 #574, Col. Norte', '2023-10-01', 720, 'silver'),
('Lucía', 'Domínguez', '+526643333048', 'lucia.d@email.com', 'Calle 48 #685, Col. Sur', '2023-10-05', 270, 'bronze'),
('Francisco', 'Ramos', '+526643333049', 'francisco.r@email.com', 'Calle 49 #796, Col. Este', '2023-10-10', 850, 'gold'),
('Mariana', 'Guerra', '+526643333050', 'mariana.g@email.com', 'Calle 50 #817, Col. Oeste', '2023-10-15', 320, 'bronze'),
('Antonio', 'Méndez', '+526643333051', 'antonio.m@email.com', 'Calle 51 #928, Col. Centro', '2023-10-20', 590, 'silver'),
('Rosa', 'Ortega', '+526643333052', 'rosa.o@email.com', 'Calle 52 #139, Col. Norte', '2023-10-25', 160, 'bronze'),
('Enrique', 'Vargas', '+526643333053', 'enrique.v@email.com', 'Calle 53 #241, Col. Sur', '2023-11-01', 1080, 'platinum'),
('Carla', 'Muñoz', '+526643333054', 'carla.m@email.com', 'Calle 54 #352, Col. Este', '2023-11-05', 440, 'silver'),
('Jorge', 'Navarro', '+526643333055', 'jorge.n@email.com', 'Calle 55 #463, Col. Oeste', '2023-11-10', 210, 'bronze'),
('Patricia', 'Luna', '+526643333056', 'patricia.l@email.com', 'Calle 56 #574, Col. Centro', '2023-11-15', 660, 'silver'),
('Manuel', 'Escobar', '+526643333057', 'manuel.e@email.com', 'Calle 57 #685, Col. Norte', '2023-11-20', 390, 'bronze'),
('Silvia', 'Paredes', '+526643333058', 'silvia.p@email.com', 'Calle 58 #796, Col. Sur', '2023-11-25', 910, 'gold'),
('Roberto', 'Cabrera', '+526643333059', 'roberto.c@email.com', 'Calle 59 #817, Col. Este', '2023-12-01', 250, 'bronze'),
('Angélica', 'Ríos', '+526643333060', 'angelica.r@email.com', 'Calle 60 #928, Col. Oeste', '2023-12-05', 530, 'silver'),
('Humberto', 'Leal', '+526643333061', 'humberto.l@email.com', 'Calle 61 #139, Col. Centro', '2023-12-10', 170, 'bronze'),
('Diana', 'Mejía', '+526643333062', 'diana.m@email.com', 'Calle 62 #241, Col. Norte', '2023-12-15', 780, 'silver'),
('Felipe', 'Contreras', '+526643333063', 'felipe.c@email.com', 'Calle 63 #352, Col. Sur', '2023-12-20', 340, 'bronze'),
('Verónica', 'Acosta', '+526643333064', 'veronica.a@email.com', 'Calle 64 #463, Col. Este', '2023-12-25', 1010, 'platinum'),
('Santiago', 'Luna', '+526643333065', 'santiago.l@email.com', 'Calle 65 #574, Col. Oeste', '2024-01-01', 410, 'silver'),
('Mónica', 'Trejo', '+526643333066', 'monica.t@email.com', 'Calle 66 #685, Col. Centro', '2024-01-05', 200, 'bronze'),
('Ricardo', 'Guzmán', '+526643333067', 'ricardo.g@email.com', 'Calle 67 #796, Col. Norte', '2024-01-10', 860, 'gold'),
('Lorena', 'Herrera', '+526643333068', 'lorena.h@email.com', 'Calle 68 #817, Col. Sur', '2024-01-15', 280, 'bronze'),
('Bruno', 'Zapata', '+526643333069', 'bruno.z@email.com', 'Calle 69 #928, Col. Este', '2024-01-20', 610, 'silver'),
('Andrea', 'Flores', '+526643333070', 'andrea.f@email.com', 'Calle 70 #139, Col. Oeste', '2024-01-25', 150, 'bronze'),
('Eduardo', 'Mora', '+526643333071', 'eduardo.m@email.com', 'Calle 71 #241, Col. Centro', '2024-02-01', 740, 'silver'),
('Carolina', 'Vega', '+526643333072', 'carolina.v@email.com', 'Calle 72 #352, Col. Norte', '2024-02-05', 330, 'bronze'),
('Luis', 'Ponce', '+526643333073', 'luis.p@email.com', 'Calle 73 #463, Col. Sur', '2024-02-10', 990, 'gold'),
('María', 'Sánchez', '+526643333074', 'maria.s@email.com', 'Calle 74 #574, Col. Este', '2024-02-15', 240, 'bronze'),
('Fernando', 'Rivas', '+526643333075', 'fernando.r@email.com', 'Calle 75 #685, Col. Oeste', '2024-02-20', 560, 'silver'),
('Alejandra', 'Cruz', '+526643333076', 'alejandra.c@email.com', 'Calle 76 #796, Col. Centro', '2024-02-25', 190, 'bronze'),
('Carlos', 'Morales', '+526643333077', 'carlos.m@email.com', 'Calle 77 #817, Col. Norte', '2024-03-01', 690, 'silver'),
('Patricia', 'Jiménez', '+526643333078', 'patricia.j@email.com', 'Calle 78 #928, Col. Sur', '2024-03-05', 300, 'bronze'),
('Roberto', 'Delgado', '+526643333079', 'roberto.d@email.com', 'Calle 79 #139, Col. Este', '2024-03-10', 1040, 'platinum'),
('Sofia', 'Ruíz', '+526643333080', 'sofia.r@email.com', 'Calle 80 #241, Col. Oeste', '2024-03-15', 470, 'silver'),
('Miguel', 'Ángel', '+526643333081', 'miguel.a@email.com', 'Calle 81 #352, Col. Centro', '2024-03-20', 220, 'bronze'),
('Ana', 'Beltrán', '+526643333082', 'ana.b@email.com', 'Calle 82 #463, Col. Norte', '2024-03-25', 830, 'gold'),
('Javier', 'Campos', '+526643333083', 'javier.c@email.com', 'Calle 83 #574, Col. Sur', '2024-04-01', 360, 'bronze'),
('Diana', 'López', '+526643333084', 'diana.l@email.com', 'Calle 84 #685, Col. Este', '2024-04-05', 510, 'silver'),
('Héctor', 'Salazar', '+526643333085', 'hector.s@email.com', 'Calle 85 #796, Col. Oeste', '2024-04-10', 180, 'bronze'),
('Laura', 'Mendoza', '+526643333086', 'laura.m@email.com', 'Calle 86 #817, Col. Centro', '2024-04-15', 640, 'silver'),
('Pablo', 'Ramírez', '+526643333087', 'pablo.r@email.com', 'Calle 87 #928, Col. Norte', '2024-04-20', 290, 'bronze'),
('Renata', 'Guerrero', '+526643333088', 'renata.g@email.com', 'Calle 88 #139, Col. Sur', '2024-04-25', 960, 'gold'),
('Gustavo', 'Torres', '+526643333089', 'gustavo.t@email.com', 'Calle 89 #241, Col. Este', '2024-05-01', 430, 'silver'),
('Valentina', 'Ortiz', '+526643333090', 'valentina.o@email.com', 'Calle 90 #352, Col. Oeste', '2024-05-05', 260, 'bronze'),
('Diego', 'Villa', '+526643333091', 'diego.v@email.com', 'Calle 91 #463, Col. Centro', '2024-05-10', 570, 'silver'),
('Carolina', 'Paz', '+526643333092', 'carolina.p@email.com', 'Calle 92 #574, Col. Norte', '2024-05-15', 350, 'bronze'),
('Raúl', 'Castro', '+526643333093', 'raul.c@email.com', 'Calle 93 #685, Col. Sur', '2024-05-20', 870, 'gold'),
('Adriana', 'Flores', '+526643333094', 'adriana.f@email.com', 'Calle 94 #796, Col. Este', '2024-05-25', 200, 'bronze'),
('Sergio', 'Méndez', '+526643333095', 'sergio.m@email.com', 'Calle 95 #817, Col. Oeste', '2024-06-01', 680, 'silver'),
('Miriam', 'Lara', '+526643333096', 'miriam.l@email.com', 'Calle 96 #928, Col. Centro', '2024-06-05', 310, 'bronze'),
('Iván', 'Soto', '+526643333097', 'ivan.s@email.com', 'Calle 97 #139, Col. Norte', '2024-06-10', 1120, 'platinum'),
('Vanessa', 'Aguilar', '+526643333098', 'vanessa.a@email.com', 'Calle 98 #241, Col. Sur', '2024-06-15', 480, 'silver'),
('Pablo', 'Romero', '+526643333099', 'pablo.r@email.com', 'Calle 99 #352, Col. Este', '2024-06-20', 170, 'bronze'),
('Renata', 'Silva', '+526643333100', 'renata.s@email.com', 'Calle 100 #463, Col. Oeste', '2024-06-25', 760, 'silver');

# Inventory (games, consoles, products per branch)
INSERT INTO inventory (branch_id, item_type, item_id, quantity, min_stock, last_updated) VALUES
(1, 'game', 1, 15, 5, '2024-06-01'),
(1, 'game', 2, 12, 5, '2024-06-01'),
(1, 'game', 3, 20, 5, '2024-06-01'),
(1, 'game', 4, 10, 5, '2024-06-01'),
(1, 'game', 5, 25, 5, '2024-06-01'),
(1, 'console', 1, 8, 3, '2024-06-01'),
(1, 'console', 3, 6, 3, '2024-06-01'),
(1, 'product', 1, 50, 20, '2024-06-01'),
(1, 'product', 7, 10, 5, '2024-06-01'),
(2, 'game', 1, 18, 5, '2024-06-01'),
(2, 'game', 6, 14, 5, '2024-06-01'),
(2, 'game', 7, 22, 5, '2024-06-01'),
(2, 'game', 8, 10, 5, '2024-06-01'),
(2, 'console', 2, 7, 3, '2024-06-01'),
(2, 'console', 5, 5, 3, '2024-06-01'),
(2, 'product', 2, 40, 20, '2024-06-01'),
(2, 'product', 8, 8, 5, '2024-06-01'),
(3, 'game', 2, 15, 5, '2024-06-01'),
(3, 'game', 3, 25, 5, '2024-06-01'),
(3, 'game', 9, 18, 5, '2024-06-01'),
(3, 'game', 10, 12, 5, '2024-06-01'),
(3, 'console', 1, 6, 3, '2024-06-01'),
(3, 'console', 6, 4, 3, '2024-06-01'),
(3, 'product', 3, 35, 20, '2024-06-01'),
(3, 'product', 9, 12, 5, '2024-06-01'),
(4, 'game', 4, 14, 5, '2024-06-01'),
(4, 'game', 11, 16, 5, '2024-06-01'),
(4, 'game', 12, 20, 5, '2024-06-01'),
(4, 'game', 13, 8, 5, '2024-06-01'),
(4, 'console', 3, 5, 3, '2024-06-01'),
(4, 'product', 4, 15, 10, '2024-06-01'),
(4, 'product', 10, 6, 5, '2024-06-01'),
(5, 'game', 5, 22, 5, '2024-06-01'),
(5, 'game', 14, 10, 5, '2024-06-01'),
(5, 'game', 15, 25, 5, '2024-06-01'),
(5, 'game', 16, 8, 5, '2024-06-01'),
(5, 'console', 4, 4, 3, '2024-06-01'),
(5, 'product', 5, 12, 10, '2024-06-01'),
(5, 'product', 11, 7, 5, '2024-06-01'),
(6, 'game', 1, 20, 5, '2024-06-01'),
(6, 'game', 17, 14, 5, '2024-06-01'),
(6, 'game', 18, 18, 5, '2024-06-01'),
(6, 'game', 19, 16, 5, '2024-06-01'),
(6, 'console', 5, 8, 3, '2024-06-01'),
(6, 'console', 7, 3, 3, '2024-06-01'),
(6, 'product', 6, 5, 3, '2024-06-01'),
(6, 'product', 12, 20, 10, '2024-06-01'),
(7, 'game', 2, 16, 5, '2024-06-01'),
(7, 'game', 20, 20, 5, '2024-06-01'),
(7, 'game', 21, 12, 5, '2024-06-01'),
(7, 'game', 22, 18, 5, '2024-06-01'),
(7, 'console', 2, 5, 3, '2024-06-01'),
(7, 'console', 8, 2, 3, '2024-06-01'),
(7, 'product', 7, 12, 5, '2024-06-01'),
(7, 'product', 13, 5, 3, '2024-06-01'),
(8, 'game', 3, 22, 5, '2024-06-01'),
(8, 'game', 23, 10, 5, '2024-06-01'),
(8, 'game', 24, 30, 5, '2024-06-01'),
(8, 'game', 25, 15, 5, '2024-06-01'),
(8, 'console', 3, 6, 3, '2024-06-01'),
(8, 'console', 9, 3, 3, '2024-06-01'),
(8, 'product', 8, 10, 5, '2024-06-01'),
(8, 'product', 14, 8, 5, '2024-06-01'),
(9, 'game', 4, 12, 5, '2024-06-01'),
(9, 'game', 26, 8, 5, '2024-06-01'),
(9, 'game', 27, 20, 5, '2024-06-01'),
(9, 'game', 28, 10, 5, '2024-06-01'),
(9, 'console', 1, 4, 3, '2024-06-01'),
(9, 'product', 9, 6, 5, '2024-06-01'),
(9, 'product', 15, 25, 10, '2024-06-01'),
(10, 'game', 5, 25, 5, '2024-06-01'),
(10, 'game', 29, 15, 5, '2024-06-01'),
(10, 'game', 30, 20, 5, '2024-06-01'),
(10, 'console', 10, 6, 3, '2024-06-01'),
(10, 'product', 10, 7, 5, '2024-06-01'),
(10, 'product', 16, 30, 15, '2024-06-01');

# Sale Notes
INSERT INTO sale_notes (client_id, employee_id, branch_id, sale_date, total, points_earned, payment_method, status) VALUES
(1, 11, 1, '2024-04-01 09:15:00', 1388.00, 14, 'card', 'completed'),
(2, 12, 2, '2024-04-01 10:30:00', 1199.00, 12, 'cash', 'completed'),
(3, 13, 3, '2024-04-02 11:00:00', 1798.00, 18, 'card', 'completed'),
(4, 14, 4, '2024-04-02 14:20:00', 899.00, 9, 'transfer', 'completed'),
(5, 15, 5, '2024-04-03 09:45:00', 2498.00, 25, 'card', 'completed'),
(6, 16, 6, '2024-04-03 15:00:00', 349.00, 3, 'cash', 'completed'),
(7, 17, 7, '2024-04-04 10:15:00', 1299.00, 13, 'card', 'completed'),
(8, 18, 8, '2024-04-04 16:30:00', 1898.00, 19, 'card', 'completed'),
(9, 19, 9, '2024-04-05 09:00:00', 5499.00, 55, 'transfer', 'completed'),
(10, 20, 10, '2024-04-05 11:45:00', 799.00, 8, 'cash', 'completed'),
(11, 11, 1, '2024-04-10 10:30:00', 1199.00, 12, 'card', 'completed'),
(12, 12, 2, '2024-04-10 13:00:00', 1598.00, 16, 'card', 'completed'),
(13, 13, 3, '2024-04-11 09:15:00', 899.00, 9, 'cash', 'completed'),
(14, 14, 4, '2024-04-11 14:45:00', 1299.00, 13, 'card', 'completed'),
(15, 15, 5, '2024-04-12 10:00:00', 699.00, 7, 'cash', 'completed'),
(16, 16, 6, '2024-04-15 09:30:00', 1399.00, 14, 'card', 'completed'),
(17, 17, 7, '2024-04-15 11:20:00', 899.00, 9, 'cash', 'completed'),
(18, 18, 8, '2024-04-20 09:45:00', 1099.00, 11, 'card', 'completed'),
(19, 19, 9, '2024-04-20 14:30:00', 5299.00, 53, 'card', 'completed'),
(20, 20, 10, '2024-04-25 10:00:00', 3197.00, 32, 'transfer', 'completed'),
(21, 11, 1, '2024-04-25 12:15:00', 1299.00, 13, 'card', 'completed'),
(22, 12, 2, '2024-04-30 09:30:00', 1399.00, 14, 'card', 'completed'),
(23, 13, 3, '2024-04-30 11:00:00', 899.00, 9, 'cash', 'completed'),
(24, 14, 4, '2024-05-05 09:00:00', 2898.00, 29, 'card', 'completed'),
(25, 15, 5, '2024-05-05 14:00:00', 1998.00, 20, 'card', 'completed'),
(26, 16, 6, '2024-05-06 10:30:00', 799.00, 8, 'cash', 'completed'),
(27, 17, 7, '2024-05-06 15:45:00', 1199.00, 12, 'card', 'completed'),
(28, 18, 8, '2024-05-07 09:15:00', 1299.00, 13, 'card', 'completed'),
(29, 19, 9, '2024-05-07 13:30:00', 349.00, 3, 'cash', 'completed'),
(30, 20, 10, '2024-05-10 09:00:00', 4499.00, 45, 'card', 'completed');

# Sale Details
INSERT INTO sale_details (sale_id, item_type, item_id, quantity, unit_price, subtotal) VALUES
(1, 'game', 1, 1, 1299.00, 1299.00),
(1, 'product', 1, 1, 89.00, 89.00),
(2, 'game', 2, 1, 1199.00, 1199.00),
(3, 'game', 3, 2, 999.00, 1798.00),
(4, 'game', 7, 1, 899.00, 899.00),
(5, 'console', 5, 1, 4499.00, 4499.00),
(6, 'product', 1, 2, 89.00, 178.00),
(6, 'product', 3, 2, 99.00, 198.00),
(7, 'game', 8, 1, 1299.00, 1299.00),
(8, 'game', 4, 1, 1399.00, 1399.00),
(8, 'product', 7, 1, 1599.00, 1599.00),
(9, 'console', 1, 1, 5499.00, 5499.00),
(10, 'game', 9, 1, 799.00, 799.00),
(11, 'game', 11, 1, 1099.00, 1199.00),
(12, 'product', 7, 1, 1599.00, 1598.00),
(13, 'game', 22, 1, 899.00, 899.00),
(14, 'game', 13, 1, 1299.00, 1299.00),
(15, 'product', 11, 1, 699.00, 699.00),
(16, 'game', 16, 1, 1399.00, 1399.00),
(17, 'game', 27, 1, 899.00, 899.00),
(18, 'game', 5, 1, 1099.00, 1099.00),
(19, 'console', 3, 1, 5299.00, 5299.00),
(20, 'game', 1, 1, 1299.00, 1299.00),
(20, 'game', 3, 1, 999.00, 999.00),
(20, 'product', 7, 1, 899.00, 899.00),
(21, 'game', 23, 1, 999.00, 1299.00),
(22, 'game', 14, 1, 1399.00, 1399.00),
(23, 'game', 28, 1, 899.00, 899.00),
(24, 'game', 6, 1, 1299.00, 1299.00),
(24, 'product', 7, 1, 1599.00, 1599.00),
(25, 'game', 15, 2, 799.00, 1598.00),
(25, 'product', 4, 1, 349.00, 349.00),
(26, 'game', 9, 1, 799.00, 799.00),
(27, 'game', 20, 1, 1099.00, 1199.00),
(28, 'game', 29, 1, 1299.00, 1299.00),
(29, 'product', 3, 2, 99.00, 198.00),
(29, 'product', 16, 1, 199.00, 199.00),
(30, 'console', 6, 1, 5499.00, 5499.00);

# Purchase Notes
INSERT INTO purchase_notes (supplier_id, branch_id, purchase_date, total, status, received_date) VALUES
(1, 1, '2024-03-15', 54990.00, 'received', '2024-03-18'),
(2, 2, '2024-03-16', 47960.00, 'received', '2024-03-19'),
(3, 3, '2024-03-17', 38990.00, 'received', '2024-03-20'),
(1, 4, '2024-03-18', 28970.00, 'received', '2024-03-21'),
(2, 5, '2024-03-19', 42980.00, 'received', '2024-03-22'),
(4, 6, '2024-03-20', 18990.00, 'received', '2024-03-23'),
(5, 7, '2024-03-21', 25990.00, 'received', '2024-03-24'),
(1, 8, '2024-04-01', 65980.00, 'received', '2024-04-04'),
(2, 9, '2024-04-02', 31990.00, 'received', '2024-04-05'),
(3, 10, '2024-04-03', 28990.00, 'received', '2024-04-06');

# Purchase Details
INSERT INTO purchase_details (purchase_id, item_type, item_id, quantity, unit_cost, subtotal) VALUES
(1, 'game', 1, 10, 800.00, 8000.00),
(1, 'game', 3, 15, 650.00, 9750.00),
(1, 'console', 1, 5, 4500.00, 22500.00),
(1, 'product', 1, 100, 50.00, 5000.00),
(2, 'game', 2, 12, 750.00, 9000.00),
(2, 'game', 6, 10, 800.00, 8000.00),
(2, 'console', 3, 8, 4200.00, 33600.00),
(2, 'product', 2, 80, 45.00, 3600.00),
(3, 'game', 4, 15, 900.00, 13500.00),
(3, 'game', 5, 20, 700.00, 14000.00),
(3, 'product', 3, 60, 60.00, 3600.00),
(4, 'game', 8, 10, 850.00, 8500.00),
(4, 'game', 13, 5, 850.00, 4250.00),
(4, 'product', 4, 25, 200.00, 5000.00),
(5, 'game', 15, 25, 500.00, 12500.00),
(5, 'game', 16, 10, 900.00, 9000.00),
(5, 'console', 5, 10, 3500.00, 35000.00),
(6, 'product', 7, 20, 1200.00, 24000.00),
(7, 'game', 11, 20, 700.00, 14000.00),
(7, 'game', 12, 15, 500.00, 7500.00),
(8, 'game', 1, 20, 800.00, 16000.00),
(8, 'game', 23, 10, 650.00, 6500.00),
(8, 'console', 1, 10, 4500.00, 45000.00),
(9, 'game', 26, 8, 650.00, 5200.00),
(9, 'game', 27, 15, 550.00, 8250.00),
(10, 'game', 29, 12, 850.00, 10200.00),
(10, 'console', 10, 5, 2400.00, 12000.00);

# Audit Log (initial entries)
INSERT INTO audit_log (date, user, `table`, operation) VALUES
(NOW() - INTERVAL 5 HOUR, 'admin@gamezone.com', 'clients', 'INSERT'),
(NOW() - INTERVAL 4 HOUR, 'j.perez@gamezone.com', 'sales', 'INSERT'),
(NOW() - INTERVAL 3 HOUR, 'm.gonzalez@gamezone.com', 'inventory', 'UPDATE'),
(NOW() - INTERVAL 2 HOUR, 'c.mendoza@gamezone.com', 'purchases', 'INSERT'),
(NOW() - INTERVAL 1 HOUR, 'admin@gamezone.com', 'games', 'INSERT');