//
//  HJHXpressEngine.h
//  XpressEngine
//
//  Created by Jonghwan Hyeon on 3/3/14.
//  Copyright (c) 2014 Jonghwan Hyeon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HJHXpressEngine : NSObject

typedef void (^HJHXpressEngineCompletionHandler)(NSDictionary *response, NSError *error);

@property (readonly, nonatomic) BOOL isLoggedIn;

#pragma mark - initializer
- (instancetype)initWithBaseURL:(NSURL *)baseURL;
+ (instancetype)xpressEngineWithBaseURL:(NSURL *)baseURL;

#pragma mark - logging in / out
- (void)loginWithIdentifier:(NSString *)identifier password:(NSString *)password
                    success:(void (^)(NSDictionary *response))success
                    failure:(void (^)(NSError *error))failure;
- (void)logout;

#pragma mark - fetching
- (void)fetchDocumentsFromBoardModuleIdentifier:(NSString *)identifier onPage:(NSUInteger)page
                                        success:(void (^)(NSDictionary *response))success
                                        failure:(void (^)(NSError *error))failure;
- (void)fetchDocumentFromDocumentIdentifier:(NSString *)identifier
                                    success:(void (^)(NSDictionary *response))success
                                    failure:(void (^)(NSError *error))failure;
- (void)fetchCommentsFromDocumentIdentifier:(NSString *)identifier
                                    success:(void (^)(NSDictionary *response))success
                                    failure:(void (^)(NSError *error))failure;

- (void)fetchFileInformationsFromDocumentIdentifier:(NSString *)identifier
                                            success:(void (^)(NSDictionary *response))success
                                            failure:(void (^)(NSError *error))failure;
- (void)fetchFileFromLocation:(NSString *)location
                      success:(void (^)(NSDictionary *response))success
                      failure:(void (^)(NSError *error))failure;

#pragma mark - writing
- (void)writeDocumentOnBoardModuleIdentifier:(NSString *)identifier
                                   withTitle:(NSString *)title contents:(NSString *)contents
                                     success:(void (^)(NSDictionary *response))success
                                     failure:(void (^)(NSError *error))failure;
- (void)writeCommentOnDocumentIdentifier:(NSString *)identifier
                               withTitle:(NSString *)title contents:(NSString *)contents
                                 success:(void (^)(NSDictionary *response))success
                                 failure:(void (^)(NSError *error))failure;

#pragma mark - modifying
- (void)modifyDocumentHavingDocumentIdentifier:(NSString *)identifier
                                     withTitle:(NSString *)title contents:(NSString *)contents
                                       success:(void (^)(NSDictionary *response))success
                                       failure:(void (^)(NSError *error))failure;

- (void)modifyCommentOnDocumentIdentifier:(NSString *)documentIdentifier
                  havingCommentIdentifier:(NSString *)commentIdentifier
                             withContents:(NSString *)contents
                                  success:(void (^)(NSDictionary *response))success
                                  failure:(void (^)(NSError *error))failure;

#pragma mark - liking
- (void)likeDocumentHavingDocumentIdentifier:(NSString *)identifier
                                     success:(void (^)(NSDictionary *response))success
                                     failure:(void (^)(NSError *error))failure;
- (void)likeCommentHavingCommentIdentifier:(NSString *)identifier
                                   success:(void (^)(NSDictionary *response))success
                                   failure:(void (^)(NSError *error))failure;

#pragma mark - disliking
- (void)dislikeDocumentHavingDocumentIdentifier:(NSString *)identifier
                                        success:(void (^)(NSDictionary *response))success
                                        failure:(void (^)(NSError *error))failure;
- (void)dislikeCommentHavingCommentIdentifier:(NSString *)identifier
                                      success:(void (^)(NSDictionary *response))success
                                      failure:(void (^)(NSError *error))failure;

@end
