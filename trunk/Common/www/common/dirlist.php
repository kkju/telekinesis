<?php
$dir = $_GET["dir"];
if (!isset($dir)) $dir = $_ENV["HOME"];

if ($dir == "") $dir = "/Volumes/";

$dir = stripslashes($dir);

$dir = realpath($dir);

$iPhoneMode = strpos($_SERVER['HTTP_USER_AGENT'],"iPhone");
include("filerow.php");
?>

<html>

<head>
<title><?=$_ENV["COMPUTER_NAME"]?> - <?=$dir?></title>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<meta name="viewport" id="viewport" content="width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
<link rel="stylesheet" href="/css/style.css" type="text/css" media="screen" charset="utf-8" />
<script src="/js/remote.js" type="text/javascript" charset="utf-8"></script>
</head>

<body>

<div class="container">
<?php
echo "<ul id=\"crumbs\">";
	/* get array containing each directory name in the path */
	$parts = explode("/", $dir);  
	echo "<li><a href=\"?dir=\">" . $_ENV["COMPUTER_NAME"] . "</a></li>";

if ($parts[1] != "Volumes")
echo "<li> &#x25B6; <a href=\"?dir=/\">" . $_ENV["ROOT_VOLUME_NAME"] . "</a></li>";
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
    if ($url == "Volumes/") continue;
    $url = urlencode($url);
		if ($component != "") 
			echo "<li> &#x25B6; <a href=\"?dir=/$url\">$label</a></li>";
	}
	echo "</ul>";
echo "<ul class=\"iphonelist\">";
	// Open a known directory, and proceed to read its contents
	if (is_dir($dir)) {
		if ($dh = opendir($dir)) {
			$ignoredNames = array("Desktop DB", "Desktop DF");
      if ($dir == "/") $ignoredNames = array_merge( $ignoredNames, array("Network", "Icon\n", "cores", "bin", "etc", "mach", "mach.sym", "automount", "mach_kernel.ctfsys", "net", "private", "sbin", "tmp", "usr", "var", "home", "Volumes", "mach_kernel", "dev"));
      if ($dir == "/Volumes") {
        file_row("/", "");
        $ignoredNames[] = $_ENV["ROOT_VOLUME_NAME"];
      }
      while (($file = readdir($dh)) !== false) {
        if (in_array($file, $ignoredNames)) continue;
     
        file_row("$dir/$file");
			
      }
		closedir($dh);
	}
}
echo "</ul>";
?>
<!--
	// /t/icon?path=<?=$path?>&size={32,32}
	// cgi/nph-IconFetcher?path=<?=urlencode($path)?>&size={16,16}*/
-->
</div>
<iframe style="display:none" name="resultframe"></iframe>
</body>
</html>
