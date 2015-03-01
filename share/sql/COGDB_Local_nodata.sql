-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: ircf-login-0-1    Database: COGDB_Local
-- ------------------------------------------------------
-- Server version	5.1.73-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `COGDB_Local`
--

USE `COGDB_Local`;

--
-- Table structure for table `Organism`
--

DROP TABLE IF EXISTS `Organism`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Organism` (
  `ID` smallint(6) unsigned NOT NULL AUTO_INCREMENT,
  `Code` tinytext NOT NULL,
  `Name` tinytext NOT NULL,
  `Description` tinytext,
  `Division` varchar(20) NOT NULL DEFAULT 'unknown',
  `Other` int(11) DEFAULT NULL,
  `ID_Local` tinytext NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM AUTO_INCREMENT=55 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Whog`
--

DROP TABLE IF EXISTS `Whog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Whog` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) NOT NULL DEFAULT '',
  `ID_Organism` smallint(6) unsigned NOT NULL DEFAULT '0',
  `ID_COG` smallint(6) unsigned NOT NULL DEFAULT '0',
  `Orf_name` varchar(20) NOT NULL DEFAULT 'unknown',
  `Novel` tinyint(1) unsigned DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `ID_Organism` (`ID_Organism`)
) ENGINE=MyISAM AUTO_INCREMENT=283539 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Whog_absent`
--

DROP TABLE IF EXISTS `Whog_absent`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Whog_absent` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(20) DEFAULT NULL,
  `ID_Organism` smallint(6) unsigned NOT NULL DEFAULT '0',
  `ID_COG` smallint(6) unsigned NOT NULL DEFAULT '0',
  `Orf_name` varchar(20) NOT NULL DEFAULT 'unknown',
  PRIMARY KEY (`ID`),
  KEY `ID_Organism` (`ID_Organism`)
) ENGINE=MyISAM AUTO_INCREMENT=7676 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-02-27 17:19:00
