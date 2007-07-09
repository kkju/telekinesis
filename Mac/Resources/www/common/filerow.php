<?
function file_row($file, $dir) {
  if (substr($file, 0, 1)!=".") {
    $path = realpath("$dir/$file");
    $name = $file;
    if ($path == "/") $name = $_ENV["ROOT_VOLUME_NAME"];
    $components = explode('.',$path);
    if (count($components)>1) {
      $extension = end($components);
    }
    
    $link =  str_replace("%2F","/",rawurlencode("/files/$path"));
    $rlink =  "/t/open?path=".rawurlencode($path);
    $rlink_name =  "Open";
    
    switch($extension) {
      
      case "sh":
      case "pl":
      case "rb":
      case "py":
        if (!is_executable($path)) break;
        case "scpt":
        $rlink =  "/t/runscript?path=$path";
        $rlink_name = "Run";
      break;
	  case "mov":
	  case "m4a":
	  case "m4b":
	  case "mp4":
	  case "m4v":
      case "mp3": 
       $server = ereg_replace("\:[0-9]{4,4}", ":".$_ENV["MEDIA_PORT"], $_SERVER["HTTP_HOST"]); 
        $link = "http://".$server."/files". str_replace("%2F","/",rawurlencode($path)); // keep slashes safe in this case
      break;
      case "app":
        $rlink_name = "Launch";
        $name = substr($file, 0, strlen($file) - strlen($extension) - 1);
      break;
      default:
      if (is_dir($path)) {
        $show_arrow = true;
        $link =  "?dir=".rawurlencode($path)."/";
        $rlink = NULL;
      } 
      //  else if (is_executable($path)) {
//        $rlink =  "/t/runscript?path=$path/";
//      }
      break;
    }
    ?>

<div class="iphonerow">
      <? if ($rlink) { ?> <a href="#" onclick="loadURL('<?=$rlink?>'); return false;" class="rlink-button"><?=$rlink_name?></a><?}?>
      
      <? if ($show_arrow) { echo '<img class="arrow" align="right" src="/images/ChildArrow.png">';} ?>   
      <a style="display:block; color:black; text-decoration:none; font-family:lucida grande;" href="<?=$link?>">
<img class="icon" src="/t/icon?path=<?=rawurlencode($path)?>&size={32,32}" width="32" height="32">
      <span><?=$name?></span> 
    
    </a>
  </div>
<?
}
}
?>