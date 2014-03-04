//
//  NSDictionary+Entity.h
//  XpressEngine
//
//  Created by Jonghwan Hyeon on 3/4/14.
//  Copyright (c) 2014 Jonghwan Hyeon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Entity)
- (instancetype)dictionaryByEscapingEntities;
- (instancetype)dictionaryByUnescapingEntities;
@end
