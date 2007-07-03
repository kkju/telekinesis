<html>
<head>
	<title>Telekinesis - Remote</title>
	<meta name="viewport" content="width=320" />
	<link rel="stylesheet" href="/css/style.css" type="text/css" media="screen" charset="utf-8" />
	<script src="/js/remote.js" type="text/javascript" charset="utf-8" />
</head>
<body>

	<div style="padding:10px;">
	<?php

$dir = $_GET["dir"];
if (!isset($dir)) $dir = "/Volumes/Lore/Library/Scripts/";
echo ($dir);
echo "<hr>";
// Open a known directory, and proceed to read its contents
if (is_dir($dir)) {
	if ($dh = opendir($dir)) {
		while (($file = readdir($dh)) !== false) {
			if ($file!="." && $file!=".." && $file!=".DS_Store") {
				$path = "$dir$file";

				if (is_dir($path)) {
					$link =  "?dir=$path/";
					?>
					<div class="iphonerow"><a style="color:black; text-decoration:none; font-family:lucida grande;" href="<?=$link?>">
						<?
					} else {
						$link =  "/t/runscript?path=$path";
						?>
						<div class="iphonerow"><a style="color:black; text-decoration:none; font-family:lucida grande;" onclick="loadURL('<?=$link?>'); return false;" href="#">
							<?
						}
						?>
						<img valign="middle" hspace=2 src="/cgi/nph-IconFetcher?path=<?=urlencode($path)?>&size={16,16}" width="32" height="32"><?=$file?></a>
					</div>
					<?

			}
		}
		closedir($dh);
	}
}

?>
<!--
// /t/icon?path=<?=$path?>&size={32,32}
// cgi/nph-IconFetcher?path=<?=urlencode($path)?>&size={16,16}*/
-->
</div>
<iframe style="display:none" name="resultframe"></iframe>
</body>
</html>
