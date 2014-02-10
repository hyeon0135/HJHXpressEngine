//
//  NSDictionary+QueryString.m
//  TodayHumor
//
//  Created by Jonghwan Hyeon on 2/3/14.
//  Copyright (c) 2014 Jonghwan Hyeon. All rights reserved.
//

#import "NSDictionary+QueryString.h"

static NSString *escapeComponent(NSString *unescapedComponent, NSStringEncoding encoding) {
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                     (__bridge CFStringRef)(unescapedComponent),
                                                                     NULL,
                                                                     (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                     CFStringConvertNSStringEncodingToEncoding(encoding)
                                                                     ));
}

@implementation NSDictionary (QueryString)

- (NSString *)queryStringUsingEncoding:(NSStringEncoding)encoding {
    NSMutableArray *components = [NSMutableArray array];
    
    for (NSString *key in self) {
        [components addObject:[NSString stringWithFormat:@"%@=%@",
                               escapeComponent(key, encoding),
                               escapeComponent([self[key] description], encoding)]]; // description for other objects like NSNumber
    }
    
    return [components componentsJoinedByString:@"&"];
}

- (NSString *)queryString {
    return [self queryStringUsingEncoding:NSUTF8StringEncoding];
}

@end
