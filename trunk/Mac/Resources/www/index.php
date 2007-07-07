<html>
  <head>
  <title><?=$_ENV["COMPUTER_NAME"]?></title>
<meta name="viewport" content="width=320, height=418" />
  <link rel="stylesheet" href="/css/style.css" type="text/css" media="screen" charset="utf-8">
  <link rel="stylesheet" href="/css/menu.css" type="text/css" media="screen" charset="utf-8">
  <script src="/js/remote.js" type="text/javascript" charset="utf-8">

  </script>
  </head>
  <body class="mainmenu" style="margin:0; padding:0;" onload="setTimeout(hideLocationBar,1000)">
  <div style="margin-left:10px;margin-right:10px;margin-top:20px;">
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
          ?>
            <div style="float:left;width:75;height:90px;text-align:center;";><a class="iconlink" target="app_<?=$file?>" href="<?=$app_path?>/"><img src="<?=$imagepath?>" width="57" height="57"><br><?=$name?></a></div>
          <?
        }
      }
      closedir($dh);
    }
  }
}

?>
  </div>
  <br clear="all">
  <div class="title" align="center" style="opacity:0.5;color:#FFF; position:absolute; width:100%; bottom:0px; padding-bottom:10px;">
<?php

//echo exec("whoami") . " @ ";
$SERVER_NAME = $_SERVER["SERVER_NAME"];
$IP = gethostbyname ($SERVER_NAME);
$server = gethostbyaddr($IP);
echo $_ENV["COMPUTER_NAME"];
?>
  </div>
  </body>
  </html>
