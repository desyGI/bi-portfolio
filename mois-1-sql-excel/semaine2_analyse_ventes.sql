-- Mini-projet : Analyse des ventes (semaine 2)

-- 1. Chiffre d'affaires mensuel
WITH ca_mensuel AS (
    SELECT EXTRACT(YEAR FROM orders.order_date) AS annee,
           EXTRACT(MONTH FROM orders.order_date) AS mois,
           SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount)) AS chiffre_affaires
    FROM orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY EXTRACT(YEAR FROM orders.order_date), EXTRACT(MONTH FROM orders.order_date)
)
SELECT * FROM ca_mensuel
ORDER BY annee, mois;

-- 2. Chiffre d'affaires annuel par catégorie de produit
SELECT categories.category_name, EXTRACT(YEAR FROM orders.order_date) AS annee,
       SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount)) AS ca_cat
FROM orders
JOIN order_details ON orders.order_id = order_details.order_id
JOIN products ON order_details.product_id = products.product_id
JOIN categories ON products.category_id = categories.category_id
GROUP BY categories.category_name, EXTRACT(YEAR FROM orders.order_date)
ORDER BY annee, ca_cat DESC;

-- 3. Segmentation des clients (petit / moyen / gros)
WITH ca_client AS (
    SELECT customers.company_name,
           SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount)) AS total
    FROM customers
    JOIN orders ON customers.customer_id = orders.customer_id
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY customers.company_name
)
SELECT company_name,
       total,
       CASE
           WHEN total < 1000 THEN 'petit'
           WHEN total < 5000 THEN 'moyen'
           ELSE 'gros'
       END AS segment
FROM ca_client
ORDER BY total DESC;

-- 4. Panier moyen par client
WITH ventes_client AS (
    SELECT customers.company_name,
           SUM(order_details.unit_price * order_details.quantity * (1 - order_details.discount)) AS total,
           COUNT(DISTINCT orders.order_id) AS nb_commandes
    FROM customers
    JOIN orders ON customers.customer_id = orders.customer_id
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY customers.company_name
)
SELECT company_name,
       total,
       nb_commandes,
       total / nb_commandes AS panier_moyen
FROM ventes_client
ORDER BY panier_moyen DESC;

-- 5. Délai moyen de livraison par transporteur
SELECT shippers.company_name AS transporteur,
       AVG(orders.shipped_date - orders.order_date) AS delai_moyen_jours
FROM orders
JOIN shippers ON orders.ship_via = shippers.shipper_id
WHERE orders.shipped_date IS NOT NULL
GROUP BY shippers.company_name
ORDER BY delai_moyen_jours;

-- 6. Clients ayant passé plus d'une commande (fidélité)
WITH nb_commandes_client AS (
    SELECT customers.company_name, COUNT(orders.order_id) AS nb_commandes
    FROM customers
    JOIN orders ON customers.customer_id = orders.customer_id
    GROUP BY customers.company_name
)
SELECT * FROM nb_commandes_client
WHERE nb_commandes > 1
ORDER BY nb_commandes DESC;

-- 7. Détection de doublons (clients avec même nom d'entreprise et même ville)
WITH doublons_potentiels AS (
    SELECT company_name, city, COUNT(*) AS nb_lignes
    FROM customers
    GROUP BY company_name, city
)
SELECT * FROM doublons_potentiels
WHERE nb_lignes > 1;

-- 8. Contrôle qualité : nombre de NULL par colonne clé de la table orders
SELECT
    COUNT(*) AS total_lignes,
    COUNT(*) - COUNT(shipped_date) AS nb_null_shipped_date,
    COUNT(*) - COUNT(required_date) AS nb_null_required_date,
    COUNT(*) - COUNT(customer_id) AS nb_null_customer_id
FROM orders;
