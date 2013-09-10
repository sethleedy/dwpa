-- phpMyAdmin SQL Dump
-- version 3.5.1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Sep 10, 2013 at 05:43 PM
-- Server version: 5.5.32-0ubuntu0.12.04.1
-- PHP Version: 5.3.10-1ubuntu3.8

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `wpa`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_work`()
    MODIFIES SQL DATA
    DETERMINISTIC
    SQL SECURITY INVOKER
SELECT * FROM onets, get_dict LIMIT 1$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `dicts`
--

CREATE TABLE IF NOT EXISTS `dicts` (
  `d_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `dpath` varchar(256) NOT NULL,
  `dhash` binary(16) DEFAULT NULL,
  `dname` varchar(128) NOT NULL,
  `wcount` int(10) unsigned NOT NULL,
  `hits` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`d_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=16 ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `get_dict`
--
CREATE TABLE IF NOT EXISTS `get_dict` (
`d_id` bigint(20) unsigned
,`dpath` varchar(256)
,`dhash` varchar(32)
);
-- --------------------------------------------------------

--
-- Table structure for table `n2d`
--

CREATE TABLE IF NOT EXISTS `n2d` (
  `net_id` bigint(15) NOT NULL,
  `d_id` int(11) NOT NULL,
  `hits` int(11) NOT NULL DEFAULT '1',
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`net_id`,`d_id`),
  KEY `IDX_n2d_ts` (`ts`),
  KEY `IDX_n2d_net_id` (`net_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Triggers `n2d`
--
DROP TRIGGER IF EXISTS `TRG_n2d`;
DELIMITER //
CREATE TRIGGER `TRG_n2d` BEFORE INSERT ON `n2d`
 FOR EACH ROW BEGIN
    UPDATE nets SET hits=hits+1 WHERE nets.net_id=NEW.net_id;
    UPDATE dicts SET hits=hits+1 WHERE dicts.d_id=NEW.d_id;
END
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `nets`
--

CREATE TABLE IF NOT EXISTS `nets` (
  `net_id` bigint(15) NOT NULL AUTO_INCREMENT,
  `bssid` bigint(15) unsigned NOT NULL,
  `ssid` varchar(32) NOT NULL,
  `pass` varchar(64) DEFAULT NULL,
  `ip` int(10) unsigned NOT NULL,
  `sip` int(10) unsigned DEFAULT NULL,
  `mic` binary(16) NOT NULL,
  `cap` varbinary(4096) NOT NULL,
  `hccap` varbinary(512) NOT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sts` timestamp NULL DEFAULT NULL,
  `n_state` tinyint(1) unsigned NOT NULL,
  `u_id` bigint(20) DEFAULT NULL,
  `hits` int(11) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`net_id`),
  UNIQUE KEY `IDX_net_mic` (`mic`),
  KEY `u_id` (`u_id`),
  KEY `IDX_nets_bssid` (`bssid`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=163182 ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `onets`
--
CREATE TABLE IF NOT EXISTS `onets` (
`net_id` bigint(15)
,`mic` varchar(32)
,`cap` varbinary(4096)
,`hccap` varbinary(512)
,`bssid` bigint(15) unsigned
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `onets_dicts`
--
CREATE TABLE IF NOT EXISTS `onets_dicts` (
`net_id` bigint(15)
,`d_id` int(11)
,`hits` int(11)
);
-- --------------------------------------------------------

--
-- Table structure for table `stats`
--

CREATE TABLE IF NOT EXISTS `stats` (
  `pname` varchar(20) NOT NULL,
  `pvalue` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`pname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `submissions`
--

CREATE TABLE IF NOT EXISTS `submissions` (
  `s_id` bigint(15) NOT NULL AUTO_INCREMENT,
  `s_name` binary(16) NOT NULL,
  `userhash` binary(16) NOT NULL,
  `info` text,
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '0 - processing 1 - processed',
  `ip` int(10) NOT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`s_id`),
  UNIQUE KEY `IDX_submissions_userhash` (`userhash`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='Capture file submissions' AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `u_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `userkey` binary(16) NOT NULL,
  `mail` varchar(500) CHARACTER SET latin1 COLLATE latin1_general_ci DEFAULT NULL,
  `ip` int(10) unsigned NOT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`u_id`),
  UNIQUE KEY `IDX_users_userkey` (`userkey`),
  UNIQUE KEY `IDX_users_mail` (`mail`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=1666 ;

-- --------------------------------------------------------

--
-- Structure for view `get_dict`
--
DROP TABLE IF EXISTS `get_dict`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `get_dict` AS select `d`.`d_id` AS `d_id`,`d`.`dpath` AS `dpath`,hex(`d`.`dhash`) AS `dhash` from (`dicts` `d` left join `onets_dicts` `od` on((`d`.`d_id` = `od`.`d_id`))) order by ifnull(`od`.`hits`,0),`d`.`wcount`;

-- --------------------------------------------------------

--
-- Structure for view `onets`
--
DROP TABLE IF EXISTS `onets`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `onets` AS select `nets`.`net_id` AS `net_id`,hex(`nets`.`mic`) AS `mic`,`nets`.`cap` AS `cap`,`nets`.`hccap` AS `hccap`,`nets`.`bssid` AS `bssid` from `nets` where (`nets`.`n_state` = 0) order by `nets`.`hits`,`nets`.`ts` limit 1;

-- --------------------------------------------------------

--
-- Structure for view `onets_dicts`
--
DROP TABLE IF EXISTS `onets_dicts`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `onets_dicts` AS select `n2d`.`net_id` AS `net_id`,`n2d`.`d_id` AS `d_id`,`n2d`.`hits` AS `hits` from (`n2d` join `onets` `o`) where (`n2d`.`net_id` = `o`.`net_id`);

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`root`@`localhost` EVENT `e_stats` ON SCHEDULE EVERY '0 2' DAY_HOUR STARTS '2011-09-18 17:31:07' ON COMPLETION NOT PRESERVE ENABLE COMMENT 'Computes last day stats every 1h am' DO BEGIN
        UPDATE stats SET pvalue=(SELECT count(*) FROM n2d WHERE date(ts) = DATE_SUB(CURDATE(), INTERVAL 1 DAY)) WHERE pname='24getwork';
        UPDATE stats SET pvalue=(SELECT sum(wcount) FROM n2d, dicts WHERE date(ts) = DATE_SUB(CURDATE(), INTERVAL 1 DAY) AND n2d.d_id=dicts.d_id) WHERE pname='24psk';
        UPDATE stats SET pvalue=(SELECT count(*) FROM nets WHERE date( ts ) = DATE_SUB( CURDATE() , INTERVAL 1 DAY)) WHERE pname='24sub';
        UPDATE stats SET pvalue=(SELECT sum(dicts.wcount) FROM nets, dicts WHERE nets.n_state=0) WHERE pname='words';
        UPDATE stats SET pvalue=(SELECT sum(dicts.wcount) FROM nets, n2d, dicts WHERE nets.n_state=0 AND nets.net_id = n2d.net_id AND dicts.d_id = n2d.d_id) WHERE pname='triedwords';
      END$$

DELIMITER ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
