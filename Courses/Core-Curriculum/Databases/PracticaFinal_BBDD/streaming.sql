CREATE DATABASE  IF NOT EXISTS `streaming` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `streaming`;
-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: localhost    Database: streaming
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accion`
--

DROP TABLE IF EXISTS `accion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `accion` (
  `id_usuario` varchar(100) NOT NULL,
  `id_contenido` int NOT NULL,
  `puntuacion` int DEFAULT NULL,
  `momento_parada` int DEFAULT NULL,
  `visto` tinyint NOT NULL DEFAULT '0',
  `favorito` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_usuario`,`id_contenido`),
  KEY `accion_idcont_cont_id_idx` (`id_contenido`),
  CONSTRAINT `accion_idcont_cont_id` FOREIGN KEY (`id_contenido`) REFERENCES `contenido` (`id`),
  CONSTRAINT `accion_usu_usu_id` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accion`
--

LOCK TABLES `accion` WRITE;
/*!40000 ALTER TABLE `accion` DISABLE KEYS */;
/*!40000 ALTER TABLE `accion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `actor`
--

DROP TABLE IF EXISTS `actor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `actor` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `fotografia` blob,
  `fecha_nacimiento` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `actor`
--

LOCK TABLES `actor` WRITE;
/*!40000 ALTER TABLE `actor` DISABLE KEYS */;
/*!40000 ALTER TABLE `actor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audiolibro`
--

DROP TABLE IF EXISTS `audiolibro`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audiolibro` (
  `id` int NOT NULL,
  `autor` varchar(100) NOT NULL,
  `narrador` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  CONSTRAINT `audiolibro_id_contenido_id` FOREIGN KEY (`id`) REFERENCES `contenido` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audiolibro`
--

LOCK TABLES `audiolibro` WRITE;
/*!40000 ALTER TABLE `audiolibro` DISABLE KEYS */;
/*!40000 ALTER TABLE `audiolibro` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auditoria_administrator_plan`
--

DROP TABLE IF EXISTS `auditoria_administrator_plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auditoria_administrator_plan` (
  `id_auditoria` int NOT NULL AUTO_INCREMENT,
  `plan_id` int DEFAULT NULL,
  `nombre_plan` varchar(50) DEFAULT NULL,
  `precio_plan` decimal(4,2) DEFAULT NULL,
  `fecha_creacion_plan` date DEFAULT NULL,
  `tipo_operacion` enum('INSERT','UPDATE','DELETE') DEFAULT NULL,
  `hora_cambio` datetime DEFAULT CURRENT_TIMESTAMP,
  `usuario_cambio` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id_auditoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria_administrator_plan`
--

LOCK TABLES `auditoria_administrator_plan` WRITE;
/*!40000 ALTER TABLE `auditoria_administrator_plan` DISABLE KEYS */;
/*!40000 ALTER TABLE `auditoria_administrator_plan` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `capitulo`
--

DROP TABLE IF EXISTS `capitulo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `capitulo` (
  `id` int NOT NULL,
  `numero` int NOT NULL,
  `temporada` int NOT NULL,
  `nombre_capitulo` varchar(50) NOT NULL,
  `id_serie` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `cap_idserie_serie_nombre_idx` (`id_serie`),
  CONSTRAINT `cap_id_contenido_id` FOREIGN KEY (`id`) REFERENCES `contenido` (`id`),
  CONSTRAINT `cap_idserie_serie_nombre` FOREIGN KEY (`id_serie`) REFERENCES `serie` (`nombre_serie`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `capitulo`
--

LOCK TABLES `capitulo` WRITE;
/*!40000 ALTER TABLE `capitulo` DISABLE KEYS */;
/*!40000 ALTER TABLE `capitulo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contenido`
--

DROP TABLE IF EXISTS `contenido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contenido` (
  `id` int NOT NULL AUTO_INCREMENT,
  `fecha_publicacion` date NOT NULL,
  `genero` varchar(50) NOT NULL,
  `clasificacion_edad` int NOT NULL,
  `duracion` int NOT NULL,
  `borrado_backoffice` tinyint(1) DEFAULT '0',
  `fecha_borrado_backoffice` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contenido`
--

LOCK TABLES `contenido` WRITE;
/*!40000 ALTER TABLE `contenido` DISABLE KEYS */;
/*!40000 ALTER TABLE `contenido` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trigger_borrado_backoffice` BEFORE DELETE ON `contenido` FOR EACH ROW BEGIN
	DECLARE v_es_backoffice INT DEFAULT 0;
    SELECT COUNT(*) INTO v_es_backoffice
    FROM mysql.role_edges 
    WHERE FROM_USER = 'backoffice' 
    AND TO_USER = SUBSTRING_INDEX(USER(), '@', 1);
    
    IF (v_es_backoffice = 1) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Los usuarios backoffice no pueden borrar físicamente. Usar p_borrar_contenido_backoffice.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `contenido_backoffice`
--

DROP TABLE IF EXISTS `contenido_backoffice`;
/*!50001 DROP VIEW IF EXISTS `contenido_backoffice`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `contenido_backoffice` AS SELECT 
 1 AS `id`,
 1 AS `fecha_publicacion`,
 1 AS `clasificacion_edad`,
 1 AS `duracion`,
 1 AS `genero`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `disponible`
--

DROP TABLE IF EXISTS `disponible`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `disponible` (
  `id_plan` int NOT NULL,
  `id_contenido` int NOT NULL,
  `fecha` date NOT NULL,
  PRIMARY KEY (`id_plan`,`id_contenido`),
  KEY `disp_idcont_cont_id_idx` (`id_contenido`),
  CONSTRAINT `disp_idcont_cont_id` FOREIGN KEY (`id_contenido`) REFERENCES `contenido` (`id`),
  CONSTRAINT `disp_idplan_plan_id` FOREIGN KEY (`id_plan`) REFERENCES `plan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `disponible`
--

LOCK TABLES `disponible` WRITE;
/*!40000 ALTER TABLE `disponible` DISABLE KEYS */;
/*!40000 ALTER TABLE `disponible` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `idioma`
--

DROP TABLE IF EXISTS `idioma`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `idioma` (
  `idioma` varchar(50) NOT NULL,
  PRIMARY KEY (`idioma`),
  UNIQUE KEY `idioma_UNIQUE` (`idioma`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idioma`
--

LOCK TABLES `idioma` WRITE;
/*!40000 ALTER TABLE `idioma` DISABLE KEYS */;
/*!40000 ALTER TABLE `idioma` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `idioma_contenido`
--

DROP TABLE IF EXISTS `idioma_contenido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `idioma_contenido` (
  `id_contenido` int NOT NULL,
  `idioma` varchar(50) NOT NULL,
  PRIMARY KEY (`id_contenido`,`idioma`),
  KEY `idioCont_idioma_idioma_idx` (`idioma`),
  CONSTRAINT `idioCont_idCont_contenido_id` FOREIGN KEY (`id_contenido`) REFERENCES `contenido` (`id`),
  CONSTRAINT `idioCont_idioma_idioma` FOREIGN KEY (`idioma`) REFERENCES `idioma` (`idioma`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `idioma_contenido`
--

LOCK TABLES `idioma_contenido` WRITE;
/*!40000 ALTER TABLE `idioma_contenido` DISABLE KEYS */;
/*!40000 ALTER TABLE `idioma_contenido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pais`
--

DROP TABLE IF EXISTS `pais`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pais` (
  `pais` varchar(50) NOT NULL,
  PRIMARY KEY (`pais`),
  UNIQUE KEY `pais_UNIQUE` (`pais`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pais`
--

LOCK TABLES `pais` WRITE;
/*!40000 ALTER TABLE `pais` DISABLE KEYS */;
/*!40000 ALTER TABLE `pais` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pelicula`
--

DROP TABLE IF EXISTS `pelicula`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pelicula` (
  `id` int NOT NULL,
  `director` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  CONSTRAINT `pelicula_id_contenido_id` FOREIGN KEY (`id`) REFERENCES `contenido` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pelicula`
--

LOCK TABLES `pelicula` WRITE;
/*!40000 ALTER TABLE `pelicula` DISABLE KEYS */;
/*!40000 ALTER TABLE `pelicula` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plan`
--

DROP TABLE IF EXISTS `plan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `plan` (
  `id` int NOT NULL AUTO_INCREMENT,
  `precio` decimal(4,2) NOT NULL,
  `nombre_plan` varchar(50) NOT NULL,
  `fecha_creacion` date NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `nombre_plan_UNIQUE` (`nombre_plan`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plan`
--

LOCK TABLES `plan` WRITE;
/*!40000 ALTER TABLE `plan` DISABLE KEYS */;
/*!40000 ALTER TABLE `plan` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trigger_auditoria_plan_insert` AFTER INSERT ON `plan` FOR EACH ROW BEGIN
	DECLARE es_admin INT DEFAULT 0;
    SELECT COUNT(*) INTO es_admin FROM mysql.role_edges 
    WHERE FROM_USER = 'administrador' AND TO_USER = SUBSTRING_INDEX(USER(), '@', 1);

    IF (es_admin > 0) THEN
        INSERT INTO auditoria_administrator_plan (plan_id, tipo_operacion, usuario_cambio)
        VALUES (NEW.id, 'INSERT', USER());
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trigger_auditoria_plan_update` AFTER UPDATE ON `plan` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trigger_auditoria_plan_delete` AFTER DELETE ON `plan` FOR EACH ROW BEGIN
	DECLARE es_admin INT DEFAULT 0;
    SELECT COUNT(*) INTO es_admin FROM mysql.role_edges 
    WHERE FROM_USER = 'administrador' AND TO_USER = SUBSTRING_INDEX(USER(), '@', 1);
    IF (es_admin > 0) THEN
        INSERT INTO auditoria_administrator_plan (plan_id, nombre_plan, precio_plan, fecha_creacion_plan, tipo_operacion, usuario_cambio)
        VALUES (OLD.id, OLD.nombre_plan, OLD.precio, OLD.fecha_creacion, 'DELETE', USER());
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `plan_pais`
--

DROP TABLE IF EXISTS `plan_pais`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `plan_pais` (
  `id_plan` int NOT NULL,
  `pais` varchar(50) NOT NULL,
  PRIMARY KEY (`id_plan`,`pais`),
  KEY `pp_pais_pais_idx` (`pais`),
  CONSTRAINT `pp_idplan_plan_id` FOREIGN KEY (`id_plan`) REFERENCES `plan` (`id`),
  CONSTRAINT `pp_pais_pais` FOREIGN KEY (`pais`) REFERENCES `pais` (`pais`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plan_pais`
--

LOCK TABLES `plan_pais` WRITE;
/*!40000 ALTER TABLE `plan_pais` DISABLE KEYS */;
/*!40000 ALTER TABLE `plan_pais` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reparto_cap`
--

DROP TABLE IF EXISTS `reparto_cap`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reparto_cap` (
  `id_capitulo` int NOT NULL,
  `id_actor` int NOT NULL,
  PRIMARY KEY (`id_capitulo`,`id_actor`),
  KEY `rc_idactor_actor_id_idx` (`id_actor`),
  CONSTRAINT `rc_idactor_actor_id` FOREIGN KEY (`id_actor`) REFERENCES `actor` (`id`),
  CONSTRAINT `rc_idcap_cap_id` FOREIGN KEY (`id_capitulo`) REFERENCES `capitulo` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reparto_cap`
--

LOCK TABLES `reparto_cap` WRITE;
/*!40000 ALTER TABLE `reparto_cap` DISABLE KEYS */;
/*!40000 ALTER TABLE `reparto_cap` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reparto_peli`
--

DROP TABLE IF EXISTS `reparto_peli`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reparto_peli` (
  `id_pelicula` int NOT NULL,
  `id_actor` int NOT NULL,
  PRIMARY KEY (`id_pelicula`,`id_actor`),
  KEY `rp_idactor_actor_id_idx` (`id_actor`),
  CONSTRAINT `rp_idactor_actor_id` FOREIGN KEY (`id_actor`) REFERENCES `actor` (`id`),
  CONSTRAINT `rp_idpeli_pelicula_id` FOREIGN KEY (`id_pelicula`) REFERENCES `pelicula` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reparto_peli`
--

LOCK TABLES `reparto_peli` WRITE;
/*!40000 ALTER TABLE `reparto_peli` DISABLE KEYS */;
/*!40000 ALTER TABLE `reparto_peli` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seguir`
--

DROP TABLE IF EXISTS `seguir`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seguir` (
  `id_usuario_seguidor` varchar(100) NOT NULL,
  `id_usuario_seguido` varchar(100) NOT NULL,
  PRIMARY KEY (`id_usuario_seguidor`,`id_usuario_seguido`),
  KEY `seguir_idu_usuario_id_idx` (`id_usuario_seguido`),
  CONSTRAINT `seguir_idu_usuario_id` FOREIGN KEY (`id_usuario_seguido`) REFERENCES `usuario` (`email`),
  CONSTRAINT `seguir_idusr_usuario_id` FOREIGN KEY (`id_usuario_seguidor`) REFERENCES `usuario` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seguir`
--

LOCK TABLES `seguir` WRITE;
/*!40000 ALTER TABLE `seguir` DISABLE KEYS */;
/*!40000 ALTER TABLE `seguir` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `serie`
--

DROP TABLE IF EXISTS `serie`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `serie` (
  `nombre_serie` varchar(50) NOT NULL,
  `n_temporadas` int NOT NULL,
  PRIMARY KEY (`nombre_serie`),
  UNIQUE KEY `nombre_serie_UNIQUE` (`nombre_serie`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `serie`
--

LOCK TABLES `serie` WRITE;
/*!40000 ALTER TABLE `serie` DISABLE KEYS */;
/*!40000 ALTER TABLE `serie` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `email` varchar(100) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `apellidos` varchar(100) NOT NULL,
  `fecha_nacimiento` date NOT NULL,
  `fecha_registro` date NOT NULL,
  `id_plan` int DEFAULT NULL,
  `fecha_adquisicion` date DEFAULT NULL,
  PRIMARY KEY (`email`),
  UNIQUE KEY `email_UNIQUE` (`email`),
  KEY `usuario_idplan_plan_id_idx` (`id_plan`),
  CONSTRAINT `usuario_idplan_plan_id` FOREIGN KEY (`id_plan`) REFERENCES `plan` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario_credencial`
--

DROP TABLE IF EXISTS `usuario_credencial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario_credencial` (
  `email` varchar(100) NOT NULL,
  `password_hash` char(32) DEFAULT NULL,
  PRIMARY KEY (`email`),
  CONSTRAINT `usuario_credencial_ibfk_1` FOREIGN KEY (`email`) REFERENCES `usuario` (`email`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario_credencial`
--

LOCK TABLES `usuario_credencial` WRITE;
/*!40000 ALTER TABLE `usuario_credencial` DISABLE KEYS */;
/*!40000 ALTER TABLE `usuario_credencial` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'streaming'
--

--
-- Dumping routines for database 'streaming'
--
/*!50003 DROP PROCEDURE IF EXISTS `p_borrar_contenido_backoffice` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `p_borrar_contenido_backoffice`(IN p_id INT)
BEGIN
    UPDATE contenido 
    SET borrado_backoffice = 1, fecha_borrado_backoffice = NOW()
    WHERE id = p_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `contenido_backoffice`
--

/*!50001 DROP VIEW IF EXISTS `contenido_backoffice`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `contenido_backoffice` AS select `contenido`.`id` AS `id`,`contenido`.`fecha_publicacion` AS `fecha_publicacion`,`contenido`.`clasificacion_edad` AS `clasificacion_edad`,`contenido`.`duracion` AS `duracion`,`contenido`.`genero` AS `genero` from `contenido` where (`contenido`.`borrado_backoffice` = 0) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-04 21:28:53
