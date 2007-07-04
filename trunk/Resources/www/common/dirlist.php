<?php
$dir = $_GET["dir"];
if (!isset($dir)) $dir = $_ENV["HOME"];
$dir = realpath($dir)
?>

<html>
<head>
	<title>Telekinesis - <?=$dir?></title>
    <meta name="viewport" id="viewport" content="width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
	<link rel="stylesheet" href="/css/style.css" type="text/css" media="screen" charset="utf-8" />
	<script src="/js/remote.js" type="text/javascript" charset="utf-8" />
</head>

<body>

	<div class="container">
		<?php



	echo "<ul id=\"crumbs\">";
	/* get array containing each directory name in the path */
	$parts = explode("/", $dir);  
	echo "<li><a href=\"?dir=/\">" . $_ENV["COMPUTER_NAME"] . "</a></li>";
	foreach ($parts as $key => $component) {
		switch ($dir) {
			case "about": $label = "About Us"; break;
			/* if not in the exception list above, 
				use the directory name, capitalized */
			default: $label = ucwords($component); break;   
		}
		/* start fresh, then add each directory back to the URL */
		$url = "";
		for ($i = 1; $i <= $key; $i++) 
			{ $url .= $parts[$i] . "/"; }
		if ($component != "") 
			echo "<li> &#x25B6; <a href=\"?dir=/$url\">$label</a></li>";
	}
	echo "</ul>";

	// Open a known directory, and proceed to read its contents
	if (is_dir($dir)) {
		if ($dh = opendir($dir)) {
			while (($file = readdir($dh)) !== false) {
				if (substr($file, 0, 1)!=".") {
				if (substr($file, 0, 1)!=".") {
					$path = "$dir/$file";
					$extension = end(explode('.',$path));

					$is_script = ($extension == @"scpt");
					if (is_dir($path)) {
						$link =  "?dir=$path/";
					} else {
						$link =  "/files/$path";
					}

				
					?>
					<div class="iphonerow"><a style="display:block; color:black; text-decoration:none; font-family:lucida grande;" href="<?=$link?>">

						<img valign="middle" hspace=8 src="/t/icon?path=<?=urlencode($path)?>&size={32,32}" width="32" height="32"><?=$file?>
						<?
						if (is_dir($path)) {
							?><img src="/images/ChildArrow.png"><?
							
						}
						if ($is_script) { //} || is_executable($path)) {
							$scpt_link =  "/t/runscript?path=$path";
							?><a href="#" onclick="loadURL('<?=$scpt_link?>'); return false;" class="button">Run</a><?
						}
						?>


				
				</a>
					</div>
					<?
}
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
