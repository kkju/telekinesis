#import <Foundation/Foundation.h>
#import "grab.h"

// command line CGI-type tool to grab a PNG from a connected isight
// should work with both USB and Firewire isights, I've only tested on firewire now
// outputs to stdout!

// brian whitman brian.whitman@variogr.am 
// uses Tim Omernick's CocoaSequenceGrabber which appears to have no license
// license granted to whatever telekinesis uses

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
     [NSApplication sharedApplication];

	grab *grabFrame = [[[grab alloc] init] autorelease];
	[grabFrame doIt];
	[[NSRunLoop currentRunLoop] run];
	[pool release];
    return 0;
}
