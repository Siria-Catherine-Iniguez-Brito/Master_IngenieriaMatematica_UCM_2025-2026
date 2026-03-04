
--
-- Table structure for table `avion`
--

CREATE TABLE `avion` (
  `aid` decimal(9,0) NOT NULL,
  `nombre` varchar(30) DEFAULT NULL,
  `autonomia` decimal(6,0) DEFAULT NULL,
  PRIMARY KEY (`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


--
-- Dumping data for table `avion`
--


/*!40000 ALTER TABLE `avion` DISABLE KEYS */;
INSERT INTO `avion` (`aid`, `nombre`, `autonomia`) VALUES (1,'boeing 747-400',8430),(2,'boeing 737-800',3383),(3,'airbus a340-300',7120),(4,'british aerospace jetstream 41',1502),(5,'embraer erj-145',1530),(6,'saab 340',2128),(7,'piper archer iii',520),(8,'tupolev 154',4103),(9,'lockheed l1011',6900),(10,'boeing 757-300',4010),(11,'boeing 777-300',6441),(12,'boeing 767-400er',6475),(13,'airbus a320',2605),(14,'airbus a319',1805),(15,'boeing 727',1504),(16,'schwitzer 2-33',30);
/*!40000 ALTER TABLE `avion` ENABLE KEYS */;




--
-- Table structure for table `empleado`
--

DROP TABLE IF EXISTS `empleado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `empleado` (
  `eid` decimal(9,0) NOT NULL,
  `nombre` varchar(30) DEFAULT NULL,
  `salario` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`eid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `empleado`
--


/*!40000 ALTER TABLE `empleado` DISABLE KEYS */;
INSERT INTO `empleado` (`eid`, `nombre`, `salario`) VALUES (11564812,'john williams',153972.00),(15645489,'donald king',18050.00),(90873519,'elizabeth taylor',32021.00),(141582651,'mary johnson',178345.00),(142519864,'betty adams',227489.00),(159542516,'william moore',48250.00),(242518965,'james smith',120433.00),(248965255,'barbara wilson',43723.00),(254099823,'patricia jones',24450.00),(269734834,'george wright',289950.00),(274878974,'michael miller',99890.00),(287321212,'michael miller',48090.00),(310454876,'joseph thompson',212156.00),(310454877,'chad stewart',33546.00),(348121549,'haywood kelly',32899.00),(355548984,'angela martinez',212156.00),(356187925,'robert brown',44740.00),(390487451,'lawrence sperry',212156.00),(486512566,'david anderson',43001.00),(489221823,'richard jackson',23980.00),(489456522,'linda davis',27984.00),(548977562,'william ward',84476.00),(550156548,'karen scott',205187.00),(552455318,'larry west',101745.00),(552455348,'dorthy lewis',152013.00),(556784565,'mark young',205187.00),(567354612,'lisa walker',256481.00),(573284895,'eric cooper',114323.00),(574489456,'william jones',105743.00),(574489457,'milo brooks',20.00),(619023588,'jennifer thomas',54921.00);
/*!40000 ALTER TABLE `empleado` ENABLE KEYS */;


--
-- Table structure for table `certificado`
--

DROP TABLE IF EXISTS `certificado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `certificado` (
  `eid` decimal(9,0) NOT NULL,
  `aid` decimal(9,0) NOT NULL,
  PRIMARY KEY (`eid`,`aid`),
  KEY `aid` (`aid`),
  CONSTRAINT `certificado_ibfk_1` FOREIGN KEY (`eid`) REFERENCES `empleado` (`eid`),
  CONSTRAINT `certificado_ibfk_2` FOREIGN KEY (`aid`) REFERENCES `avion` (`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


--
-- Dumping data for table `certificado`
--

/*!40000 ALTER TABLE `certificado` DISABLE KEYS */;
INSERT INTO `certificado` (`eid`, `aid`) VALUES (142519864,1),(269734834,1),(550156548,1),(567354612,1),(11564812,2),(141582651,2),(142519864,2),(242518965,2),(269734834,2),(552455318,2),(556784565,2),(567354612,2),(142519864,3),(269734834,3),(390487451,3),(556784565,3),(567354612,3),(573284895,3),(269734834,4),(567354612,4),(573284895,4),(159542516,5),(269734834,5),(556784565,5),(567354612,5),(573284895,5),(90873519,6),(269734834,6),(356187925,6),(574489456,6),(142519864,7),(159542516,7),(269734834,7),(548977562,7),(552455318,7),(567354612,7),(574489457,7),(269734834,8),(310454876,8),(355548984,8),(574489456,8),(269734834,9),(310454876,9),(355548984,9),(567354612,9),(11564812,10),(141582651,10),(142519864,10),(242518965,10),(269734834,10),(274878974,10),(567354612,10),(142519864,11),(269734834,11),(567354612,11),(141582651,12),(142519864,12),(269734834,12),(274878974,12),(550156548,12),(567354612,12),(142519864,13),(269734834,13),(390487451,13),(269734834,14),(390487451,14),(552455318,14),(269734834,15),(567354612,15);
/*!40000 ALTER TABLE `certificado` ENABLE KEYS */;

--
-- Table structure for table `vuelo`
--

DROP TABLE IF EXISTS `vuelo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vuelo` (
  `flno` decimal(4,0) NOT NULL,
  `origen` varchar(20) DEFAULT NULL,
  `destino` varchar(20) DEFAULT NULL,
  `distancia` decimal(6,0) DEFAULT NULL,
  `salida` datetime DEFAULT NULL,
  `llegada` datetime DEFAULT NULL,
  `precio` decimal(7,2) DEFAULT NULL,
  PRIMARY KEY (`flno`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vuelo`
--

/*!40000 ALTER TABLE `vuelo` DISABLE KEYS */;
INSERT INTO `vuelo` (`flno`, `origen`, `destino`, `distancia`, `salida`, `llegada`, `precio`) VALUES (2,'los angeles','tokyo',5478,'2005-12-04 06:30:00','2005-12-04 03:55:00',780.99),(7,'los angeles','sydney',7487,'2005-12-04 05:30:00','2005-12-04 11:10:00',278.56),(13,'los angeles','chicago',1749,'2005-12-04 08:45:00','2005-12-04 08:45:00',220.98),(33,'los angeles','honolulu',2551,'2005-12-04 09:15:00','2005-12-04 11:15:00',375.23),(34,'los angeles','honolulu',2551,'2005-12-04 12:45:00','2005-12-04 03:18:00',425.98),(68,'chicago','new york',802,'2005-12-04 09:00:00','2005-12-04 12:02:00',202.45),(76,'chicago','los angeles',1749,'2005-12-04 08:32:00','2005-12-04 10:03:00',220.98),(99,'los angeles','washington d.c.',2308,'2005-12-04 09:30:00','2005-12-04 09:40:00',235.98),(149,'pittsburgh','new york',303,'2005-12-04 09:42:00','2005-12-04 12:09:00',1165.00),(304,'minneapolis','new york',991,'2005-12-04 10:00:00','2005-12-04 01:39:00',101.56),(346,'los angeles','dallas',1251,'2005-12-04 11:50:00','2005-12-04 07:05:00',182.00),(387,'los angeles','boston',2606,'2005-12-04 07:03:00','2005-12-04 05:03:00',261.56),(701,'detroit','new york',470,'2005-12-04 08:55:00','2005-12-04 10:26:00',180.56),(702,'madison','new york',789,'2005-12-04 07:05:00','2005-12-04 10:12:00',202.34),(2223,'madison','pittsburgh',517,'2005-12-04 08:02:00','2005-12-04 10:01:00',189.98),(4884,'madison','chicago',84,'2005-12-04 10:12:00','2005-12-04 11:02:00',112.45),(5694,'madison','minneapolis',247,'2005-12-04 08:32:00','2005-12-04 09:33:00',120.11),(7789,'madison','detroit',319,'2005-12-04 06:15:00','2005-12-04 08:19:00',120.33);
/*!40000 ALTER TABLE `vuelo` ENABLE KEYS */;