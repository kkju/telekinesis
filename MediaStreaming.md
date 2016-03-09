## Streaming video and audio ##

If you store movie or music files on your computer, you can watch and listen to them on your iPhone using telekinesis after enabling  the feature in the preference pane. **This feature is off by default for security reasons, please see below.**

The files you play have to be supported by the iPhone:

  * H.264 Baseline Profile Level 3.0 video, up to 640 x 480 at 30 fps.
  * MPEG-4 Part 2 video (Simple Profile)
  * AAC-LC audio, up to 48 kHz
  * .mov, .mp4, .m4v, .3gp file formats
  * Any movies or audio files that can play on an iPod, including protected files if the iPhone is authorized to play them.

Over EDGE you stream media in real time up to 160kbits (in practice 80-100 however.)

To play a media file, simply touch it in the file browser mode. The CoreMedia (Quicktime plugin) player will launch and start to buffer the  media. You can use other applications (Mail, Phone, etc) while the media is playing but you cannot navigate to other MobileSafari pages.

As of now there is no way to stream playlists or queue multiple files.

If you have any problems or improvements, please let us know at the discussion group:

http://groups.google.com/group/telekinesis-discuss

## Caveats of media streaming ##

The iPhone doesn't appear to accept media encrypted with a self signed certificate. To enable streaming, iPhone Remote needs to send it insecurely.

**If you choose to enable this feature, anyone can connect to your machine to access m4b, m4v, m4a, mov, and mp3 files if they can access your computer and know the full path to the file**

**Do not enable this unless you are sure your network is secure.**

You can enable this feature in the preference pane. Hit "Restart Server" after checking the box.