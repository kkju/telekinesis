<?
function file_row($path) {detail_file_row($path, NULL, NULL);}
function detail_file_row($path, $name, $details) {
  if (!strncmp($path, "http://", 5)  ){
    $url = $path;
    if (!$name) $name = basename($path);
    ?>
    
    <li class="iphonerow">
    <img class="arrow" align="right" src="/images/ChildArrow.png">  
    <a class="rowlink" href="<?=$url?>">
    <img class="icon" src="/images/BookmarkGlobe.png" width="32" height="32">
    <span class="name"><?=$name?></span> 
      <br><span class="details"><?=$url?></span>
    
    </a>
    </li>
    <?
    return ;
  }
  
  if (!strncmp($path, "file://", 5)  ){
      $path = parse_url($path);
      $path = urldecode($path['path']);
      $path = realpath($path);
  }
  
  $dir = dirname($path);
  $file = basename($path);
  if (substr($file, 0, 1)!=".") {
    if (!$name)
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
	  case "m4p":
       $server = ereg_replace("\:[0-9]{4,4}", ":".$_ENV["MEDIA_PORT"], $_SERVER["HTTP_HOST"]); 
        $link = "http://".$server."/files". str_replace("%2F","/",rawurlencode($path)); // keep slashes safe in this case
      break;
      case "app":
        $link = NULL;
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

<li class="iphonerow">
      <? if ($rlink) { ?> <a href="#" onclick="loadURL('<?=$rlink?>'); return false;" class="rlink-button"><?=$rlink_name?></a><?}?>
      
      <? if ($show_arrow) { echo '<img class="arrow" align="right" src="/images/ChildArrow.png">';} ?>   
      <a class="rowlink"  
      <?= $link ? "" : 'onclick="return false;"'?>
      href="<?=$link?>">
<img class="icon" src="/t/icon?path=<?=rawurlencode($path)?>&size={32,32}" width="32" height="32">
      <span class="name"><?=$name?></span> 
      
      <? if ($details) { ?><br><span class="details"><?=$details?></span><?}?>
      
    </a>
  </li>
<?
}
}
?>