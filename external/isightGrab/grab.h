#import <Cocoa/Cocoa.h>
#define WARM_UP_FRAMES 10
#define COMPRESSION_RATIO 0.5

@class CSGCamera;

@interface grab : NSObject
{
	uint warmUpCounter;
	CSGCamera *camera;
}

- (void)doIt;


@end
