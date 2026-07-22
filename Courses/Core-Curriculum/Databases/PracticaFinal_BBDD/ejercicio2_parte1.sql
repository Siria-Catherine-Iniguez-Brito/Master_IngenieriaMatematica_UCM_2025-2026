/* Parte 1: Ejercicio 2*/

/*1*/
CREATE TABLE usuario_credencial (
    email VARCHAR(100) PRIMARY KEY,
    password_hash CHAR(32),
    FOREIGN KEY (email) REFERENCES usuario(email) ON DELETE CASCADE);

-- Mover contraseñas de usuario a usuario_credencial y eliminar la columna en usuario
-- Como aún no hay datos, no ha que insertarlos en la nueva tabla
ALTER TABLE usuario DROP COLUMN contrasena;

/*2*/
/*MySQL no permite tratar los permisos como una lista modificable cuando se han
concedido de forma global. Cuando se ejecuta un GRANT SELECT ON streaming.*, se 
otorga acceso a todas las tablas del esquema de manera conjunta, y ese permiso no 
puede “recortarse” posteriormente excluyendo tablas concretas con REVOKE. Esto ocurre
 porque el sistema de permisos de MySQL es jerárquico y acumulativo: los privilegios 
 se suman desde distintos niveles (global, esquema, tabla), pero no se pueden restar 
 parcialmente dentro de un mismo nivel. Por ello, si se necesita excluir tablas sensibles,
 la única solución válida es no usar permisos globales y conceder el acceso de forma 
 explícita tabla a tabla, aplicando así el principio de mínimo privilegio.*/
 
CREATE USER 'backup_generic_readonly'@'%' IDENTIFIED BY 'password_segura1'; 

/*Generar los GRANTS que tenemos que realizar*/
SELECT CONCAT('GRANT SELECT ON streaming.', table_name, ' TO ''backup_generic_readonly''@''%'';')
FROM information_schema.tables
WHERE table_schema = 'streaming'
AND table_name NOT IN ('usuario_credencial', 'accion');

/*Copiamos el resultado anterior y ejecutamos*/
GRANT SELECT ON streaming.actor TO 'backup_generic_readonly'@'%';
GRANT SELECT ON streaming.audiolibro TO 'backup_generic_readonly'@'%';
GRANT SELECT ON streaming.capitulo TO 'backup_generic_readonly'@'%';
GRANT SELECT ON streaming.contenido TO 'backup_generic_readonly'@'%';
GRANT SELECT ON streaming.disponible TO 'backup_generic_readonly'@'%';
GRANT SELECT ON streaming.idioma TO 'backup_generic_readonly'@'%';
GRANT SELECT ON streaming.idioma_contenido TO 'backup_generic_readonly'@'%';
GRANT SELECT ON streaming.pais TO 'backup_generic_readonly'@'%';
GRANT SELECT ON streaming.pelicula TO 'backup_generic_readonly'@'%';
GRANT SELECT ON streaming.plan TO 'backup_generic_readonly'@'%';
GRANT SELECT ON streaming.plan_pais TO 'backup_generic_readonly'@'%';
GRANT SELECT ON streaming.reparto_cap TO 'backup_generic_readonly'@'%';
GRANT SELECT ON streaming.reparto_peli TO 'backup_generic_readonly'@'%';
GRANT SELECT ON streaming.seguir TO 'backup_generic_readonly'@'%';
GRANT SELECT ON streaming.serie TO 'backup_generic_readonly'@'%';
GRANT SELECT ON streaming.usuario TO 'backup_generic_readonly'@'%';

/*3*/
CREATE USER 'backup_sensible_readonly'@'%' IDENTIFIED BY 'password_segura2';
GRANT SELECT ON streaming.accion TO 'backup_sensible_readonly'@'%';

/*4*/
CREATE ROLE 'backoffice';

/*5*/
CREATE USER 'web_client'@'%' IDENTIFIED BY 'password_segura3';
GRANT 'backoffice' to 'web_client'@'%';
SET DEFAULT ROLE 'backoffice' TO 'web_client'@'%' ;

/*6*/
-- Parte 1: añadir campos a la tabla original
ALTER TABLE contenido 
ADD COLUMN borrado_backoffice BOOLEAN DEFAULT 0,
ADD COLUMN fecha_borrado_backoffice DATETIME DEFAULT NULL;

-- Parte 2: crear vista, excluyendo campos borrado_aplicativo y fecha_borrado_aplicativo
CREATE OR REPLACE VIEW contenido_backoffice AS 
SELECT id, fecha_publicacion, clasificacion_edad, duracion, genero   
FROM contenido
WHERE borrado_backoffice = 0;

-- Parte 3: Procedimiento
DELIMITER //
CREATE PROCEDURE p_borrar_contenido_backoffice(IN p_id INT)
BEGIN
    UPDATE contenido 
    SET borrado_backoffice = 1, fecha_borrado_backoffice = NOW()
    WHERE id = p_id;
END //
DELIMITER ;

-- Parte 4: Trigger de seguridad en la tabla base - uso de variable de sesión
DELIMITER //
CREATE TRIGGER trigger_borrado_backoffice
BEFORE DELETE ON contenido
FOR EACH ROW
BEGIN
	DECLARE v_es_backoffice INT DEFAULT 0;
    SELECT COUNT(*) INTO v_es_backoffice
    FROM mysql.role_edges 
    WHERE FROM_USER = 'backoffice' 
    AND TO_USER = SUBSTRING_INDEX(USER(), '@', 1);
    
    IF (v_es_backoffice = 1) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Los usuarios backoffice no pueden borrar físicamente. Usar p_borrar_contenido_backoffice.';
    END IF;
END //
DELIMITER ;



/*7*/
-- Paso 1: Tabla de auditorias
CREATE TABLE auditoria_administrator_plan (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    
    plan_id INT,
    nombre_plan VARCHAR(50),
    precio_plan DECIMAL(4,2),
    fecha_creacion_plan DATE,
    
    tipo_operacion ENUM('INSERT', 'UPDATE', 'DELETE'),
    hora_cambio DATETIME DEFAULT CURRENT_TIMESTAMP,
    usuario_cambio VARCHAR(100)
);

-- Paso 2: tregger para UPDATE
DELIMITER //
CREATE TRIGGER trigger_auditoria_plan_update
AFTER UPDATE 
ON plan
FOR EACH ROW
BEGIN
	DECLARE es_admin INT DEFAULT 0;
    
    -- Verificamos si el usuario actual tiene el rol 'administrador'
    SELECT COUNT(*) INTO es_admin
    FROM mysql.role_edges 
    WHERE FROM_USER = 'administrador' 
    AND TO_USER = SUBSTRING_INDEX(USER(), '@', 1);

    IF (es_admin > 0) THEN
        INSERT INTO auditoria_administrator_plan (plan_id, nombre_plan, precio_plan, fecha_creacion_plan, tipo_operacion, usuario_cambio)
        VALUES (OLD.id, 
                IF(OLD.nombre_plan <> NEW.nombre_plan, OLD.nombre_plan, NULL), 
                IF(OLD.precio <> NEW.precio, OLD.precio, NULL),
                IF(OLD.fecha_creacion <> NEW.fecha_creacion, OLD.fecha_creacion, NULL),
                'UPDATE', USER());
    END IF;
END //
DELIMITER ;

-- Paso 3: Trigger para INSERT
DELIMITER //
CREATE TRIGGER trigger_auditoria_plan_insert
AFTER INSERT 
ON plan
FOR EACH ROW
BEGIN
	DECLARE es_admin INT DEFAULT 0;
    SELECT COUNT(*) INTO es_admin FROM mysql.role_edges 
    WHERE FROM_USER = 'administrador' AND TO_USER = SUBSTRING_INDEX(USER(), '@', 1);

    IF (es_admin > 0) THEN
        INSERT INTO auditoria_administrator_plan (plan_id, tipo_operacion, usuario_cambio)
        VALUES (NEW.id, 'INSERT', USER());
    END IF;
END //
DELIMITER ;

-- Paso 4: Trigger para DELETE
DELIMITER //
CREATE TRIGGER trigger_auditoria_plan_delete
AFTER DELETE 
ON plan
FOR EACH ROW
BEGIN
	DECLARE es_admin INT DEFAULT 0;
    SELECT COUNT(*) INTO es_admin FROM mysql.role_edges 
    WHERE FROM_USER = 'administrador' AND TO_USER = SUBSTRING_INDEX(USER(), '@', 1);
    IF (es_admin > 0) THEN
        INSERT INTO auditoria_administrator_plan (plan_id, nombre_plan, precio_plan, fecha_creacion_plan, tipo_operacion, usuario_cambio)
        VALUES (OLD.id, OLD.nombre_plan, OLD.precio, OLD.fecha_creacion, 'DELETE', USER());
    END IF;
END //
DELIMITER ;


/*8*/
-- Crear role
CREATE ROLE 'administrador';

-- Conceder permisos tabla a tabla, excluyendo auditoria_administrator_plan
GRANT ALL PRIVILEGES ON streaming.plan TO 'administrador';
GRANT ALL PRIVILEGES ON streaming.pais TO 'administrador';
GRANT ALL PRIVILEGES ON streaming.plan_pais TO 'administrador';
GRANT ALL PRIVILEGES ON streaming.usuario TO 'administrador';
GRANT ALL PRIVILEGES ON streaming.seguir TO 'administrador';
GRANT ALL PRIVILEGES ON streaming.contenido TO 'administrador';
GRANT ALL PRIVILEGES ON streaming.idioma TO 'administrador';
GRANT ALL PRIVILEGES ON streaming.idioma_contenido TO 'administrador';
GRANT ALL PRIVILEGES ON streaming.disponible TO 'administrador';
GRANT ALL PRIVILEGES ON streaming.accion TO 'administrador';
GRANT ALL PRIVILEGES ON streaming.audiolibro TO 'administrador';
GRANT ALL PRIVILEGES ON streaming.pelicula TO 'administrador';
GRANT ALL PRIVILEGES ON streaming.serie TO 'administrador';
GRANT ALL PRIVILEGES ON streaming.capitulo TO 'administrador';
GRANT ALL PRIVILEGES ON streaming.actor TO 'administrador';
GRANT ALL PRIVILEGES ON streaming.reparto_peli TO 'administrador';
GRANT ALL PRIVILEGES ON streaming.reparto_cap TO 'administrador';

-- Tablas y vistas creadas durante el Ejercicio 2
GRANT ALL PRIVILEGES ON streaming.usuario_credencial TO 'administrador';
GRANT ALL PRIVILEGES ON streaming.contenido_backoffice TO 'administrador';

-- Ppermisos para ejecutar el procedimiento de borrado lógico
GRANT EXECUTE ON PROCEDURE streaming.p_borrar_contenido_backoffice TO 'administrador';


/*9*/
CREATE USER 'administrador_andres_perez_indra'@'%' IDENTIFIED BY 'SUCONTRASENA';
GRANT 'administrador' TO 'administrador_andres_perez_indra'@'%';
SET DEFAULT ROLE 'administrador' TO 'administrador_andres_perez_indra'@'%';


/*10*/
 
/* TABLAS USUARIO ROLES */ 
/*Listar usuarios y sus estados*/
SELECT user, host, account_locked, password_last_changed 
FROM mysql.user 
WHERE user IN ('backup_generic_readonly', 'backup_sensible_readonly', 'web_client', 'administrador_andres_perez_indra');

/*RELACION USUARIO-ROL*/
SELECT FROM_USER AS 'Rol', TO_USER AS 'Usuario' 
FROM mysql.role_edges;

/*COMPROBAR LOS PERMISIOS**/
-- Para el backup genérico 
SHOW GRANTS FOR 'backup_generic_readonly'@'%';

-- Para el cliente web 
SHOW GRANTS FOR 'web_client'@'%';


