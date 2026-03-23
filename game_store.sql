CREATE DATABASE IF NOT EXISTS game_store;
USE game_store;
 

 
CREATE TABLE roles (
    role_id     INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    permissions VARCHAR(100)
);
 
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(50)  NOT NULL,
    min_age     INT,
    description VARCHAR(255)
);
 
CREATE TABLE branches (
    branch_id     INT PRIMARY KEY AUTO_INCREMENT,
    name          VARCHAR(100) NOT NULL,
    address       VARCHAR(200) NOT NULL,
    phone         VARCHAR(20)  NOT NULL,
    email         VARCHAR(100),
    schedule      VARCHAR(100),
    branch_number VARCHAR(10),
    manager_id    INT NULL,
    status        ENUM('active', 'inactive') DEFAULT 'active'
);
 
CREATE TABLE suppliers (
    supplier_id  INT PRIMARY KEY AUTO_INCREMENT,
    name         VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    phone        VARCHAR(20)  NOT NULL,
    email        VARCHAR(100),
    address      VARCHAR(200),
    status       ENUM('active', 'inactive') DEFAULT 'active'
);
 
CREATE TABLE consoles (
    console_id    INT PRIMARY KEY AUTO_INCREMENT,
    name          VARCHAR(50)   NOT NULL,
    manufacturer  VARCHAR(50)   NOT NULL,
    release_year  INT,
    price         DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    status        ENUM('active', 'inactive') DEFAULT 'active'
);
 
CREATE TABLE categories_esrb (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(50) NOT NULL,
    min_age     INT,
    description VARCHAR(255)
);
 
CREATE TABLE games (
    game_id      INT PRIMARY KEY AUTO_INCREMENT,
    title        VARCHAR(150)  NOT NULL,
    console_id   INT           NOT NULL,
    category_id  INT           NOT NULL,
    price        DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    release_date DATE,
    rating       DECIMAL(3,1),
    stock_total  INT           DEFAULT 0,
    status       ENUM('active', 'inactive') DEFAULT 'active',
    CONSTRAINT fk_game_console  FOREIGN KEY (console_id)  REFERENCES consoles(console_id),
    CONSTRAINT fk_game_category FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
 
CREATE TABLE products (
    product_id   INT PRIMARY KEY AUTO_INCREMENT,
    name         VARCHAR(100)  NOT NULL,
    description  VARCHAR(255),
    price        DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stock_total  INT           DEFAULT 0,
    product_type VARCHAR(50),
    status       ENUM('active', 'inactive') DEFAULT 'active'
);
 
CREATE TABLE inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    branch_id    INT NOT NULL,
    game_id      INT NULL,
    console_id   INT NULL,
    product_id   INT NULL,
    quantity     INT NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    min_stock    INT NOT NULL DEFAULT 5  CHECK (min_stock >= 0),
    last_update  DATETIME DEFAULT CURRENT_TIMESTAMP,
    status       ENUM('active', 'inactive') DEFAULT 'active',
    CONSTRAINT fk_inv_branch  FOREIGN KEY (branch_id)  REFERENCES branches(branch_id),
    CONSTRAINT fk_inv_game    FOREIGN KEY (game_id)    REFERENCES games(game_id),
    CONSTRAINT fk_inv_console FOREIGN KEY (console_id) REFERENCES consoles(console_id),
    CONSTRAINT fk_inv_product FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT chk_inv_item CHECK (
        (game_id IS NOT NULL AND console_id IS NULL AND product_id IS NULL) OR
        (game_id IS NULL AND console_id IS NOT NULL AND product_id IS NULL) OR
        (game_id IS NULL AND console_id IS NULL AND product_id IS NOT NULL)
    )
);
 
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name  VARCHAR(50)   NOT NULL,
    last_name   VARCHAR(50)   NOT NULL,
    email       VARCHAR(100),
    phone       VARCHAR(20)   NOT NULL,
    hire_date   DATE,
    salary      DECIMAL(10,2) NOT NULL CHECK (salary >= 0),
    role_id     INT           NOT NULL,
    branch_id   INT           NOT NULL,
    status      ENUM('active', 'inactive') DEFAULT 'active',
    CONSTRAINT fk_emp_role   FOREIGN KEY (role_id)   REFERENCES roles(role_id),
    CONSTRAINT fk_emp_branch FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);
 
ALTER TABLE branches
ADD CONSTRAINT fk_branch_manager
FOREIGN KEY (manager_id) REFERENCES employees(employee_id);
 
CREATE TABLE clients (
    client_id       INT PRIMARY KEY AUTO_INCREMENT,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    phone           VARCHAR(20)  NOT NULL,
    email           VARCHAR(100),
    address         VARCHAR(200),
    membership_date DATE,
    points          INT DEFAULT 0 CHECK (points >= 0),
    membership_type ENUM('bronze', 'silver', 'gold', 'platinum') DEFAULT 'bronze',
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
    status          ENUM('active', 'inactive') DEFAULT 'active'
);
 
CREATE TABLE sales (
    sale_id        INT PRIMARY KEY AUTO_INCREMENT,
    client_id      INT           NOT NULL,
    employee_id    INT           NOT NULL,
    branch_id      INT           NOT NULL,
    sale_date      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total          DECIMAL(12,2) NOT NULL CHECK (total >= 0),
    points_earned  INT           DEFAULT 0,
    payment_method ENUM('cash', 'card', 'transfer') NOT NULL,
    status         ENUM('completed', 'cancelled', 'pending') DEFAULT 'completed',
    CONSTRAINT fk_sale_client   FOREIGN KEY (client_id)   REFERENCES clients(client_id),
    CONSTRAINT fk_sale_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT fk_sale_branch   FOREIGN KEY (branch_id)   REFERENCES branches(branch_id)
);
 
CREATE TABLE sale_details (
    detail_id  INT PRIMARY KEY AUTO_INCREMENT,
    sale_id    INT           NOT NULL,
    game_id    INT           NULL,
    console_id INT           NULL,
    product_id INT           NULL,
    quantity   INT           NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    subtotal   DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    CONSTRAINT fk_detail_sale    FOREIGN KEY (sale_id)    REFERENCES sales(sale_id),
    CONSTRAINT fk_detail_game    FOREIGN KEY (game_id)    REFERENCES games(game_id),
    CONSTRAINT fk_detail_console FOREIGN KEY (console_id) REFERENCES consoles(console_id),
    CONSTRAINT fk_detail_product FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT chk_sale_item CHECK (
        (game_id IS NOT NULL AND console_id IS NULL AND product_id IS NULL) OR
        (game_id IS NULL AND console_id IS NOT NULL AND product_id IS NULL) OR
        (game_id IS NULL AND console_id IS NULL AND product_id IS NOT NULL)
    )
);
 
CREATE TABLE purchases (
    purchase_id   INT PRIMARY KEY AUTO_INCREMENT,
    supplier_id   INT           NOT NULL,
    branch_id     INT           NOT NULL,
    purchase_date DATE          NOT NULL,
    total         DECIMAL(12,2) NOT NULL CHECK (total >= 0),
    received_date DATE,
    status        ENUM('pending', 'received', 'cancelled') DEFAULT 'pending',
    CONSTRAINT fk_purchase_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    CONSTRAINT fk_purchase_branch   FOREIGN KEY (branch_id)   REFERENCES branches(branch_id)
);
 
CREATE TABLE purchase_details (
    detail_id   INT PRIMARY KEY AUTO_INCREMENT,
    purchase_id INT           NOT NULL,
    game_id     INT           NULL,
    console_id  INT           NULL,
    product_id  INT           NULL,
    quantity    INT           NOT NULL CHECK (quantity > 0),
    unit_cost   DECIMAL(10,2) NOT NULL CHECK (unit_cost >= 0),
    subtotal    DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    CONSTRAINT fk_pdetail_purchase FOREIGN KEY (purchase_id) REFERENCES purchases(purchase_id),
    CONSTRAINT fk_pdetail_game     FOREIGN KEY (game_id)     REFERENCES games(game_id),
    CONSTRAINT fk_pdetail_console  FOREIGN KEY (console_id)  REFERENCES consoles(console_id),
    CONSTRAINT fk_pdetail_product  FOREIGN KEY (product_id)  REFERENCES products(product_id),
    CONSTRAINT chk_purchase_item CHECK (
        (game_id IS NOT NULL AND console_id IS NULL AND product_id IS NULL) OR
        (game_id IS NULL AND console_id IS NOT NULL AND product_id IS NULL) OR
        (game_id IS NULL AND console_id IS NULL AND product_id IS NOT NULL)
    )
);
 
CREATE TABLE audit_log (
    id        INT PRIMARY KEY AUTO_INCREMENT,
    date_     DATETIME,
    user_     VARCHAR(255),
    table_    VARCHAR(255),
    operation VARCHAR(10)
);

-- DATA

 
INSERT INTO roles (name, description, permissions) VALUES
('Admin',       'System administrator',  'all'),
('Gerente',     'Branch manager',        'manage_branch'),
('Vendedor',    'Sales associate',       'sales'),
('Almacenista', 'Inventory manager',     'inventory');
 
INSERT INTO categories (name, description, min_age) VALUES
('Everyone',       'Suitable for all ages',  0),
('Everyone 10+',   'Ages 10 and up',         10),
('Teen',           'Ages 13 and up',         13),
('Mature 17+',     'Ages 17 and up',         17),
('Adults Only',    'Ages 18 and up',         18),
('Rating Pending', 'Not yet rated',           0);
 
INSERT INTO consoles (name, manufacturer, release_year, price) VALUES
('PlayStation 5',       'Sony',      2020, 5499.00),
('PlayStation 4',       'Sony',      2013, 3999.00),
('Xbox Series X',       'Microsoft', 2020, 5299.00),
('Xbox Series S',       'Microsoft', 2020, 3499.00),
('Nintendo Switch',     'Nintendo',  2017, 4499.00),
('Nintendo Switch OLED','Nintendo',  2021, 5499.00),
('PC Gaming',           'Various',   2023,15999.00),
('PlayStation 5 Pro',   'Sony',      2024, 7999.00),
('Xbox Series X Pro',   'Microsoft', 2024, 7499.00),
('Nintendo Switch Lite','Nintendo',  2019, 2999.00);
 
INSERT INTO suppliers (name, contact_name, phone, email, address) VALUES
('Sony Mexico',       'Carlos Mendoza',   '+526643333001', 'sales@sonymx.com',    'Av. Tecnológico 100, Col. Centro'),
('Microsoft Mexico',  'Ana García',       '+526643333002', 'contact@msmx.com',    'Calle Norte 200, Col. Norte'),
('Nintendo Mexico',   'Luis Ramírez',     '+526643333003', 'info@nintendo.mx',    'Av. Sur 300, Col. Sur'),
('Game Distribution', 'Patricia Herrera', '+526643333004', 'sales@gamedist.com',  'Blvd. Industrial 500, Col. Centro'),
('Game Supply MX',    'Fernando Ruiz',    '+526643333005', 'info@supplymx.com',   'Calle Comercial 150, Col. Norte');
 
INSERT INTO branches (name, address, phone, email, schedule, branch_number, status) VALUES
('GameZone Centro',  'Av. Reforma 123, Col. Centro',       '+526641111001', 'centro@gamezone.com',  'Lun-Dom 9:00-21:00',  'GZ001', 'active'),
('GameZone Norte',   'Av. Universidad 456, Col. Norte',    '+526641111002', 'norte@gamezone.com',   'Lun-Dom 9:00-21:00',  'GZ002', 'active'),
('GameZone Sur',     'Av. Insurgentes 789, Col. Sur',      '+526641111003', 'sur@gamezone.com',     'Lun-Dom 9:00-21:00',  'GZ003', 'active'),
('GameZone Este',    'Calle Oriente 321, Col. Este',       '+526641111004', 'este@gamezone.com',    'Lun-Dom 10:00-20:00', 'GZ004', 'active'),
('GameZone Oeste',   'Calle Poniente 654, Col. Oeste',     '+526641111005', 'oeste@gamezone.com',   'Lun-Dom 10:00-20:00', 'GZ005', 'active'),
('GameZone Plaza',   'Plaza Mayor 147, Col. Centro',       '+526641111006', 'plaza@gamezone.com',   'Lun-Dom 9:00-22:00',  'GZ006', 'active'),
('GameZone Mall',    'Mall Centro 258, Col. Norte',        '+526641111007', 'mall@gamezone.com',    'Lun-Dom 10:00-21:00', 'GZ007', 'active'),
('GameZone Premium', 'Av. Premium 369, Col. Sur',          '+526641111008', 'premium@gamezone.com', 'Lun-Dom 11:00-21:00', 'GZ008', 'active'),
('GameZone Express', 'Calle Express 741, Col. Este',       '+526641111009', 'express@gamezone.com', 'Lun-Dom 9:00-18:00',  'GZ009', 'active'),
('GameZone Outlet',  'Blvd. Outlet 852, Col. Oeste',       '+526641111010', 'outlet@gamezone.com',  'Lun-Dom 10:00-19:00', 'GZ010', 'active');
 
INSERT INTO employees (first_name, last_name, email, phone, hire_date, salary, role_id, branch_id) VALUES
('Juan',      'Pérez',     'j.perez@gamezone.com',     '+526642222001', '2020-01-15', 15000.00, 1,  1),
('María',     'González',  'm.gonzalez@gamezone.com',  '+526642222002', '2020-03-20', 12000.00, 2,  2),
('Carlos',    'Mendoza',   'c.mendoza@gamezone.com',   '+526642222003', '2020-05-01', 12000.00, 2,  3),
('Ana',       'López',     'a.lopez@gamezone.com',     '+526642222004', '2020-07-15', 12000.00, 2,  4),
('Luis',      'Ramírez',   'l.ramirez@gamezone.com',   '+526642222005', '2021-01-10', 12000.00, 2,  5),
('Rosa',      'Martínez',  'r.martinez@gamezone.com',  '+526642222006', '2021-03-01', 12000.00, 2,  6),
('Pedro',     'Hernández', 'p.hernandez@gamezone.com', '+526642222007', '2021-05-20', 12000.00, 2,  7),
('Laura',     'Sánchez',   'l.sanchez@gamezone.com',   '+526642222008', '2021-06-15', 12000.00, 2,  8),
('Jorge',     'Díaz',      'j.diaz@gamezone.com',      '+526642222009', '2021-08-01', 12000.00, 2,  9),
('Carmen',    'Ruiz',      'c.ruiz@gamezone.com',      '+526642222010', '2021-09-10', 12000.00, 2, 10),
('Fernando',  'Torres',    'f.torres@gamezone.com',    '+526642222011', '2020-02-01',  8500.00, 3,  1),
('Patricia',  'Flores',    'p.flores@gamezone.com',    '+526642222012', '2020-04-15',  8500.00, 3,  2),
('Miguel',    'Castro',    'm.castro@gamezone.com',    '+526642222013', '2020-06-20',  8500.00, 3,  3),
('Sofia',     'Reyes',     's.reyes@gamezone.com',     '+526642222014', '2020-08-10',  8500.00, 3,  4),
('Alejandro', 'Morales',   'a.morales@gamezone.com',   '+526642222015', '2020-10-01',  8500.00, 3,  5),
('Isabel',    'Cruz',      'i.cruz@gamezone.com',      '+526642222016', '2020-12-05',  8500.00, 3,  6),
('Roberto',   'Ortiz',     'r.ortiz@gamezone.com',     '+526642222017', '2021-02-15',  8500.00, 3,  7),
('Gabriel',   'Jiménez',   'g.jimenez@gamezone.com',   '+526642222018', '2021-04-20',  8500.00, 3,  8),
('Lucia',     'Méndez',    'l.mendez@gamezone.com',    '+526642222019', '2021-06-30',  8500.00, 3,  9),
('Ricardo',   'Navarro',   'r.navarro@gamezone.com',   '+526642222020', '2021-08-25',  8500.00, 3, 10),
('Daniela',   'Vargas',    'd.vargas@gamezone.com',    '+526642222021', '2020-01-20',  8000.00, 4,  1),
('Oscar',     'Luna',      'o.luna@gamezone.com',      '+526642222022', '2020-03-10',  8000.00, 4,  2),
('Monica',    'Alvarez',   'm.alvarez@gamezone.com',   '+526642222023', '2020-05-25',  8000.00, 4,  3),
('Eduardo',   'Rojas',     'e.rojas@gamezone.com',     '+526642222024', '2020-07-30',  8000.00, 4,  4),
('Claudia',   'Herrera',   'c.herrera@gamezone.com',   '+526642222025', '2020-09-15',  8000.00, 4,  5);
 

UPDATE branches SET manager_id = 1  WHERE branch_id = 1;
UPDATE branches SET manager_id = 2  WHERE branch_id = 2;
UPDATE branches SET manager_id = 3  WHERE branch_id = 3;
UPDATE branches SET manager_id = 4  WHERE branch_id = 4;
UPDATE branches SET manager_id = 5  WHERE branch_id = 5;
UPDATE branches SET manager_id = 6  WHERE branch_id = 6;
UPDATE branches SET manager_id = 7  WHERE branch_id = 7;
UPDATE branches SET manager_id = 8  WHERE branch_id = 8;
UPDATE branches SET manager_id = 9  WHERE branch_id = 9;
UPDATE branches SET manager_id = 10 WHERE branch_id = 10;
 

-- 100 GAMES
-- console_id: 1=PS5, 2=PS4, 3=XSX, 4=XSS, 5=Switch, 6=Switch OLED, 7=PC, 8=PS5 Pro, 9=Xbox Pro, 10=Switch Lite
-- category_id: 1=Everyone, 2=Everyone10+, 3=Teen, 4=Mature17+, 5=Adults Only, 6=Rating Pending

 
INSERT INTO games (title, console_id, category_id, price, release_date, rating, stock_total) VALUES
-- PS5 Games (console_id = 1)
('God of War Ragnarok',           1, 4, 1299.00, '2022-11-09', 9.8,  50),
('Spider-Man 2',                  1, 2, 1299.00, '2023-10-20', 9.4,  35),
('Horizon Forbidden West',        1, 2, 1199.00, '2022-02-18', 9.1,  30),
('FIFA 24',                       1, 1, 1099.00, '2023-09-29', 8.5,  80),
('Gran Turismo 7',                1, 1, 1199.00, '2022-03-04', 9.1,  40),
('Resident Evil 4 Remake',        1, 4, 1299.00, '2023-03-24', 9.3,  25),
('Final Fantasy XVI',             1, 3, 1399.00, '2023-06-22', 9.0,  20),
('Diablo IV',                     1, 4, 1299.00, '2023-06-06', 8.8,  35),
('Hogwarts Legacy',               1, 3, 1299.00, '2023-02-10', 9.0,  35),
('Assassins Creed Mirage',        1, 3, 1199.00, '2023-10-12', 8.5,  28),
('The Last of Us Part II',        1, 4,  999.00, '2020-06-19', 9.3,  22),
('GTA V',                         1, 4,  699.00, '2014-11-18', 9.5,  45),
('Ratchet and Clank Rift Apart',  1, 2, 1199.00, '2021-06-11', 9.0,  18),
('Returnal',                      1, 4, 1099.00, '2021-04-30', 8.5,  15),
('Demon Souls Remake',            1, 4, 1099.00, '2020-11-12', 9.2,  12),
('Destruction AllStars',          1, 3,  499.00, '2021-02-02', 7.0,  10),
('Deathloop',                     1, 4, 1099.00, '2021-09-14', 8.8,  20),
('Ghostwire Tokyo',               1, 4, 1099.00, '2022-03-25', 8.2,  18),
('Forspoken',                     1, 3,  899.00, '2023-01-24', 7.5,  12),
('Marvel Midnight Suns',          1, 3, 1099.00, '2022-12-02', 8.3,  15),
 
-- PS4 Games (console_id = 2)
('God of War',                    2, 4,  799.00, '2018-04-20', 9.8,  30),
('Bloodborne',                    2, 4,  699.00, '2015-03-24', 9.5,  25),
('Uncharted 4',                   2, 3,  799.00, '2016-05-10', 9.4,  20),
('The Witcher 3',                 2, 4,  699.00, '2015-05-19', 9.6,  28),
('Red Dead Redemption 2',         2, 4,  899.00, '2018-10-26', 9.7,  20),
('Persona 5 Royal',               2, 3,  899.00, '2020-03-31', 9.5,  18),
('Sekiro Shadows Die Twice',      2, 4, 1099.00, '2019-03-22', 9.1,  15),
('Death Stranding',               2, 4,  799.00, '2019-11-08', 8.5,  18),
('Ghost of Tsushima',             2, 3, 1099.00, '2020-07-17', 9.3,  22),
('Shadow of the Colossus Remake', 2, 2,  699.00, '2018-02-06', 9.1,  16),
 
-- Xbox Series X Games (console_id = 3)
('Halo Infinite',                 3, 4, 1199.00, '2021-12-08', 9.0,  45),
('Forza Horizon 5',               3, 1, 1099.00, '2021-11-09', 9.2,  45),
('Call of Duty MW III',           3, 4, 1299.00, '2023-11-10', 8.8,  55),
('Gears 5',                       3, 4,  899.00, '2019-09-10', 8.7,  20),
('Ori and the Will of the Wisps', 3, 2,  699.00, '2020-03-11', 9.3,  15),
('Fable Anniversary',             3, 3,  799.00, '2014-02-04', 8.0,  12),
('Sea of Thieves',                3, 2,  899.00, '2018-03-20', 8.1,  18),
('Microsoft Flight Simulator',    3, 1, 1199.00, '2020-08-18', 9.0,  14),
('Psychonauts 2',                 3, 2,  899.00, '2021-08-25', 9.1,  16),
('Sunset Overdrive',              3, 3,  699.00, '2014-10-28', 8.5,  10),
 
-- Nintendo Switch Games (console_id = 5)
('Zelda Breath of the Wild',      5, 2,  999.00, '2017-03-03',10.0,  60),
('Pokemon Scarlet',               5, 2,  899.00, '2022-11-18', 9.2,  70),
('Super Mario Odyssey',           5, 1,  799.00, '2017-10-27', 9.7,  55),
('Animal Crossing',               5, 1,  799.00, '2020-03-20', 9.0,  65),
('Mario Kart 8 Deluxe',           5, 1,  799.00, '2017-04-28', 9.3,  75),
('Super Smash Bros Ultimate',     5, 1,  899.00, '2018-12-07', 9.4,  55),
('Metroid Dread',                 5, 3,  899.00, '2021-10-08', 9.1,  30),
('Nintendo Switch Sports',        5, 1,  699.00, '2022-04-29', 7.5,  50),
('Pokemon Violet',                5, 2,  899.00, '2022-11-18', 9.0,  60),
('Xenoblade Chronicles 3',        5, 3,  999.00, '2022-07-29', 9.2,  22),
('Kirby and the Forgotten Land',  5, 1,  799.00, '2022-03-25', 8.8,  35),
('Splatoon 3',                    5, 2,  899.00, '2022-09-09', 8.9,  40),
('Fire Emblem Engage',            5, 3,  999.00, '2023-01-20', 8.7,  28),
('Zelda Tears of the Kingdom',    5, 2, 1199.00, '2023-05-12',10.0,  65),
('Bayonetta 3',                   5, 4,  999.00, '2022-10-28', 8.6,  20),
('Luigi Mansion 3',               5, 1,  799.00, '2019-10-31', 8.9,  30),
('Astral Chain',                  5, 3,  899.00, '2019-08-30', 8.7,  18),
('Ring Fit Adventure',            5, 1,  999.00, '2019-10-18', 8.4,  25),
('Pikmin 4',                      5, 2,  899.00, '2023-07-21', 8.7,  22),
('WarioWare Move It',             5, 1,  799.00, '2023-11-03', 7.8,  18),
 
-- PC Games (console_id = 7)
('Elden Ring',                    7, 4, 1399.00, '2022-02-25', 9.5,  40),
('Cyberpunk 2077',                7, 4,  899.00, '2020-12-10', 8.0,  25),
('Starfield',                     7, 3, 1399.00, '2023-09-06', 8.5,  30),
('Red Dead Redemption 2',         7, 4,  899.00, '2019-11-05', 9.7,  20),
('Minecraft',                     7, 1,  299.00, '2011-11-18', 9.5, 100),
('Baldurs Gate 3',                7, 4, 1399.00, '2023-08-03', 9.8,  35),
('Hollow Knight',                 7, 2,  199.00, '2017-02-24', 9.4,  60),
('Disco Elysium',                 7, 4,  699.00, '2019-10-15', 9.5,  20),
('Hades',                         7, 3,  499.00, '2020-09-17', 9.5,  40),
('Stardew Valley',                7, 1,  199.00, '2016-02-26', 9.3,  80),
('Among Us',                      7, 2,   99.00, '2018-06-15', 8.0, 120),
('Valheim',                       7, 3,  399.00, '2021-02-02', 8.5,  35),
('It Takes Two',                  7, 2,  699.00, '2021-03-26', 9.4,  25),
('Divinity Original Sin 2',       7, 4,  699.00, '2017-09-14', 9.6,  18),
('Terraria',                      7, 1,  149.00, '2011-05-16', 9.3, 100),
 
-- PS5 Pro Games (console_id = 8)
('Gran Turismo 7 Enhanced',       8, 1, 1599.00, '2024-01-15', 9.5,  15),
('Horizon Zero Dawn Remastered',  8, 2, 1499.00, '2024-03-20', 9.2,  12),
('Final Fantasy VII Rebirth',     8, 3, 1599.00, '2024-02-29', 9.4,  20),
('Rise of the Ronin',             8, 4, 1499.00, '2024-03-22', 8.6,  18),
('Stellar Blade',                 8, 4, 1499.00, '2024-04-26', 8.8,  22),
 
-- Xbox Series Pro Games (console_id = 9)
('Halo Infinite Enhanced',        9, 4, 1499.00, '2024-01-20', 9.2,  10),
('Forza Motorsport',              9, 1, 1499.00, '2023-10-10', 8.9,  14),
('Avowed',                        9, 3, 1499.00, '2024-02-18', 8.5,  12),
('Senuas Saga Hellblade II',      9, 4, 1499.00, '2024-05-21', 9.0,  10),
('Indiana Jones Great Circle',    9, 3, 1499.00, '2024-12-09', 8.7,  15),
 
-- Switch OLED Games (console_id = 6)
('Zelda Echoes of Wisdom',        6, 2,  999.00, '2024-09-26', 8.9,  30),
('Mario Party Jamboree',          6, 1,  899.00, '2024-10-17', 8.5,  25),
('Super Mario Bros Wonder',       6, 1,  999.00, '2023-10-20', 9.5,  45),
('Princess Peach Showtime',       6, 1,  899.00, '2024-03-22', 8.0,  20),
('Paper Mario Thousand Year Door',6, 2,  899.00, '2024-05-23', 9.1,  22),
 
-- Switch Lite Games (console_id = 10)
('New Pokemon Snap',             10, 2,  699.00, '2021-04-30', 8.3,  20),
('Hyrule Warriors Age of Calamity',10,3, 799.00, '2020-11-20', 8.2,  18),
('Monster Hunter Rise',          10, 3,  899.00, '2021-03-26', 9.0,  22),
('Story of Seasons Pioneers',    10, 1,  699.00, '2021-03-23', 7.9,  15),
('Rune Factory 5',               10, 3,  799.00, '2021-05-20', 8.0,  12);
 

-- PRODUCTS (20)

 
INSERT INTO products (name, description, price, stock_total, product_type) VALUES
('Pokémon Cards Booster Pack',    '10 cartas aleatorias',       89.00,  200, 'cards'),
('Yu-Gi-Oh Cards Booster Pack',   '9 cartas aleatorias',        79.00,  150, 'cards'),
('Magic The Gathering Booster',   '15 cartas aleatorias',       99.00,  180, 'cards'),
('Mario Figurine 10cm',           'Figura coleccionable',      349.00,   50, 'figures'),
('Link Figurine 15cm',            'Figura Zelda BOTW',         499.00,   35, 'figures'),
('Master Chief Helmet Replica',   'Casco coleccionable',      1299.00,   10, 'merchandise'),
('PS5 Controller DualSense',      'Control oficial',          1599.00,   40, 'accessories'),
('Xbox Controller',               'Control oficial',          1399.00,   35, 'accessories'),
('Nintendo Switch Pro Controller','Control oficial',          1299.00,   30, 'accessories'),
('PS5 Headset Pulse 3D',          'Audífonos inalámbricos',   1599.00,   25, 'accessories'),
('Xbox Headset Wireless',         'Audífonos inalámbricos',   1399.00,   20, 'accessories'),
('Nintendo Switch Case',          'Funda protectora',          299.00,   60, 'accessories'),
('PS5 Stand Cooling Fan',         'Base con ventilador',       599.00,   15, 'accessories'),
('Xbox Series X Stand',           'Base vertical',             399.00,   20, 'accessories'),
('HDMI Cable 2.1 3m',             'Cable para 4K 120Hz',       299.00,   80, 'accessories'),
('Gaming Mouse Pad XL',           'Tapete grande',             199.00,  100, 'accessories'),
('Lego Mario Set',                'Set de construcción',       899.00,   25, 'merchandise'),
('Pokémon Plush Pikachu',         'Peluche 30cm',              349.00,   40, 'merchandise'),
('Zelda Poster Collection',       'Set de 3 pósters',          199.00,   50, 'merchandise'),
('Gaming Keychain Set',           'Set de 5 llaveros',          99.00,  120, 'merchandise');
 

-- CLIENTS (100)

 
INSERT INTO clients (first_name, last_name, phone, email, address, membership_date, points, membership_type) VALUES
('Carlos',    'Hernández', '+526643333001', 'carlos.h@email.com',    'Calle 1 #123, Col. Centro',  '2023-01-15',  500, 'silver'),
('Martha',    'López',     '+526643333002', 'martha.l@email.com',    'Calle 2 #456, Col. Norte',   '2023-01-20',  300, 'bronze'),
('Miguel',    'García',    '+526643333003', 'miguel.g@email.com',    'Calle 3 #789, Col. Sur',     '2023-02-01',  800, 'gold'),
('Sofia',     'Martínez',  '+526643333004', 'sofia.m@email.com',     'Calle 4 #321, Col. Este',    '2023-02-10',  150, 'bronze'),
('Alejandro', 'Rodríguez', '+526643333005', 'alejandro.r@email.com', 'Calle 5 #654, Col. Oeste',   '2023-02-15', 1200, 'platinum'),
('Isabel',    'Cruz',      '+526643333006', 'isabel.c@email.com',    'Calle 6 #987, Col. Centro',  '2023-03-01',  450, 'silver'),
('Fernando',  'Torres',    '+526643333007', 'fernando.t@email.com',  'Calle 7 #147, Col. Norte',   '2023-03-10',  600, 'silver'),
('Lucia',     'Méndez',    '+526643333008', 'lucia.m@email.com',     'Calle 8 #258, Col. Sur',     '2023-03-15',  250, 'bronze'),
('Ricardo',   'Navarro',   '+526643333009', 'ricardo.n@email.com',   'Calle 9 #369, Col. Este',    '2023-03-20',  950, 'gold'),
('Patricia',  'Rojas',     '+526643333010', 'patricia.r@email.com',  'Calle 10 #741, Col. Oeste',  '2023-03-25',  180, 'bronze'),
('Gabriel',   'Herrera',   '+526643333011', 'gabriel.h@email.com',   'Calle 11 #852, Col. Centro', '2023-04-01',  700, 'silver'),
('Mónica',    'Álvarez',   '+526643333012', 'monica.a@email.com',    'Calle 12 #963, Col. Norte',  '2023-04-05',  350, 'bronze'),
('Oscar',     'Jiménez',   '+526643333013', 'oscar.j@email.com',     'Calle 13 #159, Col. Sur',    '2023-04-10', 1100, 'platinum'),
('Claudia',   'Sánchez',   '+526643333014', 'claudia.s@email.com',   'Calle 14 #357, Col. Este',   '2023-04-15',  280, 'bronze'),
('Eduardo',   'Luna',      '+526643333015', 'eduardo.l@email.com',   'Calle 15 #753, Col. Oeste',  '2023-04-20',  520, 'silver'),
('Daniela',   'Vargas',    '+526643333016', 'daniela.v@email.com',   'Calle 16 #159, Col. Centro', '2023-04-25',  150, 'bronze'),
('Roberto',   'Castro',    '+526643333017', 'roberto.c@email.com',   'Calle 17 #268, Col. Norte',  '2023-05-01',  650, 'silver'),
('Ana',       'Morales',   '+526643333018', 'ana.m@email.com',       'Calle 18 #379, Col. Sur',    '2023-05-05',  400, 'bronze'),
('Javier',    'Ramírez',   '+526643333019', 'javier.r@email.com',    'Calle 19 #482, Col. Este',   '2023-05-10',  880, 'gold'),
('Laura',     'Flores',    '+526643333020', 'laura.f@email.com',     'Calle 20 #593, Col. Oeste',  '2023-05-15',  220, 'bronze'),
('Andrés',    'Reyes',     '+526643333021', 'andres.r@email.com',    'Calle 21 #684, Col. Centro', '2023-05-20',  750, 'silver'),
('Paulina',   'Gutiérrez', '+526643333022', 'paulina.g@email.com',   'Calle 22 #795, Col. Norte',  '2023-05-25',  380, 'bronze'),
('Marco',     'Díaz',      '+526643333023', 'marco.d@email.com',     'Calle 23 #816, Col. Sur',    '2023-06-01', 1050, 'platinum'),
('Silvia',    'Moreno',    '+526643333024', 'silvia.m@email.com',    'Calle 24 #927, Col. Este',   '2023-06-05',  290, 'bronze'),
('Héctor',    'Ortiz',     '+526643333025', 'hector.o@email.com',    'Calle 25 #138, Col. Oeste',  '2023-06-10',  580, 'silver'),
('Valentina', 'Ruiz',      '+526643333026', 'valentina.r@email.com', 'Calle 26 #241, Col. Centro', '2023-06-15',  170, 'bronze'),
('Diego',     'Mendoza',   '+526643333027', 'diego.m@email.com',     'Calle 27 #352, Col. Norte',  '2023-06-20',  920, 'gold'),
('Carolina',  'Lara',      '+526643333028', 'carolina.l@email.com',  'Calle 28 #463, Col. Sur',    '2023-06-25',  420, 'silver'),
('Raúl',      'Soto',      '+526643333029', 'raul.s@email.com',      'Calle 29 #574, Col. Este',   '2023-07-01',  210, 'bronze'),
('Adriana',   'Delgado',   '+526643333030', 'adriana.d@email.com',   'Calle 30 #685, Col. Oeste',  '2023-07-05',  680, 'silver'),
('Sergio',    'Vega',      '+526643333031', 'sergio.v@email.com',    'Calle 31 #796, Col. Centro', '2023-07-10',  340, 'bronze'),
('Miriam',    'Castillo',  '+526643333032', 'miriam.c@email.com',    'Calle 32 #817, Col. Norte',  '2023-07-15', 1150, 'platinum'),
('Iván',      'Ríos',      '+526643333033', 'ivan.r@email.com',      'Calle 33 #928, Col. Sur',    '2023-07-20',  480, 'silver'),
('Vanessa',   'Mendoza',   '+526643333034', 'vanessa.m@email.com',   'Calle 34 #139, Col. Este',   '2023-07-25',  190, 'bronze'),
('Pablo',     'Aguilar',   '+526643333035', 'pablo.a@email.com',     'Calle 35 #241, Col. Oeste',  '2023-08-01',  770, 'silver'),
('Renata',    'Silva',     '+526643333036', 'renata.s@email.com',    'Calle 36 #352, Col. Centro', '2023-08-05',  260, 'bronze'),
('Gustavo',   'Campos',    '+526643333037', 'gustavo.c@email.com',   'Calle 37 #463, Col. Norte',  '2023-08-10',  890, 'gold'),
('Elena',     'Villa',     '+526643333038', 'elena.v@email.com',     'Calle 38 #574, Col. Sur',    '2023-08-15',  310, 'bronze'),
('Arturo',    'Salazar',   '+526643333039', 'arturo.s@email.com',    'Calle 39 #685, Col. Este',   '2023-08-20',  540, 'silver'),
('Natalia',   'Romero',    '+526643333040', 'natalia.r@email.com',   'Calle 40 #796, Col. Oeste',  '2023-08-25',  140, 'bronze'),
('Emilio',    'Zapata',    '+526643333041', 'emilio.z@email.com',    'Calle 41 #817, Col. Centro', '2023-09-01',  620, 'silver'),
('Patricia',  'Núñez',     '+526643333042', 'patricia.n@email.com',  'Calle 42 #928, Col. Norte',  '2023-09-05',  230, 'bronze'),
('Federico',  'Beltrán',   '+526643333043', 'federico.b@email.com',  'Calle 43 #139, Col. Sur',    '2023-09-10',  980, 'gold'),
('Alicia',    'Peña',      '+526643333044', 'alicia.p@email.com',    'Calle 44 #241, Col. Este',   '2023-09-15',  370, 'bronze'),
('Rubén',     'Cortés',    '+526643333045', 'ruben.c@email.com',     'Calle 45 #352, Col. Oeste',  '2023-09-20',  550, 'silver'),
('Gabriela',  'Serrano',   '+526643333046', 'gabriela.s@email.com',  'Calle 46 #463, Col. Centro', '2023-09-25',  180, 'bronze'),
('Tomás',     'Velasco',   '+526643333047', 'tomas.v@email.com',     'Calle 47 #574, Col. Norte',  '2023-10-01',  720, 'silver'),
('Lucía',     'Domínguez', '+526643333048', 'lucia.d@email.com',     'Calle 48 #685, Col. Sur',    '2023-10-05',  270, 'bronze'),
('Francisco', 'Ramos',     '+526643333049', 'francisco.r@email.com', 'Calle 49 #796, Col. Este',   '2023-10-10',  850, 'gold'),
('Mariana',   'Guerra',    '+526643333050', 'mariana.g@email.com',   'Calle 50 #817, Col. Oeste',  '2023-10-15',  320, 'bronze'),
('Antonio',   'Méndez',    '+526643333051', 'antonio.m@email.com',   'Calle 51 #928, Col. Centro', '2023-10-20',  590, 'silver'),
('Rosa',      'Ortega',    '+526643333052', 'rosa.o@email.com',      'Calle 52 #139, Col. Norte',  '2023-10-25',  160, 'bronze'),
('Enrique',   'Vargas',    '+526643333053', 'enrique.v@email.com',   'Calle 53 #241, Col. Sur',    '2023-11-01', 1080, 'platinum'),
('Carla',     'Muñoz',     '+526643333054', 'carla.m@email.com',     'Calle 54 #352, Col. Este',   '2023-11-05',  440, 'silver'),
('Jorge',     'Navarro',   '+526643333055', 'jorge.n@email.com',     'Calle 55 #463, Col. Oeste',  '2023-11-10',  210, 'bronze'),
('Patricia',  'Luna',      '+526643333056', 'patricia.l@email.com',  'Calle 56 #574, Col. Centro', '2023-11-15',  660, 'silver'),
('Manuel',    'Escobar',   '+526643333057', 'manuel.e@email.com',    'Calle 57 #685, Col. Norte',  '2023-11-20',  390, 'bronze'),
('Silvia',    'Paredes',   '+526643333058', 'silvia.p@email.com',    'Calle 58 #796, Col. Sur',    '2023-11-25',  910, 'gold'),
('Roberto',   'Cabrera',   '+526643333059', 'roberto.cb@email.com',  'Calle 59 #817, Col. Este',   '2023-12-01',  250, 'bronze'),
('Angélica',  'Ríos',      '+526643333060', 'angelica.r@email.com',  'Calle 60 #928, Col. Oeste',  '2023-12-05',  530, 'silver'),
('Humberto',  'Leal',      '+526643333061', 'humberto.l@email.com',  'Calle 61 #139, Col. Centro', '2023-12-10',  170, 'bronze'),
('Diana',     'Mejía',     '+526643333062', 'diana.m@email.com',     'Calle 62 #241, Col. Norte',  '2023-12-15',  780, 'silver'),
('Felipe',    'Contreras', '+526643333063', 'felipe.c@email.com',    'Calle 63 #352, Col. Sur',    '2023-12-20',  340, 'bronze'),
('Verónica',  'Acosta',    '+526643333064', 'veronica.a@email.com',  'Calle 64 #463, Col. Este',   '2023-12-25', 1010, 'platinum'),
('Santiago',  'Luna',      '+526643333065', 'santiago.l@email.com',  'Calle 65 #574, Col. Oeste',  '2024-01-01',  410, 'silver'),
('Mónica',    'Trejo',     '+526643333066', 'monica.t@email.com',    'Calle 66 #685, Col. Centro', '2024-01-05',  200, 'bronze'),
('Ricardo',   'Guzmán',    '+526643333067', 'ricardo.g@email.com',   'Calle 67 #796, Col. Norte',  '2024-01-10',  860, 'gold'),
('Lorena',    'Herrera',   '+526643333068', 'lorena.h@email.com',    'Calle 68 #817, Col. Sur',    '2024-01-15',  280, 'bronze'),
('Bruno',     'Zapata',    '+526643333069', 'bruno.z@email.com',     'Calle 69 #928, Col. Este',   '2024-01-20',  610, 'silver'),
('Andrea',    'Flores',    '+526643333070', 'andrea.f@email.com',    'Calle 70 #139, Col. Oeste',  '2024-01-25',  150, 'bronze'),
('Eduardo',   'Mora',      '+526643333071', 'eduardo.m@email.com',   'Calle 71 #241, Col. Centro', '2024-02-01',  740, 'silver'),
('Carolina',  'Vega',      '+526643333072', 'carolina.v@email.com',  'Calle 72 #352, Col. Norte',  '2024-02-05',  330, 'bronze'),
('Luis',      'Ponce',     '+526643333073', 'luis.p@email.com',      'Calle 73 #463, Col. Sur',    '2024-02-10',  990, 'gold'),
('María',     'Sánchez',   '+526643333074', 'maria.s@email.com',     'Calle 74 #574, Col. Este',   '2024-02-15',  240, 'bronze'),
('Fernando',  'Rivas',     '+526643333075', 'fernando.r@email.com',  'Calle 75 #685, Col. Oeste',  '2024-02-20',  560, 'silver'),
('Alejandra', 'Cruz',      '+526643333076', 'alejandra.c@email.com', 'Calle 76 #796, Col. Centro', '2024-02-25',  190, 'bronze'),
('Carlos',    'Morales',   '+526643333077', 'carlos.m@email.com',    'Calle 77 #817, Col. Norte',  '2024-03-01',  690, 'silver'),
('Patricia',  'Jiménez',   '+526643333078', 'patricia.j@email.com',  'Calle 78 #928, Col. Sur',    '2024-03-05',  300, 'bronze'),
('Roberto',   'Delgado',   '+526643333079', 'roberto.d@email.com',   'Calle 79 #139, Col. Este',   '2024-03-10', 1040, 'platinum'),
('Sofia',     'Ruíz',      '+526643333080', 'sofia.r@email.com',     'Calle 80 #241, Col. Oeste',  '2024-03-15',  470, 'silver'),
('Miguel',    'Ángel',     '+526643333081', 'miguel.a@email.com',    'Calle 81 #352, Col. Centro', '2024-03-20',  220, 'bronze'),
('Ana',       'Beltrán',   '+526643333082', 'ana.b@email.com',       'Calle 82 #463, Col. Norte',  '2024-03-25',  830, 'gold'),
('Javier',    'Campos',    '+526643333083', 'javier.c@email.com',    'Calle 83 #574, Col. Sur',    '2024-04-01',  360, 'bronze'),
('Diana',     'López',     '+526643333084', 'diana.l@email.com',     'Calle 84 #685, Col. Este',   '2024-04-05',  510, 'silver'),
('Héctor',    'Salazar',   '+526643333085', 'hector.s@email.com',    'Calle 85 #796, Col. Oeste',  '2024-04-10',  180, 'bronze'),
('Laura',     'Mendoza',   '+526643333086', 'laura.m@email.com',     'Calle 86 #817, Col. Centro', '2024-04-15',  640, 'silver'),
('Pablo',     'Ramírez',   '+526643333087', 'pablo.r@email.com',     'Calle 87 #928, Col. Norte',  '2024-04-20',  290, 'bronze'),
('Renata',    'Guerrero',  '+526643333088', 'renata.g@email.com',    'Calle 88 #139, Col. Sur',    '2024-04-25',  960, 'gold'),
('Gustavo',   'Torres',    '+526643333089', 'gustavo.t@email.com',   'Calle 89 #241, Col. Este',   '2024-05-01',  430, 'silver'),
('Valentina', 'Ortiz',     '+526643333090', 'valentina.o@email.com', 'Calle 90 #352, Col. Oeste',  '2024-05-05',  260, 'bronze'),
('Diego',     'Villa',     '+526643333091', 'diego.v@email.com',     'Calle 91 #463, Col. Centro', '2024-05-10',  570, 'silver'),
('Carolina',  'Paz',       '+526643333092', 'carolina.p@email.com',  'Calle 92 #574, Col. Norte',  '2024-05-15',  350, 'bronze'),
('Raúl',      'Castro',    '+526643333093', 'raul.c@email.com',      'Calle 93 #685, Col. Sur',    '2024-05-20',  870, 'gold'),
('Adriana',   'Flores',    '+526643333094', 'adriana.f@email.com',   'Calle 94 #796, Col. Este',   '2024-05-25',  200, 'bronze'),
('Sergio',    'Méndez',    '+526643333095', 'sergio.m@email.com',    'Calle 95 #817, Col. Oeste',  '2024-06-01',  680, 'silver'),
('Miriam',    'Lara',      '+526643333096', 'miriam.l@email.com',    'Calle 96 #928, Col. Centro', '2024-06-05',  310, 'bronze'),
('Iván',      'Soto',      '+526643333097', 'ivan.s@email.com',      'Calle 97 #139, Col. Norte',  '2024-06-10', 1120, 'platinum'),
('Vanessa',   'Aguilar',   '+526643333098', 'vanessa.a@email.com',   'Calle 98 #241, Col. Sur',    '2024-06-15',  480, 'silver'),
('Pablo',     'Romero',    '+526643333099', 'pablo.ro@email.com',    'Calle 99 #352, Col. Este',   '2024-06-20',  170, 'bronze'),
('Renata',    'Pedraza',   '+526643333100', 'renata.p@email.com',    'Calle 100 #463, Col. Oeste', '2024-06-25',  760, 'silver');
 

-- INVENTORY (sample per branch)

 
INSERT INTO inventory (branch_id, game_id, quantity, min_stock) VALUES
(1,  1, 15, 5), (1,  2, 12, 5), (1,  3, 20, 5), (1,  4, 10, 5), (1,  5, 25, 5),
(1, 41, 18, 5), (1, 63, 10, 5), (1, 66, 8,  5), (1, 67, 12, 5), (1, 43, 15, 5),
(2,  6, 14, 5), (2,  7, 10, 5), (2,  8, 20, 5), (2, 31, 12, 5), (2, 32, 18, 5),
(2, 42, 22, 5), (2, 44, 16, 5), (2, 50, 12, 5), (2, 68, 10, 5), (2, 69,  8, 5),
(3,  9, 15, 5), (3, 10, 20, 5), (3, 11, 18, 5), (3, 21, 12, 5), (3, 22, 10, 5),
(3, 45, 25, 5), (3, 46, 18, 5), (3, 47, 14, 5), (3, 70,  8, 5), (3, 71, 10, 5),
(4, 12, 14, 5), (4, 13, 16, 5), (4, 14, 20, 5), (4, 23,  8, 5), (4, 24, 12, 5),
(4, 48, 20, 5), (4, 49, 15, 5), (4, 51, 10, 5), (4, 72,  6, 3), (4, 73,  8, 3),
(5, 15, 22, 5), (5, 16, 10, 5), (5, 17,  8, 5), (5, 25, 15, 5), (5, 26, 10, 5),
(5, 52, 22, 5), (5, 53, 18, 5), (5, 54, 14, 5), (5, 74,  5, 3), (5, 75,  7, 3),
(6, 18, 14, 5), (6, 19, 18, 5), (6, 20, 16, 5), (6, 27, 12, 5), (6, 28, 10, 5),
(6, 55, 20, 5), (6, 56, 15, 5), (6, 57, 18, 5), (6, 81, 12, 5), (6, 82, 10, 5),
(7, 33, 20, 5), (7, 34, 12, 5), (7, 35, 16, 5), (7, 36, 18, 5), (7, 37, 14, 5),
(7, 58, 16, 5), (7, 59, 20, 5), (7, 60, 12, 5), (7, 83, 10, 5), (7, 84,  8, 5),
(8, 38, 10, 5), (8, 39, 12, 5), (8, 40, 15, 5), (8, 61, 10, 5), (8, 62, 25, 5),
(8, 76,  5, 3), (8, 77,  4, 3), (8, 78,  8, 3), (8, 85, 12, 5), (8, 86, 10, 5),
(9, 29, 12, 5), (9, 30, 10, 5), (9, 64,  8, 5), (9, 65, 10, 5), (9, 87, 10, 5),
(9, 88, 14, 5), (9, 89, 12, 5), (9, 90, 10, 5), (9, 96, 20, 5), (9, 97, 18, 5),
(10, 91, 25, 5),(10, 92, 15, 5),(10, 93, 20, 5),(10, 98,  6, 3),(10, 99,  6, 3),
(10,100, 12, 5),(10, 43, 18, 5),(10, 44, 14, 5),(10, 45, 20, 5),(10, 46, 16, 5);
 
INSERT INTO inventory (branch_id, console_id, quantity, min_stock) VALUES
(1, 1, 8, 3),(1, 3, 6, 3),
(2, 2, 7, 3),(2, 5, 5, 3),
(3, 1, 6, 3),(3, 6, 4, 3),
(4, 3, 5, 3),(4, 4, 4, 3),
(5, 5, 8, 3),(5, 7, 3, 3),
(6, 2, 5, 3),(6, 8, 2, 3),
(7, 3, 6, 3),(7, 9, 3, 3),
(8, 1, 4, 3),(8, 6, 3, 3),
(9, 5,10, 3),
(10,10, 6, 3);
 
INSERT INTO inventory (branch_id, product_id, quantity, min_stock) VALUES
(1,  1, 50, 20),(1,  7, 10,  5),
(2,  2, 40, 20),(2,  8,  8,  5),
(3,  3, 35, 20),(3,  9, 12,  5),
(4,  4, 15, 10),(4, 10,  6,  5),
(5,  5, 12, 10),(5, 11,  7,  5),
(6,  6,  5,  3),(6, 12, 20, 10),
(7,  7, 12,  5),(7, 13,  5,  3),
(8,  8, 10,  5),(8, 14,  8,  5),
(9,  9,  6,  5),(9, 15, 25, 10),
(10,10,  7,  5),(10,16, 30, 15);
 

-- SALES (30)

 
INSERT INTO sales (client_id, employee_id, branch_id, sale_date, total, points_earned, payment_method, status) VALUES
(1,  11, 1, '2024-04-01 09:15:00', 1388.00, 14, 'card',     'completed'),
(2,  12, 2, '2024-04-01 10:30:00', 1199.00, 12, 'cash',     'completed'),
(3,  13, 3, '2024-04-02 11:00:00', 1798.00, 18, 'card',     'completed'),
(4,  14, 4, '2024-04-02 14:20:00',  899.00,  9, 'transfer', 'completed'),
(5,  15, 5, '2024-04-03 09:45:00', 2498.00, 25, 'card',     'completed'),
(6,  16, 6, '2024-04-03 15:00:00',  349.00,  3, 'cash',     'completed'),
(7,  17, 7, '2024-04-04 10:15:00', 1299.00, 13, 'card',     'completed'),
(8,  18, 8, '2024-04-04 16:30:00', 1898.00, 19, 'card',     'completed'),
(9,  19, 9, '2024-04-05 09:00:00', 5499.00, 55, 'transfer', 'completed'),
(10, 20,10, '2024-04-05 11:45:00',  799.00,  8, 'cash',     'completed'),
(11, 11, 1, '2024-04-10 10:30:00', 1199.00, 12, 'card',     'completed'),
(12, 12, 2, '2024-04-10 13:00:00', 1598.00, 16, 'card',     'completed'),
(13, 13, 3, '2024-04-11 09:15:00',  899.00,  9, 'cash',     'completed'),
(14, 14, 4, '2024-04-11 14:45:00', 1299.00, 13, 'card',     'completed'),
(15, 15, 5, '2024-04-12 10:00:00',  699.00,  7, 'cash',     'completed'),
(16, 16, 6, '2024-04-15 09:30:00', 1399.00, 14, 'card',     'completed'),
(17, 17, 7, '2024-04-15 11:20:00',  899.00,  9, 'cash',     'completed'),
(18, 18, 8, '2024-04-20 09:45:00', 1099.00, 11, 'card',     'completed'),
(19, 19, 9, '2024-04-20 14:30:00', 5299.00, 53, 'card',     'completed'),
(20, 20,10, '2024-04-25 10:00:00', 3197.00, 32, 'transfer', 'completed'),
(21, 11, 1, '2024-04-25 12:15:00', 1299.00, 13, 'card',     'completed'),
(22, 12, 2, '2024-04-30 09:30:00', 1399.00, 14, 'card',     'completed'),
(23, 13, 3, '2024-04-30 11:00:00',  899.00,  9, 'cash',     'completed'),
(24, 14, 4, '2024-05-05 09:00:00', 2898.00, 29, 'card',     'completed'),
(25, 15, 5, '2024-05-05 14:00:00', 1998.00, 20, 'card',     'completed'),
(26, 16, 6, '2024-05-06 10:30:00',  799.00,  8, 'cash',     'completed'),
(27, 17, 7, '2024-05-06 15:45:00', 1199.00, 12, 'card',     'completed'),
(28, 18, 8, '2024-05-07 09:15:00', 1299.00, 13, 'card',     'completed'),
(29, 19, 9, '2024-05-07 13:30:00',  349.00,  3, 'cash',     'completed'),
(30, 20,10, '2024-05-10 09:00:00', 4499.00, 45, 'card',     'completed');
 

-- SALE DETAILS (30)

 
INSERT INTO sale_details (sale_id, game_id, quantity, unit_price, subtotal) VALUES
(1,  1, 1, 1299.00, 1299.00),
(2,  31,1, 1199.00, 1199.00),
(3,  41,2,  999.00, 1798.00),
(4,  42,1,  899.00,  899.00),
(7,  2, 1, 1299.00, 1299.00),
(8,  63,1, 1399.00, 1399.00),
(10, 43,1,  799.00,  799.00),
(11, 32,1, 1099.00, 1099.00),
(13, 50,1,  899.00,  899.00),
(14, 6, 1, 1299.00, 1299.00),
(16, 64,1, 1399.00, 1399.00),
(17, 46,1,  899.00,  899.00),
(18, 4, 1, 1099.00, 1099.00),
(21, 66,1, 1299.00, 1299.00),
(22, 7, 1, 1399.00, 1399.00),
(23, 47,1,  899.00,  899.00),
(24, 33,1, 1299.00, 1299.00),
(25, 44,2,  799.00, 1598.00),
(26, 43,1,  799.00,  799.00),
(27, 58,1, 1099.00, 1099.00),
(28, 91,1, 1299.00, 1299.00),
(30, 82,1,  899.00,  899.00);
 
INSERT INTO sale_details (sale_id, console_id, quantity, unit_price, subtotal) VALUES
(5,  5, 1, 4499.00, 4499.00),
(9,  1, 1, 5499.00, 5499.00),
(19, 3, 1, 5299.00, 5299.00),
(30, 6, 1, 5499.00, 5499.00);
 
INSERT INTO sale_details (sale_id, product_id, quantity, unit_price, subtotal) VALUES
(1,  1, 1,   89.00,   89.00),
(6,  1, 2,   89.00,  178.00),
(6,  3, 2,   99.00,  198.00),
(8,  7, 1, 1599.00, 1599.00),
(12, 7, 1, 1599.00, 1599.00),
(15,11, 1,  699.00,  699.00),
(20, 7, 1,  899.00,  899.00),
(20, 4, 1,  349.00,  349.00),
(24, 7, 1, 1599.00, 1599.00),
(25, 4, 1,  349.00,  349.00),
(29, 3, 2,   99.00,  198.00),
(29,16, 1,  199.00,  199.00);
 

-- PURCHASES (10)

 
INSERT INTO purchases (supplier_id, branch_id, purchase_date, total, received_date, status) VALUES
(1, 1, '2024-03-15', 54990.00, '2024-03-18', 'received'),
(2, 2, '2024-03-16', 47960.00, '2024-03-19', 'received'),
(3, 3, '2024-03-17', 38990.00, '2024-03-20', 'received'),
(1, 4, '2024-03-18', 28970.00, '2024-03-21', 'received'),
(2, 5, '2024-03-19', 42980.00, '2024-03-22', 'received'),
(4, 6, '2024-03-20', 18990.00, '2024-03-23', 'received'),
(5, 7, '2024-03-21', 25990.00, '2024-03-24', 'received'),
(1, 8, '2024-04-01', 65980.00, '2024-04-04', 'received'),
(2, 9, '2024-04-02', 31990.00, '2024-04-05', 'received'),
(3,10, '2024-04-03', 28990.00, '2024-04-06', 'received');
 
INSERT INTO purchase_details (purchase_id, game_id, quantity, unit_cost, subtotal) VALUES
(1,  1, 10, 800.00,  8000.00),
(1, 41, 15, 650.00,  9750.00),
(2, 31, 12, 750.00,  9000.00),
(2, 33, 10, 800.00,  8000.00),
(3, 63, 15, 900.00, 13500.00),
(3, 42, 20, 700.00, 14000.00),
(4,  2, 10, 850.00,  8500.00),
(4,  6,  5, 850.00,  4250.00),
(5, 44, 25, 500.00, 12500.00),
(5, 64, 10, 900.00,  9000.00),
(7, 32, 20, 700.00, 14000.00),
(7, 43, 15, 500.00,  7500.00),
(8,  1, 20, 800.00, 16000.00),
(8, 66, 10, 650.00,  6500.00),
(9, 46,  8, 650.00,  5200.00),
(9, 47, 15, 550.00,  8250.00),
(10,91, 12, 850.00, 10200.00);
 
INSERT INTO purchase_details (purchase_id, console_id, quantity, unit_cost, subtotal) VALUES
(1, 1,  5, 4500.00, 22500.00),
(2, 3,  8, 4200.00, 33600.00),
(5, 5, 10, 3500.00, 35000.00),
(6, 7,  5, 3800.00, 19000.00),
(8, 1, 10, 4500.00, 45000.00),
(10,10, 5, 2400.00, 12000.00);
 
INSERT INTO purchase_details (purchase_id, product_id, quantity, unit_cost, subtotal) VALUES
(1,  1, 100,  50.00,  5000.00),
(2,  2,  80,  45.00,  3600.00),
(3,  3,  60,  60.00,  3600.00),
(4,  4,  25, 200.00,  5000.00),
(6,  7,  20,1200.00, 24000.00);
 

-- AUDIT LOG

 
INSERT INTO audit_log (date_, user_, table_, operation) VALUES
(NOW() - INTERVAL 5 HOUR, 'admin@gamezone.com',      'clients',    'INSERT'),
(NOW() - INTERVAL 4 HOUR, 'j.perez@gamezone.com',    'sales',      'INSERT'),
(NOW() - INTERVAL 3 HOUR, 'm.gonzalez@gamezone.com', 'inventory',  'UPDATE'),
(NOW() - INTERVAL 2 HOUR, 'c.mendoza@gamezone.com',  'purchases',  'INSERT'),
(NOW() - INTERVAL 1 HOUR, 'admin@gamezone.com',      'games',      'INSERT');

###Reports 
 # Report 1:Total sales for branch
  SELECT
      b.name AS sucursal,
      SUM(s.total) AS total_ventas
  FROM branches b
  JOIN sales s ON s.branch_id = b.branch_id
  WHERE s.status = 'completed'
  GROUP BY b.branch_id, b.name
  ORDER BY total_ventas DESC;

  # Report 2: The 5 best-selling games
  SELECT
      g.title AS juego,
      SUM(sd.quantity) AS cantidad_vendida
  FROM games g
  JOIN sale_details sd ON sd.game_id = g.game_id
  GROUP BY g.game_id, g.title
  ORDER BY cantidad_vendida DESC
  LIMIT 5;

   # Report 3: Games with low stock per branch
  SELECT
      b.name AS sucursal,
      g.title AS juego,
      i.quantity AS stock_actual
  FROM inventory i
  JOIN branches b ON b.branch_id = i.branch_id
  JOIN games g ON g.game_id = i.game_id
  WHERE i.quantity < i.min_stock
  ORDER BY stock_actual ASC;

  # Report 4: Number of customers by membership type
  SELECT
      membership_type AS membresia,
      COUNT(*) AS total_clientes
  FROM clients
  GROUP BY membership_type;

  # Report 5: Sales by payment method
  SELECT
      payment_method AS metodo_pago,
      COUNT(*) AS total_ventas,
      SUM(total) AS total_monto
  FROM sales
  WHERE status = 'completed'
  GROUP BY payment_method;


#Views 


# View 1: Total sales by branch
  CREATE VIEW vw_total_sales_by_branch AS
  SELECT
      row_number() OVER (ORDER BY SUM(s.total) DESC) AS view_id,
      b.branch_id,
      b.name AS branch_name,
      SUM(s.total) AS total_sales
  FROM branches b
  JOIN sales s ON s.branch_id = b.branch_id
  WHERE s.status = 'completed'
  GROUP BY b.branch_id, b.name;

  # View 2: Top 5 best-selling games
  CREATE VIEW vw_top_5_best_selling_games AS
  SELECT
      row_number() OVER (ORDER BY SUM(sd.quantity) DESC) AS view_id,
      g.game_id,
      g.title AS game_title,
      SUM(sd.quantity) AS total_sold
  FROM games g
  JOIN sale_details sd ON sd.game_id = g.game_id
  GROUP BY g.game_id, g.title
  ORDER BY total_sold DESC
  LIMIT 5;

  # View 3: Games with low stock by branch
  CREATE VIEW vw_low_stock_games_by_branch AS
  SELECT
      row_number() OVER (ORDER BY i.quantity ASC) AS view_id,
      b.branch_id,
      b.name AS branch_name,
      g.game_id,
      g.title AS game_title,
      i.quantity AS current_stock,
      i.min_stock
  FROM inventory i
  JOIN branches b ON b.branch_id = i.branch_id
  JOIN games g ON g.game_id = i.game_id
  WHERE i.quantity < i.min_stock;

  # View 4: Customers by membership type
  CREATE VIEW vw_customers_by_membership AS
  SELECT
      row_number() OVER (ORDER BY membership_type) AS view_id,
      membership_type,
      COUNT(*) AS total_customers
  FROM clients
  GROUP BY membership_type;

  # View 5: Sales by payment method
  CREATE VIEW vw_sales_by_payment_method AS
  SELECT
      row_number() OVER (ORDER BY payment_method) AS view_id,
      payment_method,
      COUNT(*) AS total_sales,
      SUM(total) AS total_amount
  FROM sales
  WHERE status = 'completed'
  GROUP BY payment_method;


# TRIGGERS FOR ROLES TABLE


  # Trigger: INSERT for roles
  DELIMITER //
  CREATE TRIGGER tr_roles_insert
  AFTER INSERT ON roles
  FOR EACH ROW
  BEGIN
      INSERT INTO audit_log (date_, user_, table_, operation)
      VALUES (NOW(), CURRENT_USER(), 'roles', 'INSERT');
  END//
  DELIMITER ;

  # Trigger: UPDATE for roles
  DELIMITER //
  CREATE TRIGGER tr_roles_update
  AFTER UPDATE ON roles
  FOR EACH ROW
  BEGIN
      INSERT INTO audit_log (date_, user_, table_, operation)
      VALUES (NOW(), CURRENT_USER(), 'roles', 'UPDATE');
  END//
  DELIMITER ;

  # Trigger: DELETE for roles
  DELIMITER //
  CREATE TRIGGER tr_roles_delete
  AFTER DELETE ON roles
  FOR EACH ROW
  BEGIN
      INSERT INTO audit_log (date_, user_, table_, operation)
      VALUES (NOW(), CURRENT_USER(), 'roles', 'DELETE');
  END//
  DELIMITER ;

 
  # TRIGGERS FOR CATEGORIES TABLE


  # Trigger: INSERT for categories
  DELIMITER //
  CREATE TRIGGER tr_categories_insert
  AFTER INSERT ON categories
  FOR EACH ROW
  BEGIN
      INSERT INTO audit_log (date_, user_, table_, operation)
      VALUES (NOW(), CURRENT_USER(), 'categories', 'INSERT');
  END//
  DELIMITER ;

  # Trigger: UPDATE for categories
  DELIMITER //
  CREATE TRIGGER tr_categories_update
  AFTER UPDATE ON categories
  FOR EACH ROW
  BEGIN
      INSERT INTO audit_log (date_, user_, table_, operation)
      VALUES (NOW(), CURRENT_USER(), 'categories', 'UPDATE');
  END//
  DELIMITER ;

  # Trigger: DELETE for categories
  DELIMITER //
  CREATE TRIGGER tr_categories_delete
  AFTER DELETE ON categories
  FOR EACH ROW
  BEGIN
      INSERT INTO audit_log (date_, user_, table_, operation)
      VALUES (NOW(), CURRENT_USER(), 'categories', 'DELETE');
  END//
  DELIMITER ;


  # TRIGGERS FOR BRANCHES TABLE


  # Trigger: INSERT for branches
  DELIMITER //
  CREATE TRIGGER tr_branches_insert
  AFTER INSERT ON branches
  FOR EACH ROW
  BEGIN
      INSERT INTO audit_log (date_, user_, table_, operation)
      VALUES (NOW(), CURRENT_USER(), 'branches', 'INSERT');
  END//
  DELIMITER ;

  # Trigger: UPDATE for branches
  DELIMITER //
  CREATE TRIGGER tr_branches_update
  AFTER UPDATE ON branches
  FOR EACH ROW
  BEGIN
      INSERT INTO audit_log (date_, user_, table_, operation)
      VALUES (NOW(), CURRENT_USER(), 'branches', 'UPDATE');
  END//
  DELIMITER ;

  # Trigger: DELETE for branches
  DELIMITER //
  CREATE TRIGGER tr_branches_delete
  AFTER DELETE ON branches
  FOR EACH ROW
  BEGIN
      INSERT INTO audit_log (date_, user_, table_, operation)
      VALUES (NOW(), CURRENT_USER(), 'branches', 'DELETE');
  END//
  DELIMITER ;

 
  # TRIGGERS FOR SUPPLIERS TABLE


  # Trigger: INSERT for suppliers
  DELIMITER //
  CREATE TRIGGER tr_suppliers_insert
  AFTER INSERT ON suppliers
  FOR EACH ROW
  BEGIN
      INSERT INTO audit_log (date_, user_, table_, operation)
      VALUES (NOW(), CURRENT_USER(), 'suppliers', 'INSERT');
  END//
  DELIMITER ;

  # Trigger: UPDATE for suppliers
  DELIMITER //
  CREATE TRIGGER tr_suppliers_update
  AFTER UPDATE ON suppliers
  FOR EACH ROW
  BEGIN
      INSERT INTO audit_log (date_, user_, table_, operation)
      VALUES (NOW(), CURRENT_USER(), 'suppliers', 'UPDATE');
  END//
  DELIMITER ;

  # Trigger: DELETE for suppliers
  DELIMITER //
  CREATE TRIGGER tr_suppliers_delete
  AFTER DELETE ON suppliers
  FOR EACH ROW
  BEGIN
      INSERT INTO audit_log (date_, user_, table_, operation)
      VALUES (NOW(), CURRENT_USER(), 'suppliers', 'DELETE');
  END//
  DELIMITER ;


  # TRIGGERS FOR CONSOLES TABLE
 

  # Trigger: INSERT for consoles
  DELIMITER //
  CREATE TRIGGER tr_consoles_insert
  AFTER INSERT ON consoles
  FOR EACH ROW
  BEGIN
      INSERT INTO audit_log (date_, user_, table_, operation)
      VALUES (NOW(), CURRENT_USER(), 'consoles', 'INSERT');
  END//
  DELIMITER ;

  # Trigger: UPDATE for consoles
  DELIMITER //
  CREATE TRIGGER tr_consoles_update
  AFTER UPDATE ON consoles
  FOR EACH ROW
  BEGIN
      INSERT INTO audit_log (date_, user_, table_, operation)
      VALUES (NOW(), CURRENT_USER(), 'consoles', 'UPDATE');
  END//
  DELIMITER ;

  # Trigger: DELETE for consoles
  DELIMITER //
  CREATE TRIGGER tr_consoles_delete
  AFTER DELETE ON consoles
  FOR EACH ROW
  BEGIN
      INSERT INTO audit_log (date_, user_, table_, operation)
      VALUES (NOW(), CURRENT_USER(), 'consoles', 'DELETE');
  END//
  DELIMITER ;



  # STORED PROCEDURES FOR ROLES TABLE


  # Procedure: INSERT role
  DELIMITER //
  CREATE PROCEDURE sp_insert_role(
      IN p_name VARCHAR(100),
      IN p_description VARCHAR(255),
      IN p_permissions VARCHAR(100)
  )
  BEGIN
      INSERT INTO roles (name, description, permissions)
      VALUES (p_name, p_description, p_permissions);
  END//
  DELIMITER ;

  # Procedure: UPDATE role
  DELIMITER //
  CREATE PROCEDURE sp_update_role(
      IN p_role_id INT,
      IN p_name VARCHAR(100),
      IN p_description VARCHAR(255),
      IN p_permissions VARCHAR(100)
  )
  BEGIN
      UPDATE roles
      SET name = p_name,
          description = p_description,
          permissions = p_permissions
      WHERE role_id = p_role_id;
  END//
  DELIMITER ;

  # Procedure: DELETE role
  DELIMITER //
  CREATE PROCEDURE sp_delete_role(
      IN p_role_id INT
  )
  BEGIN
      DELETE FROM roles WHERE role_id = p_role_id;
  END//
  DELIMITER ;


  # STORED PROCEDURES FOR CATEGORIES TABLE


  # Procedure: INSERT category
  DELIMITER //
  CREATE PROCEDURE sp_insert_category(
      IN p_name VARCHAR(50),
      IN p_min_age INT,
      IN p_description VARCHAR(255)
  )
  BEGIN
      INSERT INTO categories (name, min_age, description)
      VALUES (p_name, p_min_age, p_description);
  END//
  DELIMITER ;

  # Procedure: UPDATE category
  DELIMITER //
  CREATE PROCEDURE sp_update_category(
      IN p_category_id INT,
      IN p_name VARCHAR(50),
      IN p_min_age INT,
      IN p_description VARCHAR(255)
  )
  BEGIN
      UPDATE categories
      SET name = p_name,
          min_age = p_min_age,
          description = p_description
      WHERE category_id = p_category_id;
  END//
  DELIMITER ;

  # Procedure: DELETE category
  DELIMITER //
  CREATE PROCEDURE sp_delete_category(
      IN p_category_id INT
  )
  BEGIN
      DELETE FROM categories WHERE category_id = p_category_id;
  END//
  DELIMITER ;


  # STORED PROCEDURES FOR BRANCHES TABLE


  # Procedure: INSERT branch
  DELIMITER //
  CREATE PROCEDURE sp_insert_branch(
      IN p_name VARCHAR(100),
      IN p_address VARCHAR(200),
      IN p_phone VARCHAR(20),
      IN p_email VARCHAR(100),
      IN p_schedule VARCHAR(100),
      IN p_branch_number VARCHAR(10),
      IN p_manager_id INT,
      IN p_status VARCHAR(20)
  )
  BEGIN
      INSERT INTO branches (name, address, phone, email, schedule, branch_number, manager_id, status)
      VALUES (p_name, p_address, p_phone, p_email, p_schedule, p_branch_number, p_manager_id, p_status);
  END//
  DELIMITER ;

  # Procedure: UPDATE branch
  DELIMITER //
  CREATE PROCEDURE sp_update_branch(
      IN p_branch_id INT,
      IN p_name VARCHAR(100),
      IN p_address VARCHAR(200),
      IN p_phone VARCHAR(20),
      IN p_email VARCHAR(100),
      IN p_schedule VARCHAR(100),
      IN p_branch_number VARCHAR(10),
      IN p_manager_id INT,
      IN p_status VARCHAR(20)
  )
  BEGIN
      UPDATE branches
      SET name = p_name,
          address = p_address,
          phone = p_phone,
          email = p_email,
          schedule = p_schedule,
          branch_number = p_branch_number,
          manager_id = p_manager_id,
          status = p_status
      WHERE branch_id = p_branch_id;
  END//
  DELIMITER ;

  # Procedure: DELETE branch
  DELIMITER //
  CREATE PROCEDURE sp_delete_branch(
      IN p_branch_id INT
  )
  BEGIN
      DELETE FROM branches WHERE branch_id = p_branch_id;
  END//
  DELIMITER ;


  # STORED PROCEDURES FOR SUPPLIERS TABLE


  # Procedure: INSERT supplier
  DELIMITER //
  CREATE PROCEDURE sp_insert_supplier(
      IN p_name VARCHAR(100),
      IN p_contact_name VARCHAR(100),
      IN p_phone VARCHAR(20),
      IN p_email VARCHAR(100),
      IN p_address VARCHAR(200),
      IN p_status VARCHAR(20)
  )
  BEGIN
      INSERT INTO suppliers (name, contact_name, phone, email, address, status)
      VALUES (p_name, p_contact_name, p_phone, p_email, p_address, p_status);
  END//
  DELIMITER ;

  # Procedure: UPDATE supplier
  DELIMITER //
  CREATE PROCEDURE sp_update_supplier(
      IN p_supplier_id INT,
      IN p_name VARCHAR(100),
      IN p_contact_name VARCHAR(100),
      IN p_phone VARCHAR(20),
      IN p_email VARCHAR(100),
      IN p_address VARCHAR(200),
      IN p_status VARCHAR(20)
  )
  BEGIN
      UPDATE suppliers
      SET name = p_name,
          contact_name = p_contact_name,
          phone = p_phone,
          email = p_email,
          address = p_address,
          status = p_status
      WHERE supplier_id = p_supplier_id;
  END//
  DELIMITER ;

  # Procedure: DELETE supplier
  DELIMITER //
  CREATE PROCEDURE sp_delete_supplier(
      IN p_supplier_id INT
  )
  BEGIN
      DELETE FROM suppliers WHERE supplier_id = p_supplier_id;
  END//
  DELIMITER ;


  # STORED PROCEDURES FOR CONSOLES TABLE
  

  # Procedure: INSERT console
  DELIMITER //
  CREATE PROCEDURE sp_insert_console(
      IN p_name VARCHAR(50),
      IN p_manufacturer VARCHAR(50),
      IN p_release_year INT,
      IN p_price DECIMAL(10,2),
      IN p_status VARCHAR(20)
  )
  BEGIN
      INSERT INTO consoles (name, manufacturer, release_year, price, status)
      VALUES (p_name, p_manufacturer, p_release_year, p_price, p_status);
  END//
  DELIMITER ;

  # Procedure: UPDATE console
  DELIMITER //
  CREATE PROCEDURE sp_update_console(
      IN p_console_id INT,
      IN p_name VARCHAR(50),
      IN p_manufacturer VARCHAR(50),
      IN p_release_year INT,
      IN p_price DECIMAL(10,2),
      IN p_status VARCHAR(20)
  )
  BEGIN
      UPDATE consoles
      SET name = p_name,
          manufacturer = p_manufacturer,
          release_year = p_release_year,
          price = p_price,
          status = p_status
      WHERE console_id = p_console_id;
  END//
  DELIMITER ;

  # Procedure: DELETE console
  DELIMITER //
  CREATE PROCEDURE sp_delete_console(
      IN p_console_id INT
  )
  BEGIN
      DELETE FROM consoles WHERE console_id = p_console_id;
  END//
  DELIMITER ;

