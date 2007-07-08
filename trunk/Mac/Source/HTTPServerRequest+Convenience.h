//
//  HTTPServerRequest+Convenience.h
//  Telekinesis
//
//  Created by alcor on 7/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HTTPServer.h"

@interface HTTPServerRequest (Convenience) 
- (NSURL *)url;
- (void)replyWithStatusCode:(int)code
                    headers:(NSDictionary *)headers
                       body:(NSData *)body;
- (void)replyWithData:(NSData *)data MIMEType:(NSString *)type;
- (void)replyWithStatusCode:(int)code message:(NSString *)message;
@end
