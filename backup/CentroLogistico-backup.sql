-- mysqldump: [Warning] Using a password on the command line interface can be insecure.
-- MySQL dump 10.13  Distrib 9.0.1, for Linux (x86_64)
--
-- Host: 127.0.0.1    Database: CentroLogistico
-- ------------------------------------------------------
-- Server version	9.0.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Almacenes_Maquinas`
--
DROP DATABASE IF EXISTS CentroLogistico;
CREATE DATABASE CentroLogistico;

USE CentroLogistico;

DROP TABLE IF EXISTS `Almacenes_Maquinas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Almacenes_Maquinas` (
  `ID_Almacen_Maquina` int NOT NULL AUTO_INCREMENT,
  `ID_Centro` int NOT NULL,
  `ID_Maquina` int DEFAULT NULL,
  `Cantidad` int NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID_Almacen_Maquina`),
  KEY `FK_Centros_Almacenes_Maquinas` (`ID_Centro`),
  KEY `FK_Maquina_Almacenes_Maquinas` (`ID_Maquina`),
  CONSTRAINT `FK_Centros_Almacenes_Maquinas` FOREIGN KEY (`ID_Centro`) REFERENCES `Centros` (`ID_Centro`),
  CONSTRAINT `FK_Maquina_Almacenes_Maquinas` FOREIGN KEY (`ID_Maquina`) REFERENCES `Maquinas` (`ID_Maquina`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Almacenes_Maquinas`
--

LOCK TABLES `Almacenes_Maquinas` WRITE;
/*!40000 ALTER TABLE `Almacenes_Maquinas` DISABLE KEYS */;
INSERT INTO `Almacenes_Maquinas` VALUES (1,1,1,1),(2,1,2,1),(3,2,3,1),(4,2,4,1),(5,3,5,1),(6,3,6,1),(7,4,7,1),(8,4,8,1),(9,5,9,1),(10,5,10,1),(11,6,11,1),(12,6,12,1),(13,7,13,1),(14,7,14,1),(15,8,15,1),(16,8,16,1),(17,9,17,1),(18,9,18,1),(19,10,19,1),(20,10,20,1);
/*!40000 ALTER TABLE `Almacenes_Maquinas` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `Trigger_VerificarIngresoMaquinas` BEFORE INSERT ON `Almacenes_Maquinas` FOR EACH ROW BEGIN
    DECLARE v_StockTotal INT;

    -- Verificar el stock total de la máquina en todos los centros
    SELECT IFNULL(SUM(Cantidad), 0) INTO v_StockTotal
    FROM Almacenes_Maquinas
    WHERE ID_Maquina = NEW.ID_Maquina;


    -- No permitir el ingreso si la máquina ya existe en algún centro
    IF v_StockTotal > 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR_1_MAQ:No se puede ingresar la máquina: ya existe en otro centro.';
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
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `Trigger_VerificarSalidaTransferenciaMaquinas` BEFORE INSERT ON `Almacenes_Maquinas` FOR EACH ROW BEGIN
    DECLARE v_StockActual INT;

    -- Obtener el stock actual de la máquina en el centro de origen
    SELECT IFNULL(SUM(Cantidad), 0) INTO v_StockActual
    FROM Almacenes_Maquinas
    WHERE ID_Centro = NEW.ID_Centro AND ID_Maquina = NEW.ID_Maquina;
 
     -- Verificar si se está intentando realizar una salida o transferencia con cantidad negativa
    IF NEW.Cantidad < 0 THEN
        IF v_StockActual + NEW.Cantidad < 0 THEN
             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR_2_MAQ: No se puede realizar la salida o transferencia: no se encuentra la maquina en el centro.';
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Almacenes_Materiales`
--

DROP TABLE IF EXISTS `Almacenes_Materiales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Almacenes_Materiales` (
  `ID_Almacen_Material` int NOT NULL AUTO_INCREMENT,
  `ID_Centro` int NOT NULL,
  `ID_Material` int DEFAULT NULL,
  `Cantidad` int DEFAULT '0',
  PRIMARY KEY (`ID_Almacen_Material`),
  KEY `FK_Centros_Almacenes_Materiales` (`ID_Centro`),
  KEY `FK_Material_Almacenes_Materiales` (`ID_Material`),
  CONSTRAINT `FK_Centros_Almacenes_Materiales` FOREIGN KEY (`ID_Centro`) REFERENCES `Centros` (`ID_Centro`),
  CONSTRAINT `FK_Material_Almacenes_Materiales` FOREIGN KEY (`ID_Material`) REFERENCES `Materiales` (`ID_Material`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Almacenes_Materiales`
--

LOCK TABLES `Almacenes_Materiales` WRITE;
/*!40000 ALTER TABLE `Almacenes_Materiales` DISABLE KEYS */;
INSERT INTO `Almacenes_Materiales` VALUES (1,1,1,100),(2,1,2,150),(3,2,1,200),(4,2,3,300),(5,3,2,50),(6,3,3,100),(7,4,1,120),(8,4,2,80),(9,5,1,60),(10,5,3,40),(11,6,2,70),(12,6,3,110),(13,7,1,90),(14,7,2,130),(15,8,3,150),(16,8,1,200),(17,9,2,100),(18,9,3,140),(19,10,1,80),(20,10,2,60);
/*!40000 ALTER TABLE `Almacenes_Materiales` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `Trigger_VerificarMovimientoMateriales` BEFORE INSERT ON `Almacenes_Materiales` FOR EACH ROW BEGIN
    DECLARE v_StockActual INT;

    -- Obtener el stock actual del material en el centro
    SELECT IFNULL(SUM(Cantidad),0) INTO v_StockActual
    FROM Almacenes_Materiales
    WHERE ID_Centro = NEW.ID_Centro AND ID_Material = NEW.ID_Material;

    -- Verificar si se está intentando realizar una salida o transferencia con cantidad negativa
    IF NEW.Cantidad < 0 THEN
        -- Verificar si hay suficiente stock para permitir la salida o transferencia
        IF v_StockActual + NEW.Cantidad < 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR_1_MAT: No se puede realizar la salida o transferencia: stock insuficiente o inexistente.';
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Autorizaciones`
--

DROP TABLE IF EXISTS `Autorizaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Autorizaciones` (
  `ID_Autorizacion` int NOT NULL AUTO_INCREMENT,
  `ID_Solicitud` int NOT NULL,
  `ID_Socio_Gerente` int NOT NULL,
  `Estado` enum('Aprobada','Rechazada','Pendiente') DEFAULT 'Pendiente',
  `Fecha` date DEFAULT NULL,
  PRIMARY KEY (`ID_Autorizacion`),
  KEY `FK_Solicitud_Autorizaciones` (`ID_Solicitud`),
  KEY `FK_Socio_Gerente_Autorizaciones` (`ID_Socio_Gerente`),
  CONSTRAINT `FK_Socio_Gerente_Autorizaciones` FOREIGN KEY (`ID_Socio_Gerente`) REFERENCES `Socios_Gerentes` (`ID_Socio_Gerente`),
  CONSTRAINT `FK_Solicitud_Autorizaciones` FOREIGN KEY (`ID_Solicitud`) REFERENCES `Solicitudes` (`ID_Solicitud`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Autorizaciones`
--

LOCK TABLES `Autorizaciones` WRITE;
/*!40000 ALTER TABLE `Autorizaciones` DISABLE KEYS */;
/*!40000 ALTER TABLE `Autorizaciones` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `Trigger_ValidarEstadoSolicitud` BEFORE INSERT ON `Autorizaciones` FOR EACH ROW BEGIN
    DECLARE estado_actual ENUM('Pendiente', 'Parcial', 'Aprobada', 'Rechazada');
    
    SELECT Estado INTO estado_actual FROM Solicitudes WHERE ID_Solicitud = NEW.ID_Solicitud;
    
    IF estado_actual != 'Pendiente' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR_1_SOL:La solicitud no está en estado Pendiente.';
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
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `Trigger_ActualizarEstadoSolicitudAprobada` AFTER INSERT ON `Autorizaciones` FOR EACH ROW BEGIN
    IF NEW.Estado = 'Aprobada' THEN
        UPDATE Solicitudes
        SET Estado = 'Aprobada'
        WHERE ID_Solicitud = NEW.ID_Solicitud;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Centros`
--

DROP TABLE IF EXISTS `Centros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Centros` (
  `ID_Centro` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(255) NOT NULL,
  `Direccion` varchar(255) DEFAULT NULL,
  `Tipo` enum('Obra','Deposito') NOT NULL,
  PRIMARY KEY (`ID_Centro`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Centros`
--

LOCK TABLES `Centros` WRITE;
/*!40000 ALTER TABLE `Centros` DISABLE KEYS */;
INSERT INTO `Centros` VALUES (1,'Obra Central','Av. Principal 123',''),(2,'Obra Norte','Calle Secundaria 456',''),(3,'Obra Sur','Avenida del Sur 789',''),(4,'Obra Este','Calle Este 101',''),(5,'Obra Oeste','Calle Oeste 202',''),(6,'Deposito A','Av. de los Depósitos 1',''),(7,'Deposito B','Av. de los Depósitos 2',''),(8,'Deposito C','Av. de los Depósitos 3',''),(9,'Obra Central 2','Av. Central 12',''),(10,'Obra Norte 2','Calle Norte 34',''),(11,'Obra Sur 2','Avenida Sur 56',''),(12,'Obra Este 2','Calle Este 78',''),(13,'Obra Oeste 2','Calle Oeste 90',''),(14,'Obra Central 3','Av. Central 13',''),(15,'Obra Norte 3','Calle Norte 35',''),(16,'Obra Sur 3','Avenida Sur 57',''),(17,'Obra Este 3','Calle Este 79',''),(18,'Obra Oeste 3','Calle Oeste 91',''),(19,'Obra Central 4','Av. Central 14',''),(20,'Obra Norte 4','Calle Norte 36',''),(21,'Obra Central 5','Av. Central 15',''),(22,'Obra Norte 5','Calle Norte 37',''),(23,'Obra Sur 4','Avenida Sur 58',''),(24,'Obra Este 4','Calle Este 80',''),(25,'Obra Oeste 4','Calle Oeste 92',''),(26,'Obra Central 6','Av. Central 16',''),(27,'Obra Norte 6','Calle Norte 38',''),(28,'Obra Sur 5','Avenida Sur 59',''),(29,'Obra Este 5','Calle Este 81',''),(30,'Obra Oeste 5','Calle Oeste 93',''),(31,'Obra Central 7','Av. Central 17',''),(32,'Obra Norte 7','Calle Norte 39',''),(33,'Obra Sur 6','Avenida Sur 60',''),(34,'Obra Este 6','Calle Este 82',''),(35,'Obra Oeste 6','Calle Oeste 94',''),(36,'Obra Central 8','Av. Central 18',''),(37,'Obra Norte 8','Calle Norte 40',''),(38,'Obra Sur 7','Avenida Sur 61',''),(39,'Obra Este 7','Calle Este 83',''),(40,'Obra Oeste 7','Calle Oeste 95',''),(41,'Obra Central 9','Av. Central 19',''),(42,'Obra Norte 9','Calle Norte 41',''),(43,'Obra Sur 8','Avenida Sur 62',''),(44,'Obra Este 8','Calle Este 84',''),(45,'Obra Oeste 8','Calle Oeste 96',''),(46,'Obra Central 10','Av. Central 20',''),(47,'Obra Norte 10','Calle Norte 42','Obra');
/*!40000 ALTER TABLE `Centros` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Clientes`
--

DROP TABLE IF EXISTS `Clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Clientes` (
  `ID_Cliente` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(255) NOT NULL,
  `Direccion` varchar(255) DEFAULT NULL,
  `Telefono` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`ID_Cliente`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Clientes`
--

LOCK TABLES `Clientes` WRITE;
/*!40000 ALTER TABLE `Clientes` DISABLE KEYS */;
INSERT INTO `Clientes` VALUES (1,'Keith Taylor','53698 Christina Lake Apt. 697 Smithburgh VI 66880','(606)270-3268x1170\r'),(2,'Jennifer Patterson','Unit 7944 Box 2132 DPO AA 36318','(803)878-9878x659\r'),(3,'Amber Small','93132 Jesus Rapid Suite 576 Jamesberg WV 52878','2034428627\r'),(4,'Nancy Baxter','83453 Emily Heights Nelsonmouth GA 42336','612.662.9481x56604\r'),(5,'Kimberly Baird','7132 Garcia Highway Margaretbury NV 15302','623-460-2519x0003\r'),(6,'Rebecca Moore','658 Patricia Square Apt. 468 Huntmouth VA 04881','001-226-407-1476x725'),(7,'Jose Murphy','9044 Williams Trace West Tammy ME 88981','279-209-7037\r'),(8,'Timothy Robinson','93714 Michael Forges Baileymouth WA 19293','001-544-715-2847x783'),(9,'Tabitha Martin','5380 Nash Summit North Gerald CA 89404','(788)352-1349x7042\r'),(10,'Bradley Williams','48228 Jennifer Stream Suite 222 South Christopherton NE 90061','938-774-2648x715\r'),(11,'Mary Mathews','2716 Adams Mountains Suite 259 Jordanfort AR 99537','683.823.6337\r'),(12,'Jimmy Schroeder','6012 Morgan Lights Payneland, NM 63529','513.547.9029x1146\r'),(13,'Jamie Odom','72531 House Points Davidsonstad IA 68849','+1-719-634-2714x446\r'),(14,'Jeffrey Cook','77990 Young Flats Jeffreyshire WV 69382','001-635-553-4947x550'),(15,'Dana Smith','1752 Jessica Crossing Suite 413 West David MI 03554','(580)523-7099\r'),(16,'Molly Fox','11116 James Meadows Apt. 260 Eugenebury KS 99500','001-200-739-4353\r'),(17,'Emily Martinez','82706 Brandon Port East Brittany ME 33855','(435)653-4665\r'),(18,'Robert Tran','754 Gonzalez Branch Sandersmouth VI 34396','549-318-5475\r'),(19,'Virginia Hicks','7867 Jimmy Extensions Apt. 172 North Coltonport AL 48635','+1-254-845-9313x9700'),(20,'Tammy Carpenter','856 Dean Roads Matthewland NC 97336','+1-766-915-2892\r'),(21,'Brittany Hooper','942 May Cliffs New Deanna ND 09524','001-763-536-2067x339'),(22,'Ralph Palmer','094 Ronald Mission West Tina ND 77754','584-249-0851x8415\r'),(23,'Gabrielle Nguyen','680 Adam Creek Suite 839 Lake Danielshire MD 02987','+1-423-424-7547x376\r'),(24,'Christina Henderson','3646 Williams Via Fitzgeraldberg, DC 47220','250.600.8097x21454\r'),(25,'Catherine Johnson','822 Victor Brooks Apt. 521 Devonmouth CO 01167','(346)896-9525x8313\r'),(26,'Pamela Kirk','17728 Mary Tunnel Apt. 836 Anthonyton GA 48130','+1-373-529-0196x9583'),(27,'Vernon Richardson','9561 Pope Streets East Tanyaton CT 24710','348-202-0849x2384\r'),(28,'Anne Williams','622 Cook Underpass New Elizabeth NJ 63646','220-761-8939\r'),(29,'Victoria Randall','8304 Leslie Lodge Suite 625 Stuartberg AS 76425','550.975.5040x615\r'),(30,'Michelle Rodriguez','362 French Points Butlerfurt MT 59329','340.916.7263\r'),(31,'Nathan Crosby','9978 Zachary Point Suite 101 Port Loristad ID 80454','734-577-5626x35861\r'),(32,'Kristin Peterson','2233 Shaun Vista Suite 310 North Mary ND 76562','598-850-2295\r'),(33,'Nicholas Williams','3945 Jason Valley Jimenezstad AK 12463','485-255-7513x089\r'),(34,'Elizabeth Oconnor','5201 Gary Rapids Suite 271 Gentryton HI 08421','996.714.0750x9122\r'),(35,'Shelby Jackson','4907 Felicia Crossroad Suite 587 Jeffreyfort VI 53013','+1-431-355-3725x6468'),(36,'Kelly Hughes','3790 Carl Circles Davismouth WI 06701','(786)766-3126\r'),(37,'Rodney Howard','816 Jose Burg Hansonchester NY 09054','(671)930-1010x6976\r'),(38,'Megan Austin','9963 Anderson Extensions New Christopher IA 30748','514-645-7112x25331\r'),(39,'James Hutchinson','043 Michelle Lane Apt. 662 Stephenview OR 97081','001-983-612-5679x212'),(40,'Paula Miranda','94808 Silva Knolls Apt. 006 South Tonyaland IN 82147','(443)621-3113\r'),(41,'Mr. Nicholas Thompson','USNV Tanner FPO AE 88723','001-789-445-3919\r'),(42,'Kathryn Gordon','60915 Williams Mountains Apt. 764 North Roberto, VT 21833','931.848.0386x180\r'),(43,'Kayla Wood','647 David Drive New Donmouth MA 35741','310-603-6005x671\r'),(44,'James Rogers','053 Ellis Fall Suite 699 New Derrick LA 85050','(857)438-1197x9909\r'),(45,'Monica Vasquez','8511 Mcpherson Corner Carolynhaven ME 92456','945.967.8277x538\r'),(46,'Maria Hernandez','970 Christine Coves Suite 509 South Amanda, OR 39423','833.732.5490\r'),(47,'Emily Logan','08359 Bennett Motorway Gainesshire DC 20667','322-654-2700\r'),(48,'Matthew Patton','900 Jennifer Mission Apt. 669 Mooreshire UT 20804','775-957-6557x7373\r'),(49,'Christopher Thomas','Unit 9480 Box 3410 DPO AP 21280','895.798.2930\r'),(50,'Debbie Anderson','USNS Sanchez FPO AA 67272','866.286.0679\r'),(51,'Edward Chase','665 Kirk Shore Suite 143 New Sarahberg MS 66917','(393)200-4671\r'),(52,'Erica Elliott','487 Williams Passage Apt. 071 Swansonfort NE 52991','849.632.6012\r'),(53,'Glenda Mueller MD','995 Mario Groves Apt. 063 Thomasland WA 35973','001-443-287-4717x141'),(54,'Betty Salinas','476 Christine Mountains New Jenniferhaven MA 93135','+1-534-366-5836\r'),(55,'James Kidd','089 Jonathan Ford Suite 704 Fosterton NV 92944','+1-579-642-1050x5864'),(56,'Rachel Woodard','4347 Carol Ramp Vanessaport TN 92552','764.448.0150x461\r'),(57,'Samuel Parker','8143 Amy Camp North Parker IN 60501','+1-618-258-2048x204\r'),(58,'Bonnie Garcia','128 Richard Overpass North Karl MN 43856','202-622-7012x4185\r'),(59,'Anthony Gallagher','9585 Brooke Divide Apt. 759 South Bradleyshire, FL 02790','(981)297-4036x95880\r'),(60,'Michael Santos','70772 Ruth Hollow Lake Marc OR 00936','5086738372');
/*!40000 ALTER TABLE `Clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Detalle_Movimientos`
--

DROP TABLE IF EXISTS `Detalle_Movimientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Detalle_Movimientos` (
  `ID_Detalle_Movimiento` int NOT NULL AUTO_INCREMENT,
  `ID_Movimiento` int NOT NULL,
  `ID_Almacen_Origen` int DEFAULT NULL,
  `ID_Almacen_Destino` int NOT NULL,
  `ID_Material` int DEFAULT NULL,
  `ID_Maquina` int DEFAULT NULL,
  `Cantidad` int DEFAULT NULL,
  PRIMARY KEY (`ID_Detalle_Movimiento`),
  KEY `FK_Movimiento_Detalle_Movimientos` (`ID_Movimiento`),
  KEY `FK_Almacen_Origen_Detalle_Movimientos` (`ID_Almacen_Origen`),
  KEY `FK_Almacen_Destino_Detalle_Movimientos` (`ID_Almacen_Destino`),
  KEY `FK_Material_Detalle_Movimientos` (`ID_Material`),
  KEY `FK_Maquina_Detalle_Movimientos` (`ID_Maquina`),
  CONSTRAINT `FK_Almacen_Destino_Detalle_Movimientos` FOREIGN KEY (`ID_Almacen_Destino`) REFERENCES `Centros` (`ID_Centro`),
  CONSTRAINT `FK_Almacen_Origen_Detalle_Movimientos` FOREIGN KEY (`ID_Almacen_Origen`) REFERENCES `Centros` (`ID_Centro`),
  CONSTRAINT `FK_Maquina_Detalle_Movimientos` FOREIGN KEY (`ID_Maquina`) REFERENCES `Maquinas` (`ID_Maquina`),
  CONSTRAINT `FK_Material_Detalle_Movimientos` FOREIGN KEY (`ID_Material`) REFERENCES `Materiales` (`ID_Material`),
  CONSTRAINT `FK_Movimiento_Detalle_Movimientos` FOREIGN KEY (`ID_Movimiento`) REFERENCES `Movimientos` (`ID_Movimiento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Detalle_Movimientos`
--

LOCK TABLES `Detalle_Movimientos` WRITE;
/*!40000 ALTER TABLE `Detalle_Movimientos` DISABLE KEYS */;
/*!40000 ALTER TABLE `Detalle_Movimientos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Detalle_Pedidos_Compras`
--

DROP TABLE IF EXISTS `Detalle_Pedidos_Compras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Detalle_Pedidos_Compras` (
  `ID_Detalle_Pedido` int NOT NULL AUTO_INCREMENT,
  `ID_Pedido` int NOT NULL,
  `ID_Material` int NOT NULL,
  `Cantidad_Pendiente` int DEFAULT '0',
  PRIMARY KEY (`ID_Detalle_Pedido`),
  KEY `FK_Pedido_Detalle_Pedidos_Compras` (`ID_Pedido`),
  KEY `FK_Material_Detalle_Pedidos_Compras` (`ID_Material`),
  CONSTRAINT `FK_Material_Detalle_Pedidos_Compras` FOREIGN KEY (`ID_Material`) REFERENCES `Materiales` (`ID_Material`),
  CONSTRAINT `FK_Pedido_Detalle_Pedidos_Compras` FOREIGN KEY (`ID_Pedido`) REFERENCES `Pedidos_Compras` (`ID_Pedido`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Detalle_Pedidos_Compras`
--

LOCK TABLES `Detalle_Pedidos_Compras` WRITE;
/*!40000 ALTER TABLE `Detalle_Pedidos_Compras` DISABLE KEYS */;
/*!40000 ALTER TABLE `Detalle_Pedidos_Compras` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Detalle_Solicitudes`
--

DROP TABLE IF EXISTS `Detalle_Solicitudes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Detalle_Solicitudes` (
  `ID_Detalle_Solicitud` int NOT NULL AUTO_INCREMENT,
  `ID_Solicitud` int NOT NULL,
  `ID_Material` int DEFAULT NULL,
  `ID_Maquina` int DEFAULT NULL,
  `Cantidad` int DEFAULT NULL,
  PRIMARY KEY (`ID_Detalle_Solicitud`),
  KEY `FK_Solicitud_Detalle_Solicitudes` (`ID_Solicitud`),
  KEY `FK_Material_Detalle_Solicitudes` (`ID_Material`),
  KEY `FK_Maquina_Detalle_Solicitudes` (`ID_Maquina`),
  CONSTRAINT `FK_Maquina_Detalle_Solicitudes` FOREIGN KEY (`ID_Maquina`) REFERENCES `Maquinas` (`ID_Maquina`),
  CONSTRAINT `FK_Material_Detalle_Solicitudes` FOREIGN KEY (`ID_Material`) REFERENCES `Materiales` (`ID_Material`),
  CONSTRAINT `FK_Solicitud_Detalle_Solicitudes` FOREIGN KEY (`ID_Solicitud`) REFERENCES `Solicitudes` (`ID_Solicitud`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Detalle_Solicitudes`
--

LOCK TABLES `Detalle_Solicitudes` WRITE;
/*!40000 ALTER TABLE `Detalle_Solicitudes` DISABLE KEYS */;
INSERT INTO `Detalle_Solicitudes` VALUES (1,1,1,NULL,50),(2,1,2,NULL,30),(3,2,1,NULL,150),(4,2,3,NULL,200),(5,3,NULL,3,0),(6,4,NULL,1,0),(7,5,1,NULL,80),(8,5,NULL,2,0),(9,6,2,NULL,90),(10,6,NULL,4,0),(11,7,3,NULL,100),(12,7,NULL,5,0),(13,8,1,NULL,60),(14,8,NULL,6,0),(15,9,2,NULL,70),(16,9,NULL,7,0),(17,10,3,NULL,80),(18,10,NULL,8,0),(19,11,1,NULL,120),(20,11,NULL,9,0),(21,12,2,NULL,130),(22,12,NULL,10,0),(23,13,3,NULL,140),(24,14,1,NULL,100),(25,15,NULL,2,0),(26,16,2,NULL,75),(27,17,NULL,1,0),(28,18,1,NULL,90),(29,19,NULL,3,0),(30,20,20,NULL,85),(31,20,19,NULL,45),(32,20,1,NULL,1000);
/*!40000 ALTER TABLE `Detalle_Solicitudes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Empleados`
--

DROP TABLE IF EXISTS `Empleados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Empleados` (
  `ID_Empleado` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(255) NOT NULL,
  `Cargo` varchar(50) DEFAULT NULL,
  `Telefono` varchar(20) DEFAULT NULL,
  `ID_Centro` int DEFAULT NULL,
  `Tipo` enum('Obra','Deposito','Compras') NOT NULL,
  PRIMARY KEY (`ID_Empleado`),
  KEY `FK_Centros_Empleados` (`ID_Centro`),
  CONSTRAINT `FK_Centros_Empleados` FOREIGN KEY (`ID_Centro`) REFERENCES `Centros` (`ID_Centro`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Empleados`
--

LOCK TABLES `Empleados` WRITE;
/*!40000 ALTER TABLE `Empleados` DISABLE KEYS */;
INSERT INTO `Empleados` VALUES (1,'Juan Perez','Jefe de Obra','1234567890',1,''),(2,'Ana Gomez','Ingeniera Civil','2345678901',1,''),(3,'Roberto Diaz','Supervisor','3456789012',1,''),(4,'Maria Rodriguez','Obrero','4567890123',1,''),(5,'Luis Fernandez','Obrero','5678901234',1,''),(6,'Carla Martinez','Jefe de Deposito','6789012345',6,''),(7,'Pedro Lopez','Operador de Grúa','7890123456',6,''),(8,'Laura Sánchez','Auxiliar de Depósito','8901234567',6,''),(9,'Roberto Castro','Jefe de Obra','2345678901',10,''),(10,'Mario Lopez','Ingeniero de Proyecto','3456789012',10,''),(11,'Alberto Martinez','Obrero','4567890123',10,''),(12,'Claudia Rivas','Obrero','5678901234',10,''),(13,'Ricardo Perez','Jefe de Obra','6789012345',11,''),(14,'Andrea Diaz','Ingeniera de Proyecto','7890123456',11,''),(15,'Antonio Gomez','Supervisor','8901234567',11,''),(16,'Mónica Ramirez','Obrero','9012345678',11,''),(17,'Andres Vega','Obrero','0123456789',12,''),(18,'Veronica Ruiz','Jefe de Depósito','1234567890',8,''),(19,'Santiago Torres','Operador de Grua','2345678901',8,''),(20,'Laura Gonzalez','Auxiliar de Deposito','3456789012',8,''),(21,'Claudia Herrera','Jefe de Obra','7890123456',14,''),(22,'Óscar Morales','Ingeniero de Proyecto','8901234567',14,''),(23,'Silvia Lopez','Supervisor','9012345678',14,''),(24,'Juan Ramirez','Obrero','0123456789',14,''),(25,'Marta Gomez','Obrero','1234567890',15,''),(26,'Jose Martinez','Jefe de Obra','2345678901',15,''),(27,'Laura Fernandez','Ingeniera de Proyecto','3456789012',15,''),(28,'Daniela Rivas','Supervisor','4567890123',15,''),(29,'Oscar Diaz','Obrero','5678901234',15,''),(30,'Claudia Vargas','Jefe de Deposito','6789012345',7,''),(31,'Emilio Romero','Operador de Grua','7890123456',7,''),(32,'Veronica Martinez','Auxiliar de Deposito','8901234567',7,''),(33,'María Sanchez','Jefe de Obra','2345678901',18,''),(34,'Pedro Gomez','Ingeniero de Proyecto','3456789012',18,''),(35,'Claudia Diaz','Supervisor','4567890123',18,''),(36,'Luis Lopez','Obrero','5678901234',18,''),(37,'Andres Martinez','Obrero','6789012345',19,''),(38,'Mariana Ramirez','Jefe de Obra','7890123456',19,''),(39,'Jose Morales','Ingeniero de Proyecto','8901234567',19,''),(40,'Sofia Castro','Supervisor','9012345678',19,''),(41,'Ricardo Fernandez','Obrero','0123456789',19,'Obra');
/*!40000 ALTER TABLE `Empleados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Maquinas`
--

DROP TABLE IF EXISTS `Maquinas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Maquinas` (
  `ID_Maquina` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(255) NOT NULL,
  `Descripcion` text,
  `Estado` varchar(50) DEFAULT NULL,
  `ID_Proveedor` int DEFAULT NULL,
  PRIMARY KEY (`ID_Maquina`),
  KEY `FK_Proveedor_Maquinas` (`ID_Proveedor`),
  CONSTRAINT `FK_Proveedor_Maquinas` FOREIGN KEY (`ID_Proveedor`) REFERENCES `Proveedores` (`ID_Proveedor`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Maquinas`
--

LOCK TABLES `Maquinas` WRITE;
/*!40000 ALTER TABLE `Maquinas` DISABLE KEYS */;
INSERT INTO `Maquinas` VALUES (1,'Excavadora','Excavadora de orugas para movimiento de tierra','Operativa',9),(2,'Bulldozer','Bulldozer para nivelación de terreno','Operativa',12),(3,'Retroexcavadora','Retroexcavadora con pala y cubo','Operativa',6),(4,'Grúa','Grúa móvil para levantamiento de cargas','Operativa',16),(5,'Cargadora','Cargadora frontal para carga y descarga','Operativa',20),(6,'Pala mecánica','Pala mecánica para excavación','Operativa',11),(7,'Compactadora','Compactadora para suelo y asfalto','Operativa',5),(8,'Mezcladora','Mezcladora de cemento para mezclas','Operativa',18),(9,'Generador','Generador eléctrico para suministro de energía','Operativa',3),(10,'Compresora','Compresora de aire para herramientas neumáticas','Operativa',8),(11,'Taladro','Conjunto de taladros para perforación','Operativa',10),(12,'Soldadora','Soldadora eléctrica para metal','Operativa',15),(13,'Pulidora','Pulidora para acabados en metal','Operativa',17),(14,'Sierra','Sierra circular para corte de madera','Operativa',2),(15,'Cortadora de concreto','Cortadora de concreto para pavimentos','Operativa',14),(16,'Rodillo','Rodillo para compactación de asfalto','Operativa',19),(17,'Desbrozadora','Desbrozadora para vegetación','Operativa',4),(18,'Escavadora','Escavadora de brazo largo para zanjas','Operativa',13),(19,'Compresor','Compresor de tornillo para construcción','Operativa',7),(20,'Grúa torre','Grúa torre para edificios altos','Operativa',11),(21,'Motoniveladora','Motoniveladora para nivelación de carreteras','Operativa',12),(22,'Perforadora','Perforadora de suelo para pilotes','Operativa',8),(23,'Trituradora','Trituradora de escombros para reciclaje','Operativa',9),(24,'Mezcladora de asfalto','Mezcladora de asfalto para carreteras','Operativa',6),(25,'Aspersora','Aspersora para aplicación de líquidos','Operativa',16),(26,'Pulidora de pisos','Pulidora para pisos de concreto','Operativa',14),(27,'Bombas de agua','Bombas para evacuación de agua','Operativa',19),(28,'Motobomba','Motobomba para riego y drenaje','Operativa',20),(29,'Equipo de soldadura','Equipo completo de soldadura','Operativa',21),(30,'Cortadora de metal','Cortadora de metal para construcción','Operativa',10),(31,'Barredora','Barredora para limpieza de superficies','Operativa',22),(32,'Compresora de aire','Compresora de aire portátil','Operativa',5),(33,'Herramientas eléctricas','Conjunto de herramientas eléctricas','Operativa',18),(34,'Generador portátil','Generador portátil para pequeñas obras','Operativa',23),(35,'Sierra de banda','Sierra de banda para madera','Operativa',7),(36,'Cinta transportadora','Cinta transportadora para materiales','Operativa',2),(37,'Móvil de grúas','Unidad móvil de grúas para transporte','Operativa',11),(38,'Extractor de polvo','Extractor de polvo para talleres','Operativa',20),(39,'Elevador de materiales','Elevador para transporte vertical','Operativa',17),(40,'Plataforma elevadora','Plataforma para trabajos en altura','Operativa',22),(41,'Sistema de riego','Sistema de riego para obras','Operativa',8),(42,'Cortadora de asfalto','Cortadora especializada en asfalto','Operativa',12),(43,'Trituradora de madera','Trituradora de madera para desechos','Operativa',14),(44,'Pulverizador','Pulverizador para químicos','Operativa',19),(45,'Camión de volteo','Camión para descarga de materiales','Operativa',4),(46,'Rodillo de neumáticos','Rodillo para compactación con neumáticos','Operativa',16),(47,'Hidrolavadora','Hidrolavadora para limpieza de superficies','Operativa',21),(48,'Mezcladora de cemento','Mezcladora especializada en cemento','Operativa',15),(49,'Camión grúa','Camión con grúa para carga y descarga','Operativa',13),(50,'Cortadora de vidrio','Cortadora especializada en vidrio','Operativa',22);
/*!40000 ALTER TABLE `Maquinas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Materiales`
--

DROP TABLE IF EXISTS `Materiales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Materiales` (
  `ID_Material` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(255) NOT NULL,
  `Descripcion` text,
  `Unidad` varchar(10) DEFAULT NULL,
  `ID_Proveedor` int DEFAULT NULL,
  PRIMARY KEY (`ID_Material`),
  KEY `FK_Proveedor_Materiales` (`ID_Proveedor`),
  CONSTRAINT `FK_Proveedor_Materiales` FOREIGN KEY (`ID_Proveedor`) REFERENCES `Proveedores` (`ID_Proveedor`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Materiales`
--

LOCK TABLES `Materiales` WRITE;
/*!40000 ALTER TABLE `Materiales` DISABLE KEYS */;
INSERT INTO `Materiales` VALUES (1,'Cemento','Cemento Portland para construcción','saco',7),(2,'Arena','Arena de río para construcción','m3',12),(3,'Ladrillos','Ladrillos cerámicos de 20x20x40 cm','unidad',5),(4,'Vigas de acero','Vigas de acero estructural','metro',14),(5,'Grava','Grava para mezcla de concreto','m3',8),(6,'Piedra caliza','Piedra caliza para cimientos','m3',3),(7,'Tubos PVC','Tubos de PVC para tuberías','metro',15),(8,'Madera','Madera tratada para encofrado','m3',10),(9,'Mortero','Mortero de mezcla para albañilería','saco',6),(10,'Pegamento','Pegamento para cerámica','litro',20),(11,'Yeso','Yeso para paredes y techos','saco',19),(12,'Pintura','Pintura acrílica para interiores','litro',17),(13,'Revestimiento','Revestimiento para fachadas','m2',13),(14,'Aislante térmico','Aislante térmico para techos','m2',18),(15,'Clavos','Clavos de acero para madera','kg',21),(16,'Tornillos','Tornillos para construcción','kg',4),(17,'Sellador','Sellador para juntas de expansión','litro',22),(18,'Desinfectante','Desinfectante para superficies','litro',16),(19,'Cinta adhesiva','Cinta adhesiva de 50 mm','rollo',24),(20,'Alambre de acero','Alambre de acero para refuerzo','kg',11),(21,'Piedra angular','Piedra angular para cimientos','m3',30),(22,'Mallas de refuerzo','Mallas de acero para concreto','m2',9),(23,'Sierra','Sierra para madera y metal','unidad',23),(24,'Martillo','Martillo de construcción','unidad',31),(25,'Cinta métrica','Cinta métrica de 5 metros','unidad',28),(26,'Guantes','Guantes de trabajo','par',33),(27,'Casco','Casco de seguridad','unidad',12),(28,'Lentes','Lentes de seguridad','unidad',35),(29,'Mascarilla','Mascarilla para polvo','unidad',25),(30,'Botas','Botas de seguridad','par',26),(31,'Escalera','Escalera de aluminio','unidad',7),(32,'Nivel','Nivel de burbuja','unidad',8),(33,'Paleta','Paleta para mezcla de cemento','unidad',32),(34,'Alicate','Alicate de corte','unidad',13),(35,'Destornillador','Destornillador de punta plana','unidad',27),(36,'Cúter','Cúter de precisión','unidad',20),(37,'Linterna','Linterna de trabajo','unidad',11),(38,'Generador','Generador de electricidad','unidad',36),(39,'Compresora','Compresora de aire','unidad',14),(40,'Taladro','Taladro eléctrico','unidad',22),(41,'Pistola de pintura','Pistola para pintar','unidad',37),(42,'Mezcladora','Mezcladora de cemento','unidad',29),(43,'Carretilla','Carretilla para transporte de materiales','unidad',5),(44,'Cubo','Cubo de plástico para mezcla','unidad',7),(45,'Brocha','Brocha para pintura','unidad',38),(46,'Rodillo','Rodillo para pintura','unidad',39),(47,'Paleta de albañil','Paleta de albañil','unidad',40),(48,'Soplete','Soplete para soldadura','unidad',2),(49,'Máquina de corte','Máquina de corte de concreto','unidad',6),(50,'Pulidora','Pulidora para metal','unidad',15);
/*!40000 ALTER TABLE `Materiales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Movimientos`
--

DROP TABLE IF EXISTS `Movimientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Movimientos` (
  `ID_Movimiento` int NOT NULL AUTO_INCREMENT,
  `Fecha` date DEFAULT NULL,
  `Tipo` enum('Entrada','Salida','Transferencia') NOT NULL,
  `ID_Empleado` int NOT NULL,
  `ID_Autorizacion` int DEFAULT NULL,
  PRIMARY KEY (`ID_Movimiento`),
  KEY `FK_Empleado_Movimientos` (`ID_Empleado`),
  KEY `FK_Autorizacion_Movimientos` (`ID_Autorizacion`),
  CONSTRAINT `FK_Autorizacion_Movimientos` FOREIGN KEY (`ID_Autorizacion`) REFERENCES `Autorizaciones` (`ID_Autorizacion`),
  CONSTRAINT `FK_Empleado_Movimientos` FOREIGN KEY (`ID_Empleado`) REFERENCES `Empleados` (`ID_Empleado`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Movimientos`
--

LOCK TABLES `Movimientos` WRITE;
/*!40000 ALTER TABLE `Movimientos` DISABLE KEYS */;
/*!40000 ALTER TABLE `Movimientos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Pedidos_Compras`
--

DROP TABLE IF EXISTS `Pedidos_Compras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Pedidos_Compras` (
  `ID_Pedido` int NOT NULL AUTO_INCREMENT,
  `ID_Solicitud` int NOT NULL,
  `Fecha` date DEFAULT NULL,
  `ID_Empleado_Compras` int NOT NULL,
  PRIMARY KEY (`ID_Pedido`),
  KEY `FK_Solicitud_Pedidos_Compras` (`ID_Solicitud`),
  KEY `FK_Empleado_Compras_Pedidos_Compras` (`ID_Empleado_Compras`),
  CONSTRAINT `FK_Empleado_Compras_Pedidos_Compras` FOREIGN KEY (`ID_Empleado_Compras`) REFERENCES `Empleados` (`ID_Empleado`),
  CONSTRAINT `FK_Solicitud_Pedidos_Compras` FOREIGN KEY (`ID_Solicitud`) REFERENCES `Solicitudes` (`ID_Solicitud`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Pedidos_Compras`
--

LOCK TABLES `Pedidos_Compras` WRITE;
/*!40000 ALTER TABLE `Pedidos_Compras` DISABLE KEYS */;
/*!40000 ALTER TABLE `Pedidos_Compras` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Proveedores`
--

DROP TABLE IF EXISTS `Proveedores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Proveedores` (
  `ID_Proveedor` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(255) NOT NULL,
  `Direccion` varchar(255) DEFAULT NULL,
  `Telefono` varchar(20) DEFAULT NULL,
  `Rubro` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`ID_Proveedor`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Proveedores`
--

LOCK TABLES `Proveedores` WRITE;
/*!40000 ALTER TABLE `Proveedores` DISABLE KEYS */;
INSERT INTO `Proveedores` VALUES (1,'Proveedor A','Calle de Proveedores 1','1000000001','Materiales de Construcción\r'),(2,'Proveedor B','Calle de Proveedores 2','1000000002','Maquinaria Pesada\r'),(3,'Proveedor C','Calle de Proveedores 3','1000000003','Materiales de Construcción\r'),(4,'Proveedor D','Calle de Proveedores 4','1000000004','Maquinaria para Construcción\r'),(5,'Proveedor E','Calle de Proveedores 5','1000000005','Materiales de Construcción\r'),(6,'Proveedor F','Calle de Proveedores 6','1000000006','Equipos de Construcción\r'),(7,'Proveedor G','Calle de Proveedores 7','1000000007','Maquinaria de Construcción\r'),(8,'Proveedor H','Calle de Proveedores 8','1000000008','Materiales de Construcción\r'),(9,'Proveedor I','Calle de Proveedores 9','1000000009','Maquinaria y Herramientas\r'),(10,'Proveedor J','Calle de Proveedores 10','1000000010','Materiales de Construcción\r'),(11,'Proveedor K','Calle de Proveedores 11','1000000011','Equipos de Construcción\r'),(12,'Proveedor L','Calle de Proveedores 12','1000000012','Maquinaria Pesada\r'),(13,'Proveedor M','Calle de Proveedores 13','1000000013','Materiales de Construcción\r'),(14,'Proveedor N','Calle de Proveedores 14','1000000014','Maquinaria para Construcción\r'),(15,'Proveedor O','Calle de Proveedores 15','1000000015','Materiales de Construcción\r'),(16,'Proveedor P','Calle de Proveedores 16','1000000016','Equipos y Herramientas\r'),(17,'Proveedor Q','Calle de Proveedores 17','1000000017','Maquinaria de Construcción\r'),(18,'Proveedor R','Calle de Proveedores 18','1000000018','Materiales de Construcción\r'),(19,'Proveedor S','Calle de Proveedores 19','1000000019','Maquinaria Pesada\r'),(20,'Proveedor T','Calle de Proveedores 20','1000000020','Materiales de Construcción\r'),(21,'Proveedor U','Calle de Proveedores 21','1000000021','Equipos para Construcción\r'),(22,'Proveedor V','Calle de Proveedores 22','1000000022','Materiales de Construcción\r'),(23,'Proveedor W','Calle de Proveedores 23','1000000023','Maquinaria de Construcción\r'),(24,'Proveedor X','Calle de Proveedores 24','1000000024','Materiales de Construcción\r'),(25,'Proveedor Y','Calle de Proveedores 25','1000000025','Maquinaria para Construcción\r'),(26,'Proveedor Z','Calle de Proveedores 26','1000000026','Materiales de Construcción\r'),(27,'Proveedor AA','Calle de Proveedores 27','1000000027','Equipos de Construcción\r'),(28,'Proveedor BB','Calle de Proveedores 28','1000000028','Maquinaria Pesada\r'),(29,'Proveedor CC','Calle de Proveedores 29','1000000029','Materiales de Construcción\r'),(30,'Proveedor DD','Calle de Proveedores 30','1000000030','Equipos y Herramientas\r'),(31,'Proveedor EE','Calle de Proveedores 31','1000000031','Materiales de Construcción\r'),(32,'Proveedor FF','Calle de Proveedores 32','1000000032','Maquinaria para Construcción\r'),(33,'Proveedor GG','Calle de Proveedores 33','1000000033','Materiales de Construcción\r'),(34,'Proveedor HH','Calle de Proveedores 34','1000000034','Equipos de Construcción\r'),(35,'Proveedor II','Calle de Proveedores 35','1000000035','Maquinaria de Construcción\r'),(36,'Proveedor JJ','Calle de Proveedores 36','1000000036','Materiales de Construcción\r'),(37,'Proveedor KK','Calle de Proveedores 37','1000000037','Maquinaria Pesada\r'),(38,'Proveedor LL','Calle de Proveedores 38','1000000038','Materiales de Construcción\r'),(39,'Proveedor MM','Calle de Proveedores 39','1000000039','Equipos y Herramientas\r'),(40,'Proveedor NN','Calle de Proveedores 40','1000000040','Materiales de Construcción');
/*!40000 ALTER TABLE `Proveedores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Socios_Gerentes`
--

DROP TABLE IF EXISTS `Socios_Gerentes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Socios_Gerentes` (
  `ID_Socio_Gerente` int NOT NULL AUTO_INCREMENT,
  `Nombre` varchar(255) NOT NULL,
  `Telefono` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`ID_Socio_Gerente`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Socios_Gerentes`
--

LOCK TABLES `Socios_Gerentes` WRITE;
/*!40000 ALTER TABLE `Socios_Gerentes` DISABLE KEYS */;
INSERT INTO `Socios_Gerentes` VALUES (1,'Robin Lewis','9419387418\r'),(2,'Joanna Mills','(930)482-6356\r'),(3,'Christopher Kelley','+1-928-504-7167');
/*!40000 ALTER TABLE `Socios_Gerentes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Solicitudes`
--

DROP TABLE IF EXISTS `Solicitudes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Solicitudes` (
  `ID_Solicitud` int NOT NULL AUTO_INCREMENT,
  `Fecha` date DEFAULT NULL,
  `Tipo` enum('Material','Maquina') NOT NULL,
  `ID_Cliente` int DEFAULT NULL,
  `ID_Empleado` int NOT NULL,
  `Estado` enum('Pendiente','Parcial','Aprobada','Rechazada') DEFAULT 'Pendiente',
  `ID_Proveedor` int DEFAULT NULL,
  `ID_Centro` int NOT NULL,
  PRIMARY KEY (`ID_Solicitud`),
  KEY `FK_Cliente_Solicitudes` (`ID_Cliente`),
  KEY `FK_Empleado_Solicitudes` (`ID_Empleado`),
  KEY `FK_Proveedor_Solicitudes` (`ID_Proveedor`),
  KEY `FK_Centros_Solicitudes` (`ID_Centro`),
  CONSTRAINT `FK_Centros_Solicitudes` FOREIGN KEY (`ID_Centro`) REFERENCES `Centros` (`ID_Centro`),
  CONSTRAINT `FK_Cliente_Solicitudes` FOREIGN KEY (`ID_Cliente`) REFERENCES `Clientes` (`ID_Cliente`),
  CONSTRAINT `FK_Empleado_Solicitudes` FOREIGN KEY (`ID_Empleado`) REFERENCES `Empleados` (`ID_Empleado`),
  CONSTRAINT `FK_Proveedor_Solicitudes` FOREIGN KEY (`ID_Proveedor`) REFERENCES `Proveedores` (`ID_Proveedor`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Solicitudes`
--

LOCK TABLES `Solicitudes` WRITE;
/*!40000 ALTER TABLE `Solicitudes` DISABLE KEYS */;
INSERT INTO `Solicitudes` VALUES (1,'2024-06-01','Material',1,1,'Pendiente',1,1),(2,'2024-06-02','Material',2,2,'Aprobada',2,2),(3,'2024-06-03','Maquina',3,3,'Rechazada',3,3),(4,'2024-06-04','Material',4,4,'Aprobada',4,1),(5,'2024-06-05','Maquina',5,5,'Pendiente',5,4),(6,'2024-06-06','Material',6,6,'Aprobada',6,5),(7,'2024-06-07','Maquina',7,7,'Rechazada',7,6),(8,'2024-06-08','Material',8,8,'Pendiente',8,7),(9,'2024-06-09','Maquina',9,9,'Aprobada',9,8),(10,'2024-06-10','Material',10,10,'Rechazada',10,9),(11,'2024-06-11','Maquina',11,11,'Aprobada',11,10),(12,'2024-06-12','Material',12,12,'Pendiente',12,1),(13,'2024-06-13','Maquina',13,13,'Aprobada',13,2),(14,'2024-06-14','Material',14,14,'Rechazada',14,3),(15,'2024-06-15','Maquina',15,15,'Aprobada',15,4),(16,'2024-06-16','Material',16,16,'Pendiente',16,5),(17,'2024-06-17','Maquina',17,17,'Aprobada',17,6),(18,'2024-06-18','Material',18,18,'Rechazada',18,7),(19,'2024-06-19','Maquina',19,19,'Pendiente',19,8),(20,'2024-06-20','Material',20,20,'Aprobada',20,9);
/*!40000 ALTER TABLE `Solicitudes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `Vista_Maquinas_Deposito`
--

DROP TABLE IF EXISTS `Vista_Maquinas_Deposito`;
/*!50001 DROP VIEW IF EXISTS `Vista_Maquinas_Deposito`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `Vista_Maquinas_Deposito` AS SELECT 
 1 AS `Nombre_Centro`,
 1 AS `Nombre_Maquina`,
 1 AS `Descripcion`,
 1 AS `Estado`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `Vista_Materiales_Deposito`
--

DROP TABLE IF EXISTS `Vista_Materiales_Deposito`;
/*!50001 DROP VIEW IF EXISTS `Vista_Materiales_Deposito`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `Vista_Materiales_Deposito` AS SELECT 
 1 AS `Nombre_Centro`,
 1 AS `Nombre_Material`,
 1 AS `Cantidad`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `Vista_Movimientos`
--

DROP TABLE IF EXISTS `Vista_Movimientos`;
/*!50001 DROP VIEW IF EXISTS `Vista_Movimientos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `Vista_Movimientos` AS SELECT 
 1 AS `ID_Movimiento`,
 1 AS `Fecha`,
 1 AS `Tipo`,
 1 AS `Nombre_Centro`,
 1 AS `Nombre_Empleado`,
 1 AS `ID_Material`,
 1 AS `ID_Maquina`,
 1 AS `Cantidad`,
 1 AS `Nombre_Item`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `Vista_Solicitudes`
--

DROP TABLE IF EXISTS `Vista_Solicitudes`;
/*!50001 DROP VIEW IF EXISTS `Vista_Solicitudes`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `Vista_Solicitudes` AS SELECT 
 1 AS `ID_Solicitud`,
 1 AS `Fecha`,
 1 AS `Tipo`,
 1 AS `Nombre_Cliente`,
 1 AS `Nombre_Empleado`,
 1 AS `Nombre_Centro`,
 1 AS `ID_Material`,
 1 AS `ID_Maquina`,
 1 AS `Cantidad`,
 1 AS `Nombre_Item`,
 1 AS `Estado`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `Vista_SolicitudesPendientes`
--

DROP TABLE IF EXISTS `Vista_SolicitudesPendientes`;
/*!50001 DROP VIEW IF EXISTS `Vista_SolicitudesPendientes`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `Vista_SolicitudesPendientes` AS SELECT 
 1 AS `ID_Solicitud`,
 1 AS `Cliente`,
 1 AS `Empleado`,
 1 AS `Tipo`,
 1 AS `Estado`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `Vista_Stock_Maquinas`
--

DROP TABLE IF EXISTS `Vista_Stock_Maquinas`;
/*!50001 DROP VIEW IF EXISTS `Vista_Stock_Maquinas`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `Vista_Stock_Maquinas` AS SELECT 
 1 AS `ID_Centro`,
 1 AS `ID_Maquina`,
 1 AS `Nombre_Maquina`,
 1 AS `Stock_Actual`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `Vista_Stock_Materiales`
--

DROP TABLE IF EXISTS `Vista_Stock_Materiales`;
/*!50001 DROP VIEW IF EXISTS `Vista_Stock_Materiales`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `Vista_Stock_Materiales` AS SELECT 
 1 AS `ID_Centro`,
 1 AS `ID_Material`,
 1 AS `Nombre_Material`,
 1 AS `Stock_Actual`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'CentroLogistico'
--
/*!50003 DROP FUNCTION IF EXISTS `Funcion_ObtenerCantidadMaterialCentro` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `Funcion_ObtenerCantidadMaterialCentro`(
    centro_id INT,
    material_id INT
) RETURNS int
    READS SQL DATA
BEGIN
    DECLARE cantidad INT;
    
    SELECT Cantidad INTO cantidad
    FROM Almacenes_Materiales
    WHERE ID_Centro = centro_id AND ID_Material = material_id;
    
    IF cantidad IS NULL THEN
        RETURN 0; -- Si no se encuentra el material en el centro, retornar 0
    ELSE
        RETURN cantidad;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `Funcion_ObtenerCantidadMaterialPorCentro` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `Funcion_ObtenerCantidadMaterialPorCentro`(
    p_ID_Material INT
) RETURNS text CHARSET utf8mb4
    READS SQL DATA
BEGIN
    DECLARE resultado TEXT;
    DECLARE max_len INT DEFAULT 5000; -- Ajusta este valor según sea necesario

    -- Establecer un límite mayor para group_concat_max_len
    SET SESSION group_concat_max_len = max_len;

    -- Usar GROUP_CONCAT para construir la cadena de resultados
    SELECT GROUP_CONCAT(CONCAT('Centro ID: ', c.ID_Centro, ' - ', c.Nombre, ' - Cantidad: ', IFNULL(am.Cantidad, 0)) SEPARATOR '\n')
    INTO resultado
    FROM Centros c
    LEFT JOIN Almacenes_Materiales am ON c.ID_Centro = am.ID_Centro AND am.ID_Material = p_ID_Material;

    RETURN resultado;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `Funcion_ObtenerEstadoMaquina` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `Funcion_ObtenerEstadoMaquina`(ID_Maquina INT) RETURNS varchar(50) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
    DECLARE Estado VARCHAR(50);
    SELECT m.Estado INTO Estado
    FROM Maquinas m
    WHERE m.ID_Maquina = ID_Maquina;
    RETURN Estado;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_AprobarORechazarSolicitud` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_AprobarORechazarSolicitud`(
    IN p_ID_Solicitud INT,
    IN p_ID_Socio_Gerente INT,
    IN p_Accion VARCHAR(10) -- 'Aprobada' o 'Rechazada'
)
BEGIN
    DECLARE v_Accion_Valida BOOLEAN DEFAULT FALSE;

    -- Comprobar si la acción es válida
    IF p_Accion = 'Aprobada' OR p_Accion = 'Rechazada' THEN
        SET v_Accion_Valida = TRUE;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Acción no válida. Debe ser "Aprobada" o "Rechazada".';
    END IF;

    -- Crear o actualizar una autorización en la tabla Autorizaciones
    IF v_Accion_Valida THEN
        INSERT INTO Autorizaciones (ID_Solicitud, ID_Socio_Gerente, Estado, Fecha)
        VALUES (p_ID_Solicitud, p_ID_Socio_Gerente, p_Accion, NOW())
        ON DUPLICATE KEY UPDATE Estado = p_Accion, Fecha = NOW();

        -- Actualizar el estado de la solicitud en la tabla Solicitudes
        UPDATE Solicitudes
        SET Estado = p_Accion
        WHERE ID_Solicitud = p_ID_Solicitud;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_CrearSolicitud` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_CrearSolicitud`(
    IN p_Tipo ENUM('Material', 'Maquina'),
    IN p_ID_Cliente INT,
    IN p_ID_Empleado INT,
    IN p_ID_Centro INT,
    IN p_DetallesSolicitud JSON
)
BEGIN
    DECLARE v_ID_Solicitud INT;
    DECLARE v_ID_Item INT;
    DECLARE v_Cantidad INT;
    DECLARE v_Index INT DEFAULT 0;
    DECLARE v_Limit INT;

    -- Obtener el número de elementos en el JSON
    SET v_Limit = JSON_LENGTH(p_DetallesSolicitud);

    -- Crear la solicitud con estado 'Pendiente'
    INSERT INTO Solicitudes (Fecha, Tipo, ID_Cliente, ID_Empleado, ID_Centro, Estado)
    VALUES (CURDATE(), p_Tipo, p_ID_Cliente, p_ID_Empleado, p_ID_Centro, 'Pendiente');

    -- Obtener el ID de la solicitud recién creada
    SET v_ID_Solicitud = LAST_INSERT_ID();

    -- Iterar sobre los detalles de la solicitud
    WHILE v_Index < v_Limit DO
        -- Extraer ID_Item y Cantidad
        SET v_ID_Item = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_DetallesSolicitud, CONCAT('$[', v_Index, '].ID_Item'))) AS UNSIGNED);
        SET v_Cantidad = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_DetallesSolicitud, CONCAT('$[', v_Index, '].Cantidad'))) AS UNSIGNED);

        -- Insertar en Detalle_Solicitudes según el tipo (Material o Maquina)
        IF p_Tipo = 'Material' THEN
            INSERT INTO Detalle_Solicitudes (ID_Solicitud, ID_Material, Cantidad)
            VALUES (v_ID_Solicitud, v_ID_Item, v_Cantidad);
        ELSE
            INSERT INTO Detalle_Solicitudes (ID_Solicitud, ID_Maquina)
            VALUES (v_ID_Solicitud, v_ID_Item);
        END IF;

        -- Incrementar el índice para la próxima iteración
        SET v_Index = v_Index + 1;
    END WHILE;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_GenerarPedidoCompras` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GenerarPedidoCompras`(
    IN p_ID_Solicitud INT,
    IN p_ID_Empleado_Compras INT
)
BEGIN
    DECLARE v_ID_Material INT;
    DECLARE v_Cantidad INT;
    DECLARE v_CantidadDisponible INT;
    DECLARE v_CantidadPedir INT;
    DECLARE v_ID_Pedido INT;
    DECLARE done INT DEFAULT 0;
    DECLARE msj INT DEFAULT 0;
    DECLARE detalle_cursor CURSOR FOR
        SELECT ID_Material, Cantidad
        FROM Detalle_Solicitudes
        WHERE ID_Solicitud = p_ID_Solicitud;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Verificar si la solicitud está aprobada
    IF (SELECT COUNT(*) FROM Solicitudes WHERE ID_Solicitud = p_ID_Solicitud AND Estado = 'Aprobada') = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no está aprobada o no existe.';
    END IF;

    -- Crear el registro del pedido de compras para cada material
    INSERT INTO Pedidos_Compras (ID_Solicitud, Fecha, ID_Empleado_Compras)
    VALUES (p_ID_Solicitud, CURDATE(), p_ID_Empleado_Compras);

    -- Obtener el ID del pedido de compras recién creado
    SET v_ID_Pedido = LAST_INSERT_ID();

    -- Abrir el cursor
    OPEN detalle_cursor;

    -- Bucle para cada material en el detalle de la solicitud
    read_loop: LOOP
        FETCH detalle_cursor INTO v_ID_Material, v_Cantidad;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Obtener la cantidad disponible en centros de tipo "Deposito"
        SELECT IFNULL(SUM(Cantidad), 0) INTO v_CantidadDisponible
        FROM Almacenes_Materiales
        WHERE ID_Material = v_ID_Material AND ID_Centro IN (7, 8, 9);

        -- Si la cantidad disponible es suficiente, emitir advertencia y continuar
        IF v_CantidadDisponible >= v_Cantidad THEN
            -- Todo el material está disponible en depósitos, advertir y no crear pedido
            SET msj = 1; -- Salir del bucle en este caso

        ELSE
            -- Cantidad a pedir es la requerida menos la disponible en depósitos
            SET v_CantidadPedir = v_Cantidad - v_CantidadDisponible;

            -- Insertar el detalle del pedido de compras
            INSERT INTO Detalle_Pedidos_Compras (ID_Pedido, ID_Material, Cantidad_Pendiente)
            VALUES (v_ID_Pedido, v_ID_Material, v_CantidadPedir);
        END IF;

    END LOOP;

    -- Cerrar el cursor
    CLOSE detalle_cursor;
    
     -- Eliminar el pedido de compras si no se han creado detalles
    IF NOT EXISTS (SELECT 1 FROM Detalle_Pedidos_Compras WHERE ID_Pedido = v_ID_Pedido) THEN
        DELETE FROM Pedidos_Compras WHERE ID_Pedido = v_ID_Pedido;
    END IF;

    -- Señalar una advertencia al final del procedimiento si hay materiales completamente disponibles
    IF msj = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ADVERTENCIA: Uno o más materiales están completamente disponibles en depósitos.';
    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_RealizarMovimientoMaquinas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_RealizarMovimientoMaquinas`(
    IN p_ID_Solicitud INT,
    IN p_ID_Empleado INT,
    IN p_ID_Centro_Origen INT,
    IN p_Maquinas JSON -- JSON con pares {ID_Maquina:}
)
BEGIN
    DECLARE v_ID_Centro_Destino INT;
    DECLARE v_ID_Movimiento INT;
    DECLARE v_ID_Maquina INT;
    DECLARE v_Indice INT DEFAULT 0;
    -- DECLARE v_ID_Autorizacion INT;

    -- Obtener el centro de destino de la solicitud
    SELECT ID_Centro INTO v_ID_Centro_Destino
    FROM Solicitudes
    WHERE ID_Solicitud = p_ID_Solicitud;
    -- SELECT ID_Autorizacion INTO v_ID_Autorizacion
    -- FROM Autorizaciones
    -- WHERE ID_Solicitud = p_ID_Solicitud;

    -- Verificar si la solicitud está aprobada
    IF (SELECT Estado FROM Solicitudes WHERE ID_Solicitud = p_ID_Solicitud) != 'Aprobada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no está aprobada';
    END IF;

    -- Registrar el movimiento en la tabla 'Movimientos'
    INSERT INTO Movimientos (Fecha, Tipo, ID_Empleado) -- Agregar ID_Autorizacion
    VALUES (CURDATE(), 'Transferencia', p_ID_Empleado); -- Agregar v_ID_Autorizacion

    -- Obtener el ID del movimiento recién creado
    SET v_ID_Movimiento = LAST_INSERT_ID();

    -- Procesar las máquinas
    WHILE v_Indice < JSON_LENGTH(p_Maquinas) DO
        SET v_ID_Maquina = JSON_UNQUOTE(JSON_EXTRACT(p_Maquinas, CONCAT('$[', v_Indice, '].ID_Maquina')));

        INSERT INTO Almacenes_Maquinas (ID_Centro, ID_Maquina, Cantidad)
        VALUES (p_ID_Centro_Origen, v_ID_Maquina, -1);
        INSERT INTO Almacenes_Maquinas (ID_Centro, ID_Maquina)
        VALUES (v_ID_Centro_Destino, v_ID_Maquina);
        INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Origen, ID_Almacen_Destino, ID_Maquina)
        VALUES (v_ID_Movimiento, p_ID_Centro_Origen, v_ID_Centro_Destino, v_ID_Maquina);

        SET v_Indice = v_Indice + 1;
    END WHILE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_RealizarMovimientoMateriales` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_RealizarMovimientoMateriales`(
    IN p_ID_Solicitud INT,
    IN p_ID_Empleado INT,
    IN p_ID_Centro_Origen INT,
    IN p_Materiales JSON -- JSON con pares {ID_Material:, Cantidad:}
)
BEGIN
    DECLARE v_ID_Centro_Destino INT;
    DECLARE v_ID_Movimiento INT;
    DECLARE v_Cantidad INT;
    DECLARE v_ID_Material INT;
    DECLARE v_Indice INT DEFAULT 0;
    -- DECLARE v_Id_Autorizacion INT;

    -- Obtener el centro de destino de la solicitud
    SELECT ID_Centro INTO v_ID_Centro_Destino
    FROM Solicitudes
    WHERE ID_Solicitud = p_ID_Solicitud;
    -- SELECT ID_Autorizacion INTO v_ID_Autorizacion
    -- FROM Autorizaciones
    -- WHERE ID_Solicitud = p_ID_Solicitud;

    -- Verificar si la solicitud está aprobada y es de tipo 'Material'
    IF (SELECT Estado FROM Solicitudes WHERE ID_Solicitud = p_ID_Solicitud) != 'Aprobada'
        OR (SELECT Tipo FROM Solicitudes WHERE ID_Solicitud = p_ID_Solicitud) != 'Material' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no está aprobada o no es de tipo Material';
    END IF;

    -- Registrar el movimiento en la tabla 'Movimientos'
     INSERT INTO Movimientos (Fecha, Tipo, ID_Empleado) -- Agregar ID_Autorizacion
    VALUES (CURDATE(), 'Transferencia', p_ID_Empleado); -- Agregar v_ID_Autorizacion

    -- Obtener el ID del movimiento recién creado
    SET v_ID_Movimiento = LAST_INSERT_ID();

    -- Procesar los materiales
    WHILE v_Indice < JSON_LENGTH(p_Materiales) DO
        SET v_ID_Material = JSON_UNQUOTE(JSON_EXTRACT(p_Materiales, CONCAT('$[', v_Indice, '].ID_Material')));
        SET v_Cantidad = JSON_UNQUOTE(JSON_EXTRACT(p_Materiales, CONCAT('$[', v_Indice, '].Cantidad')));

        INSERT INTO Almacenes_Materiales (ID_Centro, ID_Material, Cantidad)
        VALUES (p_ID_Centro_Origen, v_ID_Material, -v_Cantidad);
        INSERT INTO Almacenes_Materiales (ID_Centro, ID_Material, Cantidad)
        VALUES (v_ID_Centro_Destino, v_ID_Material, v_Cantidad);
        INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Origen, ID_Almacen_Destino, ID_Material, Cantidad)
        VALUES (v_ID_Movimiento, p_ID_Centro_Origen, v_ID_Centro_Destino, v_ID_Material, v_Cantidad);
        SET v_Indice = v_Indice + 1;
    END WHILE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_RegistrarEntrada` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_RegistrarEntrada`(
    IN p_Tipo ENUM('Material', 'Maquina'),
    IN p_ID_Centro INT,
    IN p_ID_Item INT,
    IN p_Cantidad INT,
    IN p_ID_Empleado INT
)
BEGIN
    DECLARE v_ID_Movimiento INT;

    -- Registrar el movimiento en la tabla 'Movimientos'
    INSERT INTO Movimientos (Fecha, Tipo, ID_Empleado)
    VALUES (CURDATE(), 'Entrada', p_ID_Empleado);

    -- Obtener el ID del movimiento recién creado
    SET v_ID_Movimiento = LAST_INSERT_ID();

    IF p_Tipo = 'Material' THEN
        -- Registrar el detalle del movimiento para Materiales con cantidad positiva
        INSERT INTO Almacenes_Materiales (ID_Centro, ID_Material, Cantidad)
        VALUES (p_ID_Centro, p_ID_Item, p_Cantidad);
        
        -- Registrar el detalle del movimiento en Detalle_Movimientos
        INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Destino, Cantidad, ID_Material)
        VALUES (v_ID_Movimiento, p_ID_Centro, p_Cantidad, p_ID_Item);
    ELSE
        -- Registrar el detalle del movimiento para Maquinas
        INSERT INTO Almacenes_Maquinas (ID_Centro, ID_Maquina)
        VALUES (p_ID_Centro, p_ID_Item);

        -- Registrar el detalle del movimiento en Detalle_Movimientos
        INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Destino, Cantidad, ID_Maquina)
        VALUES (v_ID_Movimiento, p_ID_Centro, 1, p_ID_Item);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `SP_RegistrarSalida` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_RegistrarSalida`(
    IN p_Tipo ENUM('Material', 'Maquina'),
    IN p_ID_Centro INT,
    IN p_ID_Item INT,
    IN p_Cantidad INT,
    IN p_ID_Empleado INT
)
BEGIN
    DECLARE v_ID_Movimiento INT;
    
    -- Registrar el movimiento en la tabla 'Movimientos'
    INSERT INTO Movimientos (Fecha, Tipo, ID_Empleado)
    VALUES (CURDATE(), 'Salida', p_ID_Empleado);

    -- Obtener el ID del movimiento recién creado
    SET v_ID_Movimiento = LAST_INSERT_ID();

    IF p_Tipo = 'Material' THEN
        -- Registrar el detalle del movimiento para Materiales con cantidad negativa
        INSERT INTO Almacenes_Materiales (ID_Centro, ID_Material, Cantidad)
        VALUES (p_ID_Centro, p_ID_Item, -p_Cantidad);
        
        -- Registrar el detalle del movimiento en Detalle_Movimientos
        INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Destino, Cantidad, ID_Material)
        VALUES (v_ID_Movimiento, p_ID_Centro, -p_Cantidad, p_ID_Item);
    ELSE
        -- Registrar el detalle del movimiento para Maquinas con cantidad negativa
        INSERT INTO Almacenes_Maquinas (ID_Centro, ID_Maquina, Cantidad)
        VALUES (p_ID_Centro, p_ID_Item, -1); -- se maneja de a una máquina

        -- Registrar el detalle del movimiento en Detalle_Movimientos
        INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Destino, Cantidad, ID_Maquina)
        VALUES (v_ID_Movimiento, p_ID_Centro, -1, p_ID_Item);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `Vista_Maquinas_Deposito`
--

/*!50001 DROP VIEW IF EXISTS `Vista_Maquinas_Deposito`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `Vista_Maquinas_Deposito` AS select `C`.`Nombre` AS `Nombre_Centro`,`Maq`.`Nombre` AS `Nombre_Maquina`,`Maq`.`Descripcion` AS `Descripcion`,`Maq`.`Estado` AS `Estado` from ((`Almacenes_Maquinas` `AMQ` join `Centros` `C` on((`AMQ`.`ID_Centro` = `C`.`ID_Centro`))) join `Maquinas` `Maq` on((`AMQ`.`ID_Maquina` = `Maq`.`ID_Maquina`))) where (`C`.`Tipo` = 'Deposito') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `Vista_Materiales_Deposito`
--

/*!50001 DROP VIEW IF EXISTS `Vista_Materiales_Deposito`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `Vista_Materiales_Deposito` AS select `C`.`Nombre` AS `Nombre_Centro`,`M`.`Nombre` AS `Nombre_Material`,`AM`.`Cantidad` AS `Cantidad` from ((`Almacenes_Materiales` `AM` join `Centros` `C` on((`AM`.`ID_Centro` = `C`.`ID_Centro`))) join `Materiales` `M` on((`AM`.`ID_Material` = `M`.`ID_Material`))) where (`C`.`Tipo` = 'Deposito') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `Vista_Movimientos`
--

/*!50001 DROP VIEW IF EXISTS `Vista_Movimientos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `Vista_Movimientos` AS select `M`.`ID_Movimiento` AS `ID_Movimiento`,`M`.`Fecha` AS `Fecha`,`M`.`Tipo` AS `Tipo`,`C`.`Nombre` AS `Nombre_Centro`,`E`.`Nombre` AS `Nombre_Empleado`,`DS`.`ID_Material` AS `ID_Material`,`DS`.`ID_Maquina` AS `ID_Maquina`,`DS`.`Cantidad` AS `Cantidad`,(case when (`DS`.`ID_Material` is not null) then `Mat`.`Nombre` else `Maq`.`Nombre` end) AS `Nombre_Item` from (((((`Movimientos` `M` join `Empleados` `E` on((`M`.`ID_Empleado` = `E`.`ID_Empleado`))) join `Centros` `C` on((`E`.`ID_Centro` = `C`.`ID_Centro`))) left join `Detalle_Movimientos` `DS` on((`M`.`ID_Movimiento` = `DS`.`ID_Movimiento`))) left join `Materiales` `Mat` on((`DS`.`ID_Material` = `Mat`.`ID_Material`))) left join `Maquinas` `Maq` on((`DS`.`ID_Maquina` = `Maq`.`ID_Maquina`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `Vista_Solicitudes`
--

/*!50001 DROP VIEW IF EXISTS `Vista_Solicitudes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `Vista_Solicitudes` AS select `S`.`ID_Solicitud` AS `ID_Solicitud`,`S`.`Fecha` AS `Fecha`,`S`.`Tipo` AS `Tipo`,`C`.`Nombre` AS `Nombre_Cliente`,`E`.`Nombre` AS `Nombre_Empleado`,`CT`.`Nombre` AS `Nombre_Centro`,`DS`.`ID_Material` AS `ID_Material`,`DS`.`ID_Maquina` AS `ID_Maquina`,`DS`.`Cantidad` AS `Cantidad`,(case when (`DS`.`ID_Material` is not null) then `Mat`.`Nombre` else `Maq`.`Nombre` end) AS `Nombre_Item`,`S`.`Estado` AS `Estado` from ((((((`Solicitudes` `S` left join `Clientes` `C` on((`S`.`ID_Cliente` = `C`.`ID_Cliente`))) left join `Empleados` `E` on((`S`.`ID_Empleado` = `E`.`ID_Empleado`))) left join `Centros` `CT` on((`S`.`ID_Centro` = `CT`.`ID_Centro`))) left join `Detalle_Solicitudes` `DS` on((`S`.`ID_Solicitud` = `DS`.`ID_Solicitud`))) left join `Materiales` `Mat` on((`DS`.`ID_Material` = `Mat`.`ID_Material`))) left join `Maquinas` `Maq` on((`DS`.`ID_Maquina` = `Maq`.`ID_Maquina`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `Vista_SolicitudesPendientes`
--

/*!50001 DROP VIEW IF EXISTS `Vista_SolicitudesPendientes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `Vista_SolicitudesPendientes` AS select `s`.`ID_Solicitud` AS `ID_Solicitud`,`c`.`Nombre` AS `Cliente`,`e`.`Nombre` AS `Empleado`,`s`.`Tipo` AS `Tipo`,`s`.`Estado` AS `Estado` from ((`Solicitudes` `s` left join `Clientes` `c` on((`s`.`ID_Cliente` = `c`.`ID_Cliente`))) left join `Empleados` `e` on((`s`.`ID_Empleado` = `e`.`ID_Empleado`))) where (`s`.`Estado` = 'Pendiente') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `Vista_Stock_Maquinas`
--

/*!50001 DROP VIEW IF EXISTS `Vista_Stock_Maquinas`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `Vista_Stock_Maquinas` AS select `a`.`ID_Centro` AS `ID_Centro`,`a`.`ID_Maquina` AS `ID_Maquina`,`ma`.`Nombre` AS `Nombre_Maquina`,sum(`a`.`Cantidad`) AS `Stock_Actual` from (`Almacenes_Maquinas` `a` join `Maquinas` `ma` on((`a`.`ID_Maquina` = `ma`.`ID_Maquina`))) group by `a`.`ID_Centro`,`a`.`ID_Maquina`,`ma`.`Nombre` having (`Stock_Actual` <> 0) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `Vista_Stock_Materiales`
--

/*!50001 DROP VIEW IF EXISTS `Vista_Stock_Materiales`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `Vista_Stock_Materiales` AS select `a`.`ID_Centro` AS `ID_Centro`,`a`.`ID_Material` AS `ID_Material`,`m`.`Nombre` AS `Nombre_Material`,sum(`a`.`Cantidad`) AS `Stock_Actual` from (`Almacenes_Materiales` `a` join `Materiales` `m` on((`a`.`ID_Material` = `m`.`ID_Material`))) group by `a`.`ID_Centro`,`a`.`ID_Material`,`m`.`Nombre` having (`Stock_Actual` <> 0) */;
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

-- Dump completed on 2024-08-12 18:15:57
