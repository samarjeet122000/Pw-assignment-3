SELECT customer_id, CONCAT(first_name, ' ', last_name) AS customer_name,
       amount, RANK() OVER (ORDER BY amount DESC) AS rank_by_amount
FROM (
    SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) AS amount
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id
) AS total_amount_per_customer;
SELECT film_id, title, rental_date, amount,
       SUM(amount) OVER (PARTITION BY film_id ORDER BY rental_date) AS cumulative_revenue
FROM (
    SELECT f.film_id, f.title, r.rental_date, p.amount
    FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN payment p ON r.rental_id = p.rental_id
) AS film_revenue;

SELECT category_id, film_id, title, rental_count,
       RANK() OVER (PARTITION BY category_id ORDER BY rental_count DESC) AS rank_in_category
FROM (
    SELECT fc.category_id, f.film_id, f.title, COUNT(r.rental_id) AS rental_count
    FROM film f
    JOIN film_category fc ON f.film_id = fc.film_id
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    GROUP BY fc.category_id, f.film_id, f.title
) AS category_film_rentals
WHERE rank_in_category <= 3;
SELECT customer_id, CONCAT(first_name, ' ', last_name) AS customer_name,
       rental_count, 
       rental_count - AVG(rental_count) OVER () AS diff_from_avg_rentals
FROM (
    SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) AS rental_count
    FROM customer c
    LEFT JOIN rental r ON c.customer_id = r.customer_id
    GROUP BY c.customer_id
) AS customer_rentals;
WITH MonthlyRevenue AS (
    SELECT
        DATE_FORMAT(payment_date, '%Y-%m') AS month,
        SUM(amount) AS total_revenue
    FROM
        payment
    GROUP BY
        DATE_FORMAT(payment_date, '%Y-%m')
)
SELECT
    month,
    total_revenue,
    SUM(total_revenue) OVER (ORDER BY month) AS cumulative_revenue
FROM
    MonthlyRevenue
ORDER BY
    month;
    WITH CustomerSpending AS (
    SELECT
        customer_id,
        SUM(amount) AS total_spending,
        RANK() OVER (ORDER BY SUM(amount) DESC) AS customer_rank
    FROM
        payment
    GROUP BY
        customer_id
)
SELECT
    customer_id,
    total_spending
FROM
    CustomerSpending
WHERE
    customer_rank <= (SELECT 0.2 * COUNT(DISTINCT customer_id) + 1 FROM CustomerSpending);
    WITH CategoryRentalCount AS (
    SELECT
        fc.category_id,
        COUNT(r.rental_id) AS rental_count,
        RANK() OVER (PARTITION BY fc.category_id ORDER BY COUNT(r.rental_id) DESC) AS rental_rank
    FROM
        film_category fc
    JOIN
        rental r ON fc.film_id = r.inventory_id
    GROUP BY
        fc.category_id
)
SELECT
    crc.category_id,
    crc.rental_count,
    SUM(crc.rental_count) OVER (ORDER BY crc.rental_rank) AS running_total
FROM
    CategoryRentalCount crc
ORDER BY
    crc.rental_rank;
    WITH FilmRentalInfo AS (
    SELECT
        fc.film_id,
        fc.category_id,
        COUNT(r.rental_id) AS rental_count,
        AVG(COUNT(r.rental_id)) OVER (PARTITION BY fc.category_id) AS avg_rental_count
    FROM
        film_category fc
    JOIN
        rental r ON fc.film_id = r.inventory_id
    GROUP BY
        fc.film_id, fc.category_id
)
SELECT
    fri.film_id,
    fri.category_id,
    fri.rental_count,
    fri.avg_rental_count
FROM
    FilmRentalInfo fri
WHERE
    fri.rental_count < fri.avg_rental_count;
    WITH MonthlyRevenue AS (
    SELECT
        DATE_FORMAT(payment_date, '%Y-%m') AS month,
        SUM(amount) AS total_revenue
    FROM
        payment
    GROUP BY
        DATE_FORMAT(payment_date, '%Y-%m')
)
SELECT
    month,
    total_revenue
FROM
    MonthlyRevenue
ORDER BY
    total_revenue DESC
LIMIT 5;
    








