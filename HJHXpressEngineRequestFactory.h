//
//  HJHXpressEngineRequestFactory.h
//  XpressEngine
//
//  Created by Jonghwan Hyeon on 3/3/14.
//  Copyright (c) 2014 Jonghwan Hyeon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HJHXpressEngineRequestFactory : NSObject

@property (readonly, nonatomic) NSURL *baseURL;

#pragma mark - initalizer
- (instancetype)initWithBaseURL:(NSURL *)baseURL;
+ (instancetype)factoryWithBaseURL:(NSURL *)baseURL;

#pragma mark - logging in / out
- (NSURLRequest *)requestForLoggingInWithIdentifier:(NSString *)identifier password:(NSString *)password;
- (NSURLRequest *)requestForLoggingOut;

#pragma mark - fetching
- (NSURLRequest *)requestForFetchingDocumentsFromBoardModuleIdentifier:(NSString *)identifier
                                                                   onPage:(NSUInteger)page;
- (NSURLRequest *)requestForFetchingDocumentFromDocumentIdentifier:(NSString *)identifier;
- (NSURLRequest *)requestForFetchingCommentsFromDocumentIdentifier:(NSString *)identifier;

- (NSURLRequest *)requestForFetchingFileInformationsFromDocumentIdentifier:(NSString *)identifier;
- (NSURLRequest *)requestForFetchingFileFromLocation:(NSString *)location;

#pragma mark - writing
- (NSURLRequest *)requestForWritingDocumentOnBoardModuleIdentifier:(NSString *)identifier
                                                         withTitle:(NSString *)title
                                                          contents:(NSString *)contents;

- (NSURLRequest *)requestForWritingCommentOnDocumentIdentifier:(NSString *)identifier
                                                  withContents:(NSString *)contents;

#pragma mark - modifying
- (NSURLRequest *)requestForModifyingDocumentHavingDocumentIdentifier:(NSString *)identifier
                                                            withTitle:(NSString *)title
                                                             contents:(NSString *)contents;

- (NSURLRequest *)requestForModifyingCommentOnDocumentIdentifier:(NSString *)documentIdentifier
                                         havingCommentIdentifier:(NSString *)commentIdentifier
                                                    withContents:(NSString *)contents;

#pragma mark - liking
- (NSURLRequest *)requestForLikingDocumentHavingDocumentIdentifier:(NSString *)identifier;
- (NSURLRequest *)requestForLikingCommentHavingCommentIdentifier:(NSString *)identifier;

#pragma mark - disliking
- (NSURLRequest *)requestForDislikingDocumentHavingDocumentIdentifier:(NSString *)identifier;
- (NSURLRequest *)requestForDislikingCommentHavingCommentIdentifier:(NSString *)identifier;

@end
