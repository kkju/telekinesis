var BASEURL = '/t/telekinesis?';

function handleKeyEvent(e) {
sendData({
  't' : e.type,
  'k' : e.keyCode,
  's' : e.shiftKey,
  'c' : String.fromCharCode(e.keyCode)
});

return false;
}

function hideLocationBar() {
  setTimeout(hideLocationBarNow, 100);
}
function hideLocationBarNow() {
  window.scrollTo(0, 1);
}
function handleMouseEvent(e) {
sendData({
  't' : e.type,
  'b' : e.button,
  // these coords may also be clientX/Y, offsetX/Y, pageX/Y - test
  'x' : e.screenX,
  'y' : e.screenY
});
  
  return false;
}
function loadURL(url) {
  // We use images to get around the two-connection limit
  // note that it would be far better from a resource usage
  // standpoint if we just created an array of images and
  // reused them, but this will do as a proof of concept.
  var img = new Image();
  img.src = url;

  //document.body.innerHTML = url;
  return false;
}

function sendURL(data, url) {
  // TODO: Array speedup
  for (var key in data) {
    url += key + "=" + data[key] + "&";
  }
  loadURL(url);
}

function sendData(data) {
  var url = BASEURL;
  sendURL(data, url);
  //alert(url);
}