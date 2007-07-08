<?
// Connect to DB
$link = mysql_connect('localhost', '', '');
mysql_select_db("telekinesis", $link);

// Get submitted vars
$ips = explode(",", mysql_real_escape_string($_GET['ips']));
$ports = explode(",", mysql_real_escape_string($_GET['ports']));
$uid = mysql_real_escape_string($_GET['uid']);
$name = mysql_real_escape_string($_GET['name']);

if (!$uid || !$name) {
  echo "-1,no name or uid provided";
  exit();
}

// Get user's external IP
$ip = (getenv(HTTP_X_FORWARDED_FOR))
    ?  getenv(HTTP_X_FORWARDED_FOR)
    :  getenv(REMOTE_ADDR);

array_push($ips, $ip);

// Insert user entry
mysql_query("INSERT INTO users (uid, name) VALUES ('$uid', '$name')");
$id = mysql_insert_id();

// Insert IP addresses
$multiInsert = "";
$i = 0;
foreach($ips as $value) {
  if ($i != 0) {
    $multiInsert .= ",";
  }
  $multiInsert .= "($id, '$value')";
  $i++;
}

mysql_query("INSERT INTO ips (userid, ip) VALUES $multiInsert");

// Insert ports
$multiInsert = "";
$i = 0;
foreach($ports as $value) {
  if ($i != 0) {
    $multiInsert .= ",";
  }
  $value = explode(':', $value);
  $port = $value[0];
  $service = $value[1];

  $multiInsert .= "($id, '$port', '$service')";
  $i++;
}

mysql_query("INSERT INTO ports (userid, port, service) VALUES $multiInsert");
?>