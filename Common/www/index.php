



<html>
<head>
  <title><?=$_ENV["COMPUTER_NAME"]?></title>
  <meta name="viewport" content="width=320, height=418" />
  <link rel="stylesheet" href="css/menu.css" type="text/css" media="screen" charset="utf-8">
  <script src="js/menu.js" type="text/javascript" charset="utf-8"></script>
<script src="/js/hidelocation.js" type="text/javascript" charset="utf-8" />
</head>

<?

$img_path = $_ENV["HOME"]."/Library/Application Support/iPhone Remote/Background.jpg";

if (!file_exists($img_path))
	$img_path = $_ENV["HOME"]."/Library/Application Support/iPhone Remote/Background.default.jpg";

//echo $img_path;
if (!file_exists($img_path)) {
  echo '<body>';
} else {
  echo "<body style=\"background: black url('/files/$img_path');\">";
}

include("common/defaults.php");
$useTabs = readDefault("openAppsInNewTab");
if (!$useTabs) $useTabs = 0;
?>

<div id="icon-container"></div>
<br clear="all">
<div class="page-title" align="center">
  <?=$_ENV["COMPUTER_NAME"];?> - <?=$_ENV["USER_FULLNAME"];?>
</div>
<script type="text/javascript">
<?php
$dirs = array("tapps", $_ENV["HOME"] . "/Library/Application Support/iPhone Remote/Apps");

foreach ($dirs as $dir) {
  if (is_dir($dir) && $dh = opendir($dir)) {
    while (($file = readdir($dh)) !== false) {
      if (substr($file, -5, 5) == ".tapp") {
        $name = substr($file, 0, strrpos($file, '.')); // remove Extension

        $basepath = basename($dir);
        $app_path = "$basepath/$file";
        
        $imagepath = realpath("$dir/$file/Icon.png");

        // if the image doesn't exist, try a different type
        if (!file_exists($imagepath)) {
          $imagepath = realpath("$dir/$file/$name.png");
        }

        if (file_exists($imagepath)) {
          // set the path to something a client can use
          $imagepath = "/files/" . $imagepath;
        } else {
          // give the user a generic image
          $imagepath = "/images/GenericApp.png";
        }
        
        
        $info_path = realpath("$dir/$file/Info.plist");
        if (file_exists($info_path))
          $app_path = '/t/tapp?path=/' . $app_path;
        
        echo "new Widget('$name', '$app_path', false, '$imagepath', $useTabs);";
      }
    }

    closedir($dh);
  }
}
?>
</script>
</body>
</html>