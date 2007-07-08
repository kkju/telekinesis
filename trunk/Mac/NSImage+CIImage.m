//
//  NSImage+CIImage.m
//  Telekinesis
//
//  Created by alcor on 7/7/07.
//  Copyright 2007 Blacktree Inc. All rights reserved.
//

#import "NSImage+CIImage.h"
#import <QuartzCore/QuartzCore.h>
#import <Quartz/Quartz.h>

@implementation NSImage (CICreation)
+ (NSImage *)imageWithCIImage:(CIImage *)i fromRect:(CGRect)r
{
  NSImage *image;
  NSCIImageRep *ir;
  
  ir = [NSCIImageRep imageRepWithCIImage:i];
  image = [[[NSImage alloc] initWithSize:
		NSMakeSize(r.size.width, r.size.height)]
    autorelease];
  [image addRepresentation:ir];
  return image;
}

+ (NSImage *)imageWithCIImage:(CIImage *)i
{
	return [self imageWithCIImage:i fromRect:[i extent]];
}
@end

@implementation NSBitmapImageRep (CICreation)
+ (NSBitmapImageRep *)imageRepWithCIImage:(CIImage *)i fromRect:(CGRect)r
{
	
	// Create a new NSBitmapImageRep.
	NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:r.size.width pixelsHigh:r.size.height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
	
	// Create an NSGraphicsContext that draws into the NSBitmapImageRep. (This capability is new in Tiger.)
	NSGraphicsContext *nsContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
	
	// Save the previous graphics context and state, and make our bitmap context current.
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext: nsContext];
	
	// Get a CIContext from the NSGraphicsContext, and use it to draw the CIImage into the NSBitmapImageRep.
	[[nsContext CIContext] drawImage:i atPoint:CGPointZero fromRect:r];
	
	// Restore the previous graphics context and state.
	[NSGraphicsContext restoreGraphicsState];
	
  return [rep autorelease];
}

+ (NSBitmapImageRep *)imageRepWithCIImage:(CIImage *)i
{
	return [self imageRepWithCIImage:i fromRect:[i extent]];
}
@end