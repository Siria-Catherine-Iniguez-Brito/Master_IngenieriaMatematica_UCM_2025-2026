/* Parte 2 - Ejercicio 4: Consultas*/

/* PREGUNTA 1 */
SELECT accion.id_contenido, COUNT(*) AS vistos_totales 
FROM accion 
WHERE accion.visto = TRUE
GROUP BY accion.id_contenido 
ORDER BY vistos_totales DESC
LIMIT 10;

-- Version optimizada con indice
CREATE INDEX idx_visto_idcont ON accion (visto, id_contenido);
SELECT 
    accion.id_contenido, COUNT(*) AS vistos_totales
FROM accion
JOIN contenido ON accion.id_contenido = contenido.id
WHERE accion.visto = TRUE
GROUP BY accion.id_contenido
ORDER BY vistos_totales DESC
LIMIT 10;

/* PREGUNTA 2 */
SELECT accion.id_contenido, AVG(accion.puntuacion) AS puntuacion_media 
FROM accion 
WHERE accion.puntuacion IS NOT NULL 
GROUP BY accion.id_contenido HAVING COUNT(accion.puntuacion) >= 50 
ORDER BY puntuacion_media DESC
LIMIT 10;

/* PREGUNTA 3 */ 
SELECT 
    id_contenido, 
    STDDEV_POP(puntuacion) AS desviacion, 
    COUNT(puntuacion) AS n_votos
FROM accion 
WHERE puntuacion IS NOT NULL 
GROUP BY id_contenido 
HAVING n_votos >= 50
ORDER BY desviacion DESC
LIMIT 10;


/* PREGUNTA 4 */
SELECT  usuario.email, usuario.nombre 
FROM usuario
WHERE DATE_ADD(fecha_adquisicion, INTERVAL 30 DAY) >= (SELECT MAX(fecha_adquisicion) FROM usuario);

/* PREGUNTA 5 */ 
SELECT usuario.email, usuario.nombre, COUNT(accion.favorito) AS n_favoritos 
FROM accion 
JOIN usuario ON accion.id_usuario = usuario.email
WHERE accion.favorito = TRUE
GROUP BY accion.id_usuario HAVING n_favoritos > 100; 

-- Primer intento de optimizacion sin indices
SELECT usuario.email, usuario.nombre, top_favoritos.n_favoritos FROM 
usuario JOIN ( 
	SELECT accion.id_usuario, COUNT(*) AS n_favoritos  FROM 
    accion WHERE accion.favorito = TRUE
    GROUP BY accion.id_usuario HAVING n_favoritos > 100)  AS top_favoritos
    ON top_favoritos.id_usuario = usuario.email; 

-- Version optimizada con indices 
CREATE INDEX idx_accion_favorito_usuario ON accion(favorito, id_usuario);
SELECT u.email, u.nombre, top_favoritos.n_favoritos 
FROM usuario u
INNER JOIN ( 
    SELECT id_usuario, COUNT(*) AS n_favoritos 
    FROM accion 
    WHERE favorito = 1  
    GROUP BY id_usuario 
    HAVING n_favoritos > 100
) AS top_favoritos ON top_favoritos.id_usuario = u.email;


/* PREGUNTA 6 */
SELECT 
    contenido.genero, 
    AVG(accion.puntuacion) AS media_genero
FROM contenido
JOIN accion ON contenido.id = accion.id_contenido
WHERE accion.puntuacion IS NOT NULL
GROUP BY contenido.genero;


 /* PREGUNTA 7 */
-- Justificacion: Suponiendo que visto se considera si lo vio por completo
 SELECT 
    usuario.nombre, 
    accion.id_usuario, 
    COUNT(*) AS n_vistos 
FROM accion 
JOIN usuario ON accion.id_usuario = usuario.email 
WHERE accion.visto = TRUE 
GROUP BY accion.id_usuario, usuario.nombre
ORDER BY n_vistos DESC 
LIMIT 20;

-- Version optimizada sin el join 
SELECT accion.id_usuario, COUNT(*) AS n_vistos FROM
accion WHERE visto = TRUE 
GROUP BY accion.id_usuario 
ORDER BY  n_vistos DESC 
LIMIT 20;   


-- Version optimizada sin join y con un indice
CREATE INDEX idx_usuario_visto ON accion(id_usuario, visto);
SELECT id_usuario, COUNT(id_usuario) AS n_vistos 
FROM accion USE INDEX (idx_usuario_visto)
WHERE visto = 1
GROUP BY id_usuario
ORDER BY n_vistos DESC
LIMIT 20;   



/*PREGUNTA 8*/ 
-- email de un usuario para la BBDD de 6 meses 
SET @mi_email = 'user10074_kcespedes@stream.com'; 

-- email de un usuario para la BBDD de 1 ano
SET @mi_email = 'user10008_lara76@stream.com';

SELECT 
    accion.id_contenido, 
    COUNT(*) AS relevancia
FROM accion 
JOIN seguir ON accion.id_usuario = seguir.id_usuario_seguido
WHERE accion.favorito = TRUE 
    AND seguir.id_usuario_seguidor = @mi_email
    AND accion.id_contenido NOT IN (
        SELECT id_contenido 
        FROM accion 
        WHERE id_usuario = @mi_email AND visto = TRUE
    )
GROUP BY accion.id_contenido 
ORDER BY relevancia DESC 
LIMIT 20;

/*PREGUNTA 9*/
-- email de un usuario para la BBDD de 6 meses  
SET @email_9 = 'user1_wilfredoperez@stream.com'; 

-- email de un usuario para la BBDD de 1 ano
SET @email_9 = 'user10008_lara76@stream.com';
SELECT  a2.id_usuario AS usuario2, COUNT(*) AS favoritos_comunes 
FROM accion AS a1 
JOIN accion AS a2 ON a1.id_contenido = a2.id_contenido
WHERE a1.id_usuario = @email_9 
	AND a1.favorito = TRUE 
    AND a1.id_usuario != a2.id_usuario
    AND a2.favorito = TRUE 
GROUP BY a2.id_usuario 
ORDER BY favoritos_comunes DESC;

/*PREGUNTA 10*/
SET @id_plan = 2;
SELECT accion.id_usuario
FROM accion
JOIN disponible ON accion.id_contenido = disponible.id_contenido
WHERE disponible.id_plan =  @id_plan 
  AND accion.visto = 1          
GROUP BY accion.id_usuario
HAVING COUNT(DISTINCT accion.id_contenido) = 
		(SELECT COUNT(id_contenido)            
		FROM disponible
		WHERE id_plan =  @id_plan);  


/*PREGUNTA 11*/
SELECT contenido.id
FROM contenido 
WHERE NOT EXISTS (
    SELECT 1 
    FROM accion  
    WHERE accion.id_contenido = contenido.id 
      AND accion.visto = 1);


/*PREGUNTA 12*/
SELECT accion.id_contenido 
FROM accion 
WHERE accion.visto = 1
GROUP BY id_contenido HAVING COUNT(DISTINCT accion.id_usuario) = (SELECT COUNT(*) FROM usuario); 

/*PREGUNTA 13*/
SELECT usuario.email, usuario.nombre
FROM usuario 
LEFT JOIN accion ON usuario.email = accion.id_usuario AND accion.puntuacion IS NOT NULL
WHERE accion.id_usuario IS NULL;

/* Pregunta 14*/
SELECT id_contenido, COUNT(id_usuario) as veces_abandonado
FROM accion
WHERE momento_parada IS NOT NULL AND visto = 0
GROUP BY id_contenido
ORDER BY veces_abandonado DESC;

/*Pregunta 15*/
SELECT id_contenido, 
       SUM(CASE WHEN visto = 1 THEN 1 ELSE 0 END) 
       / NULLIF(SUM(CASE WHEN visto = 1 OR momento_parada IS NOT NULL THEN 1 ELSE 0 END), 0) as ratio_finalizacion
FROM accion
GROUP BY id_contenido;

/* Pregunta 16*/
-- Justificación: Usamos una CTE para rankear los géneros por usuario.
WITH GeneroUsuario AS (
    SELECT a.id_usuario, c.genero, COUNT(*) as total,
           RANK() OVER(PARTITION BY a.id_usuario ORDER BY COUNT(*) DESC) as rnk
    FROM accion a
    JOIN contenido c ON a.id_contenido = c.id
    WHERE a.visto = 1
    GROUP BY a.id_usuario, c.genero
)
SELECT id_usuario, genero FROM GeneroUsuario WHERE rnk = 1;

/*Pregunta 17*/
SELECT a.id_usuario
FROM accion a
JOIN contenido c ON a.id_contenido = c.id
WHERE a.visto = 1
GROUP BY a.id_usuario
HAVING COUNT(DISTINCT c.genero) = 1;

/*Pregunta 18*/ 
SELECT a.id_contenido, AVG(a.puntuacion) as media_contenido
FROM accion a
CROSS JOIN (SELECT AVG(puntuacion) as global_avg 
			FROM accion 
			WHERE puntuacion IS NOT NULL) as m
WHERE a.puntuacion IS NOT NULL
GROUP BY a.id_contenido
HAVING media_contenido > MAX(m.global_avg);

/*Pregunta 19*/
SELECT r.id_actor, act.nombre, COUNT(DISTINCT a.id_usuario) as espectadores
FROM reparto_peli r
JOIN accion a ON r.id_pelicula = a.id_contenido
JOIN actor act ON r.id_actor = act.id
WHERE a.visto = 1
GROUP BY r.id_actor, act.nombre
ORDER BY espectadores DESC;

/* Pregunta 20*/
SELECT c.id_serie, COUNT(DISTINCT a.id_usuario) as espectadores_serie
FROM capitulo c
JOIN accion a ON c.id = a.id_contenido
where a.visto = 1
GROUP BY c.id_serie
ORDER BY espectadores_serie DESC;

/* Pregunta 21*/
SELECT s.id_usuario_seguidor, s.id_usuario_seguido, COUNT(*) as favoritos_comunes
FROM seguir s
INNER JOIN accion a1 ON s.id_usuario_seguidor = a1.id_usuario 
INNER JOIN accion a2 ON s.id_usuario_seguido = a2.id_usuario
WHERE a1.favorito = TRUE AND a2.favorito = TRUE AND a1.id_contenido = a2.id_contenido
GROUP BY s.id_usuario_seguidor, s.id_usuario_seguido
HAVING favoritos_comunes >= 20;

/* Pregunta 22*/
-- Definimos el usuario para la consulta
-- email de un usuario para la BBDD de 6 meses 
SELECT email INTO @id_usuario_dado FROM usuario WHERE email = 'user0_32831c@stream.com' LIMIT 1;

-- email de un usuario para la BBDD de 1 ano
SELECT email INTO @id_usuario_dado FROM usuario WHERE email = 'user10008_lara76@stream.com' LIMIT 1;

-- 1. Identificamos el género con más contenidos finalizados (visto = 1)
WITH GeneroMasVisto AS (SELECT c.genero
						FROM accion a
						JOIN contenido c ON a.id_contenido = c.id
						WHERE a.id_usuario = @id_usuario_dado
                        AND (a.visto = 1 OR a.momento_parada IS NOT NULL)
						GROUP BY c.genero
						ORDER BY COUNT(*) DESC
						LIMIT 1)

SELECT c.id, c.genero, COALESCE(AVG(a_media.puntuacion), 0) as puntuacion_media
FROM contenido c
-- Unimos con accion solo para calcular la media de los contenidos del género elegido
LEFT JOIN accion a_media ON c.id = a_media.id_contenido AND a_media.puntuacion IS NOT NULL
-- Usamos un LEFT JOIN para excluir lo que el usuario ya vio (Más eficiente que NOT IN)
LEFT JOIN accion a_visto ON c.id = a_visto.id_contenido AND a_visto.id_usuario = @id_usuario_dado
WHERE c.genero = (SELECT genero FROM GeneroMasVisto)
  AND (a_visto.id_contenido IS NULL OR (a_visto.visto = 0 AND a_visto.momento_parada IS NULL))
GROUP BY c.id, c.genero
ORDER BY puntuacion_media DESC
LIMIT 20;


/* Pregunta 23*/
SELECT id_serie, COUNT(DISTINCT rc.id_actor) as num_actores
FROM capitulo cap
JOIN reparto_cap rc ON cap.id = rc.id_capitulo
GROUP BY id_serie
ORDER BY num_actores DESC;

/* Pregunta 24*/
WITH ActorContenido AS (
    SELECT id_actor, id_pelicula as id_cont FROM reparto_peli
    UNION
    SELECT id_actor, id_capitulo as id_cont FROM reparto_cap)
    
SELECT ac1.id_actor, COUNT(DISTINCT ac2.id_actor) - 1 as compañeros
FROM ActorContenido ac1
JOIN ActorContenido ac2 ON ac1.id_cont = ac2.id_cont
GROUP BY ac1.id_actor
ORDER BY compañeros DESC LIMIT 1;

/* Pregunta 25 - opcional*/
WITH ContenidosPorActor AS (
    SELECT a.id, a.nombre,
           TIMESTAMPDIFF(YEAR, a.fecha_nacimiento, CURDATE()) AS edad,
           (COUNT(DISTINCT rp2.id_pelicula) + COUNT(DISTINCT rc2.id_capitulo)) AS total_contenidos
    FROM actor a
    LEFT JOIN reparto_peli rp2 ON a.id = rp2.id_actor
    LEFT JOIN reparto_cap rc2 ON a.id = rc2.id_actor
    GROUP BY a.id, a.nombre, a.fecha_nacimiento),
    
MaxContenidosPorEdad AS (SELECT edad, MAX(total_contenidos) as max_contenidos
						FROM ContenidosPorActor
						GROUP BY edad)
                        
SELECT cpa.id, cpa.nombre, cpa.edad, cpa.total_contenidos
FROM ContenidosPorActor cpa
JOIN MaxContenidosPorEdad mce ON cpa.edad = mce.edad AND cpa.total_contenidos = mce.max_contenidos;


