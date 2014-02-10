//
//  HJHXpressEngineRequest.h
//  Uriuniv
//
//  Created by Jonghwan Hyeon on 2/10/14.
//  Copyright (c) 2014 Uriuniv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HJHXpressEngineRequest : NSObject

+ (NSURLRequest *)requestForLoggingInWithIdentifier:(NSString *)identifier
                                           password:(NSString *)password;
+ (NSURLRequest *)requestForLoggingOut;

+ (NSURLRequest *)requestForFetchingDocumentListFromModuleIdentifier:(NSString *)identifier
                                                              onPage:(NSInteger)page;
+ (NSURLRequest *)requestForFetchingDocumentFromDocumentIdentifier:(NSString *)identifier;
+ (NSURLRequest *)requestForFetchingCommentsFromDocumentIdentifier:(NSString *)identifier;

+ (NSURLRequest *)requestForWritingDocumentOnModuleIdentifier:(NSString *)identifier
                                                    withTitle:(NSString *)title
                                            contents:(NSString *)contents;
+ (NSURLRequest *)requestForModifyingDocumentHavingIdentifier:(NSString *)identifier
                                                    withTitle:(NSString *)title
                                                     contents:(NSString *)contents;

+ (NSURLRequest *)requestForWritingCommentOnDocumentIdentifier:(NSString *)identifier
                                                  withContents:(NSString *)contents;
+ (NSURLRequest *)requestForModifyingCommentOnDocumentIdentifier:(NSString *)documentIdentifier
                                                havingIdentifier:(NSString *)commentIdentifier
                                                withContents:(NSString *)contents;

+ (NSURLRequest *)requestForLikingDocumentHavingIdentifier:(NSString *)identifier;
+ (NSURLRequest *)requestForDislikingDocumentHavingIdentifier:(NSString *)identifier;

+ (NSURLRequest *)requestForLikingCommentHavingIdentifier:(NSString *)identifier;
+ (NSURLRequest *)requestForDislikingCommentHavingIdentifier:(NSString *)identifier;
@end
