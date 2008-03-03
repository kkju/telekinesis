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
		[aFrame lockFocus];
		NSString* myString = [[NSCalendarDate calendarDate] descriptionWithCalendarFormat:@"%a %m/%d/%y %I:%M %p"];
		
		int r = 0;
		int g = 250;
		int b = 0;
		NSFont * font = [NSFont fontWithName:@"Helvetica" size:24];
		NSMutableDictionary * fontAttributes = [[NSMutableDictionary alloc] initWithObjectsAndKeys:font, NSFontAttributeName, [NSColor colorWithCalibratedRed:(float)r/255.0 green:(float)g/255.0 blue:(float)b/255.0 alpha:1.0], NSForegroundColorAttributeName, nil];

		[myString drawAtPoint: NSMakePoint(0, 0) withAttributes: fontAttributes]; 
		[aFrame unlockFocus];
		
		NSBitmapImageRep        *bitmapRep =  [NSBitmapImageRep imageRepWithData:[aFrame TIFFRepresentation]];
		NSData * JPEG = [bitmapRep representationUsingType:NSJPEGFileType 
								   properties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:COMPRESSION_RATIO], NSImageCompressionFactor, nil]];
		const char * outputImage = (const char*)[JPEG bytes];
		fprintf(stdout, "Content-Type: image/jpeg\n\n");
		fwrite(outputImage, sizeof(char), [JPEG length], stdout);
		fflush(stdout);
		[camera stop];
	    exit(0);
	}
}




@end
