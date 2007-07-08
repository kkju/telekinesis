<html>
<head>
  <title><?=$_ENV["COMPUTER_NAME"]?></title>
  <meta name="viewport" content="width=320, height=418" />
  <link rel="stylesheet" href="css/menu.css" type="text/css" media="screen" charset="utf-8">
  <script src="js/menu.js" type="text/javascript" charset="utf-8"></script>
</head>
<body>
<div id="icon-container"></div>
<br clear="all">
<div class="page-title" align="center">
  <?=$_ENV["COMPUTER_NAME"];?>
</div>
<script type="text/javascript">
<?php
$dirs = array("ipps", $_ENV["HOME"] . "/Library/Application Support/iPhone Remote/Apps");

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

        echo "new Widget('$name', '$app_path', false, '$imagepath');";
      }
    }

    closedir($dh);
  }
}
?>
</script>
</body>
</html>