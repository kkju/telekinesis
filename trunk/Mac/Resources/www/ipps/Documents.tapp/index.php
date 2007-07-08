<?php
$dir = $_ENV["HOME"]."/Documents/";
header("Location: /common/dirlist.php?dir=$dir");
exit;
?>