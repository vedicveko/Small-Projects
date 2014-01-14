--
-- Table structure for table `reddit_posts`
--

CREATE TABLE IF NOT EXISTS `reddit_posts` (
  `seq` int(11) NOT NULL AUTO_INCREMENT,
  `reddit_id` varchar(255) NOT NULL,
  `title` mediumtext NOT NULL,
  `thumbnail` varchar(255) NOT NULL,
  `permalink` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `complete_post` mediumtext NOT NULL,
  `reposted` tinyint(4) NOT NULL,
  PRIMARY KEY (`seq`),
  KEY `reddit_id` (`reddit_id`),
  KEY `url` (`url`),
  KEY `reposted` (`reposted`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=269 ;

