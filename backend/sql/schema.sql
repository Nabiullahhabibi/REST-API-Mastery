CREATE DATABASE IF NOT EXISTS rest_api_mastery
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE rest_api_mastery;

CREATE TABLE IF NOT EXISTS products (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  description TEXT NULL,
  category VARCHAR(80) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  stock INT UNSIGNED NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT chk_products_price CHECK (price >= 0)
);

CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_created_at ON products(created_at);

INSERT INTO products (name, description, category, price, stock) VALUES
('iPhone 15', 'Apple smartphone demo product', 'Electronics', 799.00, 12),
('USB-C Charger', 'Fast charging adapter', 'Accessories', 24.99, 80),
('Wireless Headphones', 'Bluetooth over-ear headphones', 'Electronics', 89.50, 35),
('Mechanical Keyboard', 'Compact mechanical keyboard', 'Accessories', 69.00, 18),
('Laptop Stand', 'Adjustable aluminum stand', 'Office', 39.99, 25);
