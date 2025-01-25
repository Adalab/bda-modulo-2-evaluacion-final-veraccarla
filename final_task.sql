-- FINAL TASK SQL MODULE

-- Schema:
USE sakila;

-- Tables:
SELECT *
FROM actor;

SELECT *
FROM customer;

SELECT *
FROM rental;

SELECT *
FROM film;

SELECT *
FROM category;

SELECT *
FROM film_category;

SELECT *
FROM inventory;

SELECT *
FROM film_actor;

-- 1. Selecciona todos los nombres de las películas sin que aparezcan duplicados.
SELECT DISTINCT title
FROM film;

-- 2. Muestra los nombres de todas las películas que tengan una clasificación de "PG-13".
SELECT title
FROM film
WHERE rating = 'PG-13';

-- también podríamos hacer:
SELECT title
FROM film
WHERE rating LIKE 'PG-13';

-- 3. Encuentra el título y la descripción de todas las películas que contengan la palabra "amazing" en su descripción.
SELECT
	title,
	description
FROM film
WHERE description LIKE '%amazing%';

-- 4. Encuentra el título de todas las películas que tengan una duración mayor a 120 minutos.
SELECT title
FROM film
WHERE length > 120;

-- 5. Encuentra los nombres de todos los actores, muéstralos en una sola columna que se llame nombre_actor y contenga nombre y apellido.
SELECT CONCAT(first_name, ' ', last_name) as actor_full_name
FROM actor;

-- 6. Encuentra el nombre y apellido de los actores que tengan "Gibson" en su apellido.
SELECT CONCAT(first_name, ' ', last_name) as actor_full_name
FROM actor
WHERE last_name = 'Gibson';

-- 7. Encuentra los nombres de los actores que tengan un actor_id entre 10 y 20.
SELECT first_name AS actor_name
FROM actor
WHERE actor_id BETWEEN 10 AND 20;

-- 8. Encuentra el título de las películas en la tabla film que no tengan clasificacion "R" ni "PG-13".
SELECT title, rating
FROM film
WHERE rating NOT IN ('R', 'PG-13');

-- 9. Encuentra la cantidad total de películas en cada clasificación de la tabla film y muestra la clasificación junto con el recuento.
SELECT
	rating,
	COUNT(film_id) AS film_count
FROM film
GROUP BY rating
ORDER BY film_count DESC;

-- 10. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente, su nombre y apellido junto con 
-- la cantidad de películas alquiladas.
SELECT
	COUNT(*) AS film_count_by_customer, -- por si hubiese nulos, lo que quiero es que me cuente todas las filas (no me lo cuenta de una tabla concreta, sino el resultado); el orden en el que sucede sería: INNER JOIN => GROUP BY => COUNT(*)
    c.customer_id,
    c.first_name,
    c.last_name
FROM rental r
INNER JOIN customer c
ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name;

-- 11. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la categoría junto con el recuento de alquileres.
SELECT 
	c.name AS category_name,
    COUNT(r.rental_id) AS film_rental_count
FROM category c
INNER JOIN film_category fc
ON c.category_id = fc.category_id
INNER JOIN inventory i
ON fc.film_id = i.film_id
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY c.name;

-- 12. Encuentra el promedio de duración de las películas para cada clasificación de la tabla film y muestra la clasificación junto con el promedio de duración.
SELECT
	rating AS film_rating,
	AVG(film.length) AS film_average_length
FROM film
GROUP BY rating
ORDER BY film_average_length DESC;

-- 13. Encuentra el nombre y apellido de los actores que aparecen en la película con title "Indian Love".
SELECT 
	a.first_name,
    a.last_name
FROM actor a
INNER JOIN film_actor fa
ON a.actor_id = fa.actor_id
INNER JOIN film f
ON fa.film_id = f.film_id
WHERE f.title = 'Indian Love';

-- 14. Muestra el título de todas las películas que contengan la palabra "dog" o "cat" en su descripción.
SELECT title
FROM film
WHERE description LIKE '%dog%' OR description LIKE '%cat%';

-- => puedo comprobar el número de resultados haciendo lo mismo pero con REGEXP:
SELECT title
FROM film
WHERE description REGEXP 'dog|cat';

-- 15. Hay algún actor o actriz que no aparezca en ninguna película en la tabla film_actor.
SELECT 
	CONCAT(a.first_name, ' ', a.last_name) as actor_full_name
FROM actor a
WHERE NOT EXISTS (
	SELECT fa.film_id
    FROM film_actor fa
    WHERE a.actor_id = fa.actor_id
    )
;

-- Sería lo mismo que:
SELECT 
	CONCAT(a.first_name, ' ', a.last_name) as actor_full_name
FROM actor a
WHERE a.actor_id NOT IN (
	SELECT fa.actor_id
    FROM film_actor fa
    )
;

-- Si quisiera comprobar que es definitivamente ninguno:
SELECT COUNT(DISTINCT a.actor_id) AS count_actors
FROM actor a
WHERE a.actor_id NOT IN (
	SELECT fa.actor_id
    FROM film_actor fa
    )
;

-- También podría utilizar un LEFT JOIN => quiero saber si hay "actor_id" que sean NULL en la tabla secundaria film_actor:
SELECT 
	CONCAT(a.first_name, ' ', a.last_name) AS actor_full_name,
    fa.film_id
FROM actor a
LEFT JOIN film_actor fa
ON a.actor_id = fa.actor_id
WHERE fa.actor_id IS NULL; -- los filtro directamente por "NULL" para no ir uno por uno => el resultado es ninguno en este caso

-- Comentario: me devuelve todas las filas de la tabla principal (actor) y las coincidentes con la secundaria (film_actor) si las hubiese
-- a nivel de actor_id (y si no las hubiese, me mostraría los NULL en film_actor)


-- 16. Encuentra el título de todas las películas que fueron lanzadas entre el año 2005 y 2010.
SELECT title
FROM film
WHERE release_year BETWEEN 2005 AND 2010;

-- 17. Encuentra el título de todas las películas que son de la misma categoría que "Family".
SELECT f.title
FROM film f
INNER JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category c
ON fc.category_id = c.category_id
WHERE c.name = 'Family';

-- Lo mismo sería:
SELECT f.title
FROM film f
INNER JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category c
ON fc.category_id = c.category_id
WHERE c.name LIKE 'Family';

-- 18. Muestra el nombre y apellido de los actores que aparecen en más de 10 películas.
SELECT 
	a.first_name,
    a.last_name
FROM actor a
INNER JOIN film_actor fa
ON a.actor_id = fa.actor_id
GROUP BY a.first_name, a.last_name
HAVING COUNT(fa.film_id) > 10;

-- 19. Encuentra el título de todas las películas que son "R" y tienen una duración mayor a 2 horas en la tabla film.
SELECT title
FROM film
WHERE rating = 'R' AND length > 120;

-- 20. Encuentra las categorías de películas que tienen un promedio de duración superior a 120 minutos 
-- y muestra el nombre de la categoría junto con el promedio de duración.
SELECT 
	c.name,
    AVG(f.length) AS average_film_length
FROM category c
INNER JOIN film_category fc
ON c.category_id = fc.category_id
INNER JOIN film f
ON fc.film_id = f.film_id
GROUP BY c.name
HAVING average_film_length > 120;

-- 21. Encuentra los actores que han actuado en al menos 5 películas y muestra el nombre del actor junto con la cantidad de películas en las que han actuado.
SELECT 
	a.first_name AS actor_name,
    COUNT(fa.film_id) AS film_count
FROM actor a
INNER JOIN film_actor fa
ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name -- tener cuidado con los GROUP BY (siempre lo mismo que en SELECT)
HAVING film_count >= 5;

-- 22. Encuentra el título de todas las películas que fueron alquiladas durante más de 5 días. 
-- Utiliza una subconsulta para encontrar los rental_ids con una duración superior a 5 días y luego 
-- selecciona las películas correspondientes. Pista: Usamos DATEDIFF para calcular la diferencia entre 
-- una fecha y otra, ej: DATEDIFF(fecha_inicial, fecha_final)
SELECT title
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
WHERE r.rental_id IN (
	SELECT r.rental_id
    FROM rental r
    WHERE DATEDIFF(return_date,rental_date) > 5
    )
;

-- Para comprobar esto, ejecuto la subconsulta de manera individual para ver si efectivamente son rental_id de películas alquiladas durante más de 5 días:
SELECT 
	r.rental_id,
	DATEDIFF(return_date,rental_date) AS rental_time
FROM rental r
HAVING rental_time > 5;

-- 23. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría "Horror". 
-- Utiliza una subconsulta para encontrar los actores que han actuado en películas de la categoría "Horror" y luego exclúyelos 
-- de la lista de actores.
SELECT
	a.first_name,
    a.last_name
FROM actor a
WHERE a.actor_id NOT IN (
	SELECT fa.actor_id
    FROM film_actor fa
    INNER JOIN film_category fc
    ON fa.film_id = fc.film_id
    INNER JOIN category c
    ON fc.category_id = c.category_id
    WHERE c.name =  'Horror'
    )
;

-- Otra forma de hacerlo usando subconsultas correlacionadas sería:
SELECT
	a.first_name,
    a.last_name
FROM actor a
WHERE a.actor_id NOT IN (
	SELECT fa.actor_id
    FROM film_actor fa
    WHERE fa.film_id IN (
		SELECT fc.film_id
        FROM film_category fc
        WHERE fc.category_id IN (
			SELECT c.category_id
            FROM category c
            WHERE c.name = 'Horror'
            )
		)
	)
;

-- 24. BONUS: Encuentra el título de las películas que son comedias y 
-- tienen una duración mayor a 180 minutos en la tabla film con subconsultas.
SELECT title AS film_title
FROM film f
WHERE f.film_id IN (
	SELECT fc.film_id
    FROM film_category fc
    WHERE fc.category_id IN (
		SELECT c.category_id
        FROM category c
        WHERE c.name = 'Comedy'
		)
    )
AND f.length > 180;

-- También podría hacerlo con INNER JOIN:
SELECT title AS film_title
FROM film f
INNER JOIN film_category fc
ON f.film_id = fc.film_id
INNER JOIN category c
ON fc.category_id = c.category_id
WHERE c.name = 'Comedy' AND f.length > 180;

-- 25. BONUS: Encuentra todos los actores que han actuado juntos en al menos una película. 
-- La consulta debe mostrar el nombre y apellido de los actores y el número de películas en las que han actuado juntos. 
-- Pista: Podemos hacer un JOIN de una tabla consigo misma, poniendole un alias diferente.
SELECT
	CONCAT(a1.first_name, ' ', a1.last_name) AS actor_1,
    CONCAT(a2.first_name, ' ', a2.last_name) AS actor_2,
	COUNT(DISTINCT fa1.film_id) AS film_count
FROM actor a1
INNER JOIN film_actor fa1
ON a1.actor_id = fa1.actor_id
INNER JOIN film_actor fa2
ON fa1.film_id = fa2.film_id
INNER JOIN actor a2
ON fa2.actor_id = a2.actor_id
WHERE a1.actor_id < a2.actor_id -- para evitar que el mismo par de actores me genere el resultado duplicado en ambos sentidos (me garantizaría que el primer actor del par siempre sea el de menor ID y que no se duplique cuando se compare al segundo actor con el mismo; por ejemplo que  se genere un par 1, 2 pero ya luego no 2, 1)
GROUP BY a1.actor_id, a2.actor_id
HAVING film_count >= 1;

-- Con CTE's:
WITH actors_films AS ( -- Primero, creamos una tabla temporal que muestre qué actores han participado en qué películas
	SELECT
		fa.actor_id,
        fa.film_id
	FROM film_actor fa
),

 actor_pairs AS ( -- ahora hacemos el SELF JOIN utilizando el anterior CTE => obtendremos las combinaciones de actores que han trabajado juntos en la misma peli (y volvemos a evitar los duplicados)
	SELECT 
		af1.actor_id AS actor_1,
        af2.actor_id AS actor_2,
        af1.film_id
	FROM actors_films af1
    INNER JOIN actors_films af2
    ON af1.film_id = af2.film_id
    WHERE af1.actor_id < af2.actor_id
)
SELECT -- agrupamos y filtramos
	CONCAT(a1.first_name, ' ', a1.last_name) AS actor_1,
    CONCAT(a2.first_name, ' ', a2.last_name) AS actor_2,
    COUNT(DISTINCT ap.film_id) AS film_count
FROM actor_pairs ap
INNER JOIN actor a1
ON ap.actor_1 = a1.actor_id
INNER JOIN actor a2
ON ap.actor_2 = a2.actor_id
GROUP BY ap.actor_1, ap.actor_2, a1.first_name, a1.last_name, a2.first_name, a2.last_name
HAVING COUNT(DISTINCT ap.film_id) >= 1;
-- No da el mismo resultado