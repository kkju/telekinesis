//
//  NSImage+CIImage.h
//  Telekinesis
//
//  Created by alcor on 7/7/07.
//  Copyright 2007 Blacktree Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (CICreation)
+ (NSImage *)imageWithCIImage:(CIImage *)i fromRect:(CGRect)r;
+ (NSImage *)imageWithCIImage:(CIImage *)i;
@end

@interface NSBitmapImageRep (CICreation)
+ (NSBitmapImageRep *)imageRepWithCIImage:(CIImage *)i fromRect:(CGRect)r;
+ (NSBitmapImageRep *)imageRepWithCIImage:(CIImage *)i;
@end