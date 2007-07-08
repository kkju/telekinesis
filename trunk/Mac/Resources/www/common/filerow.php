<?
function file_row($file, $dir) {
  if (substr($file, 0, 1)!=".") {
    $path = "$dir/$file";
    $name = $file;
    $components = explode('.',$path);
    if (count($components)>1) {
      $extension = end($components);
    }
    
    
    $link =  "/files/$path";
    $blink =  "/t/open?path=$path";
    $blink_name =  "Open";
    
    switch($extension) {
      case "scpt":
        $blink =  "/t/runscript?path=$path";
        $blink_name = "Run";
      break;
	  case "mov":
	  case "m4a":
	  case "m4b":
	  case "mp4":
	  case "m4v":
      case "mp3": 
       $server = ereg_replace("\:[0-9]{4,4}", ":".$_ENV["MEDIA_PORT"], $_SERVER["HTTP_HOST"]); 
        $link = "http://".$server."/files/$path";
      break;
      case "app":
        $blink_name = "Launch";
        $name = substr($file, 0, strlen($file) - strlen($extension) - 1);
      break;
      default:
      if (is_dir($path)) {
        $show_arrow = true;
        $link =  "?dir=$path/";
        $blink = NULL;
      } else if (is_executable($path)) {
        $blink =  "/t/runscript?path=$path/";
      }
      break;
    }
    ?>
    
    <div class="iphonerow"><a style="display:block; color:black; text-decoration:none; font-family:lucida grande;" href="<?=$link?>">
    <img valign="middle" hspace=8 src="/t/icon?path=<?=urlencode($path)?>&size={32,32}" width="32" height="32"><?=$name?>
    <? if ($show_arrow) { echo '<img src="/images/ChildArrow.png">';} ?>    
    <? if ($blink) { ?>
      <a href="#" onclick="loadURL('<?=$blink?>'); return false;" class="button"><?=$blink_name?></a>
    <?}?>
    
    </a>
  </div>
<?
}
}
?>