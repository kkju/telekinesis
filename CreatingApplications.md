# Introduction #

Adding functionality to iPhone Remote is simple, there are two approaches, basic web pages and custom servers.

Both of these are still very much in flux, advice and suggestions are welcome!

Make sure to let us know about .tapps you've made -- we'll add them to the [telekinesis-tapps project](http://code.google.com/p/telekinesis-tapps/).




## Basic Web Page ##

  * Since access to pages will be restricted to the current user and the communications encrypted, you can feel free to blatantly disregard any normal security concerns in web pages. That's the whole point. :)

  * Create a simple web page in html/php, etc and install it in
> > `~/Library/Application Support/iPhone Remote/Apps/<App Name>.tapp`
  * **Changed:** The `.tapp` extension is required for an app to be recognized. This is eventually intended to make installing them easier.
  * Give it a custom icon. (Get the [template](http://telekinesis.blacktree.com/TappTemplate.png). It's there, just white)
> > `.../Apps/<App Name>.tapp/<App Name>.png`



## Custom Servers ##

For more advanced apps, you may want to provide web content directly.
iPhone Remote is able to launch another program and proxy traffic to its port. An Info.plist inside the tapp defines this behavior:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>proxyPort</key>
	<integer>8022</integer>
	<key>startTask</key>
	<dict>
		<key>arguments</key>
		<array>
			<string>-c</string>
			<string>/bin/sh</string>
		</array>
		<key>path</key>
		<string>./WebShell-0.2.2/ajaxterm.py</string>
	</dict>
</dict>
</plist>
```

This task is run the first time the application is clicked after the server starts. A "stopTask" key with the same structure will be used to shut down the server. If none is specified, the original task will just be terminated.

## Built in functionality ##

The iPhone Remote server supports some basic functionality that may be useful in any application:

  * Running Applescripts: /t/runscript?path=<relative path>&app=<App Name>
    * Optional arguments: &handler=

<handler\_name>

&argument=

&lt;argument1&gt;

&argument=

&lt;argument2&gt;

....
  * Screen capture: /t/grabscreen
  * Move click: /t/click?x=100&y=100
  * Move mouse: /t/mousemove?x=100&y=100
  * File Icons: /t/icon?path=<Absolute path>