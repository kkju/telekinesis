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
<?php
  //echo exec("whoami") . " @ ";
  $SERVER_NAME = $_SERVER["SERVER_NAME"];
  $IP = gethostbyname ($SERVER_NAME);
  $server = gethostbyaddr($IP);
  echo $_ENV["COMPUTER_NAME"];
?>
</div>
<script type="text/javascript">
<?php
$dirs = array("ipps", $_ENV["HOME"]."/Library/Application Support/iPhone Remote/Apps");
$i = 0;
// Open a known directory, and proceed to read its contents
foreach ($dirs as $dir) {
  if (is_dir($dir)) {
    if ($dh = opendir($dir)) {
      while (($file = readdir($dh)) !== false) {
        if (substr($file, 0, 1) !=".") {
          $i++;

          $name = $file;
          if (substr($file, -5, 5) == ".tapp") //continue; // Ignore non-tapps
          $name = substr($name, 0, strrpos($name,'.')); // remove Extension

          $basepath = basename($dir);
          $app_path = "$basepath/$file";
          $imagepath = "$dir/$file/Icon.png";
          $imagepath = realpath($imagepath);

          if (!file_exists($imagepath)) {
            $imagepath = "$dir/$file/$name.png";
            $imagepath = realpath($imagepath);
          }

          if (file_exists($imagepath)) {
            $imagepath = "/files/" . $imagepath;
          } else {
            $imagepath = "/images/GenericApp.png";
          }

          echo "new Widget('$name', '$app_path', false, '$imagepath');";
        }
      }

      closedir($dh);
    }
  }
}
?>
</script>
</body>
</html>