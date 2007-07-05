//
//  NSURL+Parameters.m
//  Telekinesis
//
//  Created by Nicholas Jitkoff on 6/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSURL+Parameters.h"


@implementation NSURL (Parameters)
- (NSDictionary *)parameterDictionary {
  if (![self query]) return nil;
  NSScanner *scanner = [NSScanner scannerWithString:[self query]];
  NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
  if (!scanner) return nil;
  
  NSString *key;
  NSString *val;
  while (![scanner isAtEnd]) {
    if (![scanner scanUpToString:@"=" intoString:&key]) key = nil;
    [scanner scanString:@"=" intoString:nil];
    if (![scanner scanUpToString:@"&" intoString:&val]) val = nil;
    [scanner scanString:@"&" intoString:nil];
    
    key = [key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    val = [val stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (key && val) [dictionary setValue:val forKey:key];
  }
  return dictionary;
}


@end
