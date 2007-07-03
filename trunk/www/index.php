<html>
<head>
	<title>Telekinesis</title>
	<meta name="viewport" content="width=320" />
	<link rel="stylesheet" href="/css/style.css" type="text/css" media="screen" charset="utf-8">
<script src="/js/remote.js" type="text/javascript" charset="utf-8">
window.scrollTo(0, 1);

</script>
</head>
<body class="mainmenu" onload="setTimeout(function(){window.scrollTo(0, 1);}, 100);">
<div class="title" align="center">
<?php

echo exec("whoami") . "@";
$SERVER_NAME = $_SERVER["SERVER_NAME"];
$IP = gethostbyname ($SERVER_NAME);
$server = gethostbyaddr($IP);
echo "$server";
?>
</div>
<hr>
<table width="100%"  border=0><tr>
<?php

$dirs = array("ipps", $_ENV["HOME"]."/Library/Application Support/Telekinesis/apps");
	$i = 0;

	// Open a known directory, and proceed to read its contents
foreach ($dirs as $dir) {
	if (is_dir($dir)) {
		if ($dh = opendir($dir)) {
			while (($file = readdir($dh)) !== false) {
				if (substr($file, 0, 1) !=".") {
					if ($i % 4 == 0) echo "</tr><tr>";
					$i++;
					
					$basepath = basename($dir);
					$app_path = "$basepath/$file";
					$imagepath = "$basepath/$file/$file.png";
					if (!file_exists($imagepath)) $imagepath = "/images/GenericApp.png";
					?>
					<td align="center"><a class="iconlink" target="app_<?=$file?>" href="<?=$app_path?>/"><img src="<?=$imagepath?>" width="56" height="56"><br><?=$file?></a></td>
					<?
				}
			}
			closedir($dh);
		}
	}
}

	?>
</tr></table>
</body>
</html>
