<?php
include "../../common/filerow.php";

$kind = array(
'Applications'=>'kind:application', //, kind:applications, kind:app
'Contacts'=>'kind:contact', //, kind:contacts
'Folders'=>'kind:folder', //, kind:folders
'Email'=>'kind:email', //, kind:emails, kind:mail message, kind:mail messages
'iCal Events'=>'kind:event', //, kind:events
'iCal To Dos'=>'kind:todo', //, kind:todos, kind:to do, kind:to dos
'Images'=>'kind:image', //, kind:images
'Movies'=>'kind:movie', //, kind:movies
'Music'=>'kind:music', //
'Audio'=>'kind:audio', //
'PDF'=>'kind:pdf', //, kind:pdfs
'Preferences'=>'kind:system preferences', //, kind:preferences
'Bookmarks'=>'kind:bookmark', //, kind:bookmarks
'Fonts'=>'kind:font', //, kind:fonts
'Presentations'=>'kind:presentations', //, kind:presentation
);

function get_filename($s, $a=array()){
	foreach($a as $v){
		if(strpos($v, 'ItemDisplayName')){
			$start = strpos($v, '"')+1;
			$end = strrpos($v, '"');
			$filename = substr($v, $start, $end-$start);
			break;
		}
	}
	if(!$filename){
		$aF = explode('/',$s);
		$filename = $aF[count($aF)-1];
	}
	return $filename;
}


?>
<html>

<head>
<title><?=$_ENV["COMPUTER_NAME"]?> - Spotlight</title>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<meta name="viewport" id="viewport" content="width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
<link rel="stylesheet" href="/css/style.css" type="text/css" media="screen" charset="utf-8" />
<script src="/js/remote.js" type="text/javascript" charset="utf-8" />
</head>

<body>

<div class="container">
<ul id="crumbs"><li><a href="index.php">Spotlight</a></li><?=($_REQUEST['kind'])?'<li> &#x25B6; '.array_search($_REQUEST['kind'], $kind).'</li>':''?><?=($_REQUEST['find'])?'<li> &#x25B6; '.$_REQUEST['find'].'</li>':''?></ul>

	<form action="<?=$_SERVER['PHP_SELF']?>" method="post">
	<input type="image" value="Spotlight" src="Spotlight128.png" width="25px" height="25px" style="padding-top: 5px; float: right; padding-right: 10px;" />
	<div style="padding-top: 5px;">
		<input type="text" name="find" value="<?=($_REQUEST['find'])?$_REQUEST['find']:''?>" style="height: 20px;" />
		<select name="kind" style="height: 20px;">
		<option value="">All</option>
		<?
		foreach($kind as $k=>$v){

		   if($kind[$k] == $_REQUEST['kind'])
		   {
			   $selected = ' selected';
			}else{
			   $selected = '';
			}
		?>
		<option value="<?=$v?>" <?=$selected?>><?=$k?></option>
		<?
		}
		?>
		</select>
	</div>

</form>
<?php
if($_REQUEST['find']){
	$sFind = $_REQUEST['find'];
	$sKind = $_REQUEST['kind'];
	exec('mdfind -onlyin / "'.$sFind.' '.$sKind.'"', $aFind);
	
	echo count($aFind);
	echo " matches";
	echo "<ul class=\"iphonelist\">";

	foreach($aFind as $path){
		$file = basename($path);
		$dir = dirname($path);
		file_row("$path");
	}
	echo "</ul>";
}
?>
</div>
</body>
</html>