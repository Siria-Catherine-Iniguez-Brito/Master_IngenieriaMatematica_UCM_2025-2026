/* PREGUNTA 1*/
SELECT DISTINCT empleado.eid, empleado.nombre FROM 
avion JOIN certificado ON avion.aid = certificado.aid
JOIN empleado ON certificado.eid = empleado.eid 
WHERE avion.nombre like 'boeing%';

/*PREGUNTA 2 */
SELECT aid FROM avion
WHERE autonomia >= (SELECT distancia FROM vuelo
WHERE origen = "Los Angeles" AND destino = "Chicago") ;

/* PREGUNTA 3*/
SELECT contar.flno FROM (
SELECT vuelo.flno, count(DISTINCT empleado.eid) as n_pilotos_aptos FROM 
vuelo JOIN avion ON vuelo.distancia < avion.autonomia
JOIN certificado ON avion.aid = certificado.aid 
JOIN empleado ON certificado.eid = empleado.eid
WHERE empleado.salario > 100000
GROUP BY  vuelo.flno ) AS contar 
WHERE n_pilotos_aptos = (SELECT COUNT(DISTINCT eid) 
    FROM certificado 
    WHERE eid IN (SELECT eid FROM empleado WHERE salario > 100000));

/*PREGUNTA 4*/
SELECT DISTINCT e.eid, e.nombre FROM certificado c
JOIN empleado e ON c.eid = e.eid
JOIN avion a ON c.aid=a.aid
WHERE autonomia>3000 AND NOT EXISTS (
	SELECT 1 FROM avion a 
	JOIN certificado c ON a.aid = c.aid 
	WHERE c.eid=e.eid AND a.nombre LIKE 'boeing%');
    
/*PREGUNTA 5 */
SELECT eid, nombre FROM empleado 
WHERE salario = (SELECT max(salario) FROM empleado);

/*PREGUNTA 6*/
SELECT eid, nombre FROM empleado 
WHERE salario = (SELECT DISTINCT salario FROM empleado
ORDER BY salario DESC LIMIT 1 OFFSET 1);

/*PREGUNTA 7*/
SELECT empleado.nombre, COUNT(*) as n_certificaciones FROM 
empleado JOIN certificado ON empleado.eid = certificado.eid
GROUP BY empleado.nombre
ORDER BY n_certificaciones DESC LIMIT 1;

/*PREGUNTA 8*/
SELECT e.nombre FROM certificado c
JOIN empleado e ON c.eid=e.eid
GROUP BY e.eid
HAVING COUNT(DISTINCT c.aid) = 3;

/*PREGUNTA 9 OK */
SELECT SUM(empleado.salario) as salario_total FROM empleado;  

/*PREGUNTA 10*/
SELECT empleado.eid, empleado.nombre, max(avion.autonomia), 
    COUNT(*) AS n_aviones 
FROM certificado
JOIN empleado ON certificado.eid = empleado.eid
JOIN avion ON certificado.aid = avion.aid
GROUP BY empleado.eid
HAVING n_aviones > 3;

/*PREGUNTA 11*/
SELECT empleado.eid, empleado.nombre, max(avion.autonomia) AS autonomia_maxima FROM 
certificado JOIN empleado ON certificado.eid = empleado.eid 
JOIN avion ON certificado.aid = avion.aid 
GROUP BY empleado.eid
HAVING COUNT(DISTINCT certificado.aid) > 3;

/*PREGUNTA 12*/
SELECT DISTINCT e.nombre FROM empleado e
JOIN certificado c ON e.eid = c.eid
WHERE salario < (SELECT MIN(precio) FROM vuelo
WHERE origen LIKE 'Los Angeles' AND destino LIKE 'honolulu');

/*PREGUNTA  13*/
SELECT avion.nombre, AVG(empleado.salario) AS media_salario FROM 
avion JOIN certificado ON avion.aid = certificado.aid 
JOIN empleado ON empleado.eid = certificado.eid
WHERE avion.autonomia >1000
GROUP BY avion.aid ; 

/*PREGUNTA 14*/
SELECT (SELECT AVG(salario) FROM empleado) -  
	(SELECT AVG(salario) FROM empleado WHERE eid IN (SELECT eid FROM certificado))
        AS difernciaSalarios;

/*PREGUNTA  15*/
SELECT empleado.nombre AS empleado_nopiloto FROM empleado
WHERE empleado.eid NOT IN (SELECT DISTINCT empleado.eid AS pilotos FROM 
		empleado JOIN certificado ON empleado.eid = certificado.eid) 
	AND empleado.salario > (SELECT AVG(salario) FROM empleado 
						WHERE eid IN (SELECT eid FROM certificado));

/*PREGUNTA 16*/
SELECT DISTINCT nombre FROM empleado
WHERE eid in (SELECT c.eid FROM certificado c
	JOIN avion a ON c.aid=a.aid
    GROUP BY c.eid
    HAVING MIN(a.autonomia) > 1000);
    

/*PREGUNTA 17*/ 
SELECT e.nombre
FROM empleado e
JOIN certificado c ON e.eid = c.eid
JOIN avion a ON c.aid = a.aid
GROUP BY e.eid, e.nombre
HAVING MIN(a.autonomia) > 1000 AND COUNT(c.aid) >= 2;

/*PREGUNTA 18*/
SELECT e.eid, e.nombre FROM empleado e
JOIN certificado c ON e.eid=c.eid
JOIN avion a ON c.aid=a.aid
GROUP BY e.eid, e.nombre
HAVING MIN(a.autonomia) > 1000 
    AND SUM(CASE WHEN a.nombre LIKE 'boeing%' THEN 1 ELSE 0 END) > 0;
