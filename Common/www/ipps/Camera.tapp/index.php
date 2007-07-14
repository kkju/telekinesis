<html>
<title><?=$_ENV["COMPUTER_NAME"]?> - Camera</title>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">

	<script>
	function $(o) {return document.getElementById(o);}
	</script>
	<meta name="viewport" content="width=640, inital-scale=0.5, maximum-scale:1.0" />
</head>
<body style="background-color:black; margin:0;">

	<!-- newer firewire-and-USB-friendly CGI -->
	<a onclick="$('shot').src = '/cgi/bw-iSightGrab?' + Math.random();" href="#"><img id="shot" src="/cgi/bw-iSightGrab" ></a>

	<!-- the original cgi 
	<a onclick="$('shot').src = '/cgi/nph-SnapshotWeb?' + Math.random();" href="#"><img id="shot" src="/cgi/nph-SnapshotWeb" ></a> -->
	
</body>
</html>