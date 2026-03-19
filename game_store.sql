CREATE DATABASE game_store;
use game_store;



 # Roles Table
  CREATE TABLE roles (
      role_id     INT          PRIMARY KEY AUTO_INCREMENT,
      name        VARCHAR(100) NOT NULL,
      description VARCHAR(255)
  );

  # Categories Table
  CREATE TABLE categories (
      category_id INT         PRIMARY KEY AUTO_INCREMENT,
      name        VARCHAR(50) NOT NULL,
      min_age     INT
  );

  # Branches Table
  CREATE TABLE branches (
      branch_id INT          PRIMARY KEY AUTO_INCREMENT,
      name      VARCHAR(100) NOT NULL,
      address   VARCHAR(200) NOT NULL,
      phone     VARCHAR(20)  NOT NULL,
      status    ENUM('active', 'inactive') DEFAULT 'active'
  );

  # Suppliers Table
  CREATE TABLE suppliers (
      supplier_id  INT          PRIMARY KEY AUTO_INCREMENT,
      name         VARCHAR(100) NOT NULL,
      contact_name VARCHAR(100),
      phone        VARCHAR(20)  NOT NULL,
      status       ENUM('active', 'inactive') DEFAULT 'active'
  );



  # Consoles Table
  CREATE TABLE consoles (
      console_id   INT          PRIMARY KEY AUTO_INCREMENT,
      name         VARCHAR(50)  NOT NULL,
      manufacturer VARCHAR(50)  NOT NULL,
      price        DECIMAL(10,2) NOT NULL,
      status       ENUM('active', 'inactive') DEFAULT 'active'
  );

  # Games Table
  CREATE TABLE games (
      game_id      INT          PRIMARY KEY AUTO_INCREMENT,
      title        VARCHAR(150) NOT NULL,
      console_id   INT          NOT NULL,
      category_id  INT          NOT NULL,
      price        DECIMAL(10,2) NOT NULL,
      status       ENUM('active', 'inactive') DEFAULT 'active',
      CONSTRAINT fk_game_console  FOREIGN KEY (console_id)  REFERENCES consoles(console_id),
      CONSTRAINT fk_game_category FOREIGN KEY (category_id) REFERENCES categories(category_id)
  );

  # Products Table (cards, figures, accessories)
  CREATE TABLE products (
      product_id   INT          PRIMARY KEY AUTO_INCREMENT,
      name         VARCHAR(100) NOT NULL,
      price        DECIMAL(10,2) NOT NULL,
      status       ENUM('active', 'inactive') DEFAULT 'active'
  );



  # Inventory Table (relates products to branches)
  CREATE TABLE inventory (
      inventory_id INT          PRIMARY KEY AUTO_INCREMENT,
      branch_id    INT          NOT NULL,
      game_id      INT          NULL,
      console_id   INT          NULL,
      product_id   INT          NULL,
      quantity     INT          NOT NULL DEFAULT 0,
      min_stock    INT          NOT NULL DEFAULT 5,
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
      employee_id INT          PRIMARY KEY AUTO_INCREMENT,
      first_name  VARCHAR(50)  NOT NULL,
      last_name   VARCHAR(50)  NOT NULL,
      phone       VARCHAR(20)  NOT NULL,
      salary      DECIMAL(10,2) NOT NULL,
      role_id     INT          NOT NULL,
      branch_id   INT          NOT NULL,
      status      ENUM('active', 'inactive') DEFAULT 'active',
      CONSTRAINT fk_emp_role   FOREIGN KEY (role_id)   REFERENCES roles(role_id),
      CONSTRAINT fk_emp_branch FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
  );

  # Clients Table
  CREATE TABLE clients (
      client_id  INT          PRIMARY KEY AUTO_INCREMENT,
      first_name VARCHAR(50)  NOT NULL,
      last_name  VARCHAR(50)  NOT NULL,
      phone      VARCHAR(20)  NOT NULL,
      points     INT          DEFAULT 0,
      status     ENUM('active', 'inactive') DEFAULT 'active'
  );



  # Sales Table (Header)
  CREATE TABLE sales (
      sale_id     INT          PRIMARY KEY AUTO_INCREMENT,
      client_id   INT          NOT NULL,
      employee_id INT          NOT NULL,
      branch_id   INT          NOT NULL,
      sale_date   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
      total       DECIMAL(12,2) NOT NULL,
      status      ENUM('active', 'inactive') DEFAULT 'active',
      CONSTRAINT fk_sale_client   FOREIGN KEY (client_id)   REFERENCES clients(client_id),
      CONSTRAINT fk_sale_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
      CONSTRAINT fk_sale_branch   FOREIGN KEY (branch_id)   REFERENCES branches(branch_id)
  );

  # Purchases Table (Header)
  CREATE TABLE purchases (
      purchase_id   INT          PRIMARY KEY AUTO_INCREMENT,
      supplier_id   INT          NOT NULL,
      branch_id     INT          NOT NULL,
      purchase_date DATE         NOT NULL,
      total         DECIMAL(12,2) NOT NULL,
      status        ENUM('active', 'inactive') DEFAULT 'active',
      CONSTRAINT fk_purchase_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
      CONSTRAINT fk_purchase_branch   FOREIGN KEY (branch_id)   REFERENCES branches(branch_id)
  );


  # Sale Details Table
  CREATE TABLE sale_details (
      detail_id   INT          PRIMARY KEY AUTO_INCREMENT,
      sale_id     INT          NOT NULL,
      game_id     INT          NULL,
      console_id  INT          NULL,
      product_id  INT          NULL,
      quantity    INT          NOT NULL,
      unit_price  DECIMAL(10,2) NOT NULL,
      subtotal    DECIMAL(10,2) NOT NULL,
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
      detail_id   INT          PRIMARY KEY AUTO_INCREMENT,
      purchase_id INT          NOT NULL,
      game_id     INT          NULL,
      console_id  INT          NULL,
      product_id  INT          NULL,
      quantity    INT          NOT NULL,
      unit_cost   DECIMAL(10,2) NOT NULL,
      subtotal    DECIMAL(10,2) NOT NULL,
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



  # Audit Log Table
  CREATE TABLE audit_log (
      id        INT          PRIMARY KEY AUTO_INCREMENT,
      date      DATETIME,
      user      VARCHAR(100),
      `table`   VARCHAR(100),
      operation VARCHAR(50)
  );