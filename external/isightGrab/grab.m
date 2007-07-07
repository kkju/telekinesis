#import "grab.h"
#import "CocoaSequenceGrabber.h"

// command line CGI-type tool to grab a PNG from a connected isight
// should work with both USB and Firewire isights, I've only tested on firewire now
// outputs to stdout!

// brian whitman brian.whitman@variogr.am 
// uses Tim Omernick's CocoaSequenceGrabber which appears to have no license
// license granted to whatever telekinesis uses

@implementation grab

- (void)dealloc;
{
	[camera release];
	[super dealloc];
}


- (void)doIt;
{
	// Start recording
	warmUpCounter = 1;
	camera = [[CSGCamera alloc] init];
	[camera setDelegate:self];
	[camera startWithSize:NSMakeSize(640, 480)];	

}


- (void)camera:(CSGCamera *)aCamera didReceiveFrame:(CSGImage *)aFrame;
{
	// Wait a few camera frames to take the picture... this is up to you...
	warmUpCounter ++;
	if (warmUpCounter >= WARM_UP_FRAMES)
	{
		NSBitmapImageRep        *bitmapRep =  [NSBitmapImageRep imageRepWithData:[aFrame TIFFRepresentation]];
		NSData * PNG = [bitmapRep representationUsingType:NSPNGFileType properties:nil];
		const char * outputImage = (const char*)[PNG bytes];
		fprintf(stdout, "Content-Type: image/png\n\n");
		fwrite(outputImage, sizeof(char), [PNG length], stdout);
		fflush(stdout);
		[camera stop];
	    exit(0);
	}
}




@end
