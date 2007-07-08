//
//  HTTPServerRequest+Convenience.m
//  Telekinesis
//
//  Created by alcor on 7/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//  Adapted from SimpleCocoaHTTPServer by J√ºrgen Schweizer
//

#import "HTTPServerRequest+Convenience.h"


@implementation HTTPServerRequest (Convenience)
- (NSURL *)url {
  NSURL *uri = [(NSURL *)CFHTTPMessageCopyRequestURL(request) autorelease];
  return uri;
}


- (void)replyWithStatusCode:(int)statusCode
                    headers:(NSDictionary *)headers
                       body:(NSData *)body {
  
  CFHTTPMessageRef msg = CFHTTPMessageCreateResponse(kCFAllocatorDefault, statusCode, NULL, kCFHTTPVersion1_1);
  
  NSEnumerator *ke = [headers keyEnumerator];
  NSString *key;
  while(key = [ke nextObject]) {
    id value = [headers objectForKey:key];
    if(![value isKindOfClass:[NSString class]]) value = [value description];
    if(![key isKindOfClass:[NSString class]]) key = [key description];
    CFHTTPMessageSetHeaderFieldValue(msg, (CFStringRef)key, (CFStringRef)value);
  }

  if(body) {
    NSString *length = [NSString stringWithFormat:@"%d", [body length]];
    CFHTTPMessageSetHeaderFieldValue(msg, CFSTR("Content-Length"), (CFStringRef)length);
    CFHTTPMessageSetBody(msg, (CFDataRef)body);
  }
  
  [self setResponse:msg];
  CFRelease(msg);
}

- (void)replyWithData:(NSData *)data MIMEType:(NSString *)type {
  NSDictionary *headers = [NSDictionary dictionaryWithObject:type forKey:@"Content-Type"];
  [self replyWithStatusCode:200 headers:headers body:data];  // 200 = 'OK'
}

- (void)replyWithStatusCode:(int)code message:(NSString *)message {
  NSData *body = [message dataUsingEncoding:NSASCIIStringEncoding
                       allowLossyConversion:YES];
  [self replyWithStatusCode:code headers:nil body:body];
}

@end
