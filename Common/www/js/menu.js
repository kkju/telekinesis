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

function loadWidget(title) {
  window.title = title;

  if($(title)) {
    $(title)
  }
}

function Widget(title, appPath, isWidget, imagePath, useTabs) {
  this.title = title;
  this.appPath = appPath;
  this.imagePath = imagePath;
  this.isWidget = isWidget;
  
  this.liveWidget_ = null;
  this.ico_ = document.createElement('div');
  this.ico_.className = 'icon';

  this.icoLink_ = document.createElement('a');
  this.icoLink_.href = this.appPath;
  if (useTabs)
    this.icoLink_.target = 'app_'+this.title;
  addEvent(this.icoLink_, 'click', this.handleClick_.bind(this), true)

  this.icoImg_ = document.createElement('img');
  this.icoImg_.src = this.imagePath;

  this.icoTitle_ = document.createElement('span');
  this.icoTitle_.innerHTML = title;

  this.icoLink_.appendChild(this.icoImg_);
  this.icoLink_.appendChild(this.icoTitle_);
  this.ico_.appendChild(this.icoLink_);
  
  this.showingWidget = true;
  this.showInterval = null;

  $('icon-container').appendChild(this.ico_);
}

Widget.prototype.handleClick_ = function(e) {
  if (!this.isWidget) {
    return true; // do the HREF thing
  }
  
  if (!this.widgetContainer_) {
    this.widgetContainer_ = document.createElement('div');
    this.widgetContainer_.className = 'widget-container';
    this.widgetTitle_ = document.createElement('div');
    this.widgetTitle_.className = 'close';
    this.widgetTitle_.innerHTML = 'X'; // TODO: REPLACEME
    addEvent(this.widgetTitle_, 'click', this.handleClose_.bind(this), true);
    this.widget_ = document.createElement('iframe');

    this.widgetContainer_.appendChild(this.widget_);
    this.widgetContainer_.appendChild(this.widgetTitle_);
    this.widget_.src = this.appPath; // needs to occur after the appendChild

    // TODO: MAKE THIS A REAL URL
    document.body.appendChild(this.widgetContainer_);
  }
  
  this.beginShowWidget_();

  e.stopPropagation();
  e.preventDefault();
  e.cancelBubble = true;
}

Widget.prototype.beginShowWidget_ = function() {
  this.widgetContainer_.style.opacity = 0;
  this.widgetContainer_.style.display = '';
  this.showingWidget_ = true;
  this.showInterval_ = setInterval(this.updateWidget_.bind(this), 20);
}

Widget.prototype.beginHideWidget_ = function() {
  this.showingWidget_ = false;
  this.showInterval_ = setInterval(this.updateWidget_.bind(this), 20);
}

Widget.prototype.updateWidget_ = function() {
  var opacity = parseFloat(this.widgetContainer_.style.opacity) + (this.showingWidget_ ? 0.2 : -0.2);

  if (opacity > 1) {
    clearInterval(this.showInterval_);
    opacity = 1;
  } else if (opacity < 0) {
    clearInterval(this.showInterval_);
    opacity = 0;
    this.widgetContainer_.style.display = 'none';
  }

  this.widgetContainer_.style.opacity = opacity;
  this.widgetContainer_.style.top = (1 - opacity) * -18;
}

Widget.prototype.handleClose_ = function(e) {
  this.beginHideWidget_();
}