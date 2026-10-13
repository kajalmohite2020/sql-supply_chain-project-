CREATE DATABASE supply_chain_db;
USE supply_chain_db;
SHOW DATABASES;
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2),
    supplier_id INT,
    FOREIGN KEY (supplier_id)
        REFERENCES suppliers(supplier_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

CREATE TABLE inventory (
    product_id INT PRIMARY KEY,
    stock_qty INT,
    reorder_level INT,
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

CREATE TABLE shipments (
    shipment_id INT PRIMARY KEY,
    order_id INT,
    shipping_cost DECIMAL(10,2),
    promised_date DATE,
    delivery_date DATE,
    delivery_status VARCHAR(20),
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);

SHOW TABLES;

INSERT INTO suppliers VALUES
(1, 'TechSource', 'Pune'),
(2, 'Global Devices', 'Mumbai'),
(3, 'Smart Supply Co', 'Nashik');

INSERT INTO products VALUES
(101, 'Laptop', 'Electronics', 50000, 1),
(102, 'Mouse', 'Accessories', 500, 2),
(103, 'Keyboard', 'Accessories', 1200, 2),
(104, 'Monitor', 'Electronics', 12000, 3);

INSERT INTO customers VALUES
(1, 'Amit', 'Pune'),
(2, 'Priya', 'Mumbai'),
(3, 'Rahul', 'Nashik'),
(4, 'Sneha', 'Pune');

INSERT INTO orders VALUES
(1001, 1, '2026-01-05'),
(1002, 2, '2026-01-08'),
(1003, 3, '2026-02-10'),
(1004, 4, '2026-02-15'),
(1005, 1, '2026-03-01'),
(1006, 2, '2026-03-05');

INSERT INTO order_items VALUES
(1, 1001, 101, 2, 50000),
(2, 1001, 102, 3, 500),
(3, 1002, 103, 2, 1200),
(4, 1003, 102, 5, 500),
(5, 1004, 104, 1, 12000),
(6, 1005, 101, 1, 50000),
(7, 1006, 103, 3, 1200),
(8, 1006, 102, 2, 500);

INSERT INTO inventory VALUES
(101, 5, 3),
(102, 8, 10),
(103, 20, 5),
(104, 2, 5);

INSERT INTO shipments VALUES
(501, 1001, 500, '2026-01-10', '2026-01-09', 'On Time'),
(502, 1002, 200, '2026-01-12', '2026-01-15', 'Delayed'),
(503, 1003, 250, '2026-02-15', '2026-02-14', 'On Time'),
(504, 1004, 400, '2026-02-20', '2026-02-23', 'Delayed'),
(505, 1005, 500, '2026-03-05', '2026-03-05', 'On Time'),
(506, 1006, 200, '2026-03-10', '2026-03-09', 'On Time');

SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM shipments;

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT
    SUM(quantity * unit_price) AS total_revenue
FROM order_items;

SELECT
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY revenue DESC;

SELECT
    delivery_status,
    COUNT(*) AS total_shipments
FROM shipments
GROUP BY delivery_status;

SELECT
    ROUND(
        100.0 * SUM(
            CASE
                WHEN delivery_status = 'On Time'
                THEN 1 ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS on_time_percentage
FROM shipments;

SELECT
    ROUND(AVG(shipping_cost), 2) AS avg_shipping_cost
FROM shipments;

SELECT
    p.product_name,
    i.stock_qty,
    i.reorder_level
FROM products p
JOIN inventory i
    ON p.product_id = i.product_id
WHERE i.stock_qty <= i.reorder_level;

SELECT
    o.order_id,
    c.customer_name,
    s.promised_date,
    s.delivery_date,
    s.delivery_status
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN shipments s
    ON o.order_id = s.order_id
WHERE s.delivery_status = 'Delayed';

SELECT
    p.category,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC;

SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY order_month;

SELECT
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_orders DESC;

SELECT
    p.product_name,
    SUM(oi.quantity) AS total_quantity
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_quantity DESC;

SELECT
    order_id,
    DATEDIFF(delivery_date, promised_date)
        AS delay_days
FROM shipments
WHERE delivery_date > promised_date;

SELECT
    s.supplier_name,
    p.product_name,
    p.unit_price
FROM suppliers s
JOIN products p
    ON s.supplier_id = p.supplier_id
ORDER BY s.supplier_name;

SELECT
    product_name,
    unit_price
FROM products
WHERE unit_price > (
    SELECT AVG(unit_price)
    FROM products
);

SELECT
    o.order_id,
    SUM(oi.quantity * oi.unit_price) AS order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY o.order_id
ORDER BY order_value DESC;

SELECT
    s.supplier_name,
    COUNT(p.product_id) AS product_count
FROM suppliers s
LEFT JOIN products p
    ON s.supplier_id = p.supplier_id
GROUP BY s.supplier_id, s.supplier_name;

SELECT
    delivery_status,
    ROUND(AVG(shipping_cost), 2) AS avg_cost
FROM shipments
GROUP BY delivery_status;

SELECT
    p.product_name,
    i.stock_qty,
    i.reorder_level,
    CASE
        WHEN i.stock_qty <= i.reorder_level
            THEN 'Reorder Required'
        ELSE 'Stock Available'
    END AS stock_status
FROM products p
JOIN inventory i
    ON p.product_id = i.product_id;
    
    SELECT
    COUNT(*) AS total_shipments,
    SUM(delivery_status = 'Delayed') AS delayed_shipments,
    SUM(delivery_status = 'On Time') AS on_time_shipments,
    ROUND(AVG(shipping_cost), 2) AS avg_shipping_cost
FROM shipments;

SELECT
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY revenue DESC
LIMIT 3;

SELECT
    c.customer_name,
    SUM(oi.quantity * oi.unit_price) AS total_spending
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC;

SELECT
    p.product_name
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

SELECT
    s.supplier_name,
    SUM(oi.quantity * oi.unit_price) AS revenue
FROM suppliers s
JOIN products p ON s.supplier_id = p.supplier_id
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY s.supplier_id, s.supplier_name
ORDER BY revenue DESC;

SELECT
    DATE_FORMAT(promised_date, '%Y-%m') AS delivery_month,
    COUNT(*) AS total_shipments,
    SUM(delivery_status = 'Delayed') AS delayed_shipments
FROM shipments
GROUP BY DATE_FORMAT(promised_date, '%Y-%m')
ORDER BY delivery_month;

SELECT
    ROUND(AVG(DATEDIFF(s.delivery_date, o.order_date)), 2)
        AS avg_delivery_days
FROM orders o
JOIN shipments s ON o.order_id = s.order_id;

SELECT
    c.city,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.city
ORDER BY total_revenue DESC;

SELECT
    p.category,
    SUM(oi.quantity * oi.unit_price) AS revenue,
    ROUND(
        100.0 * SUM(oi.quantity * oi.unit_price) /
        (SELECT SUM(quantity * unit_price) FROM order_items),
        2
    ) AS revenue_percentage
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC;

SELECT
    shipment_id,
    order_id,
    DATEDIFF(delivery_date, promised_date) AS delay_days
FROM shipments
WHERE DATEDIFF(delivery_date, promised_date) > 1;

SELECT
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (SELECT ROUND(SUM(quantity * unit_price), 2)
     FROM order_items) AS total_revenue,
    (SELECT COUNT(*) FROM shipments) AS total_shipments,
    (SELECT COUNT(*) FROM shipments
     WHERE delivery_status = 'Delayed') AS delayed_shipments,
    (SELECT ROUND(
        100.0 * SUM(delivery_status = 'On Time') / COUNT(*), 2
     )
     FROM shipments) AS on_time_percentage,
    (SELECT ROUND(AVG(shipping_cost), 2)
     FROM shipments) AS avg_shipping_cost;
     
     