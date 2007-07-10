<html>
<head>
	<title><?=$_ENV["COMPUTER_NAME"]?> - Screen</title>
	<link rel="stylesheet" href="/css/style.css" type="text/css" media="screen" charset="utf-8">
	    <meta name="viewport" id="viewport" content="width=1440, initial-scale=1.0, maximum-scale=1.0, minimum-scale=0.2," />
	<script src="/js/remote.js" type="text/javascript" charset="utf-8"></script>

	<meta http-equiv="expires" content="-1"> 
	<meta http-equiv="Pragma" content="no-cache"> 
	<meta http-equiv="Cache-Control" content="no-cache">

	<script type="text/javascript">
	var ctx;
	var img;
	var ctime;
	function $(o) {return document.getElementById(o);}

	function load() {
		ctx = $('cv').getContext("2d");
		img = new Image();
		img.onload = screenLoaded;
		loadImage();
	}
	
	function screenLoaded(e) {
		
		$('cv').width = img.width;
		$('cv').height = img.height;
		$('cv').style.width = img.width;
		$('cv').style.height = img.height;
		//$('textbar').style.width = img.width;
		ctx.drawImage(img, 0, 0, img.width, img.height);
		
		//	var c = document.cookie.split("=")[1].split("+");
		//ctx.drawImage(img, parseInt(c[0]), parseInt(c[1]), img.width, img.height);
		
		//ctime = setTimeout("loadImage()", 5000);
	}

	function loadImage() {
		img.src = '/t/grabscreen?' + Math.random();
	}
	var x;
	var y;
	
	

	function sendMouseEvent(type) {
		sendMouseEventXY(type, x, y, 0, 0);
	}
	function sendMouseEventXY(type, x1, y1, x2, y2) {
		img2 = new Image();
		img2.onload = loadImage;
		img2.src = "/t/mouseevent?x1=" + x1 + "&y1=" + y1 + "&type=" + type  + "&x2=" + x2  + "&y2=" + y2;

 		
		$('cursor').style.display = "none";
		reloadImage();
	}
	
	function moveMouse(e) {
		x = e.x;
		y = e.y;
		sendMouseEvent("move");
		$('cursor').style.display = "block";
	    $('cursor').style.top = e.y - 3;
	    $('cursor').style.left = e.x - 3;

	}
	
	
	var img2;
	function sendClick() {
		img2 = new Image();
		img2.onload = loadImage;
		img2.src = "/t/click?x=" + x + "&y=" + y;
		reloadImage();
	}
	
	function reloadImage() {
		clearTimeout(ctime);
		ctime = setTimeout("loadImage()", 100);
	}
	
	function sendString(str) {
		img2.src = "/t/keyevent?string=" + str;
		reloadImage();
	}
	var dragging;
	var dx, dy;
	function startDrag() {
		dx = x;
		dy = y;
		dragging = true;
    
    $('cursor').style.display = "none";
		 $('tools').className="dragging"
       
	}
	function endDrag(valid) {

		if (valid) {
			sendMouseEventXY("drag", dx, dy, x, y);
		} 
		dragging = false;
		 $('tools').className=null;
	}
	// window.onkeydown = handleKeyEvent;
	// window.onkeyup = handleKeyEvent;
	// window.onmousedown = handleMouseEvent;
	// window.onmouseup = handleMouseEvent;
	//window.onmousemove = handleMouseEvent;
	</script>
	
	<style type="text/css" media="screen">
	#cursor {
		background:url('cursor.png') no-repeat;
		z-index:100; position:absolute; top:-1; left:-1;
		padding-top:16px;
	}
	#cursor a{
		text-decoration:none;
		display:inline-block;
		border: 1px solid gray;
		padding:4px;
		color:black;
		-webkit-border-radius:5px;
		margin:2px;
	}
	#tools {
		background-color:white;
		padding:4px;
		-webkit-border-radius:7px;
		-webkit-box-shadow: 5px 5px 5px rgba(0, 0, 0, 0.5);
		border: 1px solid gray;
	}
	#tools #canceltool, #tools #droptool, #tools.dragging a, #tools.dragging input {
		display:none;
	}
	#tools.dragging #canceltool, #tools.dragging #droptool {
		display:inline-block;
	}
	</style>
</head>
<body onload="load();" bgcolor="black" style="padding:0; margin:0;">

<div id="cursor" style="display:none;">
	<form action="#" onsubmit="sendString($('textinput').value
	); $('textinput').value = ''; $('textinput').focus(); return false;">
	<div id="tools">
		<a id="clicktool" href="javascript:sendMouseEvent('click')">Click</a>
		<a id="rightclicktool"  href="javascript:sendMouseEvent('rightclick')">Right</a>
		<a id="dragtool"  href="javascript:startDrag()">Drag</a>
		<a id="droptool"  href="javascript:endDrag(true)">End Drag</a>
		<a id="canceltool"  href="javascript:endDrag(false)">Cancel</a>
		
<br>
			<input id="textinput" style="width:100%" type="text"></input>
			
	</div>
	</form>
	
</div>
<a onclick="moveMouse(event); return false;" href="#"><canvas id="cv" style="width:1024; height:768"></canvas></a>

  <div id="textbar" style="background-color:gray; padding: 0; margin:0">

</div> -->
</body>
</html>