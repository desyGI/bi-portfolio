-- Livrable de la semaine 1 : 10 questions métier sur la base Northwind

-- 1. Quels clients sont en France ?
SELECT company_name, contact_name, city
FROM customers
WHERE country = 'France';

-- 2. Quels sont les 10 produits les plus chers ?
SELECT product_name, unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 10;

-- 3. Combien de commandes chaque client a-t-il passées ?
SELECT customers.company_name, COUNT(orders.order_id) AS nb_commande
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.company_name
ORDER BY nb_commande DESC;

-- 4. Quel est le chiffre d'affaires par catégorie de produit ?
SELECT categories.category_name,
       SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount)) AS chiffre_affaire
FROM categories
JOIN products ON categories.category_id = products.category_id
JOIN order_details ON products.product_id = order_details.product_id
GROUP BY categories.category_name
ORDER BY chiffre_affaire DESC;

-- 5. Quels clients n'ont jamais commandé ?
SELECT customers.company_name
FROM customers
LEFT JOIN orders ON customers.customer_id = orders.customer_id
WHERE orders.order_id IS NULL;

-- 6. Combien de commandes chaque employé a-t-il gérées ?
SELECT employees.first_name, employees.last_name, COUNT(orders.order_id) AS nb_commandegere
FROM employees
JOIN orders ON employees.employee_id = orders.employee_id
GROUP BY employees.first_name, employees.last_name
ORDER BY nb_commandegere DESC;

-- 7. Quels produits ont un stock inférieur à leur seuil de réapprovisionnement ?
-- reorder_level est le seuil à partir duquel il faut recommander.
SELECT product_name, units_in_stock, reorder_level
FROM products
WHERE units_in_stock < reorder_level;

-- 8. Quel est le chiffre d'affaires par pays de livraison ?
SELECT orders.ship_country,
       SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount)) AS chiffre_affaires
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
GROUP BY orders.ship_country
ORDER BY chiffre_affaires DESC;

-- 9. Quelles catégories dépassent 100 000 de chiffre d'affaires ?
SELECT categories.category_name,
       SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount)) AS chiffre_affaires
FROM categories
JOIN products ON categories.category_id = products.category_id
JOIN order_details ON products.product_id = order_details.product_id
GROUP BY categories.category_name
HAVING SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount)) > 100000
ORDER BY chiffre_affaires DESC;

-- 10. Combien de commandes ont été livrées en retard ?
-- Version "combien" (nombre) :
SELECT COUNT(*) AS nb_commandes_en_retard
FROM orders
WHERE shipped_date > required_date;

-- Version détaillée (liste des commandes concernées) :
SELECT order_id, order_date, required_date, shipped_date
FROM orders
WHERE shipped_date > required_date;
