<html>
<head>
  <title>Telekinesis Echolocation</title>
  <style type="text/css">
  body {
    font-family: "Helvetica Neue", "Helvetica";
    font-size:11px;
    color:white;
    background-color:#333388;
  }
  
  a.button {
    /* Default positioning of button */
    display: block;
    margin: 0 auto;
    text-align:center;
    line-height: 46px; /* will keep the text vertically
            centered on the 46px high button */       

    font-size: 20px;

    /* Font styling */
    font-family: Arial;
    font-weight: bold;
    text-decoration: none;
    text-transform: capitalize;

    /* Button image is 29px wide.
      14px for the left part of the button
      14px for the right
      1px for the middle
    */
    border-left: 14px;
    border-right: 14px;
  }
  a.white.button {
    color: #000;
    text-shadow: #fff 0px 1px 1px;
    -webkit-border-image: url(i/whiteButton.png) 0 14 0 14;
  }
  a.gray.button {
    color: #fff;
    text-shadow: #333 0px 1px 1px;
    -webkit-border-image: url(i/grayButton.png) 0 14 0 14;
  }
  a.button:hover {
    color: #fff;
    text-shadow: #333 0px 1px 1px;
    -webkit-border-image: url(i/blueButton.png) 0 14 0 14;
  }

  a.last.button {
    margin-top: 10px;
  }
  div.options-extend {
    padding: 20px 20px 15px;
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    background: url(images/options-extend.png) repeat-x top left;
  }
  </style>
  <script type="text/javascript">
  function $(o) {return document.getElementById(o);}

  (function () {
    function toArray(pseudoArray) {
      var result = [];
      for (var i = 0; i < pseudoArray.length; i++)
        result.push(pseudoArray[i]);
      return result;
    }

    Function.prototype.bind = function (object) {
      var method = this;
      var oldArguments = toArray(arguments).slice(1);
      return function () {
        var newArguments = toArray(arguments);
        return method.apply(object, oldArguments.concat(newArguments));
      };
    }

    Function.prototype.bindEventListener = function (object) {
      var method = this;
      var oldArguments = toArray(arguments).slice(1);
      return function (event) {
        return method.apply(object, event || window.event, oldArguments);
      };
    }
  })();

  function addEvent(obj, evType, fn, useCapture){
    if (obj.addEventListener){
      obj.addEventListener(evType, fn, useCapture);
      return true;
    } else if (obj.attachEvent){
      var r = obj.attachEvent("on"+evType, fn);
      return r;
    } else {
      alert("Handler could not be attached");
    }
  }

  var machineList = {};
  
  function addMachine(name, uid) {
    var m = new Machine(name, uid);
    machineList[uid] = m;
    return m;
  }
  
  function testMachines() {
    for (var i in machineList) {
      machineList[i].ping();
    }
  }
  
  function Machine(name, uid) {
    this.name = name;
    this.uid = uid;
    this.ips = [];
    this.ports = [];
    
    this.loaded = false; // whether we have detected a live machine
  }
  
  Machine.prototype.addIP = function(ip) {
    this.ips.push(ip);
  }
  
  Machine.prototype.addPort = function(port, service) {
    this.ports.push({
      port : port,
      service : service
    });
  }
  
  Machine.prototype.ping = function() {
    this.pingList_ = [];
    
    for (var portIndex in this.ports) {
      var port = this.ports[portIndex];
      
      if (port.service == 'main') {
        for (var ipIndex in this.ips) {
          var ip = this.ips[ipIndex];
          var script = document.createElement('script');
          var address = ip + ':' + port.port;
          script.src = 'http://' + address + '/t/test/?id=' + this.uid + ':' + address;
          $('scripts').appendChild(script);
        }
      }
    }
  }

  Machine.prototype.createIcon = function(address) {
    this.shortcut = document.createElement('a');
    this.shortcut.className = 'white button';
    this.shortcut.href = 'http://' + address + '/';
    this.shortcut.innerHTML = this.name;
    
    $('machines').appendChild(this.shortcut);
  }
  
  function found(id) {
    var id = id.split(':');
    machineList[id[0]].createIcon(id[1]);
  }
  </script>
</head>
<body>
<div id="machines"></div>
<div id="scripts"></div>

<?
error_reporting(E_ERROR | E_WARNING | E_PARSE);

// Connect to DB
$link = mysql_connect('localhost', '', '');
mysql_select_db("telekinesis", $link);

// Get user's external IP
$ip = (getenv(HTTP_X_FORWARDED_FOR))
    ?  getenv(HTTP_X_FORWARDED_FOR)
    :  getenv(REMOTE_ADDR);

echo '<script type="text/javascript">';

// GLEN TOO LAZY TO REMEMBER PROPER JOINING SQL, SUFFER.
$getMachines = mysql_query("SELECT 
                              users.id as userid,
                              users.name as name,
                              users.uid as uid
                            FROM users, ips 
                            WHERE 
                              ips.ip = '$ip' AND
                              users.id = ips.userid AND
                              users.created >= NOW() - 1600
                            ORDER BY userid DESC");

while ($machineRow = mysql_fetch_array($getMachines)) {
  $userid = $machineRow[0];
  echo "var m = addMachine('$machineRow[1]', '$machineRow[2]');";

  // Yes, this is redorkulous, but I appear to have forgotten everything
  // I will remember when the caffiene wears off.
  $getPorts = mysql_query("SELECT port, service FROM ports WHERE userid = '$userid'");
  while ($portrow = mysql_fetch_array($getPorts)) {
    echo "m.addPort('$portrow[0]', '$portrow[1]');";
  }

  $getIps = mysql_query("SELECT ip FROM ips WHERE userid = '$userid'");
  while ($iprow = mysql_fetch_array($getIps)) {
    echo "m.addIP('$iprow[0]');";
  }
}
echo 'testMachines();';
echo '</script>';
?>
</body>
</html>