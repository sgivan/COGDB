-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: ircf-login-0-1    Database: COGDB2014
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
-- Current Database: `COGDB2014`
--

USE `COGDB2014`;

--
-- Table structure for table `Accessions`
--

DROP TABLE IF EXISTS `Accessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Accessions` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `OrgID` int(10) NOT NULL,
  `Accession` varchar(20) NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Accession` (`Accession`),
  KEY `OrgID-Acc` (`OrgID`,`Accession`)
) ENGINE=MyISAM AUTO_INCREMENT=5214 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `COG`
--

DROP TABLE IF EXISTS `COG`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `COG` (
  `ID` smallint(6) unsigned NOT NULL DEFAULT '0',
  `Name` varchar(10) NOT NULL DEFAULT '',
  `Description` tinytext,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `ID` (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `COG__Category`
--

DROP TABLE IF EXISTS `COG__Category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `COG__Category` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ID_COG` smallint(6) unsigned NOT NULL DEFAULT '0',
  `ID_Category` smallint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  KEY `ID_COG` (`ID_COG`,`ID_Category`)
) ENGINE=MyISAM AUTO_INCREMENT=5164 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Category`
--

DROP TABLE IF EXISTS `Category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Category` (
  `ID` smallint(3) unsigned NOT NULL DEFAULT '0',
  `Code` char(1) NOT NULL DEFAULT '',
  `Name` tinytext NOT NULL,
  `Description` tinytext,
  `ID_Super` smallint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `ID` (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Division`
--

DROP TABLE IF EXISTS `Division`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Division` (
  `ID` tinyint(3) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(40) NOT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Name` (`Name`)
) ENGINE=MyISAM AUTO_INCREMENT=46 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Organism`
--

DROP TABLE IF EXISTS `Organism`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Organism` (
  `ID` smallint(6) unsigned NOT NULL AUTO_INCREMENT,
  `Code` varchar(6) DEFAULT NULL,
  `Name` tinytext NOT NULL,
  `Description` tinytext,
  `Division` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `Other` int(11) DEFAULT NULL,
  `extend` tinyint(1) NOT NULL DEFAULT '0',
  `pathogen` tinyint(1) NOT NULL DEFAULT '0',
  `GB_ACC` tinytext,
  `Proteins` smallint(5) unsigned DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `Code` (`Code`)
) ENGINE=MyISAM AUTO_INCREMENT=2807 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SuperCategory`
--

DROP TABLE IF EXISTS `SuperCategory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SuperCategory` (
  `ID` smallint(3) unsigned NOT NULL DEFAULT '0',
  `Name` tinytext NOT NULL,
  `Description` tinytext,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `ID` (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `Whog`
--

DROP TABLE IF EXISTS `Whog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Whog` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(100) NOT NULL,
  `ID_Organism` smallint(6) unsigned NOT NULL DEFAULT '0',
  `ID_COG` smallint(6) unsigned NOT NULL DEFAULT '0',
  `Novel` tinyint(1) unsigned DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `Name` (`Name`),
  KEY `Org-Cog` (`ID_Organism`,`ID_COG`)
) ENGINE=MyISAM AUTO_INCREMENT=3611955 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-02-27 17:16:10
