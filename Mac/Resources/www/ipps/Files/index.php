<?php
$dir = $_ENV["HOME"];
header("Location: /common/dirlist.php?dir=$dir");
exit;
?>