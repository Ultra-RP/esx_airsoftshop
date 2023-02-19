

CREATE TABLE `airsoftshops` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`zone` varchar(255) NOT NULL,
	`item` varchar(255) NOT NULL,
	`price` int(11) NOT NULL,

	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


INSERT INTO `airsoftshops` (`zone`, `item`, `price`) VALUES
	('GunShop','WEAPON_AIRSOFTAK47', 300),
	('GunShop','WEAPON_AIRSOFTG36C', 300),
	('GunShop','WEAPON_AIRSOFTGlock20', 300),
	('GunShop','WEAPON_AIRSOFTM4', 300),
	('GunShop','WEAPON_AIRSOFTM249', 300),
	('GunShop','WEAPON_AIRSOFTMicroUzi', 300),
	('GunShop','WEAPON_AIRSOFTMP5', 300),
	('GunShop','WEAPON_AIRSOFTR700', 300),
	('GunShop','WEAPON_AIRSOFTR870', 300),
;
--