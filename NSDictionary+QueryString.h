//
//  NSDictionary+QueryString.h
//  TodayHumor
//
//  Created by Jonghwan Hyeon on 2/3/14.
//  Copyright (c) 2014 Jonghwan Hyeon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (QueryString)
- (NSString *)queryStringUsingEncoding:(NSStringEncoding)encoding;
- (NSString *)queryString;
@end
