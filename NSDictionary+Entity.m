//
//  NSDictionary+Entity.m
//  XpressEngine
//
//  Created by Jonghwan Hyeon on 3/4/14.
//  Copyright (c) 2014 Jonghwan Hyeon. All rights reserved.
//

#import "NSDictionary+Entity.h"
#import "GTMNSString+HTML.h"

static id applyBlockOnNSStringRecursivley(id object, id (^block)(id object))
{
    if ([object isKindOfClass:NSDictionary.class]) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        for (NSString *key in object) {
            dictionary[key] = applyBlockOnNSStringRecursivley(object[key], block);
        }
        
        object = dictionary;
    } else if ([object isKindOfClass:NSArray.class]) {
        NSMutableArray *array = [NSMutableArray array];
        for (id element in object) {
            [array addObject:applyBlockOnNSStringRecursivley(element, block)];
        }
        
        object = array;
    } else if ([object isKindOfClass:NSString.class]) {
        object = block(object);
    }
    
    return object;
}

@implementation NSDictionary (Entity)

- (instancetype)dictionaryByEscapingEntities
{
    return applyBlockOnNSStringRecursivley(self, ^id(id object) {
        return [object gtm_stringByEscapingForAsciiHTML];
    });
}

- (instancetype)dictionaryByUnescapingEntities
{
    return applyBlockOnNSStringRecursivley(self, ^id(id object) {
        return [object gtm_stringByUnescapingFromHTML];
    });
}

@end
