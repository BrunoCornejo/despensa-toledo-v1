-- =====================================================
-- SISTEMA DE VENTAS - BASE DE DATOS COMPLETA
-- Versión: 3.0 con soporte completo para unidades, caja y múltiples métodos de pago
-- =====================================================

-- Crear base de datos si no existe
CREATE DATABASE IF NOT EXISTS sistema_ventas
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE sistema_ventas;

-- =====================================================
-- TABLA DE USUARIOS
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role ENUM('admin','empleado') NOT NULL DEFAULT 'empleado',
  active BOOLEAN NOT NULL DEFAULT TRUE,
  last_login TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_role (role),
  INDEX idx_active (active)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA DE CATEGORÍAS
-- =====================================================
CREATE TABLE IF NOT EXISTS categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT DEFAULT NULL,
  color VARCHAR(7) DEFAULT '#3B82F6',
  icon VARCHAR(10) DEFAULT '📦',
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_name (name),
  INDEX idx_active (active)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA DE PRODUCTOS (CON SOPORTE PARA UNIDADES)
-- =====================================================
CREATE TABLE IF NOT EXISTS products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  description TEXT DEFAULT NULL,
  price DECIMAL(10,2) NOT NULL,
  cost DECIMAL(10,2) DEFAULT 0.00,
  stock DECIMAL(10,3) NOT NULL DEFAULT 0,
  min_stock DECIMAL(10,3) NOT NULL DEFAULT 10,
  unit_type ENUM('unidades', 'kg') NOT NULL DEFAULT 'unidades',
  category_id INT DEFAULT NULL,
  barcode VARCHAR(50) DEFAULT NULL UNIQUE,
  image VARCHAR(500) DEFAULT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_name (name),
  INDEX idx_barcode (barcode),
  INDEX idx_category (category_id),
  INDEX idx_active (active),
  INDEX idx_stock (stock),
  INDEX idx_price (price),
  INDEX idx_unit_type (unit_type),
  INDEX idx_products_active_category (active, category_id),
  INDEX idx_products_active_stock (active, stock),
  INDEX idx_products_unit_stock (unit_type, stock),
  FOREIGN KEY (category_id)
    REFERENCES categories(id)
      ON DELETE SET NULL
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA DE CLIENTES
-- =====================================================
CREATE TABLE IF NOT EXISTS customers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) DEFAULT NULL UNIQUE,
  phone VARCHAR(20) DEFAULT NULL,
  document_type ENUM('DNI','CUIT','CUIL','PASAPORTE') DEFAULT 'DNI',
  document_number VARCHAR(20) DEFAULT NULL,
  address TEXT DEFAULT NULL,
  city VARCHAR(100) DEFAULT NULL,
  credit_limit DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  notes TEXT DEFAULT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_name (name),
  INDEX idx_email (email),
  INDEX idx_document (document_number),
  INDEX idx_active (active),
  UNIQUE KEY unique_document (document_type, document_number)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA DE SESIONES DE CAJA
-- =====================================================
CREATE TABLE IF NOT EXISTS cash_sessions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  opening_amount DECIMAL(10,2) NOT NULL,
  closing_amount DECIMAL(10,2) DEFAULT NULL,
  expected_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  difference DECIMAL(10,2) DEFAULT NULL,
  status ENUM('open','closed') NOT NULL DEFAULT 'open',
  opening_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  closing_date TIMESTAMP NULL DEFAULT NULL,
  opened_by INT NOT NULL,
  closed_by INT DEFAULT NULL,
  opening_notes TEXT DEFAULT NULL,
  closing_notes TEXT DEFAULT NULL,
  total_sales DECIMAL(10,2) DEFAULT 0.00,
  total_cash_sales DECIMAL(10,2) DEFAULT 0.00,
  total_card_sales DECIMAL(10,2) DEFAULT 0.00,
  total_transfer_sales DECIMAL(10,2) DEFAULT 0.00,
  total_credit_sales DECIMAL(10,2) DEFAULT 0.00,
  total_deposits DECIMAL(10,2) DEFAULT 0.00,
  total_withdrawals DECIMAL(10,2) DEFAULT 0.00,
  total_expenses DECIMAL(10,2) DEFAULT 0.00,
  sales_count INT DEFAULT 0,
  profit DECIMAL(10,2) DEFAULT 0.00,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_status (status),
  INDEX idx_opening_date (opening_date),
  INDEX idx_opened_by (opened_by),
  INDEX idx_closed_by (closed_by),
  FOREIGN KEY (opened_by)
    REFERENCES users(id)
      ON DELETE RESTRICT,
  FOREIGN KEY (closed_by)
    REFERENCES users(id)
      ON DELETE SET NULL
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA DE VENTAS (MÚLTIPLES MÉTODOS DE PAGO)
-- =====================================================
CREATE TABLE IF NOT EXISTS sales (
  id INT AUTO_INCREMENT PRIMARY KEY,
  subtotal DECIMAL(10,2) NOT NULL,
  discount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  tax DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  total DECIMAL(10,2) NOT NULL,
  payment_method ENUM(
    'efectivo','tarjeta_credito',
    'transferencia','cuenta_corriente',
    'multiple'
  ) NOT NULL,
  payment_methods JSON DEFAULT NULL
    COMMENT 'Array de métodos de pago múltiples',
  payment_data JSON DEFAULT NULL,
  customer_id INT DEFAULT NULL,
  notes TEXT DEFAULT NULL,
  status ENUM('completed','cancelled')
    NOT NULL DEFAULT 'completed',
  user_id INT DEFAULT NULL,
  cash_session_id INT DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_date (created_at),
  INDEX idx_status (status),
  INDEX idx_payment_method (payment_method),
  INDEX idx_customer (customer_id),
  INDEX idx_user (user_id),
  INDEX idx_cash_session (cash_session_id),
  INDEX idx_total (total),
  INDEX idx_sales_date_status (created_at, status),
  FOREIGN KEY (customer_id)
    REFERENCES customers(id)
      ON DELETE SET NULL,
  FOREIGN KEY (user_id)
    REFERENCES users(id)
      ON DELETE SET NULL,
  FOREIGN KEY (cash_session_id)
    REFERENCES cash_sessions(id)
      ON DELETE SET NULL
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci
  COMMENT='Tabla de ventas con soporte para múltiples métodos de pago';

-- =====================================================
-- TABLA DE ITEMS DE VENTA (CON SOPORTE PARA UNIDADES)
-- =====================================================
CREATE TABLE IF NOT EXISTS sale_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  sale_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity DECIMAL(10,3) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  unit_type ENUM('unidades', 'kg') DEFAULT 'unidades',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_sale (sale_id),
  INDEX idx_product (product_id),
  INDEX idx_unit_type (unit_type),
  FOREIGN KEY (sale_id)
    REFERENCES sales(id)
      ON DELETE CASCADE,
  FOREIGN KEY (product_id)
    REFERENCES products(id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA DE MOVIMIENTOS DE STOCK (CON SOPORTE PARA UNIDADES)
-- =====================================================
CREATE TABLE IF NOT EXISTS stock_movements (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  type ENUM('entrada','salida','ajuste') NOT NULL,
  quantity DECIMAL(10,3) NOT NULL,
  previous_stock DECIMAL(10,3) NOT NULL,
  new_stock DECIMAL(10,3) NOT NULL,
  reason VARCHAR(255) NOT NULL,
  user_id INT DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_product (product_id),
  INDEX idx_type (type),
  INDEX idx_date (created_at),
  INDEX idx_user (user_id),
  INDEX idx_stock_movements_product_date (product_id, created_at),
  FOREIGN KEY (product_id)
    REFERENCES products(id)
      ON DELETE CASCADE,
  FOREIGN KEY (user_id)
    REFERENCES users(id)
      ON DELETE SET NULL
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA DE TRANSACCIONES DE CLIENTES (CUENTA CORRIENTE)
-- =====================================================
CREATE TABLE IF NOT EXISTS customer_transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  type ENUM('venta','pago','ajuste_debito','ajuste_credito') NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  description VARCHAR(255) NOT NULL,
  reference VARCHAR(100) DEFAULT NULL,
  user_id INT DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_customer (customer_id),
  INDEX idx_type (type),
  INDEX idx_date (created_at),
  INDEX idx_user (user_id),
  INDEX idx_customer_transactions_customer_date (customer_id, created_at),
  FOREIGN KEY (customer_id)
    REFERENCES customers(id)
      ON DELETE CASCADE,
  FOREIGN KEY (user_id)
    REFERENCES users(id)
      ON DELETE SET NULL
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA DE MOVIMIENTOS DE CAJA
-- =====================================================
CREATE TABLE IF NOT EXISTS cash_movements (
  id INT AUTO_INCREMENT PRIMARY KEY,
  cash_session_id INT NOT NULL,
  type ENUM('opening','closing','sale','deposit','withdrawal','expense') NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  description VARCHAR(255) NOT NULL,
  reference VARCHAR(100) DEFAULT NULL,
  payment_method ENUM('efectivo','tarjeta_credito','transferencia','cuenta_corriente') DEFAULT NULL,
  sale_id INT DEFAULT NULL,
  user_id INT NOT NULL,
  profit DECIMAL(10,2) DEFAULT 0.00,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_cash_session (cash_session_id),
  INDEX idx_type (type),
  INDEX idx_date (created_at),
  INDEX idx_user (user_id),
  INDEX idx_sale (sale_id),
  INDEX idx_payment_method (payment_method),
  INDEX idx_cash_movements_session_date (cash_session_id, created_at),
  FOREIGN KEY (cash_session_id)
    REFERENCES cash_sessions(id)
      ON DELETE CASCADE,
  FOREIGN KEY (sale_id)
    REFERENCES sales(id)
      ON DELETE SET NULL,
  FOREIGN KEY (user_id)
    REFERENCES users(id)
      ON DELETE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA DE ARQUEOS DE CAJA
-- =====================================================
CREATE TABLE IF NOT EXISTS cash_counts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  cash_session_id INT NOT NULL,
  expected_amount DECIMAL(10,2) NOT NULL,
  counted_amount DECIMAL(10,2) NOT NULL,
  difference DECIMAL(10,2) NOT NULL,
  bills JSON NOT NULL,
  coins JSON NOT NULL,
  notes TEXT DEFAULT NULL,
  user_id INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_cash_session (cash_session_id),
  INDEX idx_user (user_id),
  INDEX idx_date (created_at),
  FOREIGN KEY (cash_session_id)
    REFERENCES cash_sessions(id)
      ON DELETE CASCADE,
  FOREIGN KEY (user_id)
    REFERENCES users(id)
      ON DELETE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TABLA DE CONFIGURACIÓN DE CAJA
-- =====================================================
CREATE TABLE IF NOT EXISTS cash_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  min_cash_amount DECIMAL(10,2) NOT NULL DEFAULT 2000.00,
  max_cash_amount DECIMAL(10,2) NOT NULL DEFAULT 20000.00,
  auto_close_time TIME DEFAULT '22:00:00',
  require_count_for_close BOOLEAN NOT NULL DEFAULT TRUE,
  allow_negative_cash BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- INSERTAR DATOS INICIALES
-- =====================================================

-- Insertar cliente "Consumidor Final" por defecto
INSERT INTO customers (
    name, email, phone,
    document_type, document_number,
    address, city,
    credit_limit, notes,
    active, created_at, updated_at
  ) VALUES (
    'Consumidor Final', NULL, NULL,
    'DNI', '00000000',
    NULL, NULL,
    0.00,
    'Cliente por defecto para ventas rápidas. No puede usar cuenta corriente.',
    TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
  )
  ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    notes = VALUES(notes),
    updated_at = CURRENT_TIMESTAMP;

-- Insertar configuración por defecto
INSERT INTO cash_settings (
  min_cash_amount, max_cash_amount,
  auto_close_time, require_count_for_close,
  allow_negative_cash
) VALUES (
  2000.00, 20000.00,
  '22:00:00', TRUE, FALSE
) ON DUPLICATE KEY UPDATE id = id;

-- Categorías de ejemplo
INSERT INTO categories (
  name, description, color, icon, active
) VALUES
  ('Bebidas',    'Bebidas y refrescos', '#3B82F6', '🥤', TRUE),
  ('Snacks',     'Aperitivos y golosinas', '#10B981', '🍿', TRUE),
  ('Lácteos',    'Productos lácteos',      '#F59E0B', '🥛', TRUE),
  ('Panadería',  'Pan y productos de panadería', '#EF4444', '🍞', TRUE),
  ('Carnes',     'Carnes y embutidos', '#DC2626', '🥩', TRUE),
  ('Verduras',   'Frutas y verduras', '#16A34A', '🥕', TRUE)
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Usuario administrador por defecto
INSERT INTO users (
  name, email, password, role, active
) VALUES (
  'Administrador', 'admin@sistema.com', 
  '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 
  'admin', TRUE
) ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Productos de ejemplo con diferentes unidades
INSERT INTO products (
  name, description, price, cost, stock, min_stock, unit_type, category_id, active
) VALUES
  ('Coca Cola 500ml', 'Gaseosa Coca Cola 500ml', 350.00, 200.00, 50, 10, 'unidades', 1, TRUE),
  ('Papas Fritas', 'Papas fritas sabor original', 280.00, 150.00, 30, 5, 'unidades', 2, TRUE),
  ('Leche Entera 1L', 'Leche entera larga vida', 420.00, 300.00, 25, 8, 'unidades', 3, TRUE),
  ('Pan Francés', 'Pan francés fresco', 180.00, 100.00, 20, 5, 'unidades', 4, TRUE),
  ('Carne Molida', 'Carne molida especial', 2800.00, 2200.00, 15.500, 2.000, 'kg', 5, TRUE),
  ('Tomates', 'Tomates frescos', 1200.00, 800.00, 8.750, 1.000, 'kg', 6, TRUE),
  ('Manzanas', 'Manzanas rojas', 1500.00, 1000.00, 12.250, 2.000, 'kg', 6, TRUE)
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- =====================================================
-- FUNCIONES PARA MÚLTIPLES MÉTODOS DE PAGO
-- =====================================================
DELIMITER //

CREATE FUNCTION GetPaymentMethodAmount(
    payment_methods_json JSON,
    method_name VARCHAR(50)
)
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE amount DECIMAL(10,2) DEFAULT 0.00;
    DECLARE i INT DEFAULT 0;
    DECLARE methods_count INT;

    IF payment_methods_json IS NULL THEN
        RETURN 0.00;
    END IF;

    SET methods_count = JSON_LENGTH(payment_methods_json);

    WHILE i < methods_count DO
        IF JSON_UNQUOTE(
             JSON_EXTRACT(
               payment_methods_json,
               CONCAT('$[', i, '].method')
             )
           ) = method_name THEN
            SET amount = amount +
              CAST(
                JSON_UNQUOTE(
                  JSON_EXTRACT(
                    payment_methods_json,
                    CONCAT('$[', i, '].amount')
                  )
                )
              AS DECIMAL(10,2)
              );
        END IF;
        SET i = i + 1;
    END WHILE;

    RETURN amount;
END //

-- Función para calcular ganancia de una venta
CREATE FUNCTION CalculateSaleProfit(sale_id_param INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE total_profit DECIMAL(10,2) DEFAULT 0.00;
    
    SELECT COALESCE(SUM((si.unit_price - p.cost) * si.quantity), 0.00)
    INTO total_profit
    FROM sale_items si
    JOIN products p ON si.product_id = p.id
    WHERE si.sale_id = sale_id_param;
    
    RETURN total_profit;
END //

DELIMITER ;

-- =====================================================
-- TRIGGERS PARA AUTOMATIZACIÓN (CORREGIDOS)
-- =====================================================

DELIMITER //

-- Trigger para actualizar stock al crear item de venta
CREATE TRIGGER after_sale_item_insert
AFTER INSERT ON sale_items
FOR EACH ROW
BEGIN
    DECLARE current_stock DECIMAL(10,3);
    DECLARE previous_stock DECIMAL(10,3);
    DECLARE sale_user_id INT;
    
    -- Obtener stock actual y usuario de la venta
    SELECT stock INTO current_stock FROM products WHERE id = NEW.product_id;
    SET previous_stock = current_stock;
    
    SELECT user_id INTO sale_user_id FROM sales WHERE id = NEW.sale_id;
    
    -- Actualizar stock del producto
    UPDATE products 
    SET stock = stock - NEW.quantity,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.product_id;
    
    -- Crear movimiento de stock
    INSERT INTO stock_movements (
        product_id, type, quantity, 
        previous_stock, new_stock, reason, user_id
    ) VALUES (
        NEW.product_id, 
        'salida', 
        NEW.quantity,
        previous_stock,
        previous_stock - NEW.quantity,
        CONCAT('Venta #', NEW.sale_id),
        sale_user_id
    );
END //

-- Trigger para actualizar totales de sesión de caja
CREATE TRIGGER after_cash_movement_insert
AFTER INSERT ON cash_movements
FOR EACH ROW
BEGIN
    DECLARE session_profit DECIMAL(10,2) DEFAULT 0.00;
    
    -- Si es una venta, calcular ganancia
    IF NEW.type = 'sale' AND NEW.sale_id IS NOT NULL THEN
        SET session_profit = CalculateSaleProfit(NEW.sale_id);
    END IF;
    
    -- Actualizar totales de la sesión
    UPDATE cash_sessions 
    SET 
        total_sales = total_sales + 
            CASE WHEN NEW.type = 'sale' THEN NEW.amount ELSE 0 END,
        total_cash_sales = total_cash_sales + 
            CASE WHEN NEW.type = 'sale' AND NEW.payment_method = 'efectivo' 
                 THEN NEW.amount ELSE 0 END,
        total_card_sales = total_card_sales + 
            CASE WHEN NEW.type = 'sale' AND NEW.payment_method = 'tarjeta_credito' 
                 THEN NEW.amount ELSE 0 END,
        total_transfer_sales = total_transfer_sales + 
            CASE WHEN NEW.type = 'sale' AND NEW.payment_method = 'transferencia' 
                 THEN NEW.amount ELSE 0 END,
        total_credit_sales = total_credit_sales + 
            CASE WHEN NEW.type = 'sale' AND NEW.payment_method = 'cuenta_corriente' 
                 THEN NEW.amount ELSE 0 END,
        total_deposits = total_deposits + 
            CASE WHEN NEW.type = 'deposit' THEN NEW.amount ELSE 0 END,
        total_withdrawals = total_withdrawals + 
            CASE WHEN NEW.type = 'withdrawal' THEN ABS(NEW.amount) ELSE 0 END,
        total_expenses = total_expenses + 
            CASE WHEN NEW.type = 'expense' THEN ABS(NEW.amount) ELSE 0 END,
        sales_count = sales_count + 
            CASE WHEN NEW.type = 'sale' THEN 1 ELSE 0 END,
        profit = profit + session_profit,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.cash_session_id;
END //

-- Trigger para establecer unit_type en sale_items (CORREGIDO)
CREATE TRIGGER before_sale_item_insert
BEFORE INSERT ON sale_items
FOR EACH ROW
BEGIN
    DECLARE product_unit_type ENUM('unidades', 'kg');
    
    -- Obtener el unit_type del producto
    SELECT unit_type INTO product_unit_type
    FROM products 
    WHERE id = NEW.product_id;
    
    -- Asignar el unit_type al item de venta
    SET NEW.unit_type = product_unit_type;
END //

DELIMITER ;

-- =====================================================
-- PROCEDIMIENTOS ALMACENADOS
-- =====================================================

DELIMITER //

-- Procedimiento para abrir caja
CREATE PROCEDURE OpenCashSession(
    IN p_opening_amount DECIMAL(10,2),
    IN p_user_id INT,
    IN p_notes TEXT
)
BEGIN
    DECLARE session_exists INT DEFAULT 0;
    DECLARE new_session_id INT;
    
    -- Verificar si ya hay una sesión abierta
    SELECT COUNT(*) INTO session_exists
    FROM cash_sessions 
    WHERE status = 'open';
    
    IF session_exists > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Ya existe una sesión de caja abierta';
    ELSE
        -- Crear nueva sesión
        INSERT INTO cash_sessions (
            opening_amount, opened_by, opening_notes
        ) VALUES (
            p_opening_amount, p_user_id, p_notes
        );
        
        SET new_session_id = LAST_INSERT_ID();
        
        -- Crear movimiento de apertura
        INSERT INTO cash_movements (
            cash_session_id, type, amount, description, user_id
        ) VALUES (
            new_session_id, 'opening', p_opening_amount, 
            'Apertura de caja', p_user_id
        );
        
        SELECT new_session_id as session_id, 'Caja abierta correctamente' as message;
    END IF;
END //

-- Procedimiento para cerrar caja
CREATE PROCEDURE CloseCashSession(
    IN p_session_id INT,
    IN p_closing_amount DECIMAL(10,2),
    IN p_user_id INT,
    IN p_notes TEXT
)
BEGIN
    DECLARE expected_amt DECIMAL(10,2);
    DECLARE difference_amt DECIMAL(10,2);
    
    -- Calcular monto esperado
    SELECT (opening_amount + total_cash_sales + total_deposits - total_withdrawals - total_expenses)
    INTO expected_amt
    FROM cash_sessions 
    WHERE id = p_session_id;
    
    SET difference_amt = p_closing_amount - expected_amt;
    
    -- Actualizar sesión
    UPDATE cash_sessions 
    SET 
        closing_amount = p_closing_amount,
        expected_amount = expected_amt,
        difference = difference_amt,
        status = 'closed',
        closing_date = CURRENT_TIMESTAMP,
        closed_by = p_user_id,
        closing_notes = p_notes
    WHERE id = p_session_id;
    
    -- Crear movimiento de cierre
    INSERT INTO cash_movements (
        cash_session_id, type, amount, description, user_id
    ) VALUES (
        p_session_id, 'closing', p_closing_amount, 
        'Cierre de caja', p_user_id
    );
    
    SELECT 'Caja cerrada correctamente' as message, difference_amt as difference;
END //

DELIMITER ;

-- =====================================================
-- VISTAS OPTIMIZADAS
-- =====================================================

-- Estado actual de la caja
CREATE OR REPLACE VIEW current_cash_status AS
SELECT 
  cs.*,
  u_open.name AS opened_by_name,
  u_close.name AS closed_by_name,
  (cs.opening_amount + cs.total_cash_sales + cs.total_deposits - cs.total_withdrawals - cs.total_expenses) AS calculated_amount
FROM cash_sessions cs
LEFT JOIN users u_open ON cs.opened_by = u_open.id
LEFT JOIN users u_close ON cs.closed_by = u_close.id
WHERE cs.status = 'open';

-- Productos con categoría y formato de stock
CREATE OR REPLACE VIEW products_with_category AS
SELECT 
  p.*,
  c.name AS category_name,
  c.color AS category_color,
  c.icon AS category_icon,
  CASE 
    WHEN p.stock <= p.min_stock THEN 'low'
    WHEN p.stock <= p.min_stock * 2 THEN 'medium'
    ELSE 'high'
  END AS stock_level,
  CASE 
    WHEN p.unit_type = 'kg' THEN CONCAT(FORMAT(p.stock, 3), ' kg')
    ELSE CONCAT(FORMAT(p.stock, 0), ' unidades')
  END AS formatted_stock
FROM products p
LEFT JOIN categories c ON p.category_id = c.id;

-- Balances de clientes
CREATE OR REPLACE VIEW customer_balances AS
SELECT 
  c.id,
  c.name,
  c.email,
  c.credit_limit,
  COALESCE(
    SUM(
      CASE 
        WHEN ct.type IN ('venta','ajuste_debito') THEN ct.amount 
        ELSE -ct.amount 
      END
    ), 0
  ) AS current_balance,
  COUNT(ct.id) AS total_transactions,
  MAX(ct.created_at) AS last_transaction_date
FROM customers c
LEFT JOIN customer_transactions ct 
  ON c.id = ct.customer_id
WHERE c.active = TRUE
GROUP BY c.id, c.name, c.email, c.credit_limit;

-- Estadísticas diarias de ventas con unidades
CREATE OR REPLACE VIEW daily_sales_stats AS
SELECT 
  DATE(s.created_at) AS sale_date,
  COUNT(*) AS total_sales,
  SUM(CASE WHEN s.status = 'completed' THEN s.total ELSE 0 END) AS total_revenue,
  SUM(CASE WHEN s.status = 'completed' THEN s.discount ELSE 0 END) AS total_discounts,
  AVG(CASE WHEN s.status = 'completed' THEN s.total ELSE NULL END) AS average_sale,
  COUNT(CASE WHEN s.status = 'cancelled' THEN 1 END) AS cancelled_sales,
  COUNT(CASE WHEN s.payment_method = 'multiple' THEN 1 END) AS multiple_payment_sales,
  SUM(
    CASE 
      WHEN s.status = 'completed' 
       AND (
         s.payment_method = 'cuenta_corriente' 
         OR JSON_SEARCH(s.payment_methods,'one','cuenta_corriente') IS NOT NULL
       ) 
      THEN s.total 
      ELSE 0 
    END
  ) AS credit_sales,
  SUM(
    CASE 
      WHEN s.status = 'completed' 
       AND (
         s.payment_method = 'efectivo' 
         OR JSON_SEARCH(s.payment_methods,'one','efectivo') IS NOT NULL
       ) 
      THEN s.total 
      ELSE 0 
    END
  ) AS cash_sales
FROM sales s
LEFT JOIN sale_items si ON s.id = si.sale_id
GROUP BY DATE(s.created_at)
ORDER BY DATE(s.created_at) DESC;

-- Reporte de productos más vendidos con unidades
CREATE OR REPLACE VIEW top_products_report AS
SELECT 
  p.id,
  p.name,
  p.unit_type,
  c.name AS category_name,
  COALESCE(SUM(si.quantity), 0) AS total_quantity_sold,
  COUNT(DISTINCT si.sale_id) AS times_sold,
  COALESCE(SUM(si.subtotal), 0) AS total_revenue,
  COALESCE(AVG(si.unit_price), 0) AS average_price,
  p.stock AS current_stock,
  CASE 
    WHEN p.unit_type = 'kg' THEN CONCAT(FORMAT(COALESCE(SUM(si.quantity), 0), 3), ' kg')
    ELSE CONCAT(FORMAT(COALESCE(SUM(si.quantity), 0), 0), ' unidades')
  END AS formatted_quantity_sold,
  CASE 
    WHEN p.unit_type = 'kg' THEN CONCAT(FORMAT(p.stock, 3), ' kg')
    ELSE CONCAT(FORMAT(p.stock, 0), ' unidades')
  END AS formatted_current_stock
FROM products p
LEFT JOIN sale_items si ON p.id = si.product_id
LEFT JOIN sales s ON si.sale_id = s.id AND s.status = 'completed'
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.active = TRUE
GROUP BY p.id, p.name, p.unit_type, c.name, p.stock
ORDER BY total_quantity_sold DESC;

-- Análisis detallado de métodos de pago
CREATE OR REPLACE VIEW detailed_payment_methods_report AS
SELECT 
  DATE(s.created_at) AS sale_date,
  s.id AS sale_id,
  s.total,
  s.payment_method,
  CASE 
    WHEN s.payment_method = 'efectivo' THEN s.total
    WHEN s.payment_method = 'multiple' THEN GetPaymentMethodAmount(s.payment_methods,'efectivo')
    ELSE 0.00
  END AS cash_amount,
  CASE 
    WHEN s.payment_method = 'tarjeta_credito' THEN s.total
    WHEN s.payment_method = 'multiple' THEN GetPaymentMethodAmount(s.payment_methods,'tarjeta_credito')
    ELSE 0.00
  END AS credit_card_amount,
  CASE 
    WHEN s.payment_method = 'transferencia' THEN s.total
    WHEN s.payment_method = 'multiple' THEN GetPaymentMethodAmount(s.payment_methods,'transferencia')
    ELSE 0.00
  END AS transfer_amount,
  CASE 
    WHEN s.payment_method = 'cuenta_corriente' THEN s.total
    WHEN s.payment_method = 'multiple' THEN GetPaymentMethodAmount(s.payment_methods,'cuenta_corriente')
    ELSE 0.00
  END AS credit_account_amount,
  c.name AS customer_name,
  u.name AS cashier_name,
  cs.id AS cash_session_id
FROM sales s
LEFT JOIN customers c ON s.customer_id = c.id
LEFT JOIN users u ON s.user_id = u.id
LEFT JOIN cash_sessions cs ON s.cash_session_id = cs.id
WHERE s.status = 'completed'
ORDER BY s.created_at DESC;

-- Historial completo de caja
CREATE OR REPLACE VIEW cash_history_view AS
SELECT 
  cs.id,
  cs.opening_amount,
  cs.closing_amount,
  cs.expected_amount,
  cs.difference,
  cs.status,
  cs.opening_date,
  cs.closing_date,
  cs.total_sales,
  cs.total_cash_sales,
  cs.total_card_sales,
  cs.total_transfer_sales,
  cs.total_credit_sales,
  cs.total_deposits,
  cs.total_withdrawals,
  cs.total_expenses,
  cs.sales_count,
  cs.profit,
  u_open.name AS opened_by_name,
  u_close.name AS closed_by_name,
  TIMESTAMPDIFF(HOUR, cs.opening_date, COALESCE(cs.closing_date, NOW())) AS hours_open
FROM cash_sessions cs
LEFT JOIN users u_open ON cs.opened_by = u_open.id
LEFT JOIN users u_close ON cs.closed_by = u_close.id
ORDER BY cs.opening_date DESC;

-- =====================================================
-- ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- =====================================================
CREATE INDEX idx_sales_payment_method_status ON sales(payment_method, status);
CREATE INDEX idx_sales_created_status ON sales(created_at, status);
CREATE INDEX idx_cash_sessions_status_date ON cash_sessions(status, opening_date);
CREATE INDEX idx_cash_movements_session_type ON cash_movements(cash_session_id, type);
CREATE INDEX idx_cash_counts_session ON cash_counts(cash_session_id);
CREATE INDEX idx_sale_items_unit_type ON sale_items(unit_type);
CREATE INDEX idx_products_unit_type ON products(unit_type);

-- =====================================================
-- FIN DEL SCRIPT COMPLETO CORREGIDO
-- =====================================================



-- Agregar columnas de cancelación a la tabla sales
ALTER TABLE sales 
ADD COLUMN cancelled_by INT DEFAULT NULL AFTER status,
ADD COLUMN cancelled_at TIMESTAMP NULL DEFAULT NULL AFTER cancelled_by,
ADD INDEX idx_cancelled_by (cancelled_by),
ADD FOREIGN KEY (cancelled_by) REFERENCES users(id) ON DELETE SET NULL;
