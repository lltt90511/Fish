<?php    
	$tabNameObj = array(
		"tpl_classic",
		"tpl_classicType",
		"tpl_vipExp",
		"tpl_quest",
		"tpl_questCountType",
		"tpl_chargeGift",
		"tpl_dailyGift",
		"tpl_charge",
		'tpl_random',
		'tpl_freeGold',
	);


	$serverAddr = "10.0.37.11";
	$user = "admin";
	$pass = "123456!@#";
	

	
	$dbName = "cash_tpl";
	$lang = 1;
	$langSet = array();
	$langSet[1] = "";
	$langSet[2] = "zhTW_";
	$langSet[3] = "enUS_";
	
	
	set_time_limit(10000000);	
	mysql_connect($serverAddr,$user,$pass);
	mysql_select_db($dbName);
	mysql_query("set names UTF8");
	mysql_query("set interactive_timeout=24*3600");
	mysql_query("set wait_timeout=24*3600");
	
	$SERVER_TEMPLATE_DIR = "../scripts/common/template/data/";
?>
