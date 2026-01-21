USE sakila;

-- Step 1: Create a View

CREATE VIEW customer_rental_info AS
SELECT c.customer_id, c.first_name, c.last_name, c.email, COUNT(r.customer_id) AS rental_count
FROM customer c
JOIN rental r
ON c.customer_id = r.customer_id
GROUP BY 
c.customer_id,
c.first_name,
c.last_name,
c.email
;

SELECT *
FROM customer_rental_info;

-- Step 2: Create a Temporary Table

CREATE TEMPORARY TABLE total_paid AS
SELECT c_r_i.customer_id, SUM(p.amount) AS total_paid
FROM payment p
JOIN customer_rental_info c_r_i
ON p.customer_id = c_r_i.customer_id
GROUP BY
c_r_i.customer_id
;

SELECT *
FROM total_paid;

-- Step 3: Create a CTE and the Customer Summary Report

WITH customer_rental_summary AS (
	SELECT c_r_i.customer_id, c_r_i.first_name, c_r_i.last_name, c_r_i.email, c_r_i.rental_count, t_p.total_paid
    FROM customer_rental_info c_r_i
    JOIN total_paid t_p
		ON c_r_i.customer_id = t_p.customer_id)
        
SELECT first_name, last_name, email, rental_count, total_paid,
ROUND(total_paid / NULLIF(rental_count, 0), 2) AS average_payment_per_rental
FROM customer_rental_summary
ORDER BY total_paid DESC;

