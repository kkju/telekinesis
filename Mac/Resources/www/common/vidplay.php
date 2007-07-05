<?php
$path = $_GET["path"];
$dir = realpath($dir)
?>

<html>
<head>
	<title>Telekinesis - <?=$dir?></title>
    <meta name="viewport" id="viewport" content="width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
</head>

<body>
<EMBED HREF="/files/<?=$path?>" TYPE="video/x-m4v" TARGET="myself" SCALE="1">
</body>
</html>