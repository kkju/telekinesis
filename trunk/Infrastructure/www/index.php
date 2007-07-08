<html>
<head>
</head>
<body>
<?
error_reporting(E_ERROR | E_WARNING | E_PARSE);

// Connect to DB
$link = mysql_connect('localhost', '', '');
mysql_select_db("telekinesis", $link);

// Get user's external IP
$ip = (getenv(HTTP_X_FORWARDED_FOR))
    ?  getenv(HTTP_X_FORWARDED_FOR)
    :  getenv(REMOTE_ADDR);

// GLEN TOO LAZY TO REMEMBER PROPER JOINING SQL, SUFFER.
$getUserId = mysql_query("SELECT userid FROM ips WHERE ip = '$ip' ORDER BY userid DESC LIMIT 1");
$userid = mysql_result($getUserId, 0, "userid");

$getIps = mysql_query("SELECT ip FROM ips WHERE userid = '$userid'");
$getPorts = mysql_query("SELECT port, service FROM ports WHERE userid = '$userid'");

// Yes, this is redorkulous, but I appear to have forgotten everything
$ports = Array();
while ($portrow = mysql_fetch_array($getPorts)) {
  array_push($ports, Array($portrow[0], $portrow[1]));
}

while ($iprow = mysql_fetch_array($getIps)) {
  foreach($ports as $portValue) {
    $url = 'http://' . $iprow[0] . ':' . $portValue[0] . '/';
    echo "<a href=\"$url\">$url - $portValue[1]</a><br />";
  }
}
?>
</body>
</html>