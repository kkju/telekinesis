<?
function file_row($path) {
  $file, $dir;
  
  if (substr($file, 0, 1)!=".") {
    $path = "$dir/$file";
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
      case "mp3": // "mov", "m4a", "m4b", "mp4", "m4v";
       $server = ereg_replace("\:[0-9]{4,4}", ":".$_ENV["MEDIA_PORT"], $_SERVER["HTTP_HOST"]); 
        $link = "http://".$server."/files/$path";
      break;
      case "app":
        $blink_name = "Launch";
      
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
    <img valign="middle" hspace=8 src="/t/icon?path=<?=urlencode($path)?>&size={32,32}" width="32" height="32"><?=$file?>
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